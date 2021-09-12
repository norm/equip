#!/usr/bin/env bash

export HOME=$BATS_TEST_TMPDIR
teardown

bold=$'\e'[1m
magenta=$'\e'[35m
reset=$'\e'[0m


@test test_http_cloning {
    [ ! -d /tmp/static ]
    [ ! -d $HOME/Code/norm/static ]

    run ./kitout.sh tests/repos.url.kitfile
    echo "$output"

    [ -d /tmp/static ]
    [ -d $HOME/Code/norm/static ]
}

@test test_ssh_cloning {
    [ ! -d /tmp/static ]
    [ ! -d $HOME/Code/norm/static ]

    run ./kitout.sh tests/repos.ssh.kitfile
    echo "$output"

    [ -d /tmp/static ]
    [ -d $HOME/Code/norm/static ]
}

@test test_shortcut_cloning {
    [ ! -d /tmp/static ]
    [ ! -d $HOME/Code/norm/static ]

    run ./kitout.sh tests/repos.shortcut.kitfile
    echo "$output"

    [ -d /tmp/static ]
    [ -d $HOME/Code/norm/static ]
}

@test test_broken_cloning {
    [ ! -d /tmp/static ]

    run ./kitout.sh tests/repos.broken.kitfile
    [ "${lines[0]}" == "${bold}${magenta}*** Unknown repository format: kronk:norm/static${reset}" ]

    [ ! -d /tmp/static ]
}

@test test_nonexistent_repo_cloning {
    [ ! -d $HOME/Code/norm/nopeynopey ]
    [ ! -d /tmp/static ]

    run ./kitout.sh tests/repos.nonexistent.kitfile

    [ ! -d $HOME/Code/norm/nopeynopey ]
    [ -d /tmp/static ]
}

@test test_repodir_cloning {
    [ ! -d /tmp/repos ]
    [ ! -d $HOME/Code/norm/static ]

    run ./kitout.sh tests/repos.repodir.kitfile

    [ -d /tmp/repos/norm/static ]
    [ -d $HOME/Code/norm/static ]
}

@test test_repo_update_no_changes {
    run git clone git@github.com:norm/static.git /tmp/static
    echo "$output"
    [ $status -eq 0 ]

    run ./kitout.sh tests/repos.update.kitfile
    run git -C /tmp/static status -bs
    echo "$output"
    [ $status -eq 0 ]
    [ "${lines[0]}" == "## main...origin/main" ]
}

@test test_repo_update_different_branch {
    run git clone git@github.com:norm/static.git /tmp/static
    echo "$output"
    [ $status -eq 0 ]

    run git -C /tmp/static checkout patch
    echo "$output"
    [ $status -eq 0 ]

    run ./kitout.sh tests/repos.update.kitfile
    run git -C /tmp/static status -bs
    echo "$output"
    [ $status -eq 0 ]
    [ "${lines[0]}" == "## patch...origin/patch" ]
}

@test test_repo_update_clean_pull {
    run git clone git@github.com:norm/static.git /tmp/static
    echo "$output"
    [ $status -eq 0 ]

    run git -C /tmp/static reset --hard HEAD~2
    echo "$output"
    [ $status -eq 0 ]

    run git -C /tmp/static status -bs
    echo "$output"
    [ $status -eq 0 ]
    [ "${lines[0]}" == "## main...origin/main [behind 2]" ]

    run ./kitout.sh tests/repos.update.kitfile
    echo "$output"
    [ "${lines[2]}" == "Fast-forward" ]

    run git -C /tmp/static status -bs
    echo "$output"
    [ $status -eq 0 ]
    [ "${lines[0]}" == "## main...origin/main" ]
}

@test test_repo_update_dirty {
    run git clone git@github.com:norm/static.git /tmp/static
    echo "$output"
    [ $status -eq 0 ]

    run git -C /tmp/static reset --hard HEAD~2
    echo "$output"
    [ $status -eq 0 ]

    run git -C /tmp/static status -bs
    echo "$output"
    [ $status -eq 0 ]
    [ "${lines[0]}" == "## main...origin/main [behind 2]" ]

    echo "oh no" > /tmp/static/README.md
    git -C /tmp/static commit -a -m'oh no'

    run ./kitout.sh tests/repos.update.kitfile
    echo "$output"
    [ $status -eq 0 ]
    [ "${lines[1]}" == "    Not updating; local commits." ]

    run git -C /tmp/static status -bs
    echo "$output"
    [ "${lines[0]}" == "## main...origin/main [ahead 1, behind 2]" ]
}

function teardown {
    rm -rf /tmp/static /tmp/repos $HOME/Code/norm/static
}
