#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

export PATH=$(pwd)/install-root/bin:$PATH
export LD_LIBRARY_PATH=$(pwd)/install-root/lib

./issues/tp-5487/repro.sh
