#!/bin/bash

set -e

read -r -p "Enter S3 path to download: " S3_PATH
read -r -p "Enter local path to save (\$HOME/): " LOCAL_PATH

S3_PATH=$(echo "${S3_PATH}" | tr "@" "/")

aws --profile allganize-s3 s3 cp "${S3_PATH}" "${HOME}/${LOCAL_PATH}"
