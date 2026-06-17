#!/usr/bin/env bash

build() {
    CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r
    make
}

install() {
    make install
}

"$LX_STAGE"
