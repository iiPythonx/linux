#!/usr/bin/env bash

build() {
    make prefix=/usr
}

package() {
    make prefix=/usr install
    rm -v /usr/lib/libzstd.a
}