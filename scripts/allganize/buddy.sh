#!/bin/bash

set -e

selected_pipeline=$(echo "deploy-feature-be" "provision-feature-be" \
  | tr ' ' '\n' | fzf)

case $selected_pipeline in 
  deploy-feature-be*)
    pipeline_id=134
    BUDDY_TOKEN=${BUDDY_134_TOKEN}
    ;;
  provision-feature-be*)
    pipeline_id=133
    BUDDY_TOKEN=${BUDDY_133_TOKEN}
    ;;

  *)
    echo "Unknown Pipeline!"
    exit 1
    ;;
esac

read -r -p "Branch (feature-XXX): " feature_branch
branch_to_terminate="feature-${feature_branch}"

echo "Run $selected_pipeline with branch feature-$feature_branch"
curl --fail-with-body -X GET \
  "https://buddy.allganize.ai/allganize/alli/pipelines/pipeline/${pipeline_id}/trigger-webhook?token=${BUDDY_TOKEN}&branch=feature-${feature_branch}&branch_to_terminate=${branch_to_terminate}"
