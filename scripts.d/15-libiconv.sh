#!/bin/bash

# https://git.savannah.gnu.org/gitweb/?p=libiconv.git
LIBICONV_REPO="https://github.com/nanake/libiconv.git"
LIBICONV_COMMIT="master"

GNULIB_REPO="https://github.com/coreutils/gnulib.git"
GNULIB_COMMIT="master"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=master --single-branch "$LIBICONV_REPO" libiconv
    cd libiconv
    git checkout "$LIBICONV_COMMIT"

    git-mini-clone "$GNULIB_REPO" "$GNULIB_COMMIT" gnulib

    unset CC CFLAGS

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,dependency-tracking}
        --enable-{static,extra-encodings}
        --with-pic
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./autogen.sh
    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install
}

ffbuild_configure() {
    echo --enable-iconv
}

ffbuild_unconfigure() {
    echo --disable-iconv
}