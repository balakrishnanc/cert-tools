#!/usr/bin/env bash
# -*- mode: sh; coding: utf-8; fill-column: 80; -*-
#
#,----------------------------------------------------------------------
#| check-ocsp-staple.sh
#| Created by Balakrishnan Chandrasekaran on 2018-04-11 22:22 +0200.
#'----------------------------------------------------------------------
#

[ $# -ne 1 ]                       && \
    echo "Usage: $0 <domain>" >& 2 && \
    exit 1

readonly DOMAIN=$1

readonly CERT_TOOLS="${HOME}/cert-tools"
readonly CHECKER="${CERT_TOOLS}/chkstaple.sh"

readonly     BASEDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
readonly  OUTPUT_DIR="${BASEDIR}/ocsp-responses"
readonly OUTPUT_FILE="${OUTPUT_DIR}/$(date '+%H%M-%d%m%Y').txt.gz"

[ -d ${OUTPUT_DIR} ] || mkdir -p ${OUTPUT_DIR}

$CHECKER ${DOMAIN} 2> /dev/null | gzip -c > $OUTPUT_FILE
