idx=$1
echo "INDEX: ${idx:-0}" > /dev/null

TARGET_COMMIT=$( git log --oneline -n 1 --skip="${idx:-0}" )

echo "Copied <"${TARGET_COMMIT}"> to clipboard!"
echo "${TARGET_COMMIT}" | awk '{ print $1 }' | tr -d '\n' | pbcopy
