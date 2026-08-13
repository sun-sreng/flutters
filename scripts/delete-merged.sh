#!/bin/bash

# bash ./scripts/delete-merged.sh          # default base = main
# bash ./scripts/delete-merged.sh develop  # custom base

BASE_BRANCH="${1:-main}"

git checkout "$BASE_BRANCH" && git pull

for branch in $(git branch --merged | grep -vE "^\*|$BASE_BRANCH|master|develop"); do
  echo "🗑 Deleting local branch: $branch"
  git branch -d "$branch"

  echo "🗑 Deleting remote branch: $branch"
  git push origin --delete "$branch"
done

git remote prune origin
