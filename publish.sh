#!/usr/bin/env bash

set -euo pipefail

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$WORKSPACE_ROOT/packages"

usage() {
  cat <<'USAGE'
Usage:
  ./publish.sh [--dry-run] [package_name ...]

Examples:
  ./publish.sh --dry-run
  ./publish.sh gmana gmana_value_objects gmana_flutter
USAGE
}

DRY_RUN_ONLY=false
PACKAGE_NAMES=()

while (($#)); do
  case "$1" in
    --dry-run)
      DRY_RUN_ONLY=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      PACKAGE_NAMES+=("$1")
      ;;
  esac
  shift
done

if [[ ${#PACKAGE_NAMES[@]} -eq 0 ]]; then
  while IFS= read -r -d '' pubspec; do
    PACKAGE_NAMES+=("$(basename "$(dirname "$pubspec")")")
  done < <(find "$PACKAGES_DIR" -mindepth 2 -maxdepth 2 -name pubspec.yaml -print0 | sort -z)
fi

if [[ "$DRY_RUN_ONLY" == false ]]; then
  echo "Checking for uncommitted git changes..."
  if [[ -n "$(git -C "$WORKSPACE_ROOT" status --porcelain)" ]]; then
    echo "Error: uncommitted git changes found. Commit or stash them before publishing."
    git -C "$WORKSPACE_ROOT" status --short
    exit 1
  fi
fi

run_for_package() {
  local package_name="$1"
  local package_dir="$PACKAGES_DIR/$package_name"

  if [[ ! -f "$package_dir/pubspec.yaml" ]]; then
    echo "Error: package not found: $package_name"
    exit 1
  fi

  local pub_cmd=(dart pub)
  local analyze_cmd=(dart analyze)
  local test_cmd=(dart test)

  if grep -qE '^[[:space:]]+flutter:[[:space:]]*$' "$package_dir/pubspec.yaml"; then
    pub_cmd=(flutter pub)
    analyze_cmd=(flutter analyze)
    test_cmd=(flutter test)
  fi

  echo "=========================================================="
  echo "Publishing checks: $package_name"
  echo "=========================================================="

  (
    cd "$package_dir"
    "${pub_cmd[@]}" get
    "${analyze_cmd[@]}"
    "${test_cmd[@]}"
    "${pub_cmd[@]}" publish --dry-run

    if [[ "$DRY_RUN_ONLY" == false ]]; then
      "${pub_cmd[@]}" publish
    fi
  )

  echo "Finished: $package_name"
  echo
}

for package_name in "${PACKAGE_NAMES[@]}"; do
  run_for_package "$package_name"
done

if [[ "$DRY_RUN_ONLY" == true ]]; then
  echo "Dry run completed successfully."
else
  echo "Publish flow completed successfully."
fi
