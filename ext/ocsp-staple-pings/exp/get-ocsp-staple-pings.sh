#!/usr/bin/env bash
# -*- mode: sh; coding: utf-8; fill-column: 80; -*-
#
#,----------------------------------------------------------------------
#| get-ocsp-staple-pings.sh
#| Created by Balakrishnan Chandrasekaran on 2018-04-11 22:27 +0200.
#'----------------------------------------------------------------------
#

[ $# -ne 1 ]                       && \
    echo "Usage: $0 <domain>" >& 2 && \
    exit 1

readonly DOMAIN=$1

readonly BASEDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
readonly CHECKER="${BASEDIR}/check-ocsp-staple.sh"
readonly  PARSER="${BASEDIR}/parse-ocsp-responses.sh"
readonly  OUTPUT="${BASEDIR}/ocsp-pings--$DOMAIN.txt"

$CHECKER $DOMAIN && \
    $PARSER              | \
        sed 's/-/ /'     | \
        sort -k2,2 -k1,1 | \
                awk '{print NR, $0}' > $OUTPUT
