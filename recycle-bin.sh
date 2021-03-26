#!/bin/bash
#
#	By: Brody Rethy
#	Website: https://rethy.xyz
#
#	Name: rethyxyz_recycle_bin.sh
#	Version: 1.0
#
#	Summary:
#	A script to imitate the Windows recycle bin.
#   I still need to implement some features, such
#	as file compression, but I'll work on it in time.
#

##
## TODO Implement -h arg to prompt usage aid
## TODO function for remove file
## TODO function for move file to trash
## TODO Check age of first file/dir in Trash dir. if older than 30 days, remove.
##

remove_file() {
	{ /usr/bin/rm -rf "$FILE" > /dev/null 2>&1 && echo "Removed file $FILE" ; } || { /usr/bin/rm -rf "$FILE" > /dev/null 2>&1 && echo "Removed file $FILE using sudo" ; }
}

move_to_trash_bin() {
	{ mv -iv "$FILE" "$TRASH_DIR" > /dev/null 2>&1 && echo "$FILE to $TRASH_DIR"; } || { /usr/bin/sudo mv -iv "$FILE" "$TRASH_DIR" > /dev/null 2>&1 && echo "$FILE to $TRASH_DIR using sudo"; }
}

handle_large_file() {
	echo "$FILE size is $FILE_SIZE, over 20GB, and too large for the recycle bin"
	echo "Do you still want to remove it (this is permanent)? (y/n)"

	while true
	do
		read CHOICE

		case "$CHOICE" in
			y | Y) { /usr/bin/rm -rf "$FILE" > /dev/null 2>&1 && echo "Removed $FILE of size $FILE_SIZE"; } || { /usr/bin/sudo /usr/bin/rm -rf "$FILE" > /dev/null 2>&1 && echo "Removed $FILE of size $FILE_SIZE using sudo"; } ;;
			n | N) echo "Exit, file not removed." ;;
			*) echo ":: Choice not recognized, try again"
		esac
	done
}

handle_file_exists() {
	FILE_NUM=0
	NEW_FILE=$FILE

	while [[ -e "$TRASH_DIR/$NEW_FILE" ]]
	do
		FILE_NUM=$((FILE_NUM+1))
		NEW_FILE="${FILE_NUM}_${FILE}"
	done

	mv "$FILE" "$NEW_FILE" > /dev/null 2>&1 || /usr/bin/sudo mv "$FILE" "$NEW_FILE" > /dev/null 2>&1

	FILE=$NEW_FILE
}

TRASH_DIR="$HOME/.Trash/files/"

# IF ARGS GIVEN
if [[ $# -eq 0 ]]
then
	echo ":: No filename(s) given"; exit 1
fi

FILES=( "$@" )

# IF $TRASH_DIR ! EXISTS
if [[ ! -d "$TRASH_DIR" ]]
then
	mkdir -p "$TRASH_DIR"
fi

# Start main program loop
#
# The for loops loops through all args given, which should I'm assuming are
# files.
for FILE in "${FILES[@]}"
do
	# CHECK IF FILE EXISTS
	if [[ -e "$FILE" ]]
	then
		# CHECK IF LINK || EMPTY
		if [[ -L "$FILE" ]] || [[ ! -s "$FILE" ]]
		then
			remove_file
		else
			# GET FILE SIZE
			FILE_SIZE=$(du -h -s -m "$FILE" | awk '{print $1}')

			# CHECK IF OVER 20GB
			if [[ -e "$TRASH_DIR/$NEW_FILE" ]]
			then
				handle_file_exists
			fi

			if [[ $FILE_SIZE -ge 20000 ]]
			then
				handle_large_file
			else
				move_to_trash_bin
			fi
		fi
	else
		echo ":: File given does not exist"
	fi
done

exit 0
