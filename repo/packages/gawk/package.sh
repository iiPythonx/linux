#!/usr/bin/env bash

build() {
    sed -i 's/extras//' Makefile.in
    ./configure --prefix=/usr
    make
}

package() {
    rm -f /usr/bin/gawk-5.4.0
    make install
    ln -sv gawk.1 /usr/share/man/man1/awk.1
}
