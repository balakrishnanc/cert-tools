#!/usr/bin/env bash
# -*- mode: sh; coding: utf-8; fill-column: 80; -*-
#
#,----------------------------------------------------------------------
#| parse-ocsp-responses.sh
#| Created by Balakrishnan Chandrasekaran on 2018-04-11 22:26 +0200.
#'----------------------------------------------------------------------
#

readonly BASEDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
readonly DATADIR="${BASEDIR}/ocsp-responses"

for f in $(ls ${DATADIR}/*.gz); do
    echo -n "$f "
    [ $(zcat $f | grep -c 'no response sent') -eq 1 ] && \
        echo '0'                                      && \
        continue
    [ $(zcat $f | grep -c 'OCSP Response Status: successful') -eq 1 ] && \
        echo '1'                                                      && \
        continue
    echo -1
done                      | \
    sed "s^${DATADIR}/^^" | \
    sed 's/.txt.gz//'
