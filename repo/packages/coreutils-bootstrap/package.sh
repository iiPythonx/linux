#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr                     \
                --host=$LX_TARGET                 \
                --build=$(build-aux/config.guess) \
                --enable-install-program=hostname \
                --enable-no-install-program=kill,uptime
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
    mkdir -p $LX_ROOTFS/usr/sbin
    mv -v $LX_ROOTFS/usr/bin/chroot $LX_ROOTFS/usr/sbin
    mkdir -pv $LX_ROOTFS/usr/share/man/man8
    mv -v $LX_ROOTFS/usr/share/man/man1/chroot.1 $LX_ROOTFS/usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/' $LX_ROOTFS/usr/share/man/man8/chroot.8
}