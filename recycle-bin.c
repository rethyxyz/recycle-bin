//
// Currently incomplete as of now.
//

#include <stdio.h>
#include <dirent.h>
#include <errno.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/stat.h>

// bool check_file_symlink(char *file) {
	// struct stat stats; // Find out what the hell this does
// 
	// stat(file, &stats);
// 
	// Check for file existence
	// if (stats.st_mode & F_OK)
		// return true;
// 
	// return false;
// }

void handle_file_exists(char *file) { return; }
void handle_file_large(char *file) { return; }

// TODO This function needs error checking
void move_file_or_dir(char *file, char *newfile) {
	rename(file, newfile);
	printf("Moved file from %s to %s\n", file, newfile);
}

void display_help() {
	printf("Usage: rb [FILE(s)]\n");
	printf("Move (populated) file to ~/Trash/ (recycle bin).\n");
}

long long int check_file_size(char *file) {
	// TODO Find out what the hell this does
	struct stat stats;

	stat(file, &stats);

	// Check file size
	if (stats.st_size || stats.st_size == 0) {
		int file_size = stats.st_size;

		printf("File %s of size %i bytes\n", file, file_size);
		return file_size;
	}

	return -1;
}

bool check_file_exists(char *file) {
	FILE *file_pointer = fopen(file, "r");

    if (file_pointer != NULL) {
		fclose(file_pointer);
        return true; // EXISTS
	}

	return false; // DOES NOT EXISTS
}

bool check_dir_exists(char *dir) {
	DIR *dir_pointer = opendir(dir);

	if (dir_pointer) {
		closedir(dir_pointer);
		return true;
	}
	else if (ENOENT == errno) {
		return false;
	}
	else {
		return false;
	}
}

int main(int argc, char *argv[]) {
	// Add checks for dirs, and shortcuts (just add an || to every if statement)
	unsigned int i;
    char *trash_directory = "C:/Users/brody/Trash/";

    if (argc <= 1) {
        printf(":: No filename(s) given\n");
        return 1;
    }

	if (strcmp(argv[1], "-h") == 0) {
		display_help();
		return 0;
	}

	// If trash_directory doesn't exist
    if (! check_dir_exists(trash_directory)) {
        mkdir(trash_directory);
        printf("Made directory %s\n", trash_directory);
    }

	// Start at one to skip first index (filename)
	for (i = 1; i < argc; i++) {
		char *file = argv[i];

		if (check_file_exists(file) || check_dir_exists(file)) {
			char *file_trash = (char *) malloc(1 + strlen(trash_directory) + strlen(file));
			strcpy(file_trash, trash_directory);
			strcat(file_trash, file);

			if (check_file_exists(file_trash)) {
				handle_file_exists(file);
			}

			move_file_or_dir(file, file_trash);
		} else {
			printf(":: Filename given doesn't exist\n");
		}
	}

	return 0;
}
