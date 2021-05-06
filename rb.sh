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

ITEMS=("$@")
RECYCLE_DIR="$HOME/.Trash"

display_help() {
    echo "rb.sh [ITEM] [ITEM 2] [ITEM 3] ..."
    echo ""
    echo "List the item(s) you want to remove."
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

# If not args given, echo and exit.
if [ $# -eq 0 ]; then echo -e ":: No filename(s) given\n::"; display_help; exit 1
# Else if an arg matches, call display_help.
elif [ "$*" = "--help" ] || [ "$*" = "-h" ]; then display_help; exit 0; fi

# If $RECYCLE_DIR doesn't exists, create it.
if [ ! -d "$RECYCLE_DIR" ]; then mkdir -p "$RECYCLE_DIR"; fi

# Start main program loop. Loops through all args given.
for ITEM in "${ITEMS[@]}"; do
    # If item exists, continute.
    if [ -e "$ITEM" ]; then
        # If link, remove.
        if [ -L "$ITEM" ]; then
            { /usr/bin/rm -rf "$ITEM" && echo "Removed link \"$ITEM\"."; } || { /usr/bin/sudo /usr/bin/rm -rf "$ITEM" && echo "Removed link \"$ITEM\" using sudo."; }
        # Else if item empty, remove.
        elif [ ! -s "$ITEM" ]; then
            TEXT="Removed empty file $ITEM"
            { /usr/bin/rm -rf "$ITEM" && echo "$TEXT"; } || { /usr/bin/sudo /usr/bin/rm -rf "$ITEM" && echo "$TEXT" using sudo; }
        else
            # If item exists in recycle bin, rename until no match.
            if [ -e "$RECYCLE_DIR/$ITEM" ]; then handle_item_exists; fi
            # Move file to trash
            /usr/bin/mv "$ITEM" "$RECYCLE_DIR/$ITEM" && echo "Item \"$ITEM\" to \"$RECYCLE_DIR\"" || echo "Failed to move "
        fi
    else
        echo ":: Item \"$ITEM\" does not exist."
        echo "::"
        echo ":: Use --help/-h for help."
    fi
done

exit 0
