#!/bin/bash

LCMS_REPO="https://github.com/mm2/Little-CMS.git"
LCMS_COMMIT="360391a0916f7c42eb31b3359514bffa7d651d69"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LCMS_REPO" "$LCMS_COMMIT" lcms
    cd lcms

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -D{fastfloat,threaded}"=true"
        -Dtests=disabled
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
