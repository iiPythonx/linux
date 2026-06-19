#!/usr/bin/env bash

build() {
    mkdir build && cd build
    ../configure --prefix=/usr       \
                --sysconfdir=/etc   \
                --enable-elf-shlibs \
                --disable-libblkid  \
                --disable-libuuid   \
                --disable-uuidd     \
                --disable-fsck
    make
}

package() {
    cd build
    make DESTDIR=$LX_ROOTFS install
    rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
    gunzip -v /usr/share/info/libext2fs.info.gz
    install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
}
