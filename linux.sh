
alias ls='ls --color'
alias fixcrlf='sed -i "s/^M$//"'

MAIN_GROUP=$(groups $USER | sed "s/$USER : \([^ ]\+\).*/\1/")
export MAIN_GROUP

function clearCache() {
	local MODE
	MODE=3
	if [ ! -z "$1" ]; then
		if [ "$1" = "-h" ]; then
			echo "usage: clearCache [mode]"
			echo "modes:"
			echo "       1 - pagecache only"
			echo "       2 - dentries and inodes"
			echo "       3 - pagecache, dentries and inodes"
		elif [ "$1" = "1" -o "$1" = "2" -o "$1" = "3" ]; then
			MODE=$1
		else
			echo "Unkown mode: $1"
			return 1
		fi
	fi
	sync
	if [ "$USER" = "root" ]; then
		echo $MODE > /proc/sys/vm/drop_caches
	else
		echo -n "Switching to root... "
		if type -p sudo >/dev/null 2>/dev/null; then
			echo "with sudo"
			echo "echo $MODE > /proc/sys/vm/drop_caches" | sudo sh
		else
			echo "with su"
			su - -c "echo $MODE > /proc/sys/vm/drop_caches"
		fi
	fi
	return 0
}

