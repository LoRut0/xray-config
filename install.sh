#!/usr/bin/env bash
#abort on error
set -e

function usage {
    echo "usage: ./install.sh --install [xray || v2ray]"
    echo "   "
    echo "  -i | --install           : install command, takes \"xray\" arg or \"v2ray\""
    echo "  -h | --help              : This message"
}

function parse_args {
    # positional args
    args=()

    # named args
    while [ "$1" != "" ]; do
        case "$1" in
        -i | --install)
            an_arg="$2"
            shift
            ;;
        -h | --help)
            usage
            exit
            ;;             # quit and show usage
        *) args+=("$1") ;; # if no match, add it to the positional args
        esac
        shift # move to next kv pair
    done

    # restore positional args
    set -- "${args[@]}"

    # validate required args
    if [[ -z "${an_arg}" ]]; then
        echo "Invalid arguments"
        usage
        exit
    fi
}

function install_xray {
    ROOT=$(pwd)

    mkdir -p /usr/local/share/xray

    install -Dm644 $ROOT/xray/config.json /usr/local/etc/xray/config.json
    install -m755 $ROOT/scripts/geosite-update.sh /usr/local/bin/geosite-update.sh

    install -m644 $ROOT/systemd/xray-geosite-update.service /etc/systemd/system/xray-geosite-update.service
    install -m644 $ROOT/systemd/xray-geosite-update.timer /etc/systemd/system/xray-geosite-update.timer

    systemctl daemon-reload
    systemctl enable --now xray-geosite-update.timer
}

function install_v2ray {
    ROOT=$(pwd)

    mkdir -p /usr/local/share/v2ray

    install -m755 $ROOT/scripts/geosite-update.sh /usr/local/bin/geosite-update.sh

    install -m644 $ROOT/systemd/v2ray-geosite-update.service /etc/systemd/system/
    install -m644 $ROOT/systemd/v2ray-geosite-update.timer /etc/systemd/system/v2ray-geosite-update.timer

    systemctl daemon-reload
    systemctl enable --now v2ray-geosite-update.timer
}

function run {
    parse_args "$@"

    echo "you passed install option for $an_arg\n"
    case $an_arg in
    xray)
        install_xray
        ;;
    v2ray)
        install_v2ray
        ;;
    *)
        echo "Invalid argument $an_arg"
        ;;
    esac
}

run "$@"
