
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
