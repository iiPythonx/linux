#!/usr/bin/env python3
# Copyright (c) 2026 iiPython

import os
import re
import json
import tomllib
import subprocess
from pathlib import Path
from shutil import rmtree
from dataclasses import dataclass
from argparse import ArgumentParser, Namespace
from urllib.request import urlretrieve

__version__ = "2.0.0"

ARCHIVE_FORMATS = {
    ".tar.xz",
    ".tar.gz",
    ".tar.bz2",
    ".tgz",
    ".txz"
}

PACKAGE_NAME_REGEX = re.compile(r"([\w-]+)(?:\[([\w-]+)\])?")

@dataclass
class Source:
    name:   str
    url:    str
    main:   bool
    strip:  int
    extras: list[str]

    def __init__(self, name: str, url: str, main: bool = False, strip: int = 1, extras: list[str] = []) -> None:
        self.name, self.url, self.main, self.strip, self.extras = name, url, main, strip, extras

@dataclass
class Package:
    path:     Path
    name:     str
    version:  str
    sources:  list[Source]
    extra:    str | None

class PackageException(Exception):
    pass

class LX:
    def __init__(self, args: Namespace) -> None:
        self.root_path: Path = args.root_path
        self.lx_path: Path = args.data_path

        # Configuration options
        self.fetch: bool = args.fetch
        self.disable_chroot: bool = args.disable_chroot

        # Environment
        self.environment = os.environ | {
            "LX_TARGET": "x86_64-iipython-linux-gnu",
            "LX_ROOTFS": str(self.root_path),
            "LX_VERSION": __version__,
            "MAKEFLAGS": f"-j{os.cpu_count()}"
        }

        # Folder creation
        self.lx_path.mkdir(exist_ok = True, parents = True)

        # Grab state file
        self.state_file = self.lx_path / "package_state.json"
        if not self.state_file.is_file():
            self.state_file.write_text("{}")

        # Handle packages
        if not (args.install or args.remove):
            raise PackageException("lx: nothing to do")

        for package in self.resolve_packages(args.packages):
            (self.install if args.install else self.remove)(package)

    # Utilities
    def resolve_packages(self, packages: list[str]) -> list[Package]:
        package_list = []
        for package in packages:
            if package[0] == "@":
                package_list += self.resolve_group(package[1:])
                continue
            
            package_list.append(package)

        return [self.read_package(package) for package in package_list]

    def resolve_group(self, group: str) -> list[str]:
        group_file = self.lx_path / f"repo/lists/{group}.list"
        if not group_file.is_file():
            raise PackageException(f"lx: group not found: {group}")

        return [
            package for package in group_file.read_text().splitlines()
            if package.strip()
        ]

    def read_package(self, package: str) -> Package:
        name_data = PACKAGE_NAME_REGEX.match(package)
        if name_data is None:
            raise PackageException(f"lx: invalid package name: {package}")
        
        package_name, package_extra = name_data.groups()
        package_path = self.lx_path / f"repo/packages/{package_name}"
        if not package_path.is_dir():
            raise PackageException(f"lx: package not found: {package_name}")

        metadata = tomllib.loads((package_path / "package.toml").read_text())
        if package_extra and package_extra not in metadata["package"].get("extras", []):
            raise PackageException(f"lx: invalid extra for {package_name}: {package_extra}")

        return Package(
            path = package_path,
            name = metadata["package"]["name"],
            version = metadata["package"]["version"],
            sources = [
                Source(name = name, **data)
                for name, data in metadata.get("sources", {}).items()
            ],
            extra = package_extra
        )

    # Package state
    def read_packages(self) -> dict[str, dict]:
        return json.loads(self.state_file.read_text())

    def write_packages(self, packages: dict[str, dict]) -> None:
        self.state_file.write_text(json.dumps(packages, indent = 4))

    def add_package(self, package: Package, filelist: list[str]) -> None:
        packages = self.read_packages()
        self.conflict_check(packages, package)
        self.write_packages(packages | {package.name: {
            "version": package.version,
            "files": filelist
        }})

    def conflict_check(self, packages: dict[str, dict], package: Package) -> bool:
        if package.name in packages:
            found_version = packages[package.name]["version"]
            print(f"Package {package.name}-{package.version} can't be installed because {package.name}-{found_version} already exists!")
            return False

        return True

    # Operations
    def setup_overlay(self, package: Package) -> None:
        pkgbuild_path = Path(f"/tmp/lx/{package.name}")
        for path in {"upper", "work", "merged"}:
            (pkgbuild_path / path).mkdir(parents = True)

        subprocess.run([
            "mount",
            "-t", "overlay", "overlay",
            "-o", f"lowerdir={self.root_path},upperdir={pkgbuild_path / 'upper'},workdir={pkgbuild_path / 'work'}",
            pkgbuild_path / "merged"
        ])

        for mount in {"dev", "proc", "sys"}:
            subprocess.run(["mount", "--bind", f"/{mount}", pkgbuild_path / f"merged/{mount}"])

    def install(self, package: Package) -> None:
        packages = self.read_packages()
        if not self.conflict_check(packages, package):
            return

        cache_path = self.lx_path / f"cache/{package.name}"
        cache_path.mkdir(parents = True, exist_ok = True)

        # Download sources
        for source in package.sources:
            if source.extras and package.extra not in source.extras:
                continue

            filename = source.url.split("/")[-1].split("?")[0]

            # Retrieve file
            source_file = cache_path / filename
            if not source_file.is_file():
                print(f"Fetching source '{source.name}' for package '{package.name}'")
                urlretrieve(source.url, source_file)

            if self.fetch:
                continue

            extracted_path = cache_path / source.name
            if extracted_path.is_dir():
                rmtree(extracted_path)

            extracted_path.mkdir()
            for archive_extension in ARCHIVE_FORMATS:
                if filename.endswith(archive_extension):
                    subprocess.run(["tar", "-xf", source_file, f"--strip-components={source.strip}", "-C", extracted_path])

        if self.fetch:
            return

        # Figure out active path
        active_path = None
        if len(package.sources) == 1:
            active_path = cache_path / package.sources[0].name

        else:
            for source in package.sources:
                if active_path != self.root_path:
                    raise PackageException(f"lx: {package.name}: multiple sources marked as main!")

                if source.main:
                    active_path = cache_path / source.name

        active_path = active_path or self.root_path

        # Handle stages
        def run_stage(stage: str) -> None:
            subprocess.run(
                ["bash", "-c", f". {package.path / 'package.sh'} && {stage}"],
                env = self.environment | ({f"LX_EXTRA_{package.extra.upper()}": "1"} if package.extra else {}),
                cwd = active_path,
                check = True
            )

        for stage in ("build", "package"):
            run_stage(stage)

        # Register package
        self.add_package(package, [])

        # Cleanup
        for source in package.sources:
            extracted_path = cache_path / source.name
            if extracted_path.is_dir():
                rmtree(extracted_path)

    def remove(self, package: Package) -> None:
        print("Remove:", package)

if __name__ == "__main__":
    p = ArgumentParser("lx")
    p.add_argument("--root-path", type = Path, help = "targeted root filesystem", default = "/")
    p.add_argument("--data-path", type = Path, help = "path to lx data", default = "/var/lx")
    p.add_argument("--disable-chroot", action = "store_true", help = "disable package chroot, not recommended unless bootstrapping", default = False)
    p.add_argument("--fetch", action = "store_true", help = "only fetch sources, don't install anything", default = False)
    p.add_argument("-i", "--install", action = "store_true", help = "install a package", default = False)
    p.add_argument("-r", "--remove", action = "store_true", help = "remove a package", default = False)
    p.add_argument("packages", nargs = "+")

    LX(p.parse_args())
