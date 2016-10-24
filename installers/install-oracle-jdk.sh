#!/usr/bin/env bash

if [ $(id -u) -ne 0 ]; then
	echo "You have to be root to install JDK" >&2
	exit 1
fi

if [ "$(uname)" != "Linux" ]; then
    echo "Not supported OS type" >&2
    echo "Currently supported OS types: Linux" >&2
    exit 1
fi

#
# load
#

JDK_LINKS=$(
	wget -q --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -q -O- \
	http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html | \
	sed -n 's%.*"http://download.oracle.com/otn-pub/java/jdk/\([^"]\+\).*%http://download.oracle.com/otn-pub/java/jdk/\1%p' | \
	grep -v demos)

AVAILABLE_VERSIONS=($(echo "${JDK_LINKS[@]}" | sed 's%.*/jdk-\([^-]\+\)-.*%\1%' | uniq | sort))
AVAILABLE_OS_TYPES=("linux macosx windows solaris")
AVAILABLE_ARCHS=("i586 x64 arm64 arm32 sparcv9")

contains() {
	local item
	for item in ${@:2}; do [[ "$item" == "$1"  ]] && return 0; done
	return 1
}

yesno() {
	local yes
	local no
	if [ -z $2 ]; then
		yes="yes"
		no="no"
	else
		yes="$2"
		no="$3"
	fi
	[ $1 -eq 1 ] && echo -n "$yes" || echo -n "$no"
}

confirmInterractive() {
	if [ $SILENT -ne 1 ]; then
		read -n 1 -p "$1 [y/n]? " ANSWER
		if [ "$ANSWER" != "y" ]; then
			echo
			echo "Stopping installation. Bye"
			exit 127
		fi
		echo
	fi
}

SELECTED_VERSION=${AVAILABLE_VERSIONS[0]}

SELECTED_OS="unknown"
SELECTED_ARCH="unknown"
DOWNLOAD_LINK=""
PATCH_JAVA_SECURITY=0
INSTALL_DIR="/opt/java"
SILENT=0
INSTALL_PROFILE=0

shopt -s nocasematch
if [[ $OSTYPE =~ linux ]]; then
	SELECTED_OS="linux"
	PATCH_JAVA_SECURITY=1
fi

if uname -m | grep -q "64"; then
	SELECTED_ARCH="x64"
fi

#
# read command line parameters
#

while [ ! -z "$1" ]; do
	case $1 in
		-v|--version)
			shift
			if [ ! -z "$1" ]; then
				if contains "$1" "${AVAILABLE_VERSIONS[@]}"; then
					SELECTED_VERSION="$1"
				else
					echo "Invalid version: $1" >&2
					echo "Available versions: ${AVAILABLE_VERSIONS[@]}"
					exit 1
				fi			
			else
				echo "Version required." >&2
				echo "Available versions: ${AVAILABLE_VERSIONS[@]}" >&2
				exit 1
			fi
			;;
		-o|--os)
			shift
			if [ ! -z "$1" ]; then
				SELECTED_OS="$1"
			else
				echo "OS type required" >&2
				exit 1
			fi
			;;
		-a|--arch)
			shift
			if [ ! -z "$1" ]; then
				SELECTED_ARCH="$1"
			else
				echo "Architecture required" >&2
				exit 1
			fi
			;;
		-l|--link)
			shift
			if [ ! -z "$1" ]; then
				DOWNLOAD_LINK="$1"
			else
				echo "Download link required" >&2
				exit 1
			fi
			;;
		--patch-java-security)
			PATCH_JAVA_SECURITY=1
			;;
		-d|--dir)
			shift
			if [ ! -z "$1" ]; then
				INSTALL_DIR="$1"
			else
				echo "Install directory required" >&2
				exit 1
			fi
			;;
		-p|--install-profile)
			INSTALL_PROFILE=1
			;;
		-s|--silent)
			SILENT=1
			;;
		-h|--help)
			echo "Usage: install-oracle-jdk [-h|--help] [-v|--version <version>] [-o|--os <os type>] [-a|--arch <arch>] [-l|--link <link>] [-d|--dir <dest dir>] [-s|--silent] [--patch-java-security]"
			echo
			echo " -h, --help             - This help :)"
			echo " -v, --version          - Specify the JDK version, eg.:: 8u101"
			echo " -o, --os               - Specify the operating system type, eg.: linux"
			echo " -a, --arch             - Specify the architecture, eg.: x64"
			echo " -d, --dir              - Specify the destination directory (default: /opt/java/"
			echo " -l, --link             - Specify the JDK package download link manually"
			echo " -s, --silent           - Turns off interactive confirmations"
			echo " -p, --install-profile  - Install profile file: /etc/profile.d/oracle-jdk.sh"
			echo "                          It sets the JAVA_HOME and PATH environment variables"
			echo "                          and profives shell functions like \"javaswitch <short name>\"",
			echo "                          eg.: # javaswitch jdk8"
			echo " --patch-java-security  - Enables patching java.security with /dev/./urandom"
			echo
			exit 0
			;;
		*)
			;;
	esac
	shift
