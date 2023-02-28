#!/bin/bash

read -p "Enter Base64 Encoded String: " -r ENCODED_STRING

decode_string=$(python3 -c "import base64; print(base64.b64decode('${ENCODED_STRING}').decode('utf-8'))")
echo -n "${decode_string}" | pbcopy
