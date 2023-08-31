#!/bin/env bash

# Function to handle repository operations
update_server() {
    local server=$1
    # Access the environment variables
    local package_name=$PACKAGE_NAME
    local current_year=$CURRENT_YEAR
    local current_month=$CURRENT_MONTH
    local updatedRel=$UPDATED_REL

    # Clone the repository
    print_message1 "Cloning the $server"
    git clone https://github.com/tcet-opensource/$server.git

    # Set the file names and directory paths
    new_file="${package_name}-${current_year}.${current_month}-${updatedRel}-x86_64.pkg.tar.zst"
    destination="$server/x86_64/"

    # Remove the previous .zst file(s)
    old_files="$destination$package_name-*zst"
    for file in $old_files; do
        if [ -e "$file" ]; then
            rm "$file"
        fi
    done

    # Copy the new file to the destination
    cp "$pkgbuild_path/$new_file" "$destination"

    # Update the repository database
    print_message1 "Updating the repository database"
    cd $server/x86_64/
    ./update_repo.sh

    # Push to server
    print_message1 "Pushing to $server"
    cd ..
    git add .
    git remote set-url origin git@github.com:tcet-opensource/$server.git

    # Prompt the user for a commit message
    echo -n "${bold}${yellow}Enter commit message:${normal} "
    read commit_message
    git commit -S -m "$commit_message"

    # Attempt to push and check the exit status
    if ! git push; then
        echo "Git push failed."
        exit 0
    fi

    # Clean up the repository
    print_message1 "Removing $server"
    cd ..
    rm -rf $server*
}