done

JDK_SHORT="jdk${SELECTED_VERSION:0:1}"
INSTALL_DIR="${INSTALL_DIR%/}"

#
# show summary
#

echo
echo "Installation details:"
echo "-----------------------------------------"
echo "     Selected JDK version: ${SELECTED_VERSION}"
echo "         Selected OS type: ${SELECTED_OS}"
echo "    Selected architecture: ${SELECTED_ARCH}"
echo "     Short name (symlink): ${JDK_SHORT}"
echo " Patch java security file: $(yesno $PATCH_JAVA_SECURITY)"
echo "        Install directory: ${INSTALL_DIR}"
echo "        Installation type: $(yesno $SILENT silent interractive)"
echo "   Install profile script: $(yesno $INSTALL_PROFILE)"

#
# check OS type
#

if ! contains "$SELECTED_OS" "${AVAILABLE_OS_TYPES[@]}"; then
	echo >&2
	echo "Unknown OS type. Please specify OS type with the -o <os type> argument." >&2
	echo "Available OS types: ${AVAILABLE_OS_TYPES[@]}" >&2
	exit 1
fi

#
# check architecture
#

if ! contains "$SELECTED_ARCH" "${AVAILABLE_ARCHS[@]}"; then
	echo >&2
	echo "Unknown architectire. Please specify architecture with the -o <arch> argumant." >&2
	echo "Available architectures: ${AVAILABLE_ARCHS[@]}" >&2
	exit 1
fi

if [ -e "${INSTALL_DIR}" ] && [ ! -d "${INSTALL_DIR}" ]; then
	echo >&2
	echo "There is a file at installation path: ${INSTALL_DIR}" >&2
	echo "Please choose another installation directory with -d <path> argument." >&2
	exit 1
fi

#
# download link
#

