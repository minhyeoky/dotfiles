#!/bin/bash

read -p "Enter Base64 Encoded String: " -r ENCODED_STRING

decode_string=$(python3 -c "import base64, sys; print(base64.b64decode(sys.argv[1]).decode('utf-8'))" "$ENCODED_STRING")
echo -n "${decode_string}" | pbcopy
