#!/usr/bin/env bash

build() {
    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ./configure --disable-shared
    else
        ./configure --prefix=/usr    \
                    --disable-static \
                    --docdir=/usr/share/doc/gettext-1.0
    fi

    make
}

package() {
    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} "$LX_ROOTFS/usr/bin"
    else
        make DESTDIR="$LX_ROOTFS" install
        chmod -v 0755 /usr/lib/preloadable_libintl.so
    fi
}