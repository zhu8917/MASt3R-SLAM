#!/bin/bash
set -e

if ! command -v aria2c >/dev/null; then
    echo "aria2c 未安装"
    exit 1
fi

dest="datasets/7-scenes"
mkdir -p "$dest"

ARIA2C_OPTS="-x 16 -s 16 -k 1M --continue=true --max-connection-per-server=16"

urls=(
    "http://download.microsoft.com/download/2/8/5/28564B23-0828-408F-8631-23B1EFF1DAC8/chess.zip"
    "http://download.microsoft.com/download/2/8/5/28564B23-0828-408F-8631-23B1EFF1DAC8/fire.zip"
    "http://download.microsoft.com/download/2/8/5/28564B23-0828-408F-8631-23B1EFF1DAC8/heads.zip"
    "http://download.microsoft.com/download/2/8/5/28564B23-0828-408F-8631-23B1EFF1DAC8/office.zip"
    "http://download.microsoft.com/download/2/8/5/28564B23-0828-408F-8631-23B1EFF1DAC8/pumpkin.zip"
    "http://download.microsoft.com/download/2/8/5/28564B23-0828-408F-8631-23B1EFF1DAC8/redkitchen.zip"
    "http://download.microsoft.com/download/2/8/5/28564B23-0828-408F-8631-23B1EFF1DAC8/stairs.zip"
)

for url in "${urls[@]}"; do
    file_name=$(basename "$url")
    echo "下载 $file_name"
    aria2c $ARIA2C_OPTS -d "$dest" -o "$file_name" "$url"
    unzip "$dest/$file_name" -d "$dest"
    unzip "$dest/${file_name%.*}/seq-01" -d "$dest/${file_name%.*}"
done

