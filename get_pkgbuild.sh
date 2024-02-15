#!/bin/bash

# Function to handle PKGBUILD operations
get_pkgbuild() {
    local package_name
    local package_number
    
    if [ "$ans" == "yes" ]; then
    package_number=$i
    else
    read -p "Enter the number of your choice: " package_number
    fi
    
    # Clone the PKGBUILD repository
    print_message1 "Cloning PKGBUILD repository"
    git clone https://github.com/tcet-opensource/tcet-linux-pkgbuild.git 

    # Prompt the user for a package name
    print_message1 "Enter a directory name to search for: "
    print_message2 "1) calamares-desktop"
    print_message2 "2) calamares-desktop"
    print_message2 "3) tcet-linux-gnome-settings"
    print_message2 "4) tcet-linux-gnome-set-once"
    print_message2 "5) tcet-linux-gnome-wallpaper"
    print_message2 "6) tcet-linux-installer-config"
    print_message2 "7) tcet-linux-keyring"
    print_message2 "8) tcet-linux-lsb-release"
    print_message2 "9) tcet-linux-multilang-compiler"
    print_message2 "10) tcet-linux-neofetch"
    print_message2 "11) tcet-linux-qogir-theme"
    print_message2 "12) tcet-linux-task-manager"
    print_message2 "13) tcet-linux-xfce-set-once"
    print_message2 "14) tcet-linux-xfce-settings"
    print_message2 "15) tcet-linux-xfce-wallpaper"
    print_message2 "16) tcet-linux-welcome"
    print_message2 "17) tk"
    print_message2 "18) update-all-packages"
    print_message3 "Invalid choice"

    


# Prompt the user for a choice
#read -p "Enter the number of your choice: " choice
case $package_number in
    1) package_name="calamares-desktop"
       ;;
    2) package_name="calamares-desktop"
       ;;
    3) package_name="tcet-linux-gnome-settings"
       ;;
    4) package_name="tcet-linux-gnome-set-once"
       ;;
    5) package_name="tcet-linux-gnome-wallpaper"
       ;;
    6) package_name="tcet-linux-installer-config"
       ;;
    7) package_name="tcet-linux-keyring"
       ;;
    8) package_name="tcet-linux-lsb-release"
       ;;
    9) package_name="tcet-linux-multilang-compiler"
       ;;
    10) package_name="tcet-linux-neofetch"
        ;;
    11) package_name="tcet-linux-qogir-theme"
        ;;
    12) package_name="tcet-linux-task-manager"
        ;;
    13) package_name="tcet-linux-xfce-set-once"
        ;;
    14) package_name="tcet-linux-xfce-settings"
        ;;
    15) package_name="tcet-linux-xfce-wallpaper"
        ;;
    16) package_name="tcet-linux-welcome"
        ;;
    17) package_name="tk"
        ;;
    18) package_name="update-all-packages"
        ;;

    *) print_message3 "Invalid choice"
       perform_cleanup ;;
esac



    # Search for the directory within tcet-linux-pkgbuild folder
    pkgbuild_path=$(find tcet-linux-pkgbuild -type d -name "$package_name" -print)

    # Check if the directory was found
    if [ -z "$pkgbuild_path" ]; then
        echo "Directory '$package_name' not found within tcet-linux-pkgbuild folder."
        exit 1
    fi

    # Ask the user for confirmation
    #echo "Found directory: $pkgbuild_path"
    #echo -n "Do you want to navigate to this directory? (y/n): "
    #read user_choice

    # Check user's choice, if user presses on y or enter key it should run
   if [ "$user_choice" = "y" ] || [ "$user_choice" = "" ]; then
        cd "$pkgbuild_path"
        echo "Navigated to: $pkgbuild_path"
    else
        echo "Directory navigation aborted."
        perform_cleanup  # Exit successfully
    fi

    if [ "$package_name" = "calamares-3.2.62" ]; then
        pkgrel=$(grep -oP '^pkgrel=\K\d+' PKGBUILD)
        updatedRel=$((pkgrel + 1))
    
        # Update the PKGBUILD file with the new pkgrel value
        sed -i "s/^pkgrel=$pkgrel/pkgrel=$updatedRel/" PKGBUILD
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

    if [ "$package_name" = "welcome" ]; then
        package_name="tcet-linux-welcome"
    elif [ "$package_name" = "welcome-liveuser" ]; then
        package_name="tcet-linux-welcome"
    else
        echo $package_name
    fi


        export PACKAGE_NAME="$package_name"
        export CURRENT_YEAR="$current_year"
        export CURRENT_MONTH="$current_month"
        export UPDATED_REL="$updatedRel"

}

