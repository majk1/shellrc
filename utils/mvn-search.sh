#!/usr/bin/env bash
#
# === Maven repository search util ===
#
# MIT License
# Copyright (c) 2016 Attila Majoros
#
# Source: https://github.com/majk1/shellrc/blob/master/utils/mvn-search.sh
#
# Examples:
#

### globals
REPO_URL="https://www.mvnrepository.com"
APP_DEPS=("sed" "tr" "head")
FETCH_WITH="wget"
ONE=0
SKIP_NAME=0

### functions

function check_necessary_deps() {
    declare -a not_found_apps
    for APP in ${APP_DEPS[@]}; do
        if ! type -p "$APP" >/dev/null 2>&1; then
            not_found_apps=(${not_found_apps[@]} ${APP})
        fi
    done
    if [ ${#not_found_apps} -ne 0 ]; then
        echo "Necessary applications not found: ${not_found_apps[@]}" >&2
        exit 1
    fi

    if ! type -p "$FETCH_WITH" >/dev/null 2>&1; then
        FETCH_WITH="curl"
        if ! type -p "$FETCH_WITH" >/dev/null 2>&1; then
            echo "Cannot find wget or curl, cannot continue!" >&2
            exit 2
        fi
    fi
}

function fetch() {
    if [ "$FETCH_WITH" == "wget" ]; then
        wget -q -O- "$@"
    elif [ "$FETCH_WITH" == "curl" ]; then
        curl -s "$@"
    else
        echo "Unknown fetch app: $FETCH_WITH" >&2
        exit 3
    fi
}

# url:name <- fetch_artifact_urls (search_pattern [sort_type])
# sort_type: ("relevance":default, "newest", "popular")
function fetch_artifact_urls() {
    [ -z "$2" ] && sort_type="relevance" || sort_type="$2"
    page="$(fetch "${REPO_URL}/search?q=${1}&sort=${sort_type}")"
    artifact_urls=$(echo "$page" | sed -n '/<div class="im"><a href="\/artifact\//s/.*<div class="im"><a href="\(\/artifact\/[^"]*\)"><picture.*/\1/p')
    for artifact_url in ${artifact_urls}; do
        gid_aid="${artifact_url#/artifact/*}"
        group_id="${gid_aid%/*}"
        artifact_id="${gid_aid#*/}"
        if [ ${SKIP_NAME} -eq 1 ]; then
            echo "${group_id}:${artifact_id}"
        else
            echo -n "${group_id}:${artifact_id}::"
            echo "$page" | sed -n "s/.*span><a href=\"${artifact_url//\//\\/}\">\([^<]*\)<\/a><a class=\"im-usage\" href=\".*/\1/p"
        fi
        [ ${ONE} -eq 1 ] && break
    done
}

# release <- fetch_releases (group_id artifact_id)
function fetch_releases() {
    repo="central"
    if [ "$1" == "-r" ]; then shift; repo="$1"; shift; fi
    group_id="$1"
    artifact_id="$2"
    if [[ ${group_id} =~ .*:.* && -z "$artifact_id" ]]; then
        gid_aid="$group_id"
        group_id="${gid_aid%:*}"
        artifact_id="${gid_aid#*:}"
    fi
    releases="$(fetch "${REPO_URL}/artifact/${group_id}/${artifact_id}?repo=${repo}" | sed 's/vbtn release/#vbtn release/g' | tr '#' '\n' | sed -n "s/vbtn release\">\([^<]*\)<\/a><\/td><td>.*/\1/p")"
    [ ${ONE} -eq 1 ] && echo "$releases" | head -n 1 || echo "$releases"
}

function process_args() {
    if [ $# -lt 2 ]; then
        echo "Usage: mvn-search [options] <command> <param(s)>" >&2
        echo ""
        echo " optoins:"
        echo ""
        echo "           -1       - show only the first result / latest version"
        echo "           -n       - do not show the name of the repository"
        echo ""
        echo " commands:"
        echo "           search   - search for the pattern"
        echo "           version  - list release versions for the given group and artifact id"
        echo ""
        echo " example:"
        echo ""
        echo "           mvn-search -1 v \$(mvn-search -n1 s lombok)"
        echo ""
        exit 1
    fi

    command="$1"; shift
    case "$command" in
        "s"|"search"|"f"|"find")
            fetch_artifact_urls "$@"
            ;;
        "v"|"ver"|"vers"|"version"|"versions"|"r"|"rel"|"release"|"releases")
            fetch_releases "$@"
            ;;
        default)
            echo "Unkown command $command"
            ;;
    esac
}

### main app
while [[ "$1" =~ -.* ]]; do
    flags=${1:1}; shift
    for (( i=0; i<${#flags}; i++ )); do
        flag="${flags:$i:1}"
        case "$flag" in
            "1")
                ONE=1;
                ;;
            "n")
                SKIP_NAME=1;
                ;;
            *)
                echo "Unkown flag: $flag" >&2
                ;;
        esac
    done  
done
check_necessary_deps
process_args $@
