#!/bin/bash

set -e

# Get the clipboard content
clipboard=$(pbpaste)

# Write the clipboard content to a temporary file
tmpfile=$(mktemp)
echo "$clipboard" | jq . > $tmpfile

# Open the temporary file in the Nvim
nvim -u NONE -c 'set filetype=json | set foldmethod=indent | set shiftwidth=2 | normal zR' $tmpfile
