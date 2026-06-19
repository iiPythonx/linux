#!/usr/bin/env python3
# Copyright (c) 2026 iiPython

import os
import json
import tomllib
import subprocess
from pathlib import Path
from shutil import rmtree
from dataclasses import dataclass
from argparse import ArgumentParser, Namespace
from urllib.request import urlretrieve

__version__ = "1.0.1"

@dataclass
class Source:
    name:  str
    url:   str
    strip: int

    def __init__(self, name: str, url: str, strip: int = 1) -> None:
        self.name, self.url, self.strip = name, url, strip

@dataclass
class Package:
    path:     Path
    name:     str
    version:  str
    sources:  list[Source]

def cexit(message: str) -> None:
    print(message)
    exit()

class LX:
    def __init__(self, args: Namespace) -> None:
        self.temp_dir: Path = args.temp_dir
        self.root_dir: Path = args.root_dir
        self.extract_dir: Path = args.temp_dir / "extract"
        self.sources_dir: Path = args.sources_dir
        self.config_dir: Path = args.config_dir

        # Handle fetch mode
        self.fetch: bool = args.fetch

        # Environment
        self.environment = os.environ | {
            "LX_TARGET": "x86_64-iipython-linux-gnu",
            "LX_ROOTFS": str(self.root_dir),
            "MAKEFLAGS": f"-j{os.cpu_count()}"
        }

        # Folder creation
        self.config_dir.mkdir(exist_ok = True, parents = True)
        self.extract_dir.mkdir(exist_ok = True, parents = True)

        # Grab state file
        self.state_file = self.config_dir / "package_state.json"
        if not self.state_file.is_file():
            self.state_file.write_text("{}")

        # Handle packages
        package_list = []
        for package in args.packages:
            if package[0] == "@":
                package_list += self.resolve_group(package[1:])

            else:
                package_list.append(package)

        for package in package_list:
            self.install(package)

    # Utilities
    def resolve_group(self, group: str) -> list[str]:
        group_file = self.sources_dir / "lists" / f"{group}.list"
        if not group_file.is_file():
            cexit(f"Group not found: {group}")

        return [
            package for package in group_file.read_text().splitlines()
            if package.strip()
        ]

    def read_package(self, package: str) -> Package:
        package_path = self.sources_dir / "packages" / package
        if not package_path.is_dir():
            cexit(f"Package not found: {package}")

        metadata = tomllib.loads((package_path / "package.toml").read_text())
        return Package(
            path = package_path,
            name = metadata["package"]["name"],
            version = metadata["package"]["version"],
            sources = [
                Source(name = name, **data)
                for name, data in metadata.get("sources", {}).items()
            ]
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
    def install(self, package: str | Package) -> None:
        if not isinstance(package, Package):
            package = self.read_package(package)

        packages = self.read_packages()
        if not self.conflict_check(packages, package):
            return

        # Download sources
        for source in package.sources:
            filename = source.url.split("/")[-1]
            source_file = self.temp_dir / filename

            if not source_file.is_file():
                print(f"Fetching source '{source.name}' for package '{package.name}'")
                urlretrieve(source.url, source_file)

            else:
                print(f"Reusing source '{source.name}' for package '{package.name}'")

            if self.fetch:
                continue

            extracted_path = self.extract_dir / source.name
            if extracted_path.is_dir():
                rmtree(extracted_path)

            extracted_path.mkdir()
            for archive_extension in [".tar.xz", ".tar.gz", ".tar.bz2", ".tgz", ".txz"]:
                if filename.endswith(archive_extension):
                    subprocess.run(["tar", "-xf", source_file, f"--strip-components={source.strip}", "-C", self.extract_dir / source.name])

            else:

                # Copy file as-is
                source_file.rename(extracted_path / source_file.name)

        if self.fetch:
            return

        # Handle stages
        def run_stage(stage: str) -> None:
            active_path = self.extract_dir / package.name
            if not active_path.is_dir():
                active_path = self.root_dir  # No sources were extracted, metapackage or smth similar

            subprocess.run(
                ["bash", "-c", f". {package.path / 'package.sh'} && {stage}"],
                env = self.environment,
                cwd = active_path,
                check = True
            )

        for stage in ("build", "package"):
            run_stage(stage)

        # Register package
        self.add_package(package, [])

        # Cleanup
        for source in package.sources:
            extracted_path = self.extract_dir / source.name
            if extracted_path.is_dir():
                rmtree(extracted_path)

if __name__ == "__main__":
    p = ArgumentParser("lx")
    p.add_argument("--root-dir", type = Path, help = "targeted root filesystem", default = "/")
    p.add_argument("--temp-dir", type = Path, help = "extraction directory for package sources", default = "/tmp/lx")
    p.add_argument("--config-dir", type = Path, help = "path to lx configuration data", default = "/var/lx")
    p.add_argument("--sources-dir", type = Path, help = "directory to use as a source cache", default = "/var/cache/lx/sources")
    p.add_argument("--fetch", action = "store_true", help = "only fetch sources, don't install anything", default = False)
    p.add_argument("packages", nargs = "+")

    LX(p.parse_args())
