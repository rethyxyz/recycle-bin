# rb
A Windows like "recycle bin", and safer alternative to `rm`.

## What it does
It's a simple `Bash` script. It runs the same as `rm`, but doesn't take any flags. After "removal", it's placed into the ~/.Trash directory.

## Basic usage
- `rb.sh [FILE] [FILE 2] [FILE 3] ...`

List the file/files or directory/directories you want to remove. You may want to create an alias in place of `rm` that points to `rb.sh`.
