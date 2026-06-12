#!/usr/bin/sh

NAME="linux-headers"
VERSION="7.0.12"
SOURCE="https://www.kernel.org/pub/linux/kernel/v7.x/linux-${VERSION}.tar.xz"
SHA256=""

build() {
    make mrproper
    make headers
}

install() {
    find usr/include -type f ! -name '*.h' -delete
    cp -rv usr/include $SYSTEM_ROOT/usr
}
