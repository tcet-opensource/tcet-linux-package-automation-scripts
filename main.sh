#!/bin/bash

# Importing source file
source update_pkgbuild.sh
source get_pkgbuild.sh
source update_server.sh
source path_origin.sh
source cleanup.sh
source package_build.sh

# Define text formatting variables
bold=$(tput bold)
normal=$(tput sgr0)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
red=$(tput setaf 1)

# Function to display colored output
print_message1() {
    echo "${bold}${blue}$1${normal}"
}

print_message2() {
    echo "${bold}${green}$1${normal}"
}

print_message3() {
    echo "${bold}${yellow}$1${normal}"
}
print_message4(){
    echo "${bold}${red}$1${normal}"
}

# Running perform_cleanup when ctrl+c pressed
trap perform_cleanup SIGINT

# Call the get_pkgbuild function
get_pkgbuild $package_name

# Call the package_build
package_build $package_name
# Call the path_origin function
path_origin

# Choose server repo
print_message1 "Choose which repo you wanna clone and push"
print_message2 "1) tcet-linux-applications"
print_message2 "2) tcet-linux-repo"
print_message2 "3) both"
print_message2 "4) tcet-linux-repo-testing"

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

    4) server="tcet-linux-repo-testing"
       update_server $server
       ;;
    *) print_message3 "Invalid choice"
        perform_cleanup ;;
esac


# Call the update_pkgbuild function
update_pkgbuild

# perform_cleanup at last
#perform_cleanup


