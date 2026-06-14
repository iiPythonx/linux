#!/usr/bin/env python3
# Copyright (c) 2026 iiPython

import os
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
    path:    Path
    name:    str
    version: str
    sources: list[Source]

def cexit(message: str) -> None:
    print(message)
    exit(1)

class LX:
    def __init__(self, args: Namespace) -> None:
        self.temp_dir = args.temp_dir
        self.root_dir = args.root_dir
        self.prefix = args.prefix
        self.extract_dir = args.temp_dir / "extract"
        self.sources_dir = args.sources_dir

        # Environment
        self.environment = os.environ | {
            "LX_TARGET": "x86_64-iipython-linux-gnu",
            "LX_ROOTFS": str(self.root_dir),
            "LX_PREFIX": str(self.prefix)
        }

        # Folder creation
        if not self.extract_dir.is_dir():
            self.extract_dir.mkdir(parents = True)

        # Handle packages
        for package in args.packages:
            self.install(package)

    def read_package(self, package: str) -> Package:
        package_path = self.sources_dir / package
        if not package_path.is_dir():
            cexit(f"Package not found: {package}")

        metadata = tomllib.loads((package_path / "package.toml").read_text())
        return Package(
            path = package_path,
            **metadata["package"],
            sources = [Source(name = name, **data) for name, data in metadata["sources"].items()]
        )

    def install(self, package: str | Package) -> None:
        if not isinstance(package, Package):
            package = self.read_package(package)

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

        # Handle stages
        def run_stage(stage: str) -> None:
            subprocess.run(
                ["bash", package.path / "package.sh"],
                env = self.environment | {"LX_STAGE": stage, "LX_ROOTFS": str(fakeroot)},
                cwd = self.extract_dir / package.name
            )

        for stage in ("build", "install"):
            run_stage(stage)

if __name__ == "__main__":
    p = ArgumentParser("lx")
    p.add_argument("--root-dir", type = Path, help = "targeted root filesystem", default = "/")
    p.add_argument("--prefix", type = Path, help = "installation prefix for configure stage", default = "/")
    p.add_argument("--temp-dir", type = Path, help = "extraction directory for package sources", default = "/tmp/lx")
    p.add_argument("--sources-dir", type = Path, help = "directory to use as a source cache", default = "/var/cache/lx/sources")
    p.add_argument("packages", nargs = "+")

    LX(p.parse_args())
