#!/bin/bash

DVDREAD_REPO="https://github.com/nanake/libdvdread.git"
DVDREAD_COMMIT="e294cf7156ce8170ebb6786e21c4baf7aa5f48e4"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$DVDREAD_REPO" "$DVDREAD_COMMIT" dvdread
    cd dvdread

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -Denable_docs=false
        -Dlibdvdcss=enabled
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
    echo --enable-libdvdread
}

ffbuild_unconfigure() {
    echo --disable-libdvdread
}
