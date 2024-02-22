#!/bin/bash

# Function to handle PKGBUILD repository update
update_pkgbuild() {
    local package_name=$PACKAGE_NAME
    # Clean up the PKGBUILD repository
    cd tcet-linux-pkgbuild
    #print_message2 "Cleaning up PKGBUILD"
    #./cleanup.sh

    # Update the PKGBUILD repository
    print_message1 "Updating PKGBUILD repository"
    #git checkout 21-test
    git add .
    git remote set-url origin git@github.com:tcet-opensource/tcet-linux-pkgbuild.git

    if [ "$ans" == "all" ]; then
    commit_message="All PKGBUILD Have Been Updated"
    elif [ "$ans" == "few" ]; then
    commit_message="Few PKGBUILD Have Been Updated"
    else
    commit_message="$package_name PKGBUILD Have Been Updated"    
    fi

    # Commit changes
    git commit -S -m "$commit_message"

    # Attempt to push and check the exit status
    if ! git push; then
        print_message4 "Git push failed."
        perform_cleanup
    fi

    print_message1 "PKGBUILD repository has been updated"
}
