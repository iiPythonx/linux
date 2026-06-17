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

## Problems

Some packages have issues installing due to their install script infinitely looping.  
I have no idea what causes this as `lx` isn't the one doing it, and nothing re-calls the  
bash scripts.

The current list of affected packages is as follows:
```
dejagnu
```

## Inspiration

Based on [LFS 12.4 Stable](https://www.linuxfromscratch.org/lfs/view/stable), with some packages taken from [LFS 13.0 Development](https://www.linuxfromscratch.org/lfs/view/development).
