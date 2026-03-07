#!/usr/bin/env bash

set -euo pipefail

GEOSITE_URL="https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/download/202603071546/geosite.dat"
GEOSITE_URL_HASH="https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/download/202603071546/geosite.dat.sha256sum"

XRAY_DIR="/usr/local/share/xray"
TMP_DIR="/tmp/xray-geosite-update"

GEOSITE_FILE="$XRAY_DIR/geosite.dat"
GEOSITE_FILE_HASH="$XRAY_DIR/geosite.dat.sha256sum"

LOG="/var/log/xray-geosite-update.log"

mkdir -p "$TMP_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG"
}

download_file() {
    local url=$1
    local target=$2

    curl -L --fail --silent --show-error -o "$target" "$url"
}

file_changed() {
    local new=$1
    local old=$2

    if [ ! -f "$old" ]; then
        return 0
    fi

    if [ "$new" != "$old" ]; then
        return 0
    fi
    return 1
}

updated=0

log "Starting Xray geosite.dat update"

TMP_GEOSITE="$TMP_DIR/geosite.dat"
TMP_GEOSITE_HASH="$TMP_DIR/geosite.dat.sha256sum"

download_file "$GEOSITE_URL_HASH" "$TMP_GEOSITE_HASH"

if file_changed "$TMP_GEOSITE_HASH" "$GEOSITE_FILE_HASH"; then
    mv "$TMP_GEOSITE_HASH" "$GEOSITE_FILE_HASH"
    log "downloading geosite.dat"
    download_file "$GEOSITE_URL" "$TMP_GEOSITE"
    mv "$TMP_GEOSITE" "$GEOSITE_FILE"
    log "geosite.dat updated"
    updated=1
else
    log "hash of geosite.dat unchanged"
fi

if [ "$updated" -eq 1 ]; then
    log "Restarting Xray"
    systemctl restart xray
else
    log "No updates detected"
fi

rm -rf "$TMP_DIR"

log "Update finished"
