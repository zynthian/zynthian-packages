# zynthian-packages
This repository contains zynthian package info, art &amp; management scripts.

Contributors can add/update packages by sending Pull Request to this repository.
No package data is stored in this repository. Package data must be stored externally.

Packages are categorized in several categories:

+ Collections
+ IRs
+ Soundfonts

Each package consists of a directory with the next structure:

+ **package_name**
  + **Art** => A folder with package images
  + **info.yml** => A YAML file with the package metadata: title, size, author, license, image, etc.
  + **package_name.sh** => A shell script that manage package operations. The file name **MUST** match the package name.

A typical info.yml file:

```
title: "jRhodes3d - Stereo Rhodes MK I"
icon: "Art/jrhodes3c.jpg"
author: "Jeff Learman"
license: "CC BY-NC"
source_url: "https://github.com/sfzinstruments/jlearman.jRhodes3d.git"
size: "60MB"
content: "sfz/Pianos/jRhodes3d"
description: "Brief description blablabla.

Extended description blablabla...
"
```

Some tips:

+ When this has sense, it's recommended to use the "content" field to specify the location where the package files will be installed in the zynthian device.
+ The package size should be the installed size, not the compressed file size.
+ In the description a blank line is used to split the short description from the extended description. You can use simple HTML markup.

The package management script **MUST** implement these 3 commands:

+ install
+ uninstall
+ installed

A typical package management script: 

```
#!/bin/bash

DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Pianos"
RELEASE="2607"
DOWNLOAD_URL="https://github.com/zynthian/jlearman.jRhodes3d/archive/refs/tags/$RELEASE.zip"
DIRNAME="jRhodes3d"

do_install() {
    set -ex
    mkdir -p "$DST_DIR"
    cd "$DST_DIR"
    wget -q "$DOWNLOAD_URL"
    unzip -q "$RELEASE.zip"
    rm -f "$RELEASE.zip"
    mv "jlearman.$DIRNAME-$RELEASE" "$DIRNAME"
    rm -rf "$DIRNAME/package"
    mv "$DIRNAME/jRhodes3d-demo.mp3" "$ZYNTHIAN_MY_DATA_DIR/files/Audio/Tracks"
    set +x
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        rm -rf "$DST_DIR/$DIRNAME"
        rm -f "$ZYNTHIAN_MY_DATA_DIR/files/Audio/Tracks/jRhodes3d-demo.mp3"
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    if [[ -d "$DST_DIR/$DIRNAME" ]]; then
        echo "installed"
    else
        echo "not installed"
    fi
}

if [[ "$1" == "install" ]]; then
    do_install
elif [[ "$1" == "uninstall" ]]; then
    do_uninstall
elif [[ "$1" == "installed" ]]; then
    echo $(is_installed)
fi
```

