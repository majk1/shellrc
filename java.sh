
# JAVA

if [[ "$(uname)" = "Darwin" ]]; then
    function java_home() {
        base_path="$(find /Library/Java/JavaVirtualMachines -maxdepth 1 -name "adoptopenjdk-${1}*" | sort | tail -n 1)"
        if [[ -z "$base_path" ]]; then
            base_path="$(find /Library/Java/JavaVirtualMachines -maxdepth 1 -name "jdk-${1}*" | sort | tail -n 1)"
        fi
        if [[ -z "$base_path" ]]; then
        	base_path="$(find /Library/Java/JavaVirtualMachines -maxdepth 1 -name "openjdk-${1}*" | sort | tail -n 1)"
        fi
        if [[ -z "$base_path" ]]; then
			base_path="$(find /Library/Java/JavaVirtualMachines -maxdepth 1 -name "openjdk.jdk" | sort | tail -n 1)"
		fi
        if [[ -d "$base_path" ]]; then
            echo "${base_path}/Contents/Home"
        else
            echo ""
        fi
    }
    
    function graalvm_home() {
        base_path="$(find /Library/Java/JavaVirtualMachines -maxdepth 1 -name "graalvm-ce-${1}*" | sort | tail -n 1)"
        if [[ -z "$base_path" ]]; then
            base_path="$(find /Library/Java/JavaVirtualMachines -maxdepth 1 -name "graalvm-*-${1}*" | sort | tail -n 1)"
        fi
        if [[ -d "$base_path" ]]; then
            echo "${base_path}/Contents/Home"
        else
            echo ""
        fi
    }
        
    export JAVA_7_HOME=$(/usr/libexec/java_home -v1.7 2>/dev/null)
    export JAVA_8_HOME=$(java_home 8 2>/dev/null)
    export JAVA_9_HOME=$(java_home 9 2>/dev/null)
    export JAVA_11_HOME=$(java_home 11 2>/dev/null)
    export JAVA_16_HOME=$(java_home 16 2>/dev/null)
    export JAVA_17_HOME=$(java_home 17 2>/dev/null)
    export JAVA_18_HOME=$(java_home 18 2>/dev/null)
    export GRAALVM_19_HOME=$(graalvm_home 19 2>/dev/null)
    export GRAALVM_21_HOME=$(graalvm_home 21 2>/dev/null)
    export GRAALVM_22_HOME=$(graalvm_home 22 2>/dev/null)

    if [[ -z "$JAVA_HOME" ]]; then
        export JAVA_HOME=${JAVA_17_HOME}
    fi

    alias java7='export JAVA_HOME=${JAVA_7_HOME}'
    alias java8='export JAVA_HOME=${JAVA_8_HOME}'
    alias java9='export JAVA_HOME=${JAVA_9_HOME}'
    alias java11='export JAVA_HOME=${JAVA_11_HOME}'
    alias java16='export JAVA_HOME=${JAVA_16_HOME}'
    alias java17='export JAVA_HOME=${JAVA_17_HOME}'
    alias java18='export JAVA_HOME=${JAVA_18_HOME}'

    function graalvm19() {
        export JAVA_HOME=${GRAALVM_19_HOME}
        export PATH=${GRAALVM_19_HOME}/bin:$PATH
    }

    function graalvm21() {
        export JAVA_HOME=${GRAALVM_21_HOME}
        export PATH=${GRAALVM_21_HOME}/bin:$PATH
    }

    function graalvm22() {
        export JAVA_HOME=${GRAALVM_22_HOME}
        export PATH=${GRAALVM_22_HOME}/bin:$PATH
    }
    
    alias java_list='/usr/libexec/java_home -V'
fi

export JAVA_OPTS="-Djavax.servlet.request.encoding=UTF-8 -Dfile.encoding=UTF-8"

jvisualvm-jboss() {
    JBOSS_HOME="$1"
    shift
    
    if [[ ! -d "$JBOSS_HOME" ]]; then
        echo "Usage: jvisualvm-jboss <JBOSS HOME> [optional arguments to pass to jvisualvm]" >&2
    else
        jvisualvm --cp:a "${JBOSS_HOME}/bin/client/jboss-cli-client.jar" -J-Dmodule.path="${JBOSS_HOME}/modules/" "$@" 
    fi
}

wildfly-pid() {
    NODENAME="$1"
    if [[ -z "$NODENAME" ]]; then
        ps ax | awk '/-D\[Server|-D\[Standalone/ {pid=$1; name=$6; if (index(name, "Standalone")) { name="Standalone" } else { split(name, arr, ":"); name=substr(arr[2], 0, length(arr[2])-1) }; print pid " " name}'
    elif [[ "$NODENAME" == "-h" ]]; then
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
