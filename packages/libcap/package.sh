#!/usr/bin/env bash

build() {
    sed -i '/install -m.*STA/d' libcap/Makefile
    make prefix=/usr lib=lib
}

package() {
    make prefix=/usr lib=lib install
}