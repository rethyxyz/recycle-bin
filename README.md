# recycl-bin
A Windows like "recycle bin". Runs as an improved version of rm.

## How it works
It's just a `Bash` script. It runs the same as `rm`, but doesn't take any flags.  After it's "removed", it's placed into the .Trash/files directory.

## Basic usage
- `recycle-bin.sh $FILE1 $FILE2 $FILE3 ...`

You may want to create an alias for `rm` to `recycle-bin.sh`.
