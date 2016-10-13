
# IntelliJ IDEA

ps aux | grep $PPID | grep -q 'IntelliJ IDEA'
export TERMINAL_IN_IDEA=$?

getAbsolutePath () {
    if [ -z "$1" ]; then
        echo "/";
        return 0;
    fi;
    RELATIVE_DIR="$1";
    if [ -f "$1" ]; then
        RELATIVE_DIR="$(dirname "${RELATIVE_DIR}")";
    fi;
    echo "$(cd "${RELATIVE_DIR}"; pwd)";
    return 0
}

# TODO: fix this
getProjectNameInDir () {
    DIR="$(getAbsolutePath "$1")";
    if [ -d "${DIR}/.idea" -a -f "${DIR}/.idea/.name" ]; then
        echo -n "{$(cat "${DIR}/.idea/.name")} ";
        return 0;
    else
        if [ "${DIR}" != "/" ]; then
            getProjectNameInDir "${DIR%/*}";
            return $?;
        else
            return 1;
        fi;
    fi;
    return 1
}

if [ "$(uname)" == "Darwin" ]; then
    idea() {
        open -b com.jetbrains.intellij $@
    }
fi

