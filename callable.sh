#!/bin/bash

#################################################
# This is an alias for the help callable function
#################################################
Cipher__callable_main() {
    Cipher__callable_help
}

##################################################
# Displays relavant information on how to use
# this module
##################################################
Cipher__callable_help() {
    more "$Ash__ACTIVE_MODULE_DIRECTORY/HELP.txt"
}

##################################################
# This is an alias for the encrypt callable function
##################################################
Cipher__callable_e() {
    Cipher__callable_encrypt "$@"
}

##################################################
# This function encrypts a single file with
# the aes-256-cbc cipher algorithm
#
# @param $1: The file to encrypt
##################################################
Cipher__callable_encrypt() {
    # Check if file is passed
    if [[ "$1" = "" ]]; then
        Logger__error "No file passed"
        return 1
    fi

    # Make sure it's a file or directory
    if [[ ! -f "$1" && ! -d "$1" ]]; then
        Logger__error "'$1' is not a file or directory"
        return 1
    fi

    # Get password
    local password=""
    Logger__prompt "Enter encryption password: "; read -s password; echo
    if [[ "$password" = "" ]]; then
        Logger__error "Password must be non-empty"
        return 1
    fi
    Logger__prompt "Confirm encryption password: "; read -s cpassword; echo
    if [[ "$cpassword" != "$password" ]]; then
        Logger__error "Passwords do not match"
        return 1
    fi

    # If it's a file
    if [[ -f "$1" ]]; then
        # Encrypt
        local encrypt_file="$1.enc"
        openssl aes-256-cbc -a -e -salt -in "$1" -out "$encrypt_file" -pass file:<( echo -n "$password" )  > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            Logger__error "Bad encrypt"
            return 1
        fi
        rm "$1"
        Logger__success "File encrypted at $encrypt_file"

    # Else, it's a directory
    else
        # Zip the folder
        local file=$(echo "$1" | sed 's/\/*$//g')
        local zip_file="$file.tar.gz"
        tar czf "$zip_file" "$file"
        if [[ $? -ne 0 ]]; then
            Logger__error "Bad encrypt"
            return 1
        fi
        rm -r "$file"

        # Encrypt
        local encrypt_file="$zip_file.enc"
        openssl aes-256-cbc -a -e -salt -in "$zip_file" -out "$encrypt_file" -pass file:<( echo -n "$password" )  > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            Logger__error "Bad encrypt"
            return 1
        fi
        rm "$zip_file"
        Logger__success "Directory encrypted at $encrypt_file"
    fi
}

##################################################
# This is an alias for the decrypt callable function
##################################################
Cipher__callable_d() {
    Cipher__callable_decrypt "$@"
}

##################################################
# This function decrypts a single file that has
# been encrypted with the aes-256-cbc cipher
# algorithm
#
# @param $1: The file to decrypt
##################################################
Cipher__callable_decrypt() {
    # Check if file is passed
    if [[ "$1" = "" ]]; then
        Logger__error "No file passed"
        return 1
    fi

    # Make sure it's a file
    if [[ ! -f "$1" ]]; then
        Logger__error "'$1' is not a file"
        return 1
    fi

    # Get password
    local password=""
    Logger__prompt "Enter decryption password: "; read -s password; echo
    if [[ "$password" = "" ]]; then
        Logger__error "Password must be non-empty"
        return 1
    fi

    # Decrypt
    local out_file="$(echo $1 | sed 's/\.enc$//g')"
    openssl aes-256-cbc -a -d -salt -in "$1" -out "$out_file" -pass file:<( echo -n "$password" )  > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        if [[ -f "$out_file" ]]; then
            rm "$out_file";
        fi
        Logger__error "Bad decrypt"
        return 1
    fi
    rm "$1"

    # Unzip, if this ends with .tar.gz
    if [[ "$out_file" =~ .*.tar.gz ]]; then
        gunzip -c "$out_file" | tar xopf -
        rm $out_file
        Logger__success "Directory decrypted at $(echo "$out_file" | sed 's/\.tar\.gz$//g')/"
    else
        Logger__success "File decrypted at $out_file"
    fi
}
