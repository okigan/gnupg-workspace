#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

mkdir -p build-deps
pushd build-deps

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

wget -nc https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.9.1.tar.bz2
tar xf libgcrypt-1.9.1.tar.bz2
pushd libgcrypt-1.9.1
./configure \
    --prefix=$(pwd)/../../install-root \
    --with-libgpg-error-prefix=$(pwd)/../../install-root \
    --disable-static
make
make install
popd

wget -nc https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.4.tar.bz2
tar xf libassuan-2.5.4.tar.bz2
pushd libassuan-2.5.4
./configure \
    --prefix=$(pwd)/../../install-root \
    --with-libgpg-error-prefix=$(pwd)/../../install-root
make
make install
popd

wget -nc https://gnupg.org/ftp/gcrypt/libksba/libksba-1.3.4.tar.bz2
tar xf libksba-1.3.4.tar.bz2
pushd libksba-1.3.4
./configure \
    --prefix=$(pwd)/../../install-root \
    --with-libgpg-error-prefix=$(pwd)/../../install-root \
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
 #  --with-ksba-prefix=$(pwd)/../install-root \ #this should not be needed but threre is a nice bug in gnupg config
 
../gnupg/configure \
    --prefix=$(pwd)/../install-root \
    --with-libksba-prefix=$(pwd)/../install-root \
    --with-ksba-prefix=$(pwd)/../install-root \
    --with-libgcrypt-prefix=$(pwd)/../install-root \
    --with-libgpg-error-prefix=$(pwd)/../install-root \
    --with-libassuan-prefix=$(pwd)/../install-root \
    --enable-maintainer-mode \
    CFLAGS="-ggdb3 -O0 -DDEBUG -fsanitize=address  -fno-omit-frame-pointer" 

make
make check
popd
