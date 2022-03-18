#!/usr/bin/env sh

OUTPUT=$(memory_pressure)

echo "ORIGINAL:"
echo "${OUTPUT}"
echo
echo "----"
echo

size=toMb

page_size=$(echo "${OUTPUT}" | sed -n '/page size of/s/.*page\ size\ of\ \([0-9]*\)).*/\1/p')

toBytes() {
	echo $(( $1 * page_size))
}

toKb() {
	echo $(( ($1 * page_size) / 1024))
}

toMb() {
	echo $(( ($1 * page_size) / (1024*1024) ))
}

toGb() {
	echo $(( ($1 * page_size) / (1024*1024*1024) ))
}

toSize() {
	eval "$size $1"
}

pages_all=$(echo "${OUTPUT}" | sed -n '/pages with a page size of/s/.*(\([0-9]*\)\ pages with a.*/\1/p')

pages_free=$(echo "${OUTPUT}" | sed -n '/Pages free:/s/.*Pages\ free:\ *\([0-9]*\).*/\1/p')
pages_purgeable=$(echo "${OUTPUT}" | sed -n '/Pages purgeable:/s/.*Pages\ purgeable:\ *\([0-9]*\).*/\1/p')
pages_purged=$(echo "${OUTPUT}" | sed -n '/Pages purged:/s/.*Pages\ purged:\ *\([0-9]*\).*/\1/p')

echo "      All: $(toSize "${pages_all}")"
echo "     Free: $(toSize "${pages_free}")"
echo "Purgeable: $(toSize "${pages_purgeable}")"
echo "   Purged: $(toSize "${pages_purged}")"

