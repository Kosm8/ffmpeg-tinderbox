#!/bin/bash

ZIX_REPO="https://github.com/drobilla/zix.git"
ZIX_COMMIT="a5c18d52a5351430d370084f25aaf7d166f7afd5"

ffbuild_enabled() {
    [[ $TARGET == ucrt64 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ZIX_REPO" "$ZIX_COMMIT" zix
    cd zix

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -D{benchmarks,docs,tests,tests_cpp}"=disabled"
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
