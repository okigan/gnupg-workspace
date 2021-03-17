#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

export PATH=$(pwd)/install-root/bin:$PATH
export LD_LIBRARY_PATH=$(pwd)/install-root/lib

