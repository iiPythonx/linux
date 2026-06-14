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

@dataclass
class Source:
    name: str
    url:  str

@dataclass
class Package:
    path:     Path
    name:     str
    version:  str
    sources:  list[Source]
    fakeroot: bool

def cexit(message: str) -> None:
    print(message)
    exit()

class LX:
    def __init__(self, args: Namespace) -> None:
        self.temp_dir: Path = args.temp_dir
        self.root_dir: Path = args.root_dir
        self.prefix: Path = args.prefix
        self.extract_dir: Path = args.temp_dir / "extract"
        self.sources_dir: Path = args.sources_dir
        self.config_dir: Path = args.config_dir

        # Environment
        self.environment = os.environ | {
            "LX_TARGET": "x86_64-iipython-linux-gnu",
            "LX_ROOTFS": str(self.root_dir),
            "LX_PREFIX": str(self.prefix),
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
        for package in args.packages:
            self.install(package)

    # Utilities
    @staticmethod
    def scan_fakeroot(root: Path) -> list[str]:
        return sorted([
            "/" + str(item.relative_to(root))
            for item in root.rglob("*") if not item.is_dir()
        ])

    def read_package(self, package: str) -> Package:
        package_path = self.sources_dir / package
        if not package_path.is_dir():
            cexit(f"Package not found: {package}")

        metadata = tomllib.loads((package_path / "package.toml").read_text())
        return Package(
            path = package_path,
            name = metadata["package"]["name"],
            version = metadata["package"]["version"],
            sources = [Source(name = name, **data) for name, data in metadata["sources"].items()],
            fakeroot = metadata["package"].get("fakeroot", True)
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

    def conflict_check(self, packages: dict[str, dict], package: Package) -> None:
        if package.name in packages:
            found_version = packages[package.name]["version"]
            cexit(f"Package {package.name}-{package.version} can't be installed because {package.name}-{found_version} already exists!")

    # Operations
    def install(self, package: str | Package) -> None:
        if not isinstance(package, Package):
            package = self.read_package(package)

        packages = self.read_packages()
        self.conflict_check(packages, package)

        # Download sources
        for source in package.sources:
            filename = source.url.split("/")[-1]
            source_file = self.temp_dir / filename

            if not source_file.is_file():
                print(f"Fetching source '{source.name}' for package '{package.name}'")
                urlretrieve(source.url, source_file)

            else:
                print(f"Reusing source '{source.name}' for package '{package.name}'")

            extracted_path = self.extract_dir / source.name
            if extracted_path.is_dir():
                rmtree(extracted_path)

            extracted_path.mkdir()
            subprocess.run(["tar", "-xf", source_file, "--strip-components=1", "-C", self.extract_dir / source.name])

        # Fakeroot
        fakeroot = self.temp_dir / "fakeroot"
        if package.fakeroot:
            if fakeroot.is_dir():
                rmtree(fakeroot)

        else:
            fakeroot = self.root_dir

        # Handle stages
        def run_stage(stage: str) -> None:
            subprocess.run(
                ["bash", package.path / "package.sh"],
                env = self.environment | {"LX_STAGE": stage, "LX_ROOTFS": str(fakeroot)},
                cwd = self.extract_dir / package.name,
                check = True
            )

        for stage in ("build", "install"):
            run_stage(stage)

        # Relocate
        subprocess.run([
            "rsync",
            "-a",
            f"{fakeroot}/",
            f"{self.root_dir}/"
        ], check = True)

        # Register package
        self.add_package(package, self.scan_fakeroot(fakeroot) if package.fakeroot else [])

        # Cleanup
        if fakeroot.is_dir() and package.fakeroot:
            rmtree(fakeroot)

        for source in package.sources:
            extracted_path = self.extract_dir / source.name
            if extracted_path.is_dir():
                rmtree(extracted_path)

if __name__ == "__main__":
    p = ArgumentParser("lx")
    p.add_argument("--root-dir", type = Path, help = "targeted root filesystem", default = "/")
    p.add_argument("--prefix", type = Path, help = "installation prefix for configure stage", default = "/")
    p.add_argument("--temp-dir", type = Path, help = "extraction directory for package sources", default = "/tmp/lx")
    p.add_argument("--config-dir", type = Path, help = "path to lx configuration data", default = "/var/lx")
    p.add_argument("--sources-dir", type = Path, help = "directory to use as a source cache", default = "/var/cache/lx/sources")
    p.add_argument("packages", nargs = "+")

    LX(p.parse_args())
