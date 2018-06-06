#!/usr/bin/env bash
# -*- mode: sh; coding: utf-8; fill-column: 80; -*-
#
# chkocsp.sh
# Created by Balakrishnan Chandrasekaran on 2018-04-11 00:51 +0200.
# Copyright (c) 2017 Balakrishnan Chandrasekaran <balakrishnan.c@gmail.com>.
#

# Given a domain name, retrieves the cert. for the domain, and checks the
# validity of the cert. using OCSP, if possible.

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


readonly SERVER_CERT="$(mktemp)"
readonly ISSUER_CERT="$(mktemp)"

# Exit when any command returns an error.
set -e
# Cleanup on exit.
trap "rm -f ${SERVER_CERT} ${ISSUER_CERT}" EXIT


function get_certs {
    local certs=`$OSSL s_client -servername $DOM -host $DOM -port 443 -showcerts < ${NUL} 2> ${NUL} | sed -n '/Certificate chain/,/Server certificate/p'`
    echo "$certs"
}

function parse_certs {
    local certs=$(get_certs)
    local level=0
    while [[ "$certs" =~ '-----BEGIN CERTIFICATE-----' ]]; do
        cert="${certs%%-----END CERTIFICATE-----*}-----END CERTIFICATE-----"
        certs=${certs#*-----END CERTIFICATE-----}

        if [ $level -gt 0 ]; then
            # Certificate chain.
            echo "$cert" | $OSSL x509 -pubkey -outform pem >> $ISSUER_CERT

            pad_right "  " $(expr $level - 1)
            pad_right '`-•' 1
        else
            # Leaf; Server certificate.
            echo "$cert" | $OSSL x509 -pubkey -outform pem > $SERVER_CERT

            echo -n '•'
        fi
        echo `echo "$cert" | grep 's:' | sed 's/.*s:\(.*\)/\1/'`

        local cert_hash=$(echo "$cert"                                  | \
                              $OSSL x509 -pubkey -noout                 | \
                              $OSSL rsa -pubin -outform der 2>/dev/null | \
                              $OSSL dgst -sha256 -binary                | \
                              $OSSL enc -base64)
        local ocsp_uri=$(echo "$cert" | openssl x509 -ocsp_uri -noout)

        pad_right "  " $level
        echo -n "¦- Cert. Hash: "
        if [ $level -eq 0 ]; then
            cecho ${BLUE} "$cert_hash"
        else
            echo "$cert_hash"
        fi

        pad_right "  " $level
        echo -n "¦-   OCSP URI: "
        if [ -z ${ocsp_uri} ]; then
            if [ $level -eq 0 ]; then
                cecho ${RED} "None"
            else
                echo "None"
            fi
        else
            if [ $level -eq 0 ]; then
                cecho ${BLUE} $ocsp_uri
            else
                cecho $ocsp_uri
            fi
        fi

        let level=$level+1
    done
}


parse_certs

readonly OCSP_URI="$($OSSL x509 -noout -inform pem -in $SERVER_CERT -ocsp_uri)"
[ -z $OCSP_URI ]                                                 && \
    echo 'Error: server certificate does not support OCSP!' >& 2 && \
    exit 1

$OSSL ocsp                                    \
      -issuer $ISSUER_CERT -cert $SERVER_CERT \
      -url $OCSP_URI                          \
      -verify_other $ISSUER_CERT -resp_text <$NUL 2>&1        | \
    sed -E "s/(WARNING:.*$)/${YELLOW}\1${NORMAL}/"            | \
    sed -E "s/(Response verify.*$)/${CYAN}\1${NORMAL}/"       | \
    sed -E "s/(Responder Id:)(.*$)/\1${BLUE}\2${NORMAL}/"     | \
    sed -E "s/(Produced At:)(.*$)/\1${BLUE}\2${NORMAL}/"      | \
    sed -E "s/(Issuer Name Hash:)(.*$)/\1${BLUE}\2${NORMAL}/" | \
    sed -E "s/(Issuer Key Hash:)(.*$)/\1${BLUE}\2${NORMAL}/"  | \
    sed -E "s/(Serial Number:)(.*$)/\1${BLUE}\2${NORMAL}/"    | \
    sed -E "s/(revoked$)/${RED}\1${NORMAL}/"                  | \
    sed -E "s/(unknown$)/${YELLOW}\1${NORMAL}/"               | \
    sed -E "s/(good$)/${GREEN}\1${NORMAL}/"
