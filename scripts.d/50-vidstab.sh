#!/bin/bash

VIDSTAB_REPO="https://github.com/georgmartius/vid.stab.git"
VIDSTAB_COMMIT="4bd81e3cdd778e2e0edc591f14bba158ec40cfa1"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$VIDSTAB_REPO" "$VIDSTAB_COMMIT" vidstab
    cd vidstab

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DBUILD_SHARED_LIBS=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libvidstab
}

ffbuild_unconfigure() {
    echo --disable-libvidstab
}
