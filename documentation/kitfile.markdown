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


## Variables/shorthands

Only the following variables/shorthands can be used in kitfiles, any other
environment variables will **not** be interpolated.

* `$BREW`

    Any occurence of `$BREW` is replaced with the prefix of installed
    version of Homebrew.

* `$HOST`

    Any occurrence of `$HOST` is replaced with the short hostname of the
    computer (output of `hostname -s`). This can be overridden with the
    `-n` flag at runtime.

* `~` / `$HOME`

    `~` and `$HOME` are both expanded to be the home directory of the user
    (eg `/Users/norm`).


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

* alert [_TEXT_]

    Outputs _TEXT_ formatted in magenta, and waits for the user to
    press [Return]. Useful when something needs to be approved
    rather than done automatically.

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

* brew_update

    Runs `brew update`. Helpful to put at the start of a `kitfile` so that
    homebrew update notices are not mixed in with any other output.

* brewfile [_FILE_]

    Runs `brew bundle` with _FILE_. If _FILE_ is not specified, it will
    use "`Brewfile`".

* run _SCRIPT_

    Executes the named _SCRIPT_ (this runs with `source`, so `kitout`
    internal functions are available in the script).

* install _SOURCE_ _DESTINATION_ [_MODE_]

    Copies a file found at _SOURCE_ to _DESTINATION_. If _MODE_ is specified,
    the file has that mode applied (any valid arguments to `chmod`).

* cron_entry _MINUTE_ _HOUR_ _DAYOFMONTH_ _MONTH_ _DAYOFWEEK_ _COMMAND_

    Add an entry to the crontab, creating one if necessary. The arguments are
    described in more detail in the manual: run `man 5 crontab`.

* remind _TEXT_

    Output text now, and then again at the end of the run.
    Useful for showing manual actions needed (eg. allowing an
    application to use Accessibility features) without them being buried
    among the entire output of a run.

* symlink _SOURCE_ _DESTINATION_

    Creates a symbolic link at _DESTINATION_ that points to _SOURCE_.

* assign\_all _APPLICATION_

    Sets _APPLICATION_ to be available on all desktops.

* start _APPLICATION_

    Starts _APPLICATION_ in the background to stop it from stealing focus
    while `kitout` is still running.

* loginitem _APPLICATION_

    Sets _APPLICATION_ to run automatically every time you login.


## Breaking files into smaller components

`kitout` supports using multiple files by interpreting the following
as commands to continue executing another `kitfile`:

* _FILE_

    Any text file is assumed to be another `kitfile` and the commands within
    will be executed. The file does not have to be named `kitfile` or have a
    `.kitfile` extension, but it is recommended.

* _DIRECTORY_

    A directory is treated as though the line was `_DIRECTORY_/kitfile`
    (the directory is assumed to contain a `kitfile`).

Files referred to in `kitfiles` are relative to the kitfile itself. In
a directory containing a `kitfile` and a `Brewfile`, the `kitfile` need
only have the command:

```bash
brewfile
```

to install software, as `Brewfile` is the default name.
