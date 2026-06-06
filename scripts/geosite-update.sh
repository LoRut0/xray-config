#!/usr/bin/env bash

set -euo pipefail

GEOSITE_URL="https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geosite.dat"
GEOSITE_URL_HASH="https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geosite.dat.sha256sum"
GEOIP_URL="https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOIP_URL_HASH="https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geoip.dat.sha256sum"

TMP_DIR="/tmp/geosite-update"

GEOSITE_FILE="$GEOSITE_DIR/geosite_runetfreedom.dat"
GEOSITE_FILE_HASH="$GEOSITE_DIR/geosite_runetfreedom.dat.sha256sum"
GEOIP_FILE="$GEOSITE_DIR/geoip_runetfreedom.dat"
GEOIP_FILE_HASH="$GEOSITE_DIR/geoip_runetfreedom.dat.sha256sum"

LOG="/var/log/geosite-update.log"

mkdir -p "$TMP_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >>"$LOG"
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

log "Starting $TO_RESTART geosite.dat and geoip.dat update"

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

updated=0

TMP_GEOIP="$TMP_DIR/geoip.dat"
TMP_GEOIP_HASH="$TMP_DIR/geoip.dat.sha256sum"

download_file "$GEOIP_URL_HASH" "$TMP_GEOIP_HASH"

if file_changed "$TMP_GEOIP_HASH" "$GEOIP_FILE_HASH"; then
    mv "$TMP_GEOIP_HASH" "$GEOIP_FILE_HASH"
    log "downloading geoip.dat"
    download_file "$GEOIP_URL" "$TMP_GEOIP"
    mv "$TMP_GEOIP" "$GEOIP_FILE"
    log "geoip.dat updated"
    updated=1
else
    log "hash of geoip.dat unchanged"
fi

if [ "$updated" -eq 1 ]; then
    log "Restarting $TO_RESTART"
    systemctl restart $TO_RESTART
else
    log "No updates detected"
fi

rm -rf "$TMP_DIR"

log "Update finished"
