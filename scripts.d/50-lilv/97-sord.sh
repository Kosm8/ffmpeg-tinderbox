#!/bin/bash

SORD_REPO="https://github.com/drobilla/sord.git"
SORD_COMMIT="46f4bcbe04330645a11d00e56a7754cc1386bc45"

ffbuild_enabled() {
    [[ $TARGET == ucrt64 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SORD_REPO" "$SORD_COMMIT" sord
    cd sord

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -D{docs,tests,tools}"=disabled"
    )

    if [[ $TARGET =~ ^(ucrt64|win(64|32))$ ]]; then
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
