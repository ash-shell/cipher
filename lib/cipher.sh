#!/bin/bash

##################################################
# Encrypts a file or directory
#
# @param $1: The file or directory to encrypt
# @param $2: The password
# @param $3: Ash__TRUE to enable logging
#            Ash__FALSE to disable logging
##################################################
Cipher__encrypt() {
    # If it's a file
    if [[ -f "$1" ]]; then
        # Encrypt
        local encrypt_file="$1.enc"
        openssl aes-256-cbc -a -e -salt -in "$1" -out "$encrypt_file" -pass file:<( echo -n "$2" )  > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            if [[ $3 -eq $Ash__TRUE ]]; then Logger__error "Bad encrypt"; fi
            return $Ash__FALSE
        fi
        rm "$1"
        if [[ $3 -eq $Ash__TRUE ]]; then Logger__success "File encrypted at $encrypt_file"; fi

    # Else, it's a directory
    else
        # Zip the folder
        local file=$(echo "$1" | sed 's/\/*$//g')
        local zip_file="$file.tar.gz"
        tar czf "$zip_file" "$file"
        if [[ $? -ne 0 ]]; then
            if [[ $3 -eq $Ash__TRUE ]]; then Logger__error "Bad encrypt"; fi
            return $Ash__FALSE
        fi
        rm -r "$file"

        # Encrypt
        local encrypt_file="$zip_file.enc"
        openssl aes-256-cbc -a -e -salt -in "$zip_file" -out "$encrypt_file" -pass file:<( echo -n "$2" )  > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            if [[ $3 -eq $Ash__TRUE ]]; then Logger__error "Bad encrypt"; fi
            return $Ash__FALSE
        fi
        rm "$zip_file"
        if [[ $3 -eq $Ash__TRUE ]]; then Logger__success "Directory encrypted at $encrypt_file"; fi
    fi
    return $Ash__TRUE
}

##################################################
# Decrypts a file or directory
#
# @param $1: The file or directory to decrypt
# @param $2: The password
# @param $3: Ash__TRUE to enable logging
#            Ash__FALSE to disable logging
##################################################
Cipher__decrypt() {
    # Decrypt
    local out_file="$(echo $1 | sed 's/\.enc$//g')"
    openssl aes-256-cbc -a -d -salt -in "$1" -out "$out_file" -pass file:<( echo -n "$2" )  > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        if [[ -f "$out_file" ]]; then
            rm "$out_file";
        fi
        if [[ $3 -eq $Ash__TRUE ]]; then Logger__error "Bad decrypt"; fi
        return $Ash__FALSE
    fi
    rm "$1"

    # Unzip, if this ends with .tar.gz
    if [[ "$out_file" =~ .*.tar.gz ]]; then
        gunzip -c "$out_file" | tar xopf -
        rm $out_file
        if [[ $3 -eq $Ash__TRUE ]]; then Logger__success "Directory decrypted at $(echo "$out_file" | sed 's/\.tar\.gz$//g')/"; fi
    else
        if [[ $3 -eq $Ash__TRUE ]]; then Logger__success "File decrypted at $out_file"; fi
    fi
    return $Ash__TRUE
}
