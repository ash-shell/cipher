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

    # Encrypt the file
    Cipher__encrypt "$1" "$password" "$Ash__TRUE"
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
    Cipher__decrypt "$1" "$password" "$Ash__TRUE"
}
