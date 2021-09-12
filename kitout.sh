#!/usr/bin/env -S bash -euo pipefail

VERSION=0.2
DEBUG=0
DEFAULT_REPO_DIR="${HOME}/Code"
REPO_DIR="${REPO_DIR:=$DEFAULT_REPO_DIR}"

# ANSI sequences
bold="\e[1m"
cyan="\e[36m"
yellow="\e[33m"
magenta="\e[35m"
reset="\e[0m"

errors_occured=0


function main {
    while getopts "dhrv" option; do
        case $option in
            d)      DEBUG=1 ;;
            r)      REPO_DIR="$OPTARG" ;;
            v)      show_version ;;
            ?|h)    usage ;;
        esac
    done
    shift $(( OPTIND-1 ))

    [ -z "${1:-}" ] && usage 1
    [ "${1}" = 'help' ] && usage
    [ "${1}" = 'version' ] && show_version

    for argument in "$@"; do
        process_kitfile "$argument"
    done

    [ $errors_occured -gt 0 ] && exit 1
    exit 0
}

function usage {
    cat << EOF | sed -e 's/^        //'
        Usage:

        kitout [-h|help]
            show this usage information

        kitout -v|version
            show the version number

        kitout [-d] [-r DIR] kitfile [kitfile ...]
            runs commands listed in the kitfile(s)

            -d  turn on debugging
            -r  set DIR as directory for repositories to be cloned to;
                defaults to $HOME/Code

        Suitfiles are documented on GitHub:
        https://github.com/norm/kitout/blob/v${VERSION}/documentation/kitfile.markdown
EOF
    exit "${1:-0}"
}

function show_version {
    echo kitout version $VERSION
    exit 0
}

function debug {
    [ $DEBUG -eq 1 ] \
        && debug_output "$*" \
        || true
}

function debug_output { printf "${cyan}    ${*}${reset}\n" >&2; }
function output       { printf "    ${*}\n" >&2; }
function action       { printf "${yellow}=== ${1}${reset}\n" >&2; }
function silent_pushd { pushd "$1" >/dev/null; }
function silent_popd  { popd >/dev/null; }
function error {
    printf "${bold}${magenta}*** ${1}${reset}\n" >&2
    let "errors_occured = errors_occured + 1"
}

function process_kitfile {
    while read command argument; do
        case "$command" in
            \#|'')  : ;;
            echo)       output "$argument" ;;
            debug)      debug_output "$argument" ;;

            repodir)    set_repodir "$argument" ;;
            clone)      clone_repository $argument ;;

            *)      error "Unknown command: '$command'" ;;
        esac
    done < <(cat "$1")
}

function set_repodir {
    [ -z "$1" ] \
        && REPO_DIR="$DEFAULT_REPO_DIR" \
        || REPO_DIR="$1"
    debug repodir set to $REPO_DIR
}

function clone_repository {
    local branch remote repo state user
    local source="$1"
    local destination="${2:-}"

    if [ "${source::4}" = 'http' ]; then
        if [ "${source::19}" = 'https://github.com/' ]; then
            repo="${source:19:${#1}}"
            repo="${repo%.*}"
            user="${repo%/*}/"
            repo="${repo#${user}}/"
        fi
    elif [ "${source::4}" = 'git@' ]; then
        if [ "${source::15}" = 'git@github.com:' ]; then
            repo="${source:15:${#1}}"
            repo="${repo%.*}"
            user="${repo%/*}/"
            repo="${repo#${user}}/"
        fi
    elif [ "${source::7}" = 'github:' ]; then
        repo="${source:7:${#1}}"
        source="git@github.com:${repo}.git"
        user="${repo%/*}/"
        repo="${repo#${user}}/"
    fi

    if [ -z "${repo:-}" ]; then
        error "Unknown repository format: $1"
        return
    fi

    debug found repo has user=$user repo=$repo

    [ -z "$destination" ] && destination="${REPO_DIR}/${user}${repo}"
    if [ ! -d "$destination" ]; then
        action "clone '$source' to $destination"

        mkdir -p "$destination"
        git clone "$source" "$destination" \
            || rmdir "$destination"
    else
        action "updating repo at $destination"

        silent_pushd "$destination"
        if [ -d .git ]; then
            # FIXME multiple remotes
            remote=$(git remote show)
            branch=$(
                git remote show $remote \
                    | grep HEAD \
                    | sed -e 's/^.*: //'
            )

            debug existing repo, remote $remote, default branch $branch
            git fetch $remote

            if [ "$(git rev-parse --abbrev-ref HEAD)" == $branch ]; then
                state=$( git status --porcelain --branch | head -1 )
                if [ -n "$(echo "$state" | grep ahead)" ]; then
                    output "Not updating; local commits."
                elif [ -n "$(echo "$state" | grep behind)" ]; then
                    git pull --ff-only \
                        || true
                fi
            else
                output "Not updating; not on $branch."
            fi
        else
            output "Not updating; not a git repository."
        fi
        silent_popd
    fi
}

main "$@"
