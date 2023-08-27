#!/bin/env bash

# Define text formatting variables
bold=$(tput bold)
normal=$(tput sgr0)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)

# Function to display colored output
print_message1() {
    echo "${bold}${blue}$1${normal}"
}

print_message2() {
    echo "${bold}${green}$1${normal}"
}



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

    print_message1 "Updated PKGBUILD:"
    cat PKGBUILD
    
    print_message1 "Running makepkg"
    makepkg -s

    export PACKAGE_NAME="$package_name"
    export CURRENT_YEAR="$current_year"
    export CURRENT_MONTH="$current_month"
    export UPDATED_REL="$updatedRel"
}

# Call the get_pkgbuild
get_pkgbuild $package_name




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
    cp "$new_file" "$destination"

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




# Choose server repo
print_message2 "Choose which repo you wanna clone and push"
print_message1 "1) tcet-linux-applications"
print_message1 "2) tcet-linux-repo"
print_message1 "3) both"

# Prompt the user for a choice
read -p "Enter the number of your choice: " choice

# Map choices to http
case $choice in
    1) server="tcet-linux-applications" 
       update_server $server
       ;;
    2) server="tcet-linux-repo" 
       update_server $server
       ;;
    3) 
        server="tcet-linux-applications"
        update_server $server
        server="tcet-linux-repo"
        update_server $server
        ;;
    *) echo "Invalid choice"
       exit 0 ;;
esac




# Function to handle PKGBUILD repository update
update_pkgbuild() {
    # Clean up the PKGBUILD repository
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
        echo "Git push failed."
        exit 0
    fi

    print_message1 "PKGBUILD repository has been updated"
}

# Call the function
update_pkgbuild


