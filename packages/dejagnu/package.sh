#!/usr/bin/env bash

build() {
    mkdir build && cd build

    ../configure --prefix=/usr
    makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
    makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi
}

# WARNING: infinite death spiral present here
# As of 06/16/26, I still have NO idea why it loops, ik lx isn't doing it
package() {
    cd build
    make DESTDIR=$LX_ROOTFS install
    install -v -dm755  /usr/share/doc/dejagnu-1.6.3
    install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
}