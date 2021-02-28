#!/bin/bash
apt install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    gettext \
    libgpg-error-dev \
    libgcrypt-dev \
    libassuan-dev \
    libksba-dev \
    libnpth-dev \
    imagemagick \
    transfig \
    texinfo \
    openssh-server

# cat ~/.config/ImageMagick/policy.xml 
# <policymap>
#     <policy domain="coder" rights="read|write" pattern="PDF" />
# </policymap>
# export MAGICK_CONFIGURE_PATH=$HOME/.config/ImageMagick



ln -s $(pwd)/issues/tp-5487/sshd_config.d/ca.pub /etc/ssh/sshd_config.d/ca.pub
ln -s $(pwd)/issues/tp-5487/sshd_config.d/host_id_rsa /etc/ssh/sshd_config.d/host_id_rsa
ln -s $(pwd)/issues/tp-5487/sshd_config.d/host_id_rsa-cert.pub /etc/ssh/sshd_config.d/host_id_rsa-cert.pub
ln -s $(pwd)/issues/tp-5487/sshd_config.d/test-tp-certificate.conf /etc/ssh/sshd_config.d/test-tp-certificate.conf

sudo systemctl restart ssh
sudo systemctl status ssh
