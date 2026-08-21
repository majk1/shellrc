# dev

jwtdecode() {
	local token="$1"
	local header payload

	IFS='.' read -r header payload _ <<< "$token" || return 1

	decode() {
		local part="$1"
		local pad=$(( (4 - ${#part} % 4) % 4 ))
		part="${part}$(printf '=%.0s' $(seq 1 $pad))"
		printf '%s' "$part" | tr '_-' '/+' | base64 -d 2>/dev/null
	}

	echo "HEADER:"
	decode "$header" | jq .

	echo
	echo "PAYLOAD:"
	decode "$payload" | jq .
}
