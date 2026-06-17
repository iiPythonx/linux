#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr
    make
    make html
}

package() {
    make DESTDIR=$LX_ROOTFS install
    install -vDm644 doc/sed.html -t /usr/share/doc/sed-4.10
}
