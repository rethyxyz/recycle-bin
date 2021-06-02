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

#############
# VARIABLES #
#############

# This can be changed to anything.
RECYCLE_DIR="$HOME/.Trash"



#############
# FUNCTIONS #
#############

display_help() {
    printf "rb.sh [ITEM] [ITEM 2] [ITEM 3] ...\n\n"
    printf "List the item(s) you want to remove.\n"
}

handle_item_exists() {
    ITEM_PREFIX=0
    NEW_ITEM=$ITEM

    while [ -e "$RECYCLE_DIR/$NEW_ITEM" ]; do
        ITEM_PREFIX=$((ITEM_PREFIX+1))
        NEW_ITEM="${ITEM_PREFIX}_${ITEM}"
    done

    /usr/bin/mv "$ITEM" "$NEW_ITEM" || /usr/bin/sudo /usr/bin/mv "$ITEM" "$NEW_ITEM"

    ITEM=$NEW_ITEM
}



########
# MAIN #
########

# If not args given, printf and exit.
if [ $# -eq 0 ]; then
    printf ":: No filename(s) given\n::"
    display_help
    exit 1
# Else if an arg matches, call display_help.
elif [ "$*" = "--help" ] || [ "$*" = "-h" ]; then
    display_help
    exit 0
fi

# If $RECYCLE_DIR doesn't exists, create it.
if [ ! -d "$RECYCLE_DIR" ]; then
    mkdir -p "$RECYCLE_DIR"
fi

# Start main program loop. Loops through all args given.
for ITEM in "$@"; do
    # If item exists, continute.
    if [ -e "$ITEM" ]; then
        # If link, remove.
        if [ -L "$ITEM" ]; then
            {
                /usr/bin/rm -rf "$ITEM" \
                && printf "Removed link \"%s\"\n." "$ITEM"
            } || {
                /usr/bin/sudo /usr/bin/rm -rf "$ITEM" \
                && printf "Removed link \"%s\" using sudo.\n" "$ITEM"
            }
        # If item empty, remove.
        elif [ ! -s "$ITEM" ]; then
            {
                /usr/bin/rm -rf "$ITEM" \
                && printf "Removed empty file \"%s\".\n" "$ITEM"
            } || {
                /usr/bin/sudo /usr/bin/rm -rf "$ITEM" \
                && printf "Removed empty file \"%s\" using sudo.\n" "$ITEM"
            }
        else
            # If item exists in recycle bin, rename until no match.
            if [ -e "$RECYCLE_DIR/$ITEM" ]; then
                handle_item_exists
            fi

            # Move file to trash.
            {
                /usr/bin/mv "$ITEM" "$RECYCLE_DIR/$ITEM" \
                && printf "Item \"%s\" to \"%s\"\n" "$ITEM" "$RECYCLE_DIR"
            } || {
                /usr/bin/sudo /usr/bin/mv "$ITEM" "$RECYCLE_DIR/$ITEM" \
                && printf "Item \"%s\" to \"%s\" using sudo\n" "$ITEM" "$RECYCLE_DIR"
            }
        fi
    else
        printf ":: Item \"%s\" does not exist.\n" "$ITEM"
        printf "::\n"
        printf ":: Use --help/-h for help.\n"
    fi
done

exit 0
