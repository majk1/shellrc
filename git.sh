
# Git specific

function _git_ps1() {
	_git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
	if [ $? -eq 0 ]; then
		echo -ne " (${_git_branch})"
	else
		echo -ne ""
	fi
}
