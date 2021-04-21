#!/bin/bash
#
# By: Brody Rethy
# Website: https://rethy.xyz
#
# Name: rb.sh
#
# Summary:
# A script to imitate the Windows recycle bin. I still need
# to implement some features, such as file compression, but
# I'll work on it in time.

display_help() {
	echo "rb.sh [FILE] [FILE 2] [FILE 3] ..."
	echo ""
	echo "List the file/files or directory/directories you want to remove."
}

file_remove() {
	{ /usr/bin/rm -rf "$FILE" && echo "$TEXT"; } || { /usr/bin/sudo /usr/bin/rm -rf "$FILE" && echo "$TEXT" using sudo; }
}

file_to_trash() {
	/usr/bin/mv "$FILE" "$RECYCLE_DIR/$FILE" && echo "$FILE to $RECYCLE_DIR"
}

handle_file_exists() {
	FILE_NUM=0
	NEW_FILE=$FILE

	while [[ -e "$RECYCLE_DIR/$NEW_FILE" ]]
	do
		FILE_NUM=$((FILE_NUM+1))
		NEW_FILE="${FILE_NUM}_${FILE}"
	done

	/usr/bin/mv "$FILE" "$NEW_FILE" || /usr/bin/sudo /usr/bin/mv "$FILE" "$NEW_FILE"

	FILE=$NEW_FILE
}

RECYCLE_DIR="$HOME/.Trash"

# IF ARGS GIVEN
if [[ $# -eq 0 ]]
then
	echo ":: No filename(s) given"
	echo "::"
	echo ":: Use --help/-h for help"
	exit 1
elif [[ $@ = "--help" ]] || [[ $@ = "-h" ]]
then
	display_help
	exit 0
fi

FILES=( "$@" )

# IF $RECYCLE_DIR ! EXISTS
if [[ ! -d "$RECYCLE_DIR" ]]
then
	mkdir -p "$RECYCLE_DIR"
fi

# Start main program loop
#
# Loops through all args given, which should I'm assuming are files. They don't
# need to be, but I'm using it as the variable name none the less.
for FILE in "${FILES[@]}"
do
	# CHECK IF FILE EXISTS
	if [[ -e "$FILE" ]]
	then
		# IF $LINK
		if [[ -L "$FILE" ]]
		then
			TEXT="Removed link $FILE"; file_remove $TEXT
		# IF empty
		elif [[ ! -s "$FILE" ]]
		then
			TEXT="Removed empty file $FILE"; file_remove $TEXT
		else
			# CHECK IF FILE EXISTS IN RECYCLE BIN
			if [[ -e "$RECYCLE_DIR/$FILE" ]]
			then
				handle_file_exists
			fi

			file_to_trash
		fi
	else
		echo ":: File given does not exist"
		echo "::"
		echo ":: Use --help/-h for help"
	fi
done

exit 0
