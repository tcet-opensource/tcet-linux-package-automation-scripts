#!/bin/bash

# Function to handle repository operations
update_server() {
    local server=$1
    local package_name=$PACKAGE_NAME

    print_message1 "Updating the repository database"
    cd $server/x86_64/
    ./update_repo.sh

    # Push to server
    print_message1 "Pushing to $server"
    cd ..
    git add .
    git remote set-url origin git@github.com:tcet-opensource/$server.git

    # Create commit message

    if [ "$ans" == "yes" ]; then
    commit_message="[PKG-UPD] All Packages Are Updated"
    else
    commit_message="[PKG-UPD] $package_name"    
    fi

    # Commit changes
    git commit -S -m "$commit_message"
    # Attempt to push and check the exit status
    if ! git push; then
        print_message4 "Git push failed."
        perform_cleanup
    fi
    cd ..
}
