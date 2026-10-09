# zynthian-packages
This repository contains the official zynthian package catalog, consisting in a directory tree containing package metadata (info), art (images) & management scripts.

+ You can browse the package catalog using [this tool](https://zynthian.github.io/zynthian-packages/).
+ Contributors can add/update packages by sending **Pull Requests** to this repository.
+ No package data is stored in this repository. Package data must be stored externally.
+ A package catalog JSON file is automatically regenerated after committing/merging changes into the main branch. Please, don't modify this file *by hand*.

## Package Categories
Packages are categorized in folders. Current categories are:

+ IRs
+ Samples
+ Soundfonts

## Packages
Each package consists of a subfolder named with the **package_name**. Packages subfolders **must** be inside a category folder.
Inside the package subfolder, it **MUST** have the next structure:

   + **Art** => A folder with package images & icons.
   + **info.yml** => A YAML file with the package metadata: title, size, author, license, image, etc. See details below.
   + **package_name.sh** => A shell script that manage package operations. The file name **MUST** match the package name.

## Package Metada YAML file: info.yml

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

## Package management script

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
