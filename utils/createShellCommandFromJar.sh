#!/bin/sh

createShellCommandFromJar() {

if [ ! -z "$1" ]; then
	if [ -f "$1" ]; then
		JAR_FILE_PATH="$1"
		JAR_FILE_NAME="${1##*/}"
		JAR_FILE_BASE="${JAR_FILE_NAME%.*}"

		BASE64="$(openssl base64 -e -in "$JAR_FILE_PATH")"

		cat > ${JAR_FILE_BASE}.sh <<-EEEEEEEEND
#!/bin/sh

JAR_FILE_NAME=$JAR_FILE_NAME
JAR_FILE_TMP_DIR=/tmp/jarBundle

if [ ! -d \$JAR_FILE_TMP_DIR ]; then
		mkdir \$JAR_FILE_TMP_DIR
	fi

	if [ ! -f \$JAR_FILE_TMP_DIR/\$JAR_FILE_NAME ]; then
		openssl base64 -d > \$JAR_FILE_TMP_DIR/\$JAR_FILE_NAME <<-EOF
$BASE64
EOF
fi

java -jar \$JAR_FILE_TMP_DIR/\$JAR_FILE_NAME "\$@"
EEEEEEEEND
	chmod 755 "${JAR_FILE_BASE}.sh"
	echo "Jar shell bundle created: ${JAR_FILE_BASE}.sh"
	else
		echo "Jar file: $1 not found"
	fi
else
	echo "Usage: createShellCommandFromJar <jar path>"
fi

}

