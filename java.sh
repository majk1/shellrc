
# JAVA

if [ "$(uname)" = "Darwin" ]; then
    export JAVA_7_HOME=$(/usr/libexec/java_home -v1.7 2>/dev/null)
    export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8 2>/dev/null)
    export JAVA_9_HOME=$(/usr/libexec/java_home -v1.9 2>/dev/null)

    if [ -z "$JAVA_HOME" ]; then
        export JAVA_HOME=${JAVA_8_HOME}
    fi

    alias java7='export JAVA_HOME=${JAVA_7_HOME}'
    alias java8='export JAVA_HOME=${JAVA_8_HOME}'
    alias java9='export JAVA_HOME=${JAVA_9_HOME}'
fi

export JAVA_OPTS="-Djavax.servlet.request.encoding=UTF-8 -Dfile.encoding=UTF-8"

jvisualvm-jboss() {
    JBOSS_HOME="$1"
    shift
    
    if [ ! -d "$JBOSS_HOME" ]; then
        echo "Usage: jvisualvm-jboss <JBOSS HOME> [optional arguments to pass to jvisualvm]" >&2
    else
        jvisualvm --cp:a "${JBOSS_HOME}/bin/client/jboss-cli-client.jar" -J-Dmodule.path="${JBOSS_HOME}/modules/" "$@" 
    fi
}

wildfly-pid() {
	NODENAME="$1"
	if [ -z "$NODENAME" ]; then
		ps ax | sed -n "/java.*-D\[[S]erver:/s/\([0-9{2,}]\)\ .*Server:\([^]]*\)\].*/\1 \2/p"
	elif [ "$NODENAME" == "-h" ]; then
		echo -e "Usage: wildfly-pid [jboss.node.name]\n" >&2
		echo "if node name is not defined, then every wildfly node will be listed in format:" >&2
		echo -e "<pid> <node name>\n" >&2
	else
		ps ax | sed -n "/java.*-D\[[S]erver:/s/\([0-9{2,}]\)\ .*Server:${1}\].*/\1/p"
	fi
}

alias jmemstat="${SCRIPT_BASE_DIR}/utils/jmemstat.sh"
