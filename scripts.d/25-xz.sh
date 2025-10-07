#!/bin/bash

XZ_REPO="https://github.com/tukaani-project/xz.git"
XZ_COMMIT="8d26b72915e0d373f898b55935505857c30dbdb3"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$XZ_REPO" "$XZ_COMMIT" xz
    cd xz

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_USE_PTHREADS_INIT=ON \
        -DBUILD_{SHARED_LIBS,TESTING}=OFF \
        -DXZ_{DOC,TOOL_{LZMAINFO,XZ,XZDEC}}=OFF \
        -GNinja \
        ..

    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-lzma
}

ffbuild_unconfigure() {
    echo --disable-lzma
}
