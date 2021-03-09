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
# TODO: Implement -h arg to prompt usage aid
#

# Check if there are args given
if [ $# -eq 0 ]
then
	echo ":: No filename(s) given"; exit 1
fi

FILES=( "$@" )

# check if ~/.Trash/files doesn't exists
if [ ! -d $TRASH_DIR ]
then
	mkdir -p "$TRASH_DIR"
fi

# Start main program loop
#
# The for loops loops through all args given,
# which should I'm assuming are files.
for FILE in "${FILES[@]}"
do
	# Check if symlink
	#
	# Remove file if link
	if [ -L "$FILE" ]
	then
		/usr/bin/rm "$FILE" && echo "Removed symlink $FILE" || echo ":: Failed to remove symlink $FILE"
	   	exit 1
	fi

	# Check if file given exists
	if [ ! -e "$FILE" ]
	then
		echo ":: File given does not exist"; exit 1
	fi

	FILE_NUM=0
	TRASH_DIR="$HOME/.Trash/files/"

	# Check age of first file/dir in Trash dir
	# if older than 30 days, remove
	# TODO

	# check size of file in megabytes
	SIZE=$(du -h -s -m "$FILE" | awk '{print $1}')

	# This is somewhat of a hack job
	if [ $SIZE -ge 20000 ]
	then
		echo ":: File is $SIZE, over 20GB, and is too large for the recycle bin"
		echo "Do you still want to remove it (this is permanent)? (y/n)"

		while true
		do
			read CHOICE

			case "$CHOICE" in
				y)
					/usr/bin/rm -rf "$FILE" || /usr/bin/sudo /usr/bin/rm -rf "$FILE" 
					exit 1
					;;
				n)
					echo ":: Exit, file not removed"
					exit 0
					;;
				*) echo ":: Choice not recognized, try again"
			esac
		done
	fi

	# Check if file/dir already exists in .Trash/files dir
	#
	# I know that there is an option built into mv
	# to prompt if I want to override, but I think this is safer,
	# as you can't accidentally accept to overriding important files.
	NEW_FILE=$FILE

	while true
	do
		if [ -e "$TRASH_DIR/$NEW_FILE" ]
		then
			FILE_NUM=$((FILE_NUM+1))
			NEW_FILE="${FILE_NUM}_${FILE}"
		else
			{
			mv "$FILE" "$NEW_FILE"
			FILE=$NEW_FILE
			} > /dev/null 2>&1 && echo "Renamed file to $FILE"

			break
		fi
	done

	#TODO: Check if file needs root

	# Move file to ~/.Trash/files
	#
	# TODO: Change stdout to something better
	mv -iv "$FILE" $TRASH_DIR > /dev/null 2>&1 && echo "$FILE to $TRASH_DIR" || echo ":: Failed to move $FILE to $TRASH_DIR"
done

# A successful exit, if it gets here
exit 0
