# aliases

alias df='df -Ph -T ufsd_NTFS,hfs,msdos,exfat,apfs'
alias fixcrlf='sed -i "" "s/
$//"'
alias netinfo="${SCRIPT_BASE_DIR}/utils/netinfo.py"

MAIN_GROUP=$(groups $USER | sed "s/\([^ ]\{1,\}\).*/\1/")
export MAIN_GROUP

# airport alias

alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'

# functions

cdf() {
	eval cd "$(osascript -e 'tell app "Finder" to return the quoted form of the POSIX path of (target of window 1 as alias)' 2>/dev/null)"
}

vol() {
	if [[ -n $1 ]]; then
		osascript -e "set volume output volume $1"
	else
		osascript -e "output volume of (get volume settings)"
	fi
}

locatemd() {
	mdfind "kMDItemDisplayName == '$@'wc"
}

mailapp() {
	if [[ -n $1 ]]; then
		msg=$1
	else
		msg=$(cat | sed -e 's/\\/\\\\/g' -e 's/\"/\\\"/g')
	fi
	osascript -e "tell application \"Mail\" to make new outgoing message with properties { Content: \"${msg}\", visible: true }" -e "tell application \"Mail\" to activate"
}

quit() {
	for app in $*; do
		osascript -e 'quit app "'$app'"'
	done
}

relaunch() {
	for app in $*; do
		osascript -e 'quit app "'$app'"'
		sleep 2
		open -a $app
	done
}

selected() {
	osascript <<EOT
		tell application "Finder"
			set theFiles to selection
			set theList to ""
				repeat with aFile in theFiles
					set theList to theList & POSIX path of (aFile as alias) & "\n"
				end repeat
			theList
		end tell
EOT
}

app-bundle-id() {
	osascript -e '
	on run args
		set output to {}
		repeat with a in args
			set end of output to id of application a
		end repeat
		set text item delimiters to linefeed
		output as text
	end run' "$@"
}

dns-flush-cache() {
	# sierra+ version
	sudo killall -HUP mDNSResponder
	sudo killall -9 mDNSResponderHelper
	sudo dscacheutil -flushcache
}

# brew bash complation cache
if [[ "${SHELL_TYPE}" == "bash" ]]; then
	BREW_BIN=$(which brew)
	function brew() {
		BREW_COMMANDS_CACHE_FILE=~/.brew-commands-cache
		if [[ "_$1" == "_commands" ]] && [[ "_$2" == "_--quiet" ]] && [[ "_$3" == "_--include-aliases" ]]; then
			if ! find "${BREW_COMMANDS_CACHE_FILE}" -mtime +1 -print 2>/dev/null >&2; then
				${BREW_BIN} commands --quiet --include-aliases >"${BREW_COMMANDS_CACHE_FILE}"
			fi
			cat "${BREW_COMMANDS_CACHE_FILE}"
		else
			if [[ "_$1" == "_upgrade" ]] || [[ "_$1" == "_update" ]]; then
				rm "${BREW_COMMANDS_CACHE_FILE}" >/dev/null 2>&1
			fi
			${BREW_BIN} $@
		fi
	}
fi
