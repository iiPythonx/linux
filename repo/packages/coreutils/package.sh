#!/usr/bin/env bash

build() {
    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ./configure --prefix=/usr                 \
                --host=$LX_TARGET                 \
                --build=$(build-aux/config.guess) \
                --enable-install-program=hostname \
                --enable-no-install-program=kill,uptime
    else
        autoreconf -fv
        automake -af
        FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
    fi

    make
}

package() {
    make DESTDIR="$LX_ROOTFS" install
    mv -v $LX_ROOTFS/usr/bin/chroot $LX_ROOTFS/usr/sbin
    mkdir -pv $LX_ROOTFS/usr/share/man/man8
    mv -v $LX_ROOTFS/usr/share/man/man1/chroot.1 $LX_ROOTFS/usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/' $LX_ROOTFS/usr/share/man/man8/chroot.8
}
