#!/usr/bin/env bash
#
# === Currency exchange command line script with online data ===
#
# MIT License
# Copyright (c) 2016 Attila Majoros
#
# Source: https://github.com/majk1/shellrc/blob/master/utils/currency-exchange.sh
#
# Examples:
# $ currency-exchange 10 usd gbp
# $ currency-exchange 10 usd gbp 19
# $ currency-exchange -s 10 usd gbp 19
# 

XREF_URL="http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
XREF_FILE="/tmp/eurofxref-daily.xml"

SILENT=0
if [ "$1" == "-s" ]; then
    SILENT=1
    shift
fi

if [ $# -lt 3 ]; then
    echo "Usage: currency-exchange [-s] <amount> <from currency> <to currency> [apply tax percentage]"
    echo ""
    echo " -s    use -s to print only the result, and nothing more"
    echo ""
    exit 0
fi

function log_err() {
    if [ $SILENT -ne 1 ]; then
        echo "$@" >&2
    fi
}

function download_euroxref_daily() {
    if type -p curl >/dev/null 2>&1; then
        curl -s "$XREF_URL" > "$XREF_FILE" 2>/dev/null
        RET=$?
        if [ $RET -ne 0 ]; then
            log_err "Eurofxref file cannot be download (curl exit code: $RET)"
            return 2
        fi
    elif type -p wget >/dev/null 2>&1; then
        wget -q -O "$XREF_FILE" "$XREF_URL" >/dev/null 2>&1
        RET=$?
        if [ $RET -ne 0 ]; then
            log_err "Eurofxref file cannot be download (wget exit code: $RET)"
            return 2
        fi
    else
        log_err "Eurofxref file cannot be download (curl or wget not found)"
        return 1
    fi
    return 0
}

function get_rate_for() {
    if ! type -p xmllint >/dev/null 2>&1; then
        log_err "xmllint cannot be found, cannot process eurofxref-daily.xml"
        return 2
    fi
    CURR="$1"
    XREF="$(head -n 1 /tmp/eurofxref-daily.xml; grep 'Cube' $XREF_FILE)"
    CURR_DATE="$(date '+%Y-%m-%d')"
    XREF_DATE="$(echo $XREF | xmllint --xpath "//Cube/@time" - | sed 's/.*time=\"\([^"]*\)".*/\1/')"
    if [ "$XREF_DATE" \< "$CURR_DATE" ]; then
        LAST_MOD_TIME=$(date -r $XREF_FILE '+%Y-%m-%d')
        if [ "$LAST_MOD_TIME" \< "$CURR_DATE" ]; then
            download_euroxref_daily
        fi
        XREF="$(head -n 1 $XREF_FILE; grep 'Cube' $XREF_FILE)"
        XREF_DATE="$(echo $XREF | xmllint --xpath "//Cube/@time" - | sed 's/.*time=\"\([^"]*\)".*/\1/')"
        if [ "$XREF_DATE" \< "$CURR_DATE" ]; then
            log_err "WARNING, the downloaded eurofxref-daily.xml date is old: $XREF_DATE"
        fi
    fi

    XREF_RATE=$(echo "$XREF" | xmllint --xpath "//Cube[@currency='$CURR']/@rate" - 2>&1 | sed 's/.*rate=\"\([^"]*\)".*/\1/')
    if echo "$XREF_RATE" | grep -q 'set is empty'; then
        log_err "Could not parse currency rate for $CURR"
        return 1
    else
        echo "$XREF_RATE"
        return 0
    fi
}

if [ ! -f "$XREF_FILE" ]; then
    download_euroxref_daily
    RET=$?
    if [ $RET -ne 0 ]; then
        log_err "Cannot continue, exiting"
        exit $RET
    fi
fi

AMOUNT="$1"
CURR_FROM="$(echo "$2" | tr '[a-z]' '[A-Z]')"
CURR_TO="$(echo "$3" | tr '[a-z]' '[A-Z]')"
TAX="$4"

RATE_FROM=1
RATE_TO=1

if [ "$CURR_FROM" != "EUR" ]; then
    RATE_FROM=$(get_rate_for "$CURR_FROM")
    if [ $? -ne 0 ]; then
        log_err "Unkown source currency: $CURR_FROM"
        exit 4
    fi
fi
if [ "$CURR_TO" != "EUR" ]; then
    RATE_TO=$(get_rate_for "$CURR_TO")
    if [ $? -ne 0 ]; then
        log_err "Unkown target currency: $CURR_TO"
        exit 5
    fi
fi

if ! type -p bc >/dev/null 2>&1; then
    log_err "Application bc cannot be found, cannot calculate rates"
    exit 3
fi

AMOUNT_EURO="$(echo "scale=3; ($AMOUNT / $RATE_FROM) / 1" | bc -l)"
AMOUNT_TO="$(echo "scale=3; ($AMOUNT_EURO * $RATE_TO) / 1" | bc -l)"

if [ ! -z "$TAX" ]; then
    AMOUNT_WITH_TAX="$(echo "scale=3; ($AMOUNT_TO * (($TAX / 100) + 1)) / 1" | bc -l)"
    if [ $SILENT -eq 1 ]; then
        echo "$AMOUNT_WITH_TAX"
    else
        echo "$AMOUNT $CURR_FROM is $AMOUNT_TO $CURR_TO with tax ${TAX}% = $AMOUNT_WITH_TAX $CURR_TO"
    fi
else
    if [ $SILENT -eq 1 ]; then
        echo "$AMOUNT_TO"
    else
        echo "$AMOUNT $CURR_FROM is $AMOUNT_TO $CURR_TO"
    fi
fi
