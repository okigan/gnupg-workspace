#!/bin/bash

pushd gnupg
./autogen.sh
popd

pushd build-gnupg
CFLAGS="-ggdb3 -O0 -DDEBUG -fsanitize=address  -fno-omit-frame-pointer" ../gnupg/configure --enable-maintainer-mode
make
popd
