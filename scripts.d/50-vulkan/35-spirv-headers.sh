#!/bin/bash

SPIRVHEADERS_REPO="https://github.com/KhronosGroup/SPIRV-Headers.git"
SPIRVHEADERS_COMMIT="ad9184e76a66b1001c29db9b0a3e87f646c64de0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SPIRVHEADERS_REPO" "$SPIRVHEADERS_COMMIT" spirv-headers
    cd spirv-headers

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DSPIRV_HEADERS_ENABLE_INSTALL=ON \
        -DSPIRV_HEADERS_ENABLE_TESTS=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}
