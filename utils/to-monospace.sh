#!/usr/bin/env bash

OUTPUT=/dev/stdout

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    echo "usage: $0 [-c] \"text to convert\""
    echo
    echo "   -h     this help message"
    echo "   -c     copy the modified text to clipboard instead (mac os only)"
    echo ""
    return 0
fi

if [[ "$1" == "-c" ]]; then
cat <<EOF | pbcopy
{\rtf1\ansi
{\fonttbl\f0\fnil\fcharset0 Menlo-Regular;}
\f0 $2
}
EOF
else
cat <<EOF
{\rtf1\ansi
{\fonttbl\f0\fnil\fcharset0 Menlo-Regular;}
\f0 $1
}
EOF
fi
