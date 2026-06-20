#!/usr/bin/env bash

build() {
    [[ -n "${LX_EXTRA_BOOTSTRAP}" ]] && mkdir -pv $LX_ROOTFS/var/lib/hwclock

    CONFIG_OPTS=(
        --libdir=/usr/lib
        --runstatedir=/run
        --disable-chfn-chsh
        --disable-login
        --disable-nologin
        --disable-su
        --disable-setpriv
        --disable-runuser
        --disable-pylibmount
        --disable-static
        --disable-liblastlog2
        --without-python
        ADJTIME_PATH=/var/lib/hwclock/adjtime
        --docdir=/usr/share/doc/util-linux-2.42.2
    )

    if [[ -z "${LX_EXTRA_BOOTSTRAP}" ]]; then
        CONFIG_OPTS+=(
            --bindir=/usr/bin
            --sbindir=/usr/sbin
            --without-systemd
            --without-systemdsystemunitdir
        )
    fi

    ./configure "${CONFIG_OPTS[@]}"
    make
}

package() {
    make DESTDIR="$LX_ROOTFS" install
}
