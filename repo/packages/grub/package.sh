#!/usr/bin/env bash

build() {
    sed 's/--image-base/--nonexist-linker-option/' -i configure
    ./configure --prefix=/usr       \
                --sysconfdir=/etc   \
                --target=x86_64     \
                --with-platform=efi \
                --disable-efiemu    \
                --disable-werror
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}
