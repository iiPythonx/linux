#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr     \
                --sysconfdir=/etc \
                --enable-utf8     \
                --docdir=/usr/share/doc/nano-9.0
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
    install -v -m644 doc/{nano.html,sample.nanorc} /usr/share/doc/nano-9.0
}
