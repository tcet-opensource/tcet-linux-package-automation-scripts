#!/bin/env bash

git clone -b 2-testing https://github.com/tcet-opensource/tcet-linux-pkgbuild.git 
cd tcet-linux-pkgbuild/apps/tcet-linux-welcome

# Read the current pkgrel value from PKGBUILD
pkgrel=$(grep -oP '^pkgrel=\K\d+' PKGBUILD)

# Increment the pkgrel value
updatedRel=$((pkgrel + 1))

# Update the PKGBUILD file with the new pkgrel value
sed -i "s/^pkgrel=$pkgrel/pkgrel=$updatedRel/" PKGBUILD
echo PKGBUILD
echo "pkgbuild started"
makepkg -s

echo "cloning the repo"
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


echo "updating database"
cd tcet-linux-repo-testing/x86_64/
./update_repo.sh

echo "pushing to tcet-linux-repo-testing"
cd ..
git add .
git remote set-url origin git@github.com:tcet-opensource/tcet-linux-repo-testing.git
git commit -S -m "User input"
git push

echo "removing tcet-linux-repo"
cd ..
rm -rf tcet-linux-repo-testing*

echo "pkgbuild cleanup started"
./cleanup.sh

echo "updating pkgbuild repo"
git add .
git remote set-url origin git@github.com:tcet-opensource/tcet-linux-pkgbuild.git
git commit -S -m "User input"
git push


echo "pkgbuild has been updated"
