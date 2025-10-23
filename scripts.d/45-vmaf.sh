#!/bin/bash

VMAF_REPO="https://github.com/Netflix/vmaf.git"
VMAF_COMMIT="1b08bb4da533fe3bc08700e4c1adb45f5adccc0b"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$VMAF_REPO" "$VMAF_COMMIT" vmaf
    cd vmaf

    sed -i "/subdir('tools')/d" libvmaf/meson.build

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -D{built_in_models,enable_avx512}"=true"
        -Denable_{docs,tests}"=false"
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ../libvmaf
    ninja -j"$(nproc)"
    ninja install

    echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libvmaf.pc
}

ffbuild_configure() {
    echo --enable-libvmaf
}

ffbuild_unconfigure() {
    echo --disable-libvmaf
}
