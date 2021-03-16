#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

sed -i '/deb-src/s/^# //' /etc/apt/sources.list
apt update

apt install -y dpkg-dev sudo
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata

mkdir -p ~/sources
pushd ~/sources
apt source glibc
popd

#    libgpg-error-dev \
#    libgcrypt-dev \
#    libassuan-dev \
#    libksba-dev \
#    libnpth-dev \
apt install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    gettext \
    imagemagick \
    gsfonts \
    transfig \
    texinfo \
    ssh \
    openssh-server

apt-get update -q -q
apt-get install --yes rsync build-essential git gpg automake autoconf gettext libtool \
    libz-dev libbz2-dev libldap2-dev libsqlite3-dev libgnutls28-dev libcurl4-gnutls-dev libreadline-dev librsvg2-bin libusb-1.0-0-dev \
    texinfo transfig fig2dev imagemagick file ghostscript swig doxygen graphviz \
    pkg-config autopoint python-all-dev python3-all-dev qtbase5-dev

# cat ~/.config/ImageMagick/policy.xml 
# <policymap>
#     <policy domain="coder" rights="read|write" pattern="PDF" />
# </policymap>
# export MAGICK_CONFIGURE_PATH=$HOME/.config/ImageMagick



# ln -s $(pwd)/issues/tp-5487/sshd_config.d/ca.pub /etc/ssh/sshd_config.d/ca.pub
# ln -s $(pwd)/issues/tp-5487/sshd_config.d/host_id_rsa /etc/ssh/sshd_config.d/host_id_rsa
# ln -s $(pwd)/issues/tp-5487/sshd_config.d/host_id_rsa-cert.pub /etc/ssh/sshd_config.d/host_id_rsa-cert.pub
# ln -s $(pwd)/issues/tp-5487/sshd_config.d/test-tp-certificate.conf /etc/ssh/sshd_config.d/test-tp-certificate.conf

# sudo systemctl restart ssh
# sudo systemctl status ssh


if [ ! -f /usr/local/bin/pinentry ]; then
    mkdir -p /usr/local/bin/
    ln /usr/bin/pinentry /usr/local/bin/pinentry 
fi

echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope || true
