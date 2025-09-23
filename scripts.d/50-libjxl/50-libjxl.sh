#!/bin/bash

JXL_REPO="https://github.com/libjxl/libjxl.git"
JXL_COMMIT="ec349c55d6e32d10255b1c85355d4cb798a680ad"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$JXL_REPO" "$JXL_COMMIT" jxl
    cd jxl

    git submodule update --init --recursive --depth 1 --recommend-shallow third_party/highway

    mkdir build && cd build

    # Fix AVX2 proc (64bit) crash by highway due to unaligned stack memory
    if [[ $TARGET == win64 ]]; then
        export CXXFLAGS="$CXXFLAGS -Wa,-muse-unaligned-vector-move"
        export CFLAGS="$CFLAGS -Wa,-muse-unaligned-vector-move"
    fi

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DBUILD_{SHARED_LIBS,TESTING}=OFF \
        -DJPEGXL_BUNDLE_LIBPNG=OFF \
        -DJPEGXL_ENABLE_{BENCHMARK,DEVTOOLS,DOXYGEN,EXAMPLES,JNI,JPEGLI,MANPAGES,PLUGINS,SJPEG,SKCMS,TOOLS,VIEWERS}=OFF \
        -DJPEGXL_ENABLE_HWY_AVX3{,_SPR,_ZEN4}=ON \
        -DJPEGXL_FORCE_SYSTEM_{BROTLI,LCMS2}=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    echo "Libs.private: -lstdc++ -ladvapi32" | tee -a "${FFBUILD_PREFIX}"/lib/pkgconfig/libjxl{,_threads}.pc
}

ffbuild_configure() {
    echo --enable-libjxl
}

ffbuild_unconfigure() {
    echo --disable-libjxl
}
