# dotfiles-guard — scan ADDED lines of a unified diff for secrets / personal info.
# Reads a `git diff` on stdin. Prints findings to stdout; exits 1 if any found.
# Zero dependencies (POSIX awk). A line containing `gitguard-ok` is skipped.

/^\+\+\+ b\// { file = substr($0, 7); next }   # +++ b/<path>
/^\+\+\+ /    { file = "?";            next }
/^[-@ ]/      { next }                          # removed / hunk-header / context
/^\+/ {
  line = substr($0, 2)                          # drop leading '+'
  if (line ~ /gitguard-ok/) next                # explicit allow marker

  hit = ""
  if      (line ~ /-----BEGIN [A-Z ]*PRIVATE KEY-----/)                hit = "private-key"
  else if (line ~ /AKIA[0-9A-Z]+/)                                     hit = "aws-access-key"
  else if (line ~ /github_pat_[A-Za-z0-9_]+/)                          hit = "github-pat"
  else if (line ~ /(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]+/)                hit = "github-token"
  else if (line ~ /xox[abprs]-[A-Za-z0-9-]+/)                          hit = "slack-token"
  else if (line ~ /AIza[0-9A-Za-z_-]+/)                                hit = "google-api-key"
  else if (line ~ /eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/) hit = "jwt"
  else if (line ~ /\/Users\/[^\/"'[:space:]]+\//)                      hit = "personal-path"
  else if (line ~ /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z][A-Za-z]+/ && line !~ /noreply@|@users\.noreply\./) hit = "email"

  if (hit != "") {
    n++
    snip = line
    sub(/^[[:space:]]+/, "", snip)
    if (length(snip) > 88) snip = substr(snip, 1, 88) "..."
    printf("  %-18s %s\n        %s\n", hit, file, snip)
  }
}
END { if (n > 0) exit 1 }
