#!/bin/bash
set -ex
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
ubuild(){
    set -e
    local gh="https://raw.githubusercontent.com/debjaro/unibuild-repo"
    unibuild $gh/$1
    mv *.deb ./out
    set -ex
}
mkdir build || true
cd build
mkdir out || true
ubuild main/matcha-gtk-theme.unibuild
gitbuild https://github.com/debjaro/desktop-base
gitbuild https://github.com/debjaro/base-files

