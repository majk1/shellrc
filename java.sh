
# JAVA

if [ "$(uname)" = "Darwin" ]; then
    function java_home() {
        base_path="$(find /Library/Java/JavaVirtualMachines -type d -maxdepth 1 -name "jdk-${1}*" | sort | tail -n 1)"
        echo "${base_path}/Contents/Home"
    }
    
    export JAVA_7_HOME=$(/usr/libexec/java_home -v1.7 2>/dev/null)
    export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8 2>/dev/null)
    export JAVA_9_HOME=$(java_home 9 2>/dev/null)
    export JAVA_10_HOME=$(java_home 10 2>/dev/null)

    if [ -z "$JAVA_HOME" ]; then
        export JAVA_HOME=${JAVA_10_HOME}
    fi

    alias java7='export JAVA_HOME=${JAVA_7_HOME}'
    alias java8='export JAVA_HOME=${JAVA_8_HOME}'
    alias java9='export JAVA_HOME=${JAVA_9_HOME}'
    alias java10='export JAVA_HOME=${JAVA_10_HOME}'
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
        ps ax | awk '/-D\[Server|-D\[Standalone/ {pid=$1; name=$6; if (index(name, "Standalone")) { name="Standalone" } else { split(name, arr, ":"); name=substr(arr[2], 0, length(arr[2])-1) }; print pid " " name}'
    elif [ "$NODENAME" == "-h" ]; then
        cat <<-EOF >&2
		Usage: wildfly-pid [jboss.node.name]
		if node name is not defined, then every wildfly node will be listed in format:
		<pid> <node name>
		EOF
	else
		ps ax | awk "/-D\[Server:${NODENAME}/ {pid=\$1; name=\$6; split(name, arr, \":\"); name=substr(arr[2], 0, length(arr[2])-1); print pid \" \" name}"
	fi        
}

alias jmemstat="${SCRIPT_BASE_DIR}/utils/jmemstat.sh"
