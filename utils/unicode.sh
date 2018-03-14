#!/bin/bash
#
# === Search for unicode symbol ===
#
# MIT License
# Copyright (c) 2016 Attila Majoros
#
# Source: https://github.com/majk1/shellrc/blob/master/utils/unicode.sh
#

TEMP_UNICODE_LIST_FILE="/tmp/unicode_symbols.lst"

function download_and_generate_unicode_symbol_list() {
    local unicode_list_url="http://www.unicode.org/Public/UNIDATA/UnicodeData.txt"
    if type -p wget >/dev/null 2>&1; then
        wget -q -O- "$unicode_list_url" | sed -n 's/^\(.\{4\};[^;]*\);.*/\1/p' > "$1"
    elif type -p curl >/dev/null 2>&1; then
        curl -L -s -o- "$unicode_list_url" | sed -n 's/^\(.\{4\};[^;]*\);.*/\1/p' > "$1"
    else
        echo "Could not download unicode symbol list, curl or wget not found" >&2
        return 1
    fi
}


if [ ! -f "$TEMP_UNICODE_LIST_FILE" ]; then
    download_and_generate_unicode_symbol_list "$TEMP_UNICODE_LIST_FILE"
    ret=$?
    if [ ${ret} -ne 0 ]; then
        exit 1
    fi
fi

pattern="cat \"\$TEMP_UNICODE_LIST_FILE\""
for arg in $@; do
    pattern="$pattern | grep -i '${arg}'"
done

while read line; do
    code="${line%;*}"
    desc="${line#*;}"
    utf16="$(echo "$code" | sed 's/\(.\{2\}\)/\\x\1/g')"
    echo -n -e "$utf16" | iconv -f utf-16be
    echo " - \\u${code} - ${desc}"
done < <(eval "${pattern}")
