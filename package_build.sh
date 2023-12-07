#!/bin/bash

#function to build package and it's signature package

package_build(){
    local package_name=$PACKAGE_NAME
    local current_year=$CURRENT_YEAR
    local current_month=$CURRENT_MONTH
    local updatedRel=$UPDATED_REL
    
    # Makepkg
    print_message1 "Running makepkg"
    if ! makepkg -s; then
        print_message3 "makepkg encountered an error."
        perform_cleanup
    fi
    
    # Set the file names and directory paths
    zst_file=$package_name-$current_year.$current_month-$updatedRel-x86_64.pkg.tar.zst

    # Check if the zst_file exists, otherwise, use the alternative pattern
    if [ ! -e "$zst_file" ]; then
        zst_file=$package_name-*-x86_64.pkg.tar.zst
    fi


    # Sign package 
    # List of GPG keys
    gpg_keys=("280178FA27665D44-Akash6222" "421FFABA41F36DA5-Rishabh672003" "02F660CD5FA77EBB-0xAtharv" "BF4E1E687DD0A534-harshau007")

    print_message1 "Choose a GPG key:"
    for ((i=0; i<${#gpg_keys[@]}; i++)); do
      echo "$((i+1)). ${gpg_keys[i]}"
    done

    read -p "Enter the number of your choice: " gpg_key_choice

    if [[ ! "$gpg_key_choice" =~ ^[1-${#gpg_keys[@]}]$ ]]; then
      print_message3 "Invalid choice. Aborting."
      perform_cleanup
    fi

    selected_gpg_key=$(echo "${gpg_keys[gpg_key_choice-1]}" | cut -d'-' -f1)
    print_message1 "Selected GPG key: $selected_gpg_key"

    gpgkey() {
      gpg --output "$1.sig" \
          --default-key "$selected_gpg_key" \
          --detach-sign \
          --sign "$1"
    }

    if ! gpgkey "$zst_file"; then
      print_message3 "sig packages creation encountered an error."
      perform_cleanup
    fi

    
    # Set the file names and directory paths
    sig_file=$zst_file.sig

    # Check if the sig_file exists, otherwise, use the alternative pattern
    if [ ! -e "$sig_file" ]; then
        sig_file=$package_name-*-x86_64.pkg.tar.zst.sig
    fi

    
    export ZST_FILE="$zst_file"
    export SIG_FILE="$sig_file"

}
