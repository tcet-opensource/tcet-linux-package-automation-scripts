# Bash Script for Package Management

This Bash script simplifies package management tasks, including updating PKGBUILDs, upadting server repo, and more.

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/tcet-opensource/tcet-linux-automation-scripts.git
   cd tcet-linux-automation-scripts

Make sure your function scripts (update_pkgbuild.sh, get_pkgbuild.sh, update_server.sh) are located in the same directory as the main script main_script.sh.

2. Make the main script executable:

   ```bash
   chmod +x main.sh

3. Run the script:

   ```bash
   ./main.sh

## Function Scripts

The following function scripts are located in the same directory as the main script:

* `get_pkgbuild.sh`: This script updates a single PKGBUILD file. It prompts you to select the PKGBUILD file to update, then updates the `pkgver` and `pkgrel` values and runs `makepkg`.
* `update_server.sh`: This script handles repository operations. It clones a specified repository, copies the new package to the repository, updates the repository database, and pushes the changes to the remote repository.
* `update_pkgbuild.sh`: This script provides the update_pkgbuild function to update a PKGBUILD repository, including cleanup, changes addition, commit, push, and success confirmation.
  
## Note

* Make sure to update the repository URLs within the scripts to match your actual repository URLs.
* Ensure that you have necessary permissions to push changes to your repositories.

