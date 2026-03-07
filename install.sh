#!/usr/bin/env bash
set -e

ROOT=$(pwd)

mkdir -p /etc/xray

cp $ROOT/xray/config.json /usr/local/etc/xray/config.json
cp $ROOT/scripts/xray-geosite-update.sh /usr/local/bin/xray-geosite-update.sh

cp $ROOT/systemd/xray-dat-update.service /etc/systemd/system/
cp $ROOT/systemd/xray-dat-update.timer /etc/systemd/system/

systemctl daemon-reload
systemctl enable --now xray-dat-update.timer
