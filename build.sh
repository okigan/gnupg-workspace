#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

#imagemagick is awesome at not using local overrides, but does use user level override (bug)
#export MAGICK_CONFIGURE_PATH=$(pwd)/.config/ImageMagick
mkdir -p ~/.config/ImageMagick/
cat <<EOF >~/.config/ImageMagick/policy.xml
<policymap>
    <policy domain="coder" rights="read|write" pattern="PDF" />
</policymap>
EOF

mkdir -p build-deps
pushd build-deps

#order="npth libgpg-error libassuan libksba libgcrypt gnupg"

wget -nc ftp://ftp.gnupg.org/gcrypt/npth/npth-1.2.tar.bz2
tar xf npth-1.2.tar.bz2
pushd npth-1.2
./configure -prefix=$(pwd)/../../install-root
make
make install
popd

wget -nc https://gnupg.org/ftp/gcrypt/gpgrt/libgpg-error-1.41.tar.bz2
tar xf libgpg-error-1.41.tar.bz2
pushd libgpg-error-1.41
./configure \
    --prefix=$(pwd)/../../install-root
make
make install
popd

wget -nc https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.4.tar.bz2
tar xf libassuan-2.5.4.tar.bz2
pushd libassuan-2.5.4
./configure \
    --prefix=$(pwd)/../../install-root \
    --with-libgpg-error-prefix=$(pwd)/../../install-root \
    --enable-maintainer-mode
make
make install
popd

wget -nc https://gnupg.org/ftp/gcrypt/libksba/libksba-1.3.5.tar.bz2
tar xf libksba-1.3.5.tar.bz2
pushd libksba-1.3.5
./configure \
    --prefix=$(pwd)/../../install-root \
    --with-libgpg-error-prefix=$(pwd)/../../install-root \
    --with-libassuan-prefix=$(pwd)/../../install-root \
    --enable-maintainer-mode \
    --disable-static
make
make install
popd

wget -nc https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.9.1.tar.bz2
tar xf libgcrypt-1.9.1.tar.bz2
pushd libgcrypt-1.9.1
./configure \
    --prefix=$(pwd)/../../install-root \
    --with-libgpg-error-prefix=$(pwd)/../../install-root \
    --with-libassuan-prefix=$(pwd)/../../install-root \
    --with-ksba-prefix=$(pwd)/../../install-root \
    --with-npth-prefix=$(pwd)/../../install-root \
    --enable-maintainer-mode \
    --disable-static
make
make install
popd

popd

pushd gnupg
./autogen.sh
popd

mkdir -p build-gnupg
pushd build-gnupg
#LDFLAGS='-L$(pwd)/../install-root/lib'
#   --with-ksba-prefix=$(pwd)/../install-root \

../gnupg/configure \
    --prefix=$(pwd)/../install-root \
    --with-libgcrypt-prefix=$(pwd)/../install-root \
    --with-libgpg-error-prefix=$(pwd)/../install-root \
    --with-libassuan-prefix=$(pwd)/../install-root \
    --with-npth-prefix=$(pwd)/../install-root \
    --with-ksba-prefix=$(pwd)/../install-root \
    --with-libksba-prefix=$(pwd)/../install-root \
    --enable-maintainer-mode
# CFLAGS="-DDEBUG -fsanitize=address -fno-omit-frame-pointer -static-libasan -ggdb3 -O0"

make

popd
