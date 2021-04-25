import os, sys, platform, shutil
#
# By: Brody Rethy
# Website: https://rethy.xyz
#
# Name: rb.py
#
# Summary:
# A script to imitate the Windows recycle bin. I still need to implement some
# features, such as item compression, but I'll work on it in time.
#
# I use the term item to refer to directories, links, and/or files. I believe
# PowerShell uses this blanket term as well, so hopefully it isn't too atypical.
#

def handle_item_exists(item, recycle_dir):
    prefix_num = 0

    new_item = item
    old_item = item

    while (os.path.exists(recycle_dir + "/" + new_item)):
        prefix_num = prefix_num + 1
        new_item = str(prefix_num) + "_" + item

    os.rename(item, new_item)
    item = new_item

    print("Renamed \"" + old_item + "\" to \"" + item + "\"")

    return item

def main():
    items = sys.argv[1:]
    username = os.getlogin()
    recycle_dir = "C:/Users/" + username + "/.Trash"

    if (len(items) < 1): # If arguments given.
        print(":: No item name(s) given")
        print(":: Use --help/-h for help")
        quit(1)
    elif ("--help" in items) or ("-h" in items):
        # No function for this, as I call it once throughout.
        print("rb.py [FILE] [FILE 2] [FILE 3] ...")
        print("List the item/items you want to remove.")
        quit(0)
    else:
        if (os.path.isdir(recycle_dir) == 0): # If recycle_dir doesn't exists
            print("Made recycle bin at \"" + recycle_dir + "\"")
            os.mkdir(recycle_dir)

    # Start main program loop. Loops through all args given, which should I'm
    # assuming are items. They don't need to be, but I'm using it as the
    # variable name none the less.
    for item in items:
        if (os.path.isfile(item)): # FILE
            print("\"" + item + "\" is file")
            if (os.path.getsize(item) == 0): # If empty.
                print("\"" + item + "\" is empty")
                os.remove(item)
                print("Removed \"" + item + "\"")
            else:
                if (os.path.exists(recycle_dir + "/" + item)): # If item exists in recycle bin.
                    print("\"" + item + "\" exists in recycle bin")
                    item = handle_item_exists(item, recycle_dir)

                os.rename(item, recycle_dir + "/" + item)
                print("Moved \"" + item + "\" to \"" + recycle_dir + "\"")
        elif (os.path.isdir(item)): # DIR
            print("\"" + item + "\" is dir")
            if (len(os.listdir(item)) == 0): # If empty.
                print("\"" + item + "\" is empty")
                shutil.rmtree(item)
                print("Removed \"" + item + "\"")
            else:
                if (os.path.exists(recycle_dir + "/" + item)): # If dir exists in recycle bin.
                    print("\"" + item + "\" exists in recycle bin")
                    item = handle_item_exists(item, recycle_dir)

                os.rename(item, recycle_dir + "/" + item)
                print("Moved \"" + item + "\" to \"" + recycle_dir + "\"")
        elif (os.path.islink(item)): # LINK
            print("\"" + item + "\" is link")
            os.unlink(item)
            print("Unlinked link \"" + item + "\"")
        else:
            print(":: \"" + item + "\" does not exist")
            print(":: Use --help/-h for help")

        print("")

    quit(0)

if (platform.system().lower() == "Linux"):
    import readline
main()
