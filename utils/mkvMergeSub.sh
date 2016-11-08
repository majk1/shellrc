#!/bin/sh

mkvMergeSub() {

if [ -z "$1" ]; then
	echo "Usage:"
	echo "${FUNCNAME[0]} <video file> [subtitle file]"
	echo
	echo "if subtitle file is not specified, the script will try to guess from the video file"
	echo
	return 2
fi

VIDEO=$1
VIDEO_NAME=${VIDEO%.*}
VIDEO_EXT=${VIDEO##*.}

if [ -z "$2" ]; then
	SUB=${VIDEO_NAME}.srt
	if [ ! -f "${SUB}" ]; then
		echo "Could not found subtitle file: ${SUB}" >&2
		return 3
	fi
else
	SUB=$2
fi

SUB_NAME=${SUB%.*}
SUB_EXT=${SUB##*.}
SUB_UTF8=${SUB_NAME}-utf8.${SUB_EXT}

echo -n "Converting subtitle to UTF-8: ${SUB} ... "
iconv -f iso-8859-2 -t utf-8 $SUB > $SUB_UTF8 2>/dev/null
if [ $? -ne 0 ]; then
	echo "failed"
	echo "Some error occured during converting subtitle to UTF-8" >&2
	return 1
else
	echo "done"
fi

echo -n "Merging subtitle with video: ${VIDEO} ... "
mkvmerge $VIDEO -o ${VIDEO_NAME}-hunsub.mkv -A -D --track-name "0:magyar" --language "0:hu" -s 0 $SUB_UTF8 >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "failed"
	echo "Some error occured during subtitle merge" >&2
	return 1
else
	echo "done"
fi

}

