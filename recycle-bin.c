//
// if you're seeing this file, ignore it, as it is incomplete, 
// and a shitshow thus far. As of right now, I'm recreating 
// my recycle bin script in C.
//

#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/stat.h>

void handle_file_exists(char *file) { return; }
void move_to_trash_bin(char *file) { return; }

long long int check_file_size(char *file) {
	printf("IM HERE\n");
	struct stat stats; // Find out what the hell this does

	stat(file, &stats);

	// Check file size
	if (stats.st_size || stats.st_size == 0) {
		int file_size = stats.st_size;
		printf("%i\n", file_size);

		printf("Returning file_size\n");
		return file_size;
	}
	else {
		printf("Returning -1\n");
		return -1;
	}
}

bool check_file_symlink(char *file) {
	struct stat stats; // Find out what the hell this does

	lstat(file, &stats);

	// Check for file existence
	if (stats.st_mode & F_OK)
		return true;

	return false;
}

bool check_file_exists(char *file) {
    // Exists
    if (access(file, F_OK) == 0)
	{
        return true;
    }

    // Doesn't exist
    return false;
}


int main(int argc, char *argv[]) {
	int i;
    char *trash_directory = "/home/brody/Trash/";

    if (argc < 1) {
        printf(":: No filename(s) given\n");
        return 1;
    }

	// If trash_directory doesn't exist
    if (check_file_exists(trash_directory) == true) {
        mkdir(trash_directory, 0755);
        printf("Made directory %s\n", trash_directory);
    }

	// Start at one to skip first index (filename)
	for (i = 1; i < argc; i++) {
		char *file = argv[i];

		if (check_file_exists(file)) {
			long long int file_size = check_file_size(file);

			if (check_file_symlink(file) || file_size < 1) {
				remove(file);
			}
			else {
				if (check_file_exists(file)) {
				}

				if (file_size > 20000000000) {
					handle_file_exists(file);
				}
				else {
					move_to_trash_bin(file);
				}
			}
		}
		else {
			printf(":: Filename given doesn't exist\n");
		}
	}

	return 0;
}
