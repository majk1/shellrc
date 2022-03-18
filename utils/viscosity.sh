#!/bin/bash
#
# === Control Viscosity application in MacOS with command line applescript ===
#
# MIT License
# Copyright (c) 2022 Attila Majoros
#
# Source: https://github.com/majk1/shellrc/blob/master/utils/viscosity.sh
#

function viscosity_list_vpns() {
	if [[ "_$1" == "_-v" ]]; then
		osascript -e "tell application \"Viscosity\"" \
			-e "repeat with conn in connections" \
			-e "set n to name of conn" \
			-e "set s to state of conn" \
			-e "log n & \":\" & s" \
			-e "end repeat" \
			-e "end tell" 2>&1
	else
		osascript -e "tell application \"Viscosity\"" \
			-e "repeat with conn in connections" \
			-e "set n to name of conn" \
			-e "log n" \
			-e "end repeat" \
			-e "end tell" 2>&1
	fi
}

function viscosity_state() {
	NAME="$1"
	STATE="$(osascript -e "tell application \"Viscosity\"" \
		-e "set s to state of connections where name is \"${NAME}\"" \
		-e "log s" \
		-e "end tell" 2>&1)"
	if [[ -z $STATE ]]; then
		STATE="Unknown"
	fi
	echo "State:${STATE}"
}

function viscosity_connect() {
	NAME="$1"
	osascript -e "tell application \"Viscosity\" to connect \"${NAME}\"" 2>&1
}

function viscosity_disconnect() {
	NAME="$1"
	osascript -e "tell application \"Viscosity\" to disconnect \"${NAME}\"" 2>&1
}
