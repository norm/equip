The kitfile
===========

## Syntax

A "kitfile" is a configuration file to tell `kitout` what to do. The basic
syntax is:

```bash
# comments (lines that begin with a hash) and blank lines are ignored

echo Hello world.
debug Debug output is formatted and coloured.

    echo Commands can be indented.
```

Any line starting with a hash (`#`) is ignored.

Any other line is in the format `command arguments...`. The first word is the
command, everything that follows are the (optional) arguments for that
command.


## Commands

Available commands are:

* debug [_TEXT_]

    Outputs _TEXT_ formatted as indented and in cyan. No _TEXT_ gives
    a blank line.

* echo [_TEXT_]

    Outputs _TEXT_ formatted as indented. No _TEXT_ gives a blank line.

* section [_TEXT_]

    Outputs _TEXT_ formatted in green, surrounded by equals signs, to the
    width of the terminal. No _TEXT_ gives a line of equals signs in green.

* clone _REPOSITORY_ [_DESTINATION_]

    ```bash
    clone https://github.com/norm/kitout /tmp/kitout
    clone git@github.com:norm/kitout.git
    clone github:norm/kitout
    ```

    Performs a `git clone` action on _REPOSITORY_. This can be in one of
    three formats: an HTTP location, an ssh location, and a shorthand
    format of specifying a `git@github.com` location.

    If _DESTINATION_ is not specified, it will be cloned by default to
    $HOME/Code/_user_/_repo_/, so using the examples above to
    $HOME/Code/norm/kitout.

    If the repository has already been cloned, kitout will attempt to update
    it to the latest code, but only if it is on the default branch and there
    are no local changes.

    The default directory can be changed with the `-r` flag at runtime,
    or by adding a `repodir` command to a kitfile before any clone commands.

* repodir [_DIRECTORY_]

    ```bash
    repodir /opt/code
    repodir
    ```

    Sets the default directory for `clone` commands to _DIRECTORY_;
    if _DIRECTORY_ is not specified, the original value of
    $HOME/Code is restored.
