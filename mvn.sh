
# MAVEN

export MAVEN_OPTS="$JAVA_OPTS -noverify -Xmx2048m -XX:MaxPermSize=256m -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

alias mvnAllNoTest='mvn clean install -DskipTests'
alias mvnAllNoIT='mvn clean install -DskipITs'
alias mvnAllNoTestNoIT='mvn clean install -DskipTests -DskitITs -Dmaven.test.skip=true'
alias mvnAll='mvn clean install'
alias mvnRemoteDebug='MAVEN_OPTS="$MAVEN_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005 -Xnoagent -Djava.compiler=NONE" mvn'

if [ "$(uname)" = "Darwin" ]; then
    launchctl setenv M2_HOME $M2_HOME
    launchctl setenv MAVEN_OPTS $MAVEN_OPTS
fi

# functions

# $1 = plugin name in format: "groupId:artifactId"
mvn_get_plugin_description() {
    mvn help:describe -Dplugin=$1 2>/dev/null | grep -v '^\[[IWE]'
}

# $1 = plugin description
mvn_get_plugin_prefix() {
    echo "$1" | sed -n '/^Goal Prefix: /s/^Goal Prefix: \(.*\)/\1/p'
}

# $1 = prefix (optional)
# $2 = plugin description
mvn_get_plugin_goals() {
    local prefix
    local description
    if [ $# -eq 1 ]; then
        prefix=$(mvn_get_plugin_prefix "$1")
        description="$1"
    else
        prefix=$1
        description="$2"
    fi

    echo "$description" | sed -n "/^${prefix}:/s/^${prefix}:\(.*\)/\1/p"
}
