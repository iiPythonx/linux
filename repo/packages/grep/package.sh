#!/usr/bin/env bash

build() {
    sed -i "s/echo/#echo/" src/egrep.sh
    ./configure --prefix=/usr
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}