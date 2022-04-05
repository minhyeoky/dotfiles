idx=$1
echo "INDEX: ${idx:-0}" > /dev/null

TARGET_COMMIT=$( git log --oneline -n 1 --skip="${idx}" )

echo "Copy ${TARGET_COMMIT} to clipboard ..."
echo "${TARGET_COMMIT}" | awk '{ print $1 }' | tr -d '\n' | pbcopy
