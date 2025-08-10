#!/bin/bash
#
# === Control Viscosity application in MacOS with command line applescript ===
#
# MIT License
# Copyright (c) 2022 Attila Majoros
#
# Source: https://github.com/majk1/shellrc/blob/master/utils/viscosity.sh
#

#function reminders() (
#
#	_reminders_list() {
#		list=$1
#		if [ -z "$list" ]; then
#			osascript -e "tell application \"Reminders\"" \
#				-e "set names to name of lists" \
#				-e "repeat with n in names" \
#				-e "log n" \
#				-e "end repeat" \
#				-e "end tell" 2>&1
#		else
#			shift
#
#			osascript -e "tell application \"Reminders\"" \
#				-e "set selected_list to item 1 of (lists where name is \"${list}\")" \
#            	-e "set reminder_list to name of (reminders of selected_list) where completed is false" \
#            	-e "repeat with reminder_name in reminder_list" \
#            	-e "	log reminder_name" \
#            	-e "end repeat" \
#				-e "end tell" 2>&1
#		fi
#	}
#
#	command=$1
#	if [ -n "$command" ]; then
#		shift
#		case $command in
#		"list")
#		_reminders_list "$@"
#		;;
#		"asd")
#		;;
#		esac
#	else
#		echo "Usage: reminders <command>" >&2
#	fi
#
#)


#function viscosity_list_vpns() {
#	if [[ "_$1" == "_-v" ]]; then
#		osascript -e "tell application \"Viscosity\"" \
#			-e "repeat with conn in connections" \
#			-e "set n to name of conn" \
#			-e "set s to state of conn" \
#			-e "log n & \":\" & s" \
#			-e "end repeat" \
#			-e "end tell" 2>&1
#	else
#		osascript -e "tell application \"Viscosity\"" \
#			-e "repeat with conn in connections" \
#			-e "set n to name of conn" \
#			-e "log n" \
#			-e "end repeat" \
#			-e "end tell" 2>&1
#	fi
#}
#
#function viscosity_state() {
#	NAME="$1"
#	STATE="$(osascript -e "tell application \"Viscosity\"" \
#		-e "set s to state of connections where name is \"${NAME}\"" \
#		-e "log s" \
#		-e "end tell" 2>&1)"
#	if [[ -z $STATE ]]; then
#		STATE="Unknown"
#	fi
#	echo "State:${STATE}"
#}
#
#function viscosity_connect() {
#	NAME="$1"
#	osascript -e "tell application \"Viscosity\" to connect \"${NAME}\"" 2>&1
#}
#
#function viscosity_disconnect() {
#	NAME="$1"
#	osascript -e "tell application \"Viscosity\" to disconnect \"${NAME}\"" 2>&1
#}
