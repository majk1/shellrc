#!/usr/bin/env python
#
# === Search for unicode symbol ===
#
# MIT License
# Copyright (c) 2016 Attila Majoros
#
# Source: https://github.com/majk1/shellrc/blob/master/utils/unicode.py
#

import sys
import os.path
import re

try:
    from urllib2 import urlopen
except ImportError:
    from urllib.request import urlopen

UNICODE_SYMBOLS_SOURCE_URL = 'http://www.unicode.org/Public/UNIDATA/UnicodeData.txt'
UNICODE_SYMBOLS_SOURCE_URL_FALLBACK = 'https://static.codelens.io/UnicodeData.txt'
UNICODE_SYMBOLS_LIST = '/tmp/unicode_symbols.lst'
DEBUG = False


def debug(message):
    if DEBUG:
        sys.stderr.write('DBG: ' + message + '\n')


def fetch_unicode_data(url, target_file):
    debug('Fetching unicode symbol list from ' + url)
    data = urlopen(url)
    fl = open(target_file, 'wt')
    line_counter = 0
    for desc_line in data:
        m = re.match('^(.{4};[^<][^;]+);.*', desc_line.decode())
        if m:
            fl.write(m.group(1).lower())
            fl.write('\n')
            line_counter = line_counter + 1
    fl.close()
    debug('Fetched and filtered ' + str(line_counter) + ' symbols into ' + target_file)


def is_unicode_symbols_list_file_usable(file_name):
    if os.path.exists(file_name):
        if os.path.getsize(file_name) > 0:
            return True
    return False


if __name__ == '__main__':
    args = list(sys.argv[1:])
    if len(args) > 0:
        if args[0] == '-d':
            DEBUG = True
            args = args[1:]

    debug('Python version: ' + sys.version)

    if len(args) == 0:
        sys.stderr.write('Usage: unicode.py [-d] <search>\n')
        sys.stderr.write('\n')
        sys.stderr.write('  -d         - enabled debug messages\n')
        sys.stderr.write('  <search>   - multiple search patterns separated by space\n')
        sys.stderr.write('\n')
        sys.stderr.write('Example: ./unicode.py black circle\n')
        sys.stderr.write('\n')
        sys.exit(1)

    if not is_unicode_symbols_list_file_usable(UNICODE_SYMBOLS_LIST):
        try:
            fetch_unicode_data(UNICODE_SYMBOLS_SOURCE_URL, UNICODE_SYMBOLS_LIST)
        except Exception as e:
            debug('Could not download unicode symbol list: ' + str(e))
            debug('trying fallback url: ' + UNICODE_SYMBOLS_SOURCE_URL_FALLBACK)
            try:
                fetch_unicode_data(UNICODE_SYMBOLS_SOURCE_URL_FALLBACK, UNICODE_SYMBOLS_LIST)
            except Exception as ee:
                sys.stderr.write('Could not download unicode symbol list from fallback url: ' + str(ee) + '\n')
                sys.exit(2)

    search = [s.lower() for s in args]
    debug('searching for unicode symbols by: ' + '+'.join(search))
    with open(UNICODE_SYMBOLS_LIST, 'r') as f:
        for line in f:
            if all(s in line for s in search):
                code, name = line.rstrip().split(';')
                symbol = ('\\u' + code).encode('utf-8').decode('raw_unicode_escape')
                try:
                    print(symbol + '\t\\u' + code + '\t&#x' + code + ';\t' + name)
                except UnicodeEncodeError as e:
                    print((symbol + '\t\\u' + code + '\t&#x' + code + ';\t' + name).encode('utf-8'))
