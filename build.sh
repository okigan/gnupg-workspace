#!/bin/bash

mkdir build-gnupg
cd build-gnupg
CFLAGS="-ggdb3 -O0 -DDEBUG" ../gnupg/configure