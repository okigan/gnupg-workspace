#!/bin/bash

pushd gnupg
./autogen.sh
popd

pushd build-gnupg
CFLAGS="-ggdb3 -O0 -DDEBUG" ../gnupg/configure --enable-maintainer-mode
make
popd
