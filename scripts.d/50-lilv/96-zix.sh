#!/bin/bash

ZIX_REPO="https://github.com/drobilla/zix.git"
ZIX_COMMIT="262d4a1522c38be0588746e874159da5c7bb457d"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ZIX_REPO" "$ZIX_COMMIT" zix
    cd zix

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -D{benchmarks,docs,tests,tests_cpp}"=disabled"
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install
}
