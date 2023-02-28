#!/bin/bash

set -e

read -p "Enter search keyword: " -r KEYWORD

case "${KEYWORD}" in
  SC*)
    open "https://www.shellcheck.net/wiki/${KEYWORD}"
    ;;
  *)
    open "https://google.com/search?q=${KEYWORD}"
    open "https://www.perplexity.ai/?q=${KEYWORD}"
    ;;
esac
