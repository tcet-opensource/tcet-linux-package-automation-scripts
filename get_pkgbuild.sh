#!/bin/env bash

# Function to handle PKGBUILD operations
get_pkgbuild() {
    local package_name=$1

    # Clone the PKGBUILD repository
    print_message1 "Cloning PKGBUILD repository"
    git clone https://github.com/tcet-opensource/tcet-linux-pkgbuild.git 

    # Prompt the user for a directory name to search for
    echo -n "Enter a directory name to search for: "
    read package_name

    # Search for the directory within tcet-linux-pkgbuild folder
    pkgbuild_path=$(find tcet-linux-pkgbuild -type d -name "$package_name" -print)

    # Check if the directory was found
    if [ -z "$pkgbuild_path" ]; then
        echo "Directory '$package_name' not found within tcet-linux-pkgbuild folder."
        exit 1
    fi

    # Ask the user for confirmation
    echo "Found directory: $pkgbuild_path"
    echo -n "Do you want to navigate to this directory? (y/n): "
    read user_choice

    # Check user's choice
    if [ "$user_choice" = "y" ]; then
        cd "$pkgbuild_path"
        echo "Navigated to: $pkgbuild_path"
    else
        echo "Directory navigation aborted."
        exit 0  # Exit successfully
    fi

    if [ "$package_name" = "calamares-3.2.62" ]; then
        print_message3 "No need to update pkgbuild"
    else

        # Read the current pkgver value from PKGBUILD
        current_pkgver=$(grep -oP '^pkgver=\K\d+\.\d+' PKGBUILD)
        previous_year=$(echo "$current_pkgver" | cut -d'.' -f1)
        previous_month=$(echo "$current_pkgver" | cut -d'.' -f2)
    
        # Calculate current year and month
        current_year=$(date +'%y')
        current_month=$(date +'%m')
    
        # Update the PKGBUILD file with the new pkgver value
        new_pkgver="$current_year.$current_month"
        sed -i "s/^pkgver=.*/pkgver=$new_pkgver/" PKGBUILD
    
        # Reset pkgrel to 1 if pkgver year or month is updated
        if [ "$current_year" != "$previous_year" ] || [ "$current_month" != "$previous_month" ]; then
            sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD
            pkgrel=$(grep -oP '^pkgrel=\K\d+' PKGBUILD)
            updatedRel=$((pkgrel))
        else
            pkgrel=$(grep -oP '^pkgrel=\K\d+' PKGBUILD)
            updatedRel=$((pkgrel + 1))
    
            # Update the PKGBUILD file with the new pkgrel value
            sed -i "s/^pkgrel=$pkgrel/pkgrel=$updatedRel/" PKGBUILD
        fi
    fi

    print_message1 "Updated PKGBUILD:"
    cat PKGBUILD
    
    print_message1 "Running makepkg"
    makepkg -s

    export PACKAGE_NAME="$package_name"
    export CURRENT_YEAR="$current_year"
    export CURRENT_MONTH="$current_month"
    export UPDATED_REL="$updatedRel"
}

