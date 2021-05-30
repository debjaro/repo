#!/bin/bash
set -ex
rm -rf build || true
gitbuild(){
    set -e
    git clone "$1" $(basename "$1")
    cd $(basename "$1")
    mk-build-deps --install
    debuild -us -uc -b
    cd ..
    mv *.deb ./out
    set -ex
}
mkdir build || true
cd build
mkdir out || true
gitbuild https://github.com/debjaro/desktop-base
gitbuild https://github.com/debjaro/base-files
gitbuild https://github.com/debjaro/live-save
