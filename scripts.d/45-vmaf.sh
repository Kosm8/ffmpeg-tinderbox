#!/bin/bash

VMAF_REPO="https://github.com/Netflix/vmaf.git"
VMAF_COMMIT="908bdefc6a1174d546040f8797eb467ef4864f5c"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$VMAF_REPO" "$VMAF_COMMIT" vmaf
    cd vmaf

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=both
        -Denable_tests=false
        -Denable_docs=false
        -Denable_avx512=true
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ../libvmaf
    ninja -j"$(nproc)"
    ninja install

    sed -i 's/Libs.private:/Libs.private: -lstdc++/' "$FFBUILD_PREFIX"/lib/pkgconfig/libvmaf.pc

    if [[ $TARGET == win* ]]; then
        rm "$FFBUILD_PREFIX"/bin/libvmaf* "$FFBUILD_PREFIX"/lib/libvmaf.dll.a
    else
        echo "Unknown target"
        return -1
    fi

    cd ../..
    rm -rf vmaf
}

ffbuild_configure() {
    echo --enable-libvmaf
}

ffbuild_unconfigure() {
    echo --disable-libvmaf
}
