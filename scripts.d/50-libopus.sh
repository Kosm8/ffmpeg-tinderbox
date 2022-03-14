#!/bin/bash

OPUS_REPO="https://github.com/xiph/opus.git"
OPUS_COMMIT="c6f98577716d39907264d5388b74b5be5dea3d6c"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OPUS_REPO" "$OPUS_COMMIT" opus
    cd opus

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DOPUS_BUILD_{PROGRAMS,SHARED_LIBRARY,TESTING}=OFF \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libopus
}

ffbuild_unconfigure() {
    echo --disable-libopus
}
