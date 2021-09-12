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

* debug [...]

    Outputs the arguments formatted as indented and in cyan text.

* echo [...]

    Outputs the arguments.
