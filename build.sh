#!/bin/bash

pushd gnupg
./autogen.sh
popd

mkdir -p build-gnupg
pushd build-gnupg
CFLAGS="-ggdb3 -O0 -DDEBUG -fsanitize=address  -fno-omit-frame-pointer" ../gnupg/configure --enable-maintainer-mode
make
make check
popd
