#!/bin/bash

MINGW_REPO="https://github.com/mingw-w64/mingw-w64.git"
MINGW_COMMIT="a0fd21158e9f3d625dd6d682443bf9c905ff5e01"

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --from=${SELFLAYER} /opt/mingw/. /"
    to_df "COPY --from=${SELFLAYER} /opt/mingw/. /opt/mingw"
}

ffbuild_dockerfinal() {
    to_df "COPY --from=${PREVLAYER} /opt/mingw/. /"
}

ffbuild_dockerbuild() {
    git-mini-clone "$MINGW_REPO" "$MINGW_COMMIT" mingw
    cd mingw/mingw-w64-headers

    unset CFLAGS CXXFLAGS LDFLAGS PKG_CONFIG_LIBDIR

    SYSROOT="$($CC -print-sysroot)"
    MINGW_PREFIX="/opt/mingw/${SYSROOT#/}/mingw"

    local myconf=(
        --prefix="$MINGW_PREFIX"
        --host="$FFBUILD_TOOLCHAIN"
        --enable-idl
    )

    if [[ $TARGET == win32 ]]; then
        myconf+=(
            --with-default-msvcrt=msvcrt
        )
    fi

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install

    cd ../mingw-w64-crt

    local myconf=(
        --prefix="$MINGW_PREFIX"
        --host="$FFBUILD_TOOLCHAIN"
    )

    if [[ $TARGET == win32 ]]; then
        myconf+=(
            --disable-lib64
            --enable-lib32
            --with-default-msvcrt=msvcrt
        )
    elif [[ $TARGET == win64 ]]; then
        myconf+=(
            --disable-lib32
            --enable-lib64
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install

    cd ../mingw-w64-libraries/winpthreads

    local myconf=(
        --prefix="$MINGW_PREFIX"
        --host="$FFBUILD_TOOLCHAIN"
        --with-pic
        --disable-shared
        --enable-static
    )

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install
}

ffbuild_configure() {
    echo --disable-w32threads --enable-pthreads
}
