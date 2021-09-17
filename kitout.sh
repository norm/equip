#!/usr/bin/env -S bash -euo pipefail

VERSION=0.5
DEBUG=0
DEFAULT_REPO_DIR="${HOME}/Code"

REPO_DIR="${REPO_DIR:=$DEFAULT_REPO_DIR}"
HOST="${HOST:=$(hostname -s)}"

# ANSI sequences
bold="\e[1m"
cyan="\e[36m"
yellow="\e[33m"
green="\e[32m"
magenta="\e[35m"
reset="\e[0m"

errors_occured=0
remind_file=$( mktemp '/tmp/kitout.remind.XXXXX' )


function main {
    while getopts "dhnrv" option; do
        case $option in
            d)      DEBUG=1 ;;
            n)      HOST=$OPTARG ;;
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
        if [ -f "$argument" ]; then
            process_kitfile "$argument"
        elif [ -d "$argument" ]; then
            process_directory "$argument"
        else
            error "Kitfile does not exist: $argument"
        fi
    done

    if [ "$(stat -f'%z' $remind_file)" -gt 0 ]; then
        section "REMINDERS"
        cat $remind_file
    fi

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

        kitout [-d] [-r DIR] [-n NAME] kitfile [kitfile ...]
            runs commands listed in the kitfile(s)

            -d  turn on debugging
            -n  set the value of \$HOST to NAME
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
function section      { printf "\n${green}%s${reset}\n" "$(epad "$1")" >&2; }
function silent_pushd { pushd "$1" >/dev/null; }
function silent_popd  { popd >/dev/null; }

function alert {
    printf "${magenta}!!! ${1}${reset}\n" >&2
    output Press [Return] to continue.
    read
}

function error {
    printf "${bold}${magenta}*** ${1}${reset}\n" >&2
    let "errors_occured = errors_occured + 1"
}

function epad {
    local length pad_by

    if [ -n "$1" ]; then
        length=$(( ${#1} + 5 ))
        pad_by=$(( 79 - $length ))
        [ $pad_by -lt 3 ] && pad_by=3
        printf '=== %s %s\n' "$1" $( eval printf '=%.0s' {1..$pad_by} )
    else
        eval printf '=%.0s' {1..79}
    fi
}

function process_kitfile {
    local kitfile="$(get_full_path "$1")"
    silent_pushd "$(dirname "$kitfile")"

    # cache the kitfile in memory, rather than relying on streaming
    # from disk; in some cases (brew bundle...) that gets interrupted
    local -a lines
    while IFS= read -r line; do
        lines+=("$line")
    done < "$kitfile"

    for line in "${lines[@]}"; do
        line=$(
            echo "$line" \
                | sed -e "s:\$HOST:$HOST:g" \
                      -e "s:\$HOME:$HOME:g" \
                      -e "s:~:$HOME:g"
        )
        read command argument <<<"$line"
        case "$command" in
            \#*|'')     : ;;
            echo)       output "$argument" ;;
            debug)      debug_output "$argument" ;;
            section)    section "$argument" ;;
            alert)      alert "$argument" ;;

            repodir)    set_repodir "$argument" ;;
            clone)      clone_repository $argument ;;
            brewfile)   brewfile "$argument" ;;
            install)    install_file $argument ;;
            symlink)    symlink $argument ;;
            start)      start "$argument" ;;
            remind)     remind "$argument" ;;
            assign_all) assign_all $argument ;;
            run)        run_script $argument ;;
            brew_update)    brew_update ;;

            cron_entry) add_to_crontab "$argument" ;;

            *)  if [ -d $command ]; then
                    process_directory $command
                elif [ -f $command ]; then
                    process_kitfile $command
                else
                    error "Unknown command: '$command'"
                fi
                ;;
        esac
    done

    silent_popd
}

function get_full_path {
    local path="$1"
    silent_pushd "$(dirname $path)"
    echo "$(pwd)"/"$(basename "$path")"
    silent_popd
}

function process_directory {
    process_kitfile "$1/kitfile"
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

function brewfile {
    local file="${1:-Brewfile}"

    if [ -f "$file" ]; then
        action "installing from $file"
        HOMEBREW_NO_COLOR=1 brew bundle --file "$file"
    else
        error "brewfile '$file' does not exist"
    fi
}

function install_file {
    local target="$1"
    local dest="$2"

    action "copying '$target' to '$dest'"
    if [ ! -f "$target" ]; then
        error "'$target' does not exist"
    else
        if [ -e "$dest" -a ! -f "$dest" ]; then
            error "'$dest' exists and is not a file"
        else
            mkdir -p "$(dirname "$dest")"
            install "$target" "$dest"

            if [ -n "${3:-}" ]; then
                chmod "$3" "$dest"
            fi
        fi
    fi
}

function symlink {
    local source="$1"
    local target="$2"

    action "symbolic linking '$target' to '$source'"
    if [ -e "$target" -a ! -L "$target" ]; then
        error "cannot create symlink: '$target' already exists"
    else
        rm -f "$target"
        ln -s "$source" "$target"
    fi
}

function start {
    action "starting '$*'"
    open -g -a "$*"
}

function run_script {
    action "execute script '$1'"
    source "$1"
}

function assign_all {
    action "assigning '$*' to all Desktops"
    osascript << EOF >/dev/null
        tell application "System Events"
            tell UI element "$*" of list 1 of process "Dock"
                perform action "AXShowMenu"
                click menu item "Options" of menu 1
                click menu item "All Desktops" of menu 1 of menu item "Options" of menu 1
            end tell
        end tell
EOF
}

function brew_update {
    action 'updating homebrew'
    brew update
}

function add_to_crontab {
    local line="$*"
    local tab="$(mktemp '/tmp/kitout.crontab.XXXXX')"
    local email search

    if ! crontab -l > "$tab" 2>/dev/null; then
        email=$( git config user.email )
        [ -z "$email" ] && email='crontab@example.com'

        cat << EOF | sed -e 's/^ *//' > "$tab"
            MAILTO=$email
            PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

            #mn   hr    dom   mon   dow   cmd
EOF
        action 'initialising crontab'
    fi

    search=$(
        echo "$line" \
            | sed -e 's/\*/\\*/g' -e 's/  */ */g'
    )
    debug "crontab search='$search'"

    if ! grep -q "$search" "$tab"; then
        echo "$line" >> "$tab"
        action "added '$line' to crontab"
        crontab "$tab"
    fi
}

function remind {
    output "$*"
    echo "$*" >> $remind_file
}

main "$@"
