#!/usr/bin/env bash

setup_rootfs() {
    ln -sv /proc/self/mounts $LX_ROOTFS/etc/mtab

    printf '%s\n' \
        "127.0.0.1  localhost $(hostname)" \
        "::1        localhost" \
        > $LX_ROOTFS/etc/hosts

    printf '%s\n' \
        "root:x:0:0:root:/root:/bin/bash" \
        "bin:x:1:1:bin:/dev/null:/usr/bin/false" \
        "daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false" \
        "messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false" \
        "uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false" \
        "nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false" \
        > $LX_ROOTFS/etc/passwd

    printf '%s\n' \
        "root:x:0:" \
        "bin:x:1:daemon" \
        "sys:x:2:" \
        "kmem:x:3:" \
        "tape:x:4:" \
        "tty:x:5:" \
        "daemon:x:6:" \
        "floppy:x:7:" \
        "disk:x:8:" \
        "lp:x:9:" \
        "dialout:x:10:" \
        "audio:x:11:" \
        "video:x:12:" \
        "utmp:x:13:" \
        "cdrom:x:15:" \
        "adm:x:16:" \
        "messagebus:x:18:" \
        "input:x:24:" \
        "mail:x:34:" \
        "kvm:x:61:" \
        "uuidd:x:80:" \
        "wheel:x:97:" \
        "users:x:999:" \
        "LX_ROOTFS:x:65534:" \
        > $ROOTFS/etc/group

    mkdir -p $LX_ROOTFS/var/log
    touch $LX_ROOTFS/var/log/{btmp,lastlog,faillog,wtmp}
    sudo chgrp -v utmp $LX_ROOTFS/var/log/lastlog
    sudo chmod -v 664  $LX_ROOTFS/var/log/lastlog
    sudo chmod -v 600  $LX_ROOTFS/var/log/btmp
}

build() {
    return 0
}

package() {
    mkdir -pv "$LX_ROOTFS"/{etc,var}
    mkdir -pv "$LX_ROOTFS"/usr/{bin,lib,sbin}

    for i in bin lib sbin; do
        ln -sv "usr/$i" "$LX_ROOTFS/$i"
    done

    mkdir -pv "$LX_ROOTFS/lib64"
    setup_rootfs
}