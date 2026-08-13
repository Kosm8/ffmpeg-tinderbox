#!/bin/bash

LIBSR_REPO="https://github.com/libsndfile/libsamplerate.git"
LIBSR_COMMIT="0844c208f683527c08ea8a80acc13b398aa9c8bf"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBSR_REPO" "$LIBSR_COMMIT" libsr
    cd libsr

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{SHARED_LIBS,TESTING}=OFF \
        -DLIBSAMPLERATE_EXAMPLES=OFF \
        -DLIBSAMPLERATE_INSTALL=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}
