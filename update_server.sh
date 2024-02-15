#!/bin/bash

# Function to handle repository operations
update_server() {
    local server=$1
    local package_name=$PACKAGE_NAME
    # Access the environment variables
    local zst_file=$ZST_FILE
    local sig_file=$SIG_FILE

    # Clone the repository
    print_message1 "Cloning the $server"
    git clone https://github.com/tcet-opensource/$server.git

    print_message4 $zst_file
    print_message4 $sig_file


    destination="$server/x86_64/"

    # Remove the previous .zst file(s)
    old_zst_files="$destination$package_name-*zst"
    for file in $old_zst_files; do
        if [ -e "$file" ]; then
            rm "$file"
        fi
    done

    old_sig_files="$destination$package_name-*zst.sig"
    for file in $old_sig_files; do
        if [ -e "$file" ]; then
            rm "$file"
        fi
    done


    # Copy the new file to the destination
    cp $pkgbuild_path/$zst_file $destination
    cp $pkgbuild_path/$sig_file $destination


    # Update the repository database
    print_message1 "Updating the repository database"
    cd $server/x86_64/
    ./update_repo.sh

    # Push to server
    print_message1 "Pushing to $server"
    cd ..
    git add .
    git remote set-url origin git@github.com:tcet-opensource/$server.git

    # Create commit message
    commit_message="[PKG-UPD] $package_name"

    # Commit changes
    git commit -S -m "$commit_message"
    # Attempt to push and check the exit status
    if ! git push; then
        print_message4 "Git push failed."
        perform_cleanup
    fi
    cd ..
}
