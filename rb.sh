#!/bin/bash
#
# By: Brody Rethy
# Website: https://rethy.xyz
#
# Name: rb.sh
#
# Summary:
# A simple script to imitate the Windows recycle bin on Unix. I still need to
# implement some features, such as compression, but I'll work on it in time.
#

#############
# Variables #
#############

# This can be changed to anything.
recycle_dir="$HOME/.Trash"



#############
# Functions #
#############

display_help() {
    printf "%s [item] [item 2] [item 3] ...\n\n" "$0"
    printf "List the item(s) you want to remove.\n"
}

handle_item_exists() {
    item_prefix=0
    new_item=$item

    while [ -e "$recycle_dir/$new_item" ]; do
        item_prefix=$((item_prefix+1))
        new_item="${item_prefix}_${item}"
    done

    /usr/bin/mv "$item" "$new_item" \
        || /usr/bin/sudo /usr/bin/mv "$item" "$new_item"

    item="$new_item"
}



########
# MAIN #
########

# If not args given, printf and exit.
[ $# -eq 0 ] \
    && { printf ":: No filename(s) given\n"; display_help; exit 1; }

# Else if an arg matches, call display_help.
if [ "$*" = "--help" ] || [ "$*" = "-h" ]; then
    display_help
    exit 0
fi

# If $recycle_dir doesn't exists, create it.
[ ! -d "$recycle_dir" ] \
    && mkdir -p "$recycle_dir"

# Start main program loop. Loops through all args given.
for item in "$@"; do
    # If item exists, continute.
    if [ -e "$item" ]; then
        # If link, remove.
        if [ -L "$item" ]; then
            {
                /usr/bin/rm -rf "$item" \
                && printf "Removed link \"%s\"\n." "$item"
            } || {
                /usr/bin/sudo /usr/bin/rm -rf "$item" \
                && printf "Removed link \"%s\" using sudo.\n" "$item"
            }
        # If item empty, remove.
        elif [ ! -s "$item" ]; then
            {
                /usr/bin/rm -rf "$item" \
                && printf "Removed empty file \"%s\".\n" "$item"
            } || {
                /usr/bin/sudo /usr/bin/rm -rf "$item" \
                && printf "Removed empty file \"%s\" using sudo.\n" "$item"
            }
        else
            # If item exists in recycle bin, rename until no match.
            [ -e "$recycle_dir/$item" ] \
                && handle_item_exists

            # Move file to trash.
            {
                /usr/bin/mv "$item" "$recycle_dir/$item" \
                && printf "Item \"%s\" to \"%s\"\n" "$item" "$recycle_dir"
            } || {
                /usr/bin/sudo /usr/bin/mv "$item" "$recycle_dir/$item" \
                && printf "Item \"%s\" to \"%s\" using sudo\n" "$item" "$recycle_dir"
            }
        fi
    else
        printf ":: Item \"%s\" does not exist.\n" "$item"
        printf "::\n"
        printf ":: Use --help/-h for help.\n"
    fi
done

exit 0
