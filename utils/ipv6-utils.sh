#!/usr/bin/env bash

# $1 mac address
function ipv6_mac_to_ipv6() {
    if ! type -p python >/dev/null 2>/dev/null; then
        echo "Could not run funcion, python not found :(" >&2
        return 1
    fi
    if [ $# -ne 1 ]; then
        echo "Parameter required!" >&2
        echo "Usage: ipv6_mac_to_ipv6 <mac address>" >&2
        return 2
    fi

    python - "$1" <<'EOF_PYTHON'
import sys

def mac_to_ipv6(mac_address):
    parts = mac_address.split(":")

    parts.insert(3, "ff")
    parts.insert(4, "fe")
    parts[0] = "%x" % (int(parts[0], 16) ^ 2)

    ipv6_parts = []
    for i in range(0, len(parts), 2):
        ipv6_parts.append("".join(parts[i:i+2]))
    ipv6_addr = "fe80::%s/64" % (":".join(ipv6_parts))
    return ipv6_addr

print mac_to_ipv6(sys.argv[1])
EOF_PYTHON
}

# $1 ipv6 address
function ipv6_ipv6_to_mac() {
    if ! type -p python >/dev/null 2>/dev/null; then
        echo "Could not run funcion, python not found :(" >&2
        return 1
    fi
    if [ $# -ne 1 ]; then
        echo "Parameter required!" >&2
        echo "Usage: ipv6_ipv6_to_mac <ipv6 address>" >&2
        return 2
    fi

    python - "$1" <<'EOF_PYTHON'
import sys

def ipv6_to_mac(ipv6_address):
    subnetIndex = ipv6_address.find("/")
    if subnetIndex != -1:
        ipv6_address = ipv6_address[:subnetIndex]

    ipv6_parts = ipv6_address.split(":")
    mac_parts = []
    for ipv6_part in ipv6_parts[-4:]:
        while len(ipv6_part) < 4:
            ipv6_part = "0" + ipv6_part
        mac_parts.append(ipv6_part[:2])
        mac_parts.append(ipv6_part[-2:])

    mac_parts[0] = "%02x" % (int(mac_parts[0], 16) ^ 2)
    del mac_parts[4]
    del mac_parts[3]

    return ":".join(mac_parts)

print ipv6_to_mac(sys.argv[1])
EOF_PYTHON
}