if [ -z "$DOWNLOAD_LINK" ]; then
	# filter URLs by selected parameters
	FILTERED_JDK_LINKS=$(echo "${JDK_LINKS[@]}" | grep "${SELECTED_VERSION}-${SELECTED_OS}-${SELECTED_ARCH}.*tar.*")

	if [ ${#FILTERED_JDK_LINKS[@]} -lt 1 ]; then
		echo "No download link has been found for the specified parameters :(" >&2
		exit 1
	else
		if [ ${#FILTERED_JDK_LINKS[@]} -gt 1 ]; then
			echo "Multiple download links has been found for the specified parameters." >&2
			echo "Use one of the links with the -p <link> argument. Available links:" >&2
			for link in "${FILTERED_JDK_LINKS[@]}"; do
				echo "* ${link}" >&2
			done
			exit 1
		else
			DOWNLOAD_LINK="${FILTERED_JDK_LINKS[0]}"
		fi
	fi
fi

echo "            Download link: ${DOWNLOAD_LINK}"
echo

#
# if not silent, ask to continue
#

confirmInterractive "Start installation"

echo
echo "Starting installation..."

echo -n "Creating temporary directory: "
TEMP_DIR=$(mktemp -d -t install-jdk-XXXXX)
if [ $? -ne 0 ]; then
	echo "failed"
	echo "Could not create temporary directory :(" >&2
	exit 2
fi
echo "${TEMP_DIR}"

TEMP_JDK_PACKAGE="${TEMP_DIR}/jdk-${SELECTED_VERSION}-${SELECTED_OS}-${SELECTED_ARCH}.tar.gz"

echo "Download JDK..."
wget -q --progress=bar:noscroll --show-progress --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O "${TEMP_JDK_PACKAGE}" "$DOWNLOAD_LINK"
if [ $? -ne 0 ]; then
	echo "Cannot download the JDK package :(" >&2
	exit 2
fi

if [ ! -d "${INSTALL_DIR}" ]; then
	confirmInterractive "Create installation directory (${INSTALL_DIR})"
	mkdir -p "${INSTALL_DIR}"
	if [ $? -ne 0 ]; then
		echo "Cannot create installation directory: ${INSTALL_DIR}" >&2
		exit 2
	fi
fi

JDK_HOME="${INSTALL_DIR}/$(tar -tzf "${TEMP_JDK_PACKAGE}" | head -n1 | sed 's%\([^/]\+\).*%\1%')"
JDK_LINK="${INSTALL_DIR}/${JDK_SHORT}"

if [ -e "${JDK_HOME}" ]; then
	confirmInterractive "Target directory already exists (${JDK_HOME}). Continue"
fi

echo -n "Extracting package... "
tar -C "${INSTALL_DIR}" -xzf "${TEMP_JDK_PACKAGE}" >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "failed"
	echo "Error during extraction of the JDK package :(" >&2
	exit 2
fi
echo "done"
chown -R root:root "${JDK_HOME}"

if [ $PATCH_JAVA_SECURITY -eq 1 ]; then
	echo "Patching java.security file..."
	sed -i '/securerandom.source=/s%/dev/random%/dev/./urandom%' "${JDK_HOME}/jre/lib/security/java.security"
	if [ $? -ne 0 ]; then
		echo "!!! Could not patch java.security file at ${JDK_HOME}/jre/lib/security/java.security" >&2
	fi
fi

if [ -e "${JDK_LINK}" ]; then
	confirmInterractive "Symbolic link already present (${JDK_LINK}). Replace"
	rm -f "${JDK_LINK}"
	if [ $? -ne 0 ]; then
		echo "Could not replace symbolic link ($JDK_LINK)" >&2
		exit 2
	fi
fi
echo "Creating symbolic link to: ${JDK_LINK}"
ln -s "${JDK_HOME}" "${JDK_LINK}"

if [ $INSTALL_PROFILE -eq 1 ]; then
	

	echo "Installing profile into /etc/profile.d/oracle-jdk.sh ..."
cat << EOF > /etc/profile.d/oracle-jdk.sh
#!/bin/sh

JAVA_OPTS="-Djavax.servlet.request.encoding=UTF-8 -Dfile.encoding=UTF-8 -noverify -Xmx1g -XX:MaxPermSize=256m"
JAVA_HOME=${JDK_LINK}
PATH=\$JAVA_HOME/bin:\$PATH

export JAVA_HOME
export PATH

removeJavaFromPath() {
	PATH=\$(echo \$PATH | sed "s%${INSTALL_DIR}/[^:]*:%%g")
	export PATH
}

javaswitch() {
	local JVER
	JVER=\$1

	if [ ! -d "${INSTALL_DIR}/\$JVER" ]; then
		echo "Directory not exists: ${INSTALL_DIR}/\$JVER" >&2
		return -1
	fi

	removeJavaFromPath

	JAVA_HOME=${INSTALL_DIR}/\$JVER
	PATH=\$JAVA_HOME/bin:\$PATH

	export JAVA_HOME
	export PATH
}
EOF
fi

if [ ! -z "$TEMP_DIR" ] && [ -d "${TEMP_DIR}" ] && [[ "$TEMP_DIR" =~ tmp ]]; then
	echo "Removing temporary directory: ${TEMP_DIR}"
	rm -rf "${TEMP_DIR}"
else
	echo "Not removing temporary directory, suspicious path: \"${TEMP_DIR}\""
fi

echo
echo "Oracle JDK ${SELECTED_VERSION} has been successfuly installed"
echo

exit 0

