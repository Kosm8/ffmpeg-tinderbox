#!/bin/bash

X264_REPO="https://github.com/mirror/x264.git"
X264_COMMIT="7628a5696f79a1f0421dda99ab37b34481c69821"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$X264_REPO" "$X264_COMMIT" x264
    cd x264

    local myconf=(
        --disable-{cli,lavf,swscale}
        --enable-{static,pic}
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
            --cross-prefix="$FFBUILD_CROSS_PREFIX"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libx264
}

ffbuild_unconfigure() {
    echo --disable-libx264
}

ffbuild_cflags() {
    return 0
}

ffbuild_ldflags() {
    return 0
}
