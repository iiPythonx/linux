#!/usr/bin/env bash

build() {
    sed -i /ARPD/d Makefile
    rm -fv man/man8/arpd.8
    make NETNS_RUN_DIR=/run/netns
}

package() {
    make DESTDIR=$LX_ROOTFS SBINDIR=/usr/sbin install
}
