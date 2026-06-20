#!/usr/bin/env bash

build() {
    CONFIG_OPTS=(
        -des
        -D prefix=/usr                                \
        -D vendorprefix=/usr                          \
        -D useshrplib                                 \
        -D privlib=/usr/lib/perl5/5.42/core_perl      \
        -D archlib=/usr/lib/perl5/5.42/core_perl      \
        -D sitelib=/usr/lib/perl5/5.42/site_perl      \
        -D sitearch=/usr/lib/perl5/5.42/site_perl     \
        -D vendorlib=/usr/lib/perl5/5.42/vendor_perl  \
        -D vendorarch=/usr/lib/perl5/5.42/vendor_perl \

    )

    if [[ -z "${LX_EXTRA_BOOTSTRAP}" ]]; then
        CONFIG_OPTS+=(
            -D man1dir=/usr/share/man/man1
            -D man3dir=/usr/share/man/man3
            -D pager="/usr/bin/less -isR"
            -D usethreads
        )

        export BUILD_ZLIB=False
        export BUILD_BZIP2=0
    fi

    sh Configure "${CONFIG_OPTS[@]}" && make
}

package() {
    make DESTDIR="$LX_ROOTFS" install
}