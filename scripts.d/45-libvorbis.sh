#!/bin/bash

VORBIS_REPO="https://github.com/xiph/vorbis.git"
VORBIS_COMMIT="851cce991da34adf5e1f3132588683758a6369ec"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$VORBIS_REPO" "$VORBIS_COMMIT" vorbis
    cd vorbis

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{SHARED_LIBS,TESTING}=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libvorbis
}

ffbuild_unconfigure() {
    echo --disable-libvorbis
}
