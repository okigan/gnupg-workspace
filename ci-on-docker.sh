#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

git submodule foreach -q --recursive 'branch="$(git config -f $toplevel/.gitmodules submodule.$name.branch)"; git switch $branch'

#docker run -it --volume $(pwd):/home/project ubuntu:latest

docker run \
    --volume $(pwd):/home/project \
    ubuntu:latest \
    /bin/sh -c "cd /home/project && ./install.sh && ./build.sh && ./check.sh && ./test.sh"