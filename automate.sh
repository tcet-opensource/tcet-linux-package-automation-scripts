#!/bin/env bash

# Clone the PKGBUILD repository
git clone -b 2-testing https://github.com/tcet-opensource/tcet-linux-pkgbuild.git 
cd tcet-linux-pkgbuild/apps/tcet-linux-welcome

# Read the current pkgrel value from PKGBUILD
pkgrel=$(grep -oP '^pkgrel=\K\d+' PKGBUILD)

# Increment the pkgrel value
updatedRel=$((pkgrel + 1))

# Update the PKGBUILD file with the new pkgrel value
sed -i "s/^pkgrel=$pkgrel/pkgrel=$updatedRel/" PKGBUILD
echo "Updated PKGBUILD:"
cat PKGBUILD

echo "pkgbuild started"
makepkg -s

# Clone the testing repository
echo "Cloning the testing repository"
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
echo "Updating the repository database"
cd tcet-linux-repo-testing/x86_64/
./update_repo.sh


# Push to tcet-linux-repo-testing
echo "Pushing to tcet-linux-repo-testing"
cd ..
git add .
git remote set-url origin git@github.com:tcet-opensource/tcet-linux-repo-testing.git

# Prompt the user for a commit message
echo -n "Enter commit message: "
read commit_message
git commit -S -m "$commit_message"
git push

# Clean up the repository
echo "Removing tcet-linux-repo"
cd ..
rm -rf tcet-linux-repo-testing*

# Clean up the PKGBUILD repository
echo "Cleaning up PKGBUILD"
./cleanup.sh

# Update the PKGBUILD repository
echo "Updating PKGBUILD repository"
git add .
git remote set-url origin git@github.com:tcet-opensource/tcet-linux-pkgbuild.git
# Prompt the user for a commit message
echo -n "Enter commit message: "
read commit_message
git commit -S -m "$commit_message"
git push

echo "PKGBUILD repository has been updated"

