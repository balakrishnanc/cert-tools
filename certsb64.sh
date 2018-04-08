#!/usr/bin/env bash
# -*- mode: sh; coding: utf-8; fill-column: 80; -*-
#
# certsb64.sh
# Created by Balakrishnan Chandrasekaran on 2017-11-14 15:25 +0100.
# Copyright (c) 2017 Balakrishnan Chandrasekaran <balakrishnan.c@gmail.com>.
#

# Given a domain name this script prints the public keys in the chain as a
# SHA-256 hash using base64 encoding.
# (https://medium.com/@appmattus/android-security-ssl-pinning-1db8acb6621e)

readonly OSSL=`which openssl`

[ -z $OSSL ]                                        && \
    echo 'Error: unable to find `openssl` in PATH!' && \
    exit 2


if [ $# -ne 1 ]; then
    echo 'Usage: '$0' <domain-name>' >& 2
    exit 1
fi

DOM=$1


readonly NUL='/dev/null'

readonly NCOLORS=$(tput colors)

if test -t 1; then
    if [[ ( -n "$NCOLORS" ) && ( "$NCOLORS" -ge 8 ) ]]; then
        readonly  NORMAL="$(tput sgr0)"
        readonly   BLACK="$(tput setaf 0)"
        readonly     RED="$(tput setaf 1)"
        readonly   GREEN="$(tput setaf 2)"
        readonly  YELLOW="$(tput setaf 3)"
        readonly    BLUE="$(tput setaf 4)"
        readonly MAGENTA="$(tput setaf 5)"
        readonly    CYAN="$(tput setaf 6)"
        readonly   WHITE="$(tput setaf 7)"
    fi
fi

function cecho() {
    local color="$1"
    local   msg="$2"
    echo "${color}${msg}${NORMAL}"
}

function pad_right() {
    local padstr="$1"
    local  level="$2"
    if [ $level -le 0 ]; then
        return
    fi

    for i in $(seq 1 1 $level); do
        echo -n "${padstr}"
    done
}


function get_certs {
    # Domain name.
    local certs=`$OSSL s_client -servername $DOM -host $DOM -port 443 -showcerts < ${NUL} 2> ${NUL} | sed -n '/Certificate chain/,/Server certificate/p'`
    echo "$certs"
}

function show_certs {
    local certs=$(get_certs)
    local level=0
    while [[ "$certs" =~ '-----BEGIN CERTIFICATE-----' ]]; do
        cert="${certs%%-----END CERTIFICATE-----*}-----END CERTIFICATE-----"
        certs=${certs#*-----END CERTIFICATE-----}

        if [ $level -gt 0 ]; then
            pad_right "  " $(expr $level - 1)
            echo -n '•'
            pad_right "--" 1
        fi
        echo `echo "$cert" | grep 's:' | sed 's/.*s:\(.*\)/\1/'`

        pad_right "  " $level
        echo -n "¦- Cert. Hash: "
        cecho ${BLUE} $(echo "$cert"                                    | \
                            openssl x509 -pubkey -noout                 | \
                            openssl rsa -pubin -outform der 2>/dev/null | \
                            openssl dgst -sha256 -binary                | \
                            openssl enc -base64)

        let level=$level+1
    done
}

show_certs
