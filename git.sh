
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

function git-pull() {
    depth=3
    base_dir=()
    dry=0
    silent=1
    while [ ! -z "$1" ]; do
        cmd="$1"; shift
        case "$cmd" in
            "-h"|"--help"|"-help")
                echo "usage: git-pull [-h] [--dry] [-d depth] [directories]" >&2
                echo "" >&2
                echo " -h | --help               - this help message" >&2
                echo " -v | --verbose            - verbose mode, print git output as well" >&2
                echo " -d depth | --depth depth  - defined the find depth in dirs (default: ${depth})" >&2
                echo " --dry                     - dry run without actual git pull commands" >&2
                echo " directories               - you can specify multiple base directories to scan" >&2
                echo "                             the default directory is the current directory" >&2
                echo "" >&2
                echo "example: git-pull projects/work /git/others -d 5 ../private/projects/git-repos" >&2
                echo "" >&2
                return 127
                ;;
            "--dry")
                dry=1
                echo "== Running dry ==" >&2
                ;;
            "-v"|"--verbose")
                silent=0
                ;;
            "-d"|"--depth")
                if [ -z "$1" ]; then
                    echo "Argument -d (depth) requires parameter" >&2
                    return 1
                fi
                if [[ $1 =~ ^-?[0-9]+$ ]]; then
                    depth=$1
                else
                    echo "Argument -d (depth) requires valid integer (got: ${1})" >&2
                    return 2
                fi
                shift
                ;;
            *)
                base_dir+=("$cmd")
                ;;
        esac
    done
    
    if [ "${#base_dir[@]}" -eq 0 ]; then
        base_dir=("$(pwd)")
    else
        resolved_dirs=()
        for target_dir in "${base_dir[@]}"; do
            if [ -d "$target_dir" ]; then
                resolved_dirs+=("$(cd "$target_dir" && pwd)")
            else
                echo "Not a valid directory: $target_dir" >&1
                return 3
            fi
        done
    fi
    
    git_failures=()
    for target_dir in "${resolved_dirs[@]}"; do
        git_dirs=()
        while IFS=  read -r -d $'\0'; do git_dirs+=("${REPLY%*/.git}"); done < <(find "$target_dir" -maxdepth ${depth} -type d -name '.git' -print0)
        for git_dir in "${git_dirs[@]}"; do
            bullet; echo "pulling directory $git_dir"
            if [ ${dry} -eq 0 ]; then
                if [ ${silent} -eq 1 ]; then
                    (cd "$git_dir" && git pull) >/dev/null 2>/dev/null
                else
                    (cd "$git_dir" && git pull)
                fi
                if [ $? -ne 0 ]; then
                    git_failures+=("$git_dir")
                fi
            else
                bullet; echo " \$(git pull)"
            fi
        done
    done
    
    if [ "${#git_failures[@]}" -gt 0 ]; then
        bullet red; echo "The following git repos could not be pulled:"
        for git_fail_dir in "${git_failures[@]}"; do
            echo " - ${git_fail_dir}"        
        done
    else
        bullet green; echo "All OK"
    fi
    
}
