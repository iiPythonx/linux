# iiPython Linux

## Build Instructions

```sh
./tools/build_toolchain.sh

# Install the most basic utilities
./tools/install_packages.sh @base

# Install our bootstrapping packages
# These are stripped down versions of specific software
./tools/prep_bootstrap.sh
./tools/install_packages.sh @bootstrap

# take a backup or something here

# Download all the core packages (as the chroot won't have download suppport yet)
./tools/fetch_packages.sh @core

# Install all the core packages in the chroot
./tools/enter_chroot lx @core
```
