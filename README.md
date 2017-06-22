# Cipher

[![Build Status](https://travis-ci.org/ash-shell/cipher.svg?branch=master)](https://travis-ci.org/ash-shell/cipher)

Cipher is an [Ash](https://github.com/ash-shell/ash) module that makes it easy to perform aes-256-cbc encryption for files and directories.

## Getting started

You're going to have to install [Ash](https://github.com/ash-shell/ash) to use this module.

After you have Ash installed, run either one of these two commands depending on your git clone preference:

- `ash apm:install https://github.com/ash-shell/cipher.git`
- `ash apm:install git@github.com:ash-shell/cipher.git`

You can optionally install this globally by adding `--global` to the end of the command.

## Usage

```
Usage:

    cipher:e
    cipher:encrypt $file_name
        Encrypts a file or folder.

    cipher:d
    cipher:decrypt $file_name
        Decrypts an encrypted file.
```

## License

[MIT](LICENSE.md)
