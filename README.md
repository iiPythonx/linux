# iiPython Linux

## Build Instructions

```sh
./tools/build_toolchain.sh

# Install the most basic utilities
ln -s $(realpath repo) rootfs/var/lx/repo
./tools/install_packages.sh @base

# take a backup or something here
sudo tar -cJpf iipython-linux.tar.xz rootfs

# Download all the core packages (as the chroot won't have download suppport yet)
./tools/fetch_packages.sh @core

# Install all the core packages in the chroot
./tools/enter_chroot lx @core
```

## Inspiration

Based on [LFS 12.4 Stable](https://www.linuxfromscratch.org/lfs/view/stable), with some packages taken from [LFS 13.0 Development](https://www.linuxfromscratch.org/lfs/view/development).

Trying to build an OS similar to Arch, that is that the OS doesn't decide what software is on your system.  

In that regard, this repo is more of a collection of packages and build scripts rather than a completed system.  

You are expected to build the actual system.

## Deviations

Compared to [LFS](https://www.linuxfromscratch.org), some changes have been made:
- `gettext` is installed **before** installing `gcc`
    - If it's not, errors related to `libselinux` in `msgfmt` will break the build
- The `packaging` Python module is not installed
- `groff` is not installed
- `man-db` is not installed
- `vim` is not installed, replaced by `nano`
- `uv` is installed by default
- (Soon) `grub` replaced with `systemd-boot` or a tool that can build UKIs