
# Git specific

if [ -z "$SHOW_GIT_BRANCH_PROMPT" ]; then
    export SHOW_GIT_BRANCH_PROMPT=1
fi

function _git_ps1() {
    [ $SHOW_GIT_BRANCH_PROMPT -eq 0 ] && return 1
	_git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
	if [ $? -eq 0 ]; then
		echo -ne " (${_git_branch})"
	else
		echo -ne ""
	fi
}
