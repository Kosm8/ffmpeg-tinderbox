#!/bin/bash

package_variant() {
    IN="$1"
    OUT="$2"

    mkdir -p "$OUT"/bin
    cp "$IN"/bin/* "$OUT"/bin

    mkdir -p "$OUT/presets"
    cp "$IN"/share/ffmpeg/*.ffpreset "$OUT"/presets
}
