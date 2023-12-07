#!/bin/bash

# Function to handle PKGBUILD repository update
update_pkgbuild() {
    # Clean up the PKGBUILD repository
    cd $pkgbuild_path
    print_message2 "Cleaning up PKGBUILD"
    ./cleanup.sh

    # Update the PKGBUILD repository
    print_message1 "Updating PKGBUILD repository"
    git add .
    git remote set-url origin git@github.com:tcet-opensource/tcet-linux-pkgbuild.git

    # Prompt the user for a commit message
    echo -n "${bold}${yellow}Enter commit message:${normal} "
    read commit_message
    git commit -S -m "$commit_message"

    # Attempt to push and check the exit status
    if ! git push; then
        print_message4 "Git push failed."
        perform_cleanup
    fi

    print_message1 "PKGBUILD repository has been updated"
    perform_cleanup
}
