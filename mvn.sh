
# MAVEN

export MAVEN_OPTS="$JAVA_OPTS -noverify -Xmx2048m -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

alias mvn-all-no-test='mvn clean install -DskipTests'
alias mvn-all-no-it='mvn clean install -DskipITs'
alias mvn-all-no-test-no-it='mvn clean install -DskipTests -DskitITs -Dmaven.test.skip=true'
alias mvn-all='mvn clean install'
alias mvn-remote-debug='MAVEN_OPTS="$MAVEN_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005 -Xnoagent -Djava.compiler=NONE" mvn'

alias mvn-cleaner="${SCRIPT_BASE_DIR}/utils/mvn-cleaner.sh"
alias mvn-search="${SCRIPT_BASE_DIR}/utils/mvn-search.sh"

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
