
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
