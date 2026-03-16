#!/bin/bash

LIBUNIBREAK_REPO="https://github.com/adah1972/libunibreak.git"
LIBUNIBREAK_COMMIT="e8760630e8b73cf0187fc781383c2be136aa462d"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBUNIBREAK_REPO" "$LIBUNIBREAK_COMMIT" libunibreak
    cd libunibreak

    ./bootstrap

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,dependency-tracking}
        --enable-static
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install
}
