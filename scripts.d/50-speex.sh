#!/bin/bash

SPEEX_REPO="https://github.com/xiph/speex.git"
SPEEX_COMMIT="05895229896dc942d453446eba6f9f5ddcf95422"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SPEEX_REPO" "$SPEEX_COMMIT" speex
    cd speex

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -Dtools=disabled
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libspeex
}

ffbuild_unconfigure() {
    echo --disable-libspeex
}
