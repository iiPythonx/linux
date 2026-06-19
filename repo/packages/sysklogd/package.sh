#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr      \
                --sysconfdir=/etc  \
                --runstatedir=/run \
                --without-logger   \
                --disable-static   \
                --docdir=/usr/share/doc/sysklogd-2.7.2
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
    cat > /etc/syslog.conf << "EOF"
auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *
secure_mode 2
EOF
}
