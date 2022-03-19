#!/bin/bash

set -e

read -r -p "Enter MFA Code: " TOKEN_CODE

AWS_ALLGANIZE_PROFILE="allganize"
AWS_ALLGANIZE_MFA_PROFILE="allganize-mfa"


credentials=$( \
  aws --profile "${AWS_ALLGANIZE_PROFILE}" sts get-session-token \
  --duration-seconds 129600 \
  --serial-number arn:aws:iam::061182222301:mfa/mhlee \
  --token-code "${TOKEN_CODE}" \
  | jq .Credentials \
)

aws --profile "${AWS_ALLGANIZE_MFA_PROFILE}" \
  configure set aws_access_key_id \
  "$(echo "${credentials}" | jq -r .AccessKeyId)"
aws --profile "${AWS_ALLGANIZE_MFA_PROFILE}" \
  configure set aws_secret_access_key \
  "$(echo "${credentials}" | jq -r .SecretAccessKey)"
aws --profile "${AWS_ALLGANIZE_MFA_PROFILE}" \
  configure set aws_session_token \
  "$(echo "${credentials}" | jq -r .SessionToken)"
aws --profile "${AWS_ALLGANIZE_MFA_PROFILE}" \
  configure set region \
  "us-west-2"

echo "Done! Profile: ${AWS_ALLGANIZE_MFA_PROFILE}"

