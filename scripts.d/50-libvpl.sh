#!/bin/bash

LIBVPL_REPO="https://github.com/intel/libvpl.git"
LIBVPL_COMMIT="3591aa94dfbdf4566cd19f3e976ae5b769ab4fa2"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBVPL_REPO" "$LIBVPL_COMMIT" libvpl
    cd libvpl

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DBUILD_{EXAMPLES,EXPERIMENTAL,SHARED_LIBS,TESTS}=OFF \
        -DINSTALL_EXAMPLES=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    rm -rf "$FFBUILD_PREFIX"/{etc/vpl,share/vpl}

    echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/vpl.pc
}

ffbuild_configure() {
    echo --enable-libvpl
}

ffbuild_unconfigure() {
    echo --disable-libvpl
}
