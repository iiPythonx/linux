#!/usr/bin/env bash

build() {
    sed -i '/install -m.*STA/d' libcap/Makefile
    make prefix=/usr lib=lib
}

install() {
    make prefix=/usr lib=lib install
}

"$LX_STAGE"
