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
cd tcet-linux-pkgbuild/apps/tcet-linux-welcome

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
new_file="tcet-linux-welcome-23.08-$updatedRel-x86_64.pkg.tar.zst"
destination="tcet-linux-repo-testing/x86_64/"

# Remove the previous .zst file(s)
old_files="$destination"tcet-linux-welcome-23.08-*-x86_64.pkg.tar.zst
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
git push

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

