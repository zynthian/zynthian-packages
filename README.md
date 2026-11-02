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

## Versions & Update

If the package is managed with git tools, update is managed automatically (see subsection below).
If not, the update system will use the *version* field from the info.yml. The value of this field must be modified by the package maintainer when a new version is available.
If the package is not git-managed and not *version* field is included in the *info.yml*, only **install** and **remove** actions will be available for the package.
will be available for it.

## Package management script

The package management script is a shell script with file name identical to the package name.

It **MUST** implement these 3 commands:

+ install
+ uninstall
+ installed

This is a typical package management script:

```
#!/bin/bash

DESTINY_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Drum Machines"
URL_DOWNLOAD_BASE="https://os.zynthian.org/packages/Soundfonts/Linnoleum SFZ"


do_install() {
    mkdir -p "$DESTINY_DIR"
    wget -q -O- "$URL_DOWNLOAD_BASE/Linnoleum.tar.xz" | tar -xJ -C "$DESTINY_DIR"
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        rm -rf "$DESTINY_DIR/Linnoleum"
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    if [[ -d "$DESTINY_DIR/Linnoleum" ]]; then
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

## Git-managed packages

If the package is installed using git tools, it's recommended to implement these 2 commands too:

+ git_version
+ git_repo

These 2 commands are needed to allow the git-managed packages to be easily updated from the webconf GUI.

This is a typical git-managed package management script:

```
#!/bin/bash

DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Pianos"
DIRNAME="jRhodes3d"
REPO="jlearman.jRhodes3d"
DOWNLOAD_URL="https://github.com/zynthian/$REPO.git"

do_install() {
    set -ex
    mkdir -p "$DST_DIR"
    cd "$DST_DIR"
    git clone --depth 1 "$DOWNLOAD_URL"
    rm -rf "$REPO/.git"
    mv "$REPO" "$DIRNAME"
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

git_repo() {
    echo $DOWNLOAD_URL
}

git_version() {
    git ls-remote "$DOWNLOAD_URL" HEAD | awk '{ print $1 }'
}

if [[ "$1" == "install" ]]; then
    do_install
elif [[ "$1" == "uninstall" ]]; then
    do_uninstall
elif [[ "$1" == "installed" ]]; then
    echo $(is_installed)
elif [[ "$1" == "git_version" ]]; then
    echo $(git_version)
elif [[ "$1" == "git_repo" ]]; then
    echo $(git_repo)
fi
```
