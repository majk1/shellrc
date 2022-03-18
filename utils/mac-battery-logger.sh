#!/usr/bin/env sh

while true; do
	echo "$(date '+%Y-%m-%d %H:%M:%S' | tr '\n' ';'; \
		pmset -g batt | sed -n '/Internal/s/.*[^0-9]\([0-9]*\)%;.*\ \([0-9]\{1,2\}:[0-9]\{2\}\)\ remaining.*/ \1; \2/p')" >> battery-log.csv
	sleep 10
done
