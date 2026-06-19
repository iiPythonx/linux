#!/usr/bin/env bash

build() {
    mkdir build && cd build
    meson setup --prefix=/usr ..    \
                --buildtype=release \
                -D manpages=false
    ninja
}

package() {
    cd build && ninja install
}
