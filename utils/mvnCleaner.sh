#!/usr/bin/env bash
#
# === List and optionally clean maven project ===
#
# MIT License
# Copyright (c) 2017 Attila Majoros
#
# Source: https://github.com/majk1/shellrc/blob/master/utils/mvnCleaner.sh
#

showall=0
clean=0
scandir=.

function usage() {
    echo
    echo "Usage: mvnCleaner [options] [scan directory]"
    echo
    echo " -h|--help      - this help"
    echo " -a|--all       - show all maven projects (even without target dir)"
    echo " -c|--clean     - remove target directory where no .noautoclean file present"
    echo ""
    echo "If scan directory is not defined, the script will use the current"
    echo "directory. To prevent a project's target diretort to be removed when"
    echo "the clean option is specified, create a .noautoclean file undert the"
    echo "projects directory, next to the pom.xml file."
    echo
    echo "Project directory list headers description:"
    echo "[<has target 1|0> <clean prevented 1|0>] (target dir usage) project dir"
    echo
}

while [ ! -z "$1" ]; do
    case "$1" in
        -a|--all)
            showall=1
            ;;
        -c|--clean)
            clean=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            scandir=$1
            ;;
    esac
    shift
done

if [ ! -z "$1" ]; then
    scandir="$1"
fi

cd "$scandir"
CURDIR="$(pwd)"

echo "Scandir is \"$CURDIR\""

if [ -t 1 ]; then
    COL_DEF="$(tput sgr0)"
    COL_RED="$(tput setaf 9)"
    COL_GRAY="$(tput setaf 8)"
    COL_GREEN="$(tput setaf 2)"
    COL_YELLOW="$(tput setaf 3)"
else
    COL_DEF=""
    COL_RED=""
    COL_GRAY=""
    COL_GREEN=""
    COL_YELLOW=""
fi

total_size=0
cleanable_size=0
cleaned_size=0

for pom in $(find . -type f -name pom.xml); do

    basedir="${pom%/*}"
    absdir="$CURDIR/${basedir#./*}"
    
    has_target=0
    no_auto_clean=0
    
    col=""
    usg="(           )"
    
    if [ -d "$basedir/target" ]; then
        has_target=1
        col="$COL_RED"
        usg_size_k="$(du -sk "$absdir/target" | awk '{print $1}')"
        usg="$(printf "(%8s kB)" "$usg_size_k")"
        
        ((total_size+=usg_size_k))
      
        if [ -f "$basedir/.noautoclean" ]; then
            no_auto_clean=1
            col="$COL_GRAY"
        else
            ((cleanable_size+=usg_size_k))
            if [ $clean -eq 1 ]; then
                rm -rf "$basedir/target" >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    col="$COL_GREEN"
                    ((cleaned_size+=usg_size_k))
                else
                    col="$COL_YELLOW"
                fi
            fi
        fi
    fi
    
    if [ $has_target -eq 1 -o $no_auto_clean -eq 1 -o $showall -eq 1 ]; then
        echo "[$has_target $no_auto_clean] $usg $col$absdir$COL_DEF"
    fi
done

printf "Cleanable size: %'8d kB\n" "$cleanable_size"
printf "  Cleaned size: %'8d kB\n" "$cleaned_size"
printf "    Total size: %'8d kB\n" "$total_size"
