#!/bin/bash

if [ -n "$1" ]; then
    SRCDIR="$1"
else
    SRCDIR="../zynthian-packages-sources"
fi

if [[ ! -d  "$SRCDIR" ]]; then
    echo "Source directory doesn't exist => \"$SRCDIR\""
    exit 1
fi

echo "Updating package info from \"$SRCDIR\" ..."

catdir="Samples"
mkdir -p "$SRCDIR/$catdir"
for dir in "$SRCDIR/$catdir"/*; do
    for subdir in "$dir"/*; do
        if [[ -d "$subdir" ]]; then
            echo "Updating from $subdir ..."
            dirname=$(basename "$subdir")
            if [[ "$dirname" != _* ]]; then
                destdir=$catdir/$dirname
                mkdir -p "$destdir"
                cp -a "$subdir/Art" "$destdir"
                cp -a "$subdir/info.yml" "$destdir"
                cp -a "$subdir"/*.sh "$destdir"
                cp -a "$subdir"/*.txt "$destdir"
            fi
        fi
    done
done

catdirs=("IRs" "Soundfonts")
for catdir in "${catdirs[@]}"; do
    mkdir -p "$SRCDIR/$catdir"
    for subdir in "$SRCDIR/$catdir"/*; do
        if [[ -d "$subdir" ]]; then
            echo "Updating from $subdir ..."
            dirname=$(basename "$subdir")
            if [[ "$dirname" != _* ]]; then
                destdir=$catdir/$dirname
                if [[ -d "$subdir/package" ]]; then
                    subdir="$subdir/package"
                fi
                mkdir -p "$destdir"
                cp -a "$subdir/Art" "$destdir"
                cp -a "$subdir/info.yml" "$destdir"
                cp -a "$subdir"/*.sh "$destdir"
                cp -a "$subdir"/*.txt "$destdir"
            fi
        fi
    done
done
