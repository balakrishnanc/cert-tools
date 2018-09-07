#!/usr/bin/env bash
# -*- mode: sh; coding: utf-8; fill-column: 80; -*-
#
# chkstaple.sh
# Created by Balakrishnan Chandrasekaran on 2018-04-11 00:07 +0200.
# Copyright (c) 2017 Balakrishnan Chandrasekaran <balakrishnan.c@gmail.com>.
#

# Given a Web site domain shows if the server hosting the domain supports OCSP
# stapling.

readonly OSSL=`which openssl`

[ -z $OSSL ]                                        && \
    echo 'Error: unable to find `openssl` in PATH!' && \
    exit 2


if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo 'Usage: '$0' <domain-name> [<server name/IP>]' >& 2
    exit 1
fi

readonly DOM=$1
if [ $# -eq 2 ]; then
    readonly SERVER=$2
else
    readonly SERVER=$DOM
fi

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

function show_status {
    $OSSL s_client -connect $SERVER:443 -servername $DOM \
          -status < ${NUL} 2> ${NUL}                                               | \
        sed -n '/OCSP response:/,/---/p'                                           | \
        sed -E "s/(^OCSP response):(.*$)/${YELLOW}\1${NORMAL}:\2/"                 | \
        sed -E "s/(.*)(no response sent)/\1${RED}\2${NORMAL}/"                     | \
        sed -E "s/(OCSP Response Status: successful \(0x0\))/${GREEN}\1${NORMAL}/" | \
        sed -E "s/(Cert Status:.*$)/${BLUE}\1${NORMAL}/"
}

show_status
