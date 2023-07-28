#!/bin/bash

ZMQ_REPO="https://github.com/zeromq/libzmq.git"
ZMQ_COMMIT="ec013f3a17beaa475c18e8cf5e93970800e2f94a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ZMQ_REPO" "$ZMQ_COMMIT" zmq
    cd zmq

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,Werror}
        --enable-static
    )

    if [[ $TARGET =~ ^(ucrt64|win(64|32))$ ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
        # 💥 avoid symbol collision with libssh
        export CFLAGS="$CFLAGS -Dsha1_init=zmq_sha1_init"
        export CXXFLAGS="$CFLAGS -Dsha1_init=zmq_sha1_init"
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    sed -i 's/-lpthread/& -lws2_32/' "$FFBUILD_PREFIX"/lib/pkgconfig/libzmq.pc
    echo "Cflags.private: -DZMQ_STATIC" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libzmq.pc
}

ffbuild_configure() {
    echo --enable-libzmq
}

ffbuild_unconfigure() {
    echo --disable-libzmq
}