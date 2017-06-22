#!/bin/bash

##################################################
# Tests that a file can be encrypted, and
# unencrypted properly
##################################################
Cipher__test_file_encryption() {
    local file="$(Obj_generate_uuid).txt"
    local secret="Some super secret"
    local password="some-secure-password"

    # Write to file
    echo "$secret" > "$file"
    if [[ "$(cat "$file")" != "$secret" ]]; then
        echo "Unable to write to file, cannot to run tests"
        echo "Make sure user $(whoami) has permissions to write to $(pwd)"
        return 1
    fi

    # Encrypt file
    Cipher__encrypt "$file" "$password" "$Ash__FALSE"

    # Make sure encrypted file is created
    local encrypted_file="$file.enc"
    if [[ ! -f "$encrypted_file" ]]; then
        echo "Encrypted file '$encrypted_file' not created"
        return 1
    fi

    # Make sure unencrypted file is deleted
    if [[ -f "$file" ]]; then
        echo "Unencrypted file '$file' not deleted"
        return 1
    fi

    # Make sure there are contents
    if [[ "$(cat "$encrypted_file")" = "" ]]; then
        echo "No contents in encrypted file '$encrypted_file'"
        return 1
    fi

    # Make sure the contents are encrypted different
    if [[ "$(cat "$encrypted_file")" = "$secret" ]]; then
        echo "Contents in encrypted file '$encrypted_file' are not encrypted"
        return 1
    fi

    # Decrypt file
    Cipher__decrypt "$encrypted_file" "$password" "$Ash__FALSE"

    # Make sure encrypted file is deleted
    if [[ -f "$encrypted_file" ]]; then
        echo "Encrypted file '$encrypted_file' not deleted"
        return 1
    fi

    # Make sure uncrypted file is created
    if [[ ! -f "$file" ]]; then
        echo "Unencrypted file '$file' not created"
        return 1
    fi

    # Make sure it's been unencrypted properly
    if [[ "$(cat "$file")" != "$secret" ]]; then
        echo "File not unencrypted properly"
        echo "Expected contents: '$secret'"
        echo "Actual contents: '$(cat "$file")'"
        return 1
    fi

    # Clear the file
    rm "$file"
}

##################################################
# Tests that a directory can be encrypted, and
# unencrypted properly
##################################################
Cipher__test_directory_encryption() {
    local directory="$(Obj_generate_uuid)"
    local file_one="$directory/one.txt"
    local file_two="$directory/two.txt"
    local secret_one="Some super secret"
    local secret_two="Some other super secret"
    local password="some-secure-password"

    # Set up directory
    mkdir "$directory"
    echo "$secret_one" > "$file_one"
    echo "$secret_two" > "$file_two"
    if [[ ! -d "$directory" ]]; then
        echo "Unable to create directory, cannot to run tests"
        echo "Make sure user $(whoami) has permissions to write to $(pwd)"
        return 1
    fi

    # Encrypt directory
    Cipher__encrypt "$directory" "$password" "$Ash__FALSE"

    # Make sure unencrypted directory is deleted
    if [[ -d "$directory" ]]; then
        echo "Unencrypted directory '$directory' not deleted"
        return 1
    fi

    # Make sure encrypted file is created
    local encrypted_file="$directory.tar.gz.enc"
    if [[ ! -f "$encrypted_file" ]]; then
        echo "Encrypted file '$encrypted_file' not created"
        return 1
    fi

    # Make sure there are contents
    if [[ "$(cat "$encrypted_file")" = "" ]]; then
        echo "No contents in encrypted file '$encrypted_file'"
        return 1
    fi

    # Decrypt file
    Cipher__decrypt "$encrypted_file" "$password" "$Ash__FALSE"

    # Make sure encrypted file is deleted
    if [[ -f "$encrypted_file" ]]; then
        echo "Encrypted file '$encrypted_file' not deleted"
        return 1
    fi

    # Make sure uncrypted directory is created
    if [[ ! -d "$directory" ]]; then
        echo "Unencrypted directory '$directory' not created"
        return 1
    fi

    # Make sure it's been unencrypted properly
    if [[ "$(cat "$file_one")" != "$secret_one" ]]; then
        echo "Directory not unencrypted properly"
        echo "Expected contents for '$file_one': '$secret_one'"
        echo "Actual contents: '$(cat "$file_one")'"
        return 1
    fi
    if [[ "$(cat "$file_two")" != "$secret_two" ]]; then
        echo "Directory not unencrypted properly"
        echo "Expected contents for '$file_two': '$secret_two'"
        echo "Actual contents: '$(cat "$file_two")'"
        return 1
    fi

    # Clear the directory
    rm -r "$directory"
}
