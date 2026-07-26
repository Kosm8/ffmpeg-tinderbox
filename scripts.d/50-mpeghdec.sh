#!/bin/bash

MPEGH_REPO="https://github.com/Fraunhofer-IIS/mpeghdec.git"
MPEGH_COMMIT="4448b69738da2fa5f2f2f2b0ce29eea32509e046"

ffbuild_enabled() {
    [[ $VARIANT == *nonfree* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$MPEGH_REPO" "$MPEGH_COMMIT" mpeg-h
    cd mpeg-h

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_INSTALL_DATAROOTDIR=lib \
        -Dmpeghdec_BUILD_{BINARIES,UIMANAGER}=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    echo "Cflags.private: -DMPEGHDEC_STATIC" >> "$FFBUILD_PREFIX"/lib/pkgconfig/mpeghdec.pc
}

ffbuild_configure() {
    echo --enable-libmpeghdec
}

ffbuild_unconfigure() {
    echo --disable-libmpeghdec
}
