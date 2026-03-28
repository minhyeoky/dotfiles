#!/bin/bash

set -e

read -p "Enter search keyword: " -r KEYWORD
KEYWORD=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote_plus(sys.argv[1]))" "$KEYWORD")

case "${KEYWORD}" in
  SC*)
    open "https://www.shellcheck.net/wiki/${KEYWORD}"
    ;;
  *)
    open "https://google.com/search?q=${KEYWORD}"
    open "https://www.perplexity.ai/?q=${KEYWORD}"
    ;;
esac
