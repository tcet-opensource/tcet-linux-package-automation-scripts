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

# Clone the PKGBUILD repository
print_message1 "Cloning PKGBUILD repository"
git clone -b 2-testing https://github.com/tcet-opensource/tcet-linux-pkgbuild.git 


# Prompt the user for a directory name to search for
echo -n "Enter a directory name to search for: "
read directory_name

# Search for the directory within tcet-linux-pkgbuild folder
directory_path=$(find tcet-linux-pkgbuild -type d -name "$directory_name" -print)

# Check if the directory was found
if [ -z "$directory_path" ]; then
    echo "Directory '$directory_name' not found within tcet-linux-pkgbuild folder."
    exit 1
fi

# Ask the user for confirmation
echo "Found directory: $directory_path"
echo -n "Do you want to navigate to this directory? (y/n): "
read user_choice

# Check user's choice
if [ "$user_choice" = "y" ]; then
    cd "$directory_path"
    echo "Navigated to: $directory_path"
else
    echo "Directory navigation aborted."
    echo 0
fi



# Calculate current year and month
current_year=$(date +'%y')
current_month=$(date +'%m')

# Update the PKGBUILD file with the new pkgver value
sed -i "s/^pkgver=.*/pkgver=$current_year.$current_month/" PKGBUILD

# Read the current pkgrel value from PKGBUILD
pkgrel=$(grep -oP '^pkgrel=\K\d+' PKGBUILD)

# Increment the pkgrel value
updatedRel=$((pkgrel + 1))

# Update the PKGBUILD file with the new pkgrel value
sed -i "s/^pkgrel=$pkgrel/pkgrel=$updatedRel/" PKGBUILD
print_message1 "Updated PKGBUILD:"
cat PKGBUILD

print_message1 "Running makepkg"
makepkg -s

# Clone the testing repository
print_message1 "Cloning the testing repository"
git clone https://github.com/tcet-opensource/tcet-linux-repo-testing.git

# Set the file names and directory paths
new_file="$directory_name-$current_year.$current_month-$updatedRel-x86_64.pkg.tar.zst"
destination="tcet-linux-repo-testing/x86_64/"

# Remove the previous .zst file(s)
old_files="$destination"$directory_name-*zst
for file in $old_files; do
    if [ -e "$file" ]; then
        rm "$file"
    fi
done

# Copy the new file to the destination
cp "$new_file" "$destination"

# Update the repository database
print_message1 "Updating the repository database"
cd tcet-linux-repo-testing/x86_64/
./update_repo.sh


# Push to tcet-linux-repo-testing
print_message1 "Pushing to tcet-linux-repo-testing"
cd ..
git add .
git remote set-url origin git@github.com:tcet-opensource/tcet-linux-repo-testing.git

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
print_message1 "Removing tcet-linux-repo"
cd ..
rm -rf tcet-linux-repo-testing*

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
git push

print_message1 "PKGBUILD repository has been updated"

