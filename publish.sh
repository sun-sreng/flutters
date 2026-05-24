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

contains_package() {
  local needle="$1"
  shift

  local package_name
  for package_name in "$@"; do
    if [[ "$package_name" == "$needle" ]]; then
      return 0
    fi
  done

  return 1
}

local_package_dependencies() {
  local package_name="$1"
  local package_dir="$PACKAGES_DIR/$package_name"

  awk '
    /^[^[:space:]][^:]*:/ {
      in_dependencies = ($1 == "dependencies:")
    }
    in_dependencies && /^[[:space:]]{2}[A-Za-z0-9_]+:/ {
      dependency = $1
      sub(/:$/, "", dependency)
      print dependency
    }
  ' "$package_dir/pubspec.yaml" | while IFS= read -r dependency; do
    if [[ -f "$PACKAGES_DIR/$dependency/pubspec.yaml" ]]; then
      echo "$dependency"
    fi
  done
}

sort_package_names_by_dependency() {
  SORTED_PACKAGE_NAMES=()
  VISITED_PACKAGE_NAMES=("__publish_sh_array_sentinel__")
  VISITING_PACKAGE_NAMES=("__publish_sh_array_sentinel__")

  local package_name
  for package_name in "${PACKAGE_NAMES[@]}"; do
    visit_package "$package_name"
  done

  PACKAGE_NAMES=("${SORTED_PACKAGE_NAMES[@]}")
}

visit_package() {
  local package_name="$1"

  if contains_package "$package_name" "${VISITED_PACKAGE_NAMES[@]}"; then
    return
  fi

  if contains_package "$package_name" "${VISITING_PACKAGE_NAMES[@]}"; then
    echo "Error: circular local dependency involving $package_name"
    exit 1
  fi

  if [[ ! -f "$PACKAGES_DIR/$package_name/pubspec.yaml" ]]; then
    echo "Error: package not found: $package_name"
    exit 1
  fi

  VISITING_PACKAGE_NAMES+=("$package_name")

  local dependency
  while IFS= read -r dependency; do
    if contains_package "$dependency" "${PACKAGE_NAMES[@]}"; then
      visit_package "$dependency"
    fi
  done < <(local_package_dependencies "$package_name")

  local remaining_package_names=()
  local visiting_package_name
  for visiting_package_name in "${VISITING_PACKAGE_NAMES[@]}"; do
    if [[ "$visiting_package_name" != "$package_name" ]]; then
      remaining_package_names+=("$visiting_package_name")
    fi
  done
  if [[ ${#remaining_package_names[@]} -eq 0 ]]; then
    remaining_package_names=("__publish_sh_array_sentinel__")
  fi
  VISITING_PACKAGE_NAMES=("${remaining_package_names[@]}")

  VISITED_PACKAGE_NAMES+=("$package_name")
  SORTED_PACKAGE_NAMES+=("$package_name")
}

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

sort_package_names_by_dependency

echo "Package order: ${PACKAGE_NAMES[*]}"
echo

if [[ "$DRY_RUN_ONLY" == false ]]; then
  echo "Checking for uncommitted git changes..."
  if [[ -n "$(git -C "$WORKSPACE_ROOT" status --porcelain)" ]]; then
    echo "Warning: uncommitted git changes found. Publishing will use the current working tree."
    git -C "$WORKSPACE_ROOT" status --short
  fi
fi

run_for_package() {
  local package_name="$1"
  local package_dir="$PACKAGES_DIR/$package_name"

  if [[ ! -f "$package_dir/pubspec.yaml" ]]; then
    echo "Error: package not found: $package_name"
    exit 1
  fi

  if [[ "$DRY_RUN_ONLY" == false ]] && grep -qE '^publish_to:[[:space:]]*none[[:space:]]*$' "$package_dir/pubspec.yaml"; then
    echo "Skipping $package_name because publish_to is none."
    echo
    return
  fi

  local pub_cmd=(dart pub)
  local analyze_cmd=(dart analyze --fatal-infos --fatal-warnings)
  local test_cmd=(dart test)
  local publish_dry_cmd=()

  if grep -qE '^[[:space:]]+flutter:[[:space:]]*$' "$package_dir/pubspec.yaml"; then
    pub_cmd=(flutter pub)
    analyze_cmd=(flutter analyze --fatal-infos --fatal-warnings)
    test_cmd=(flutter test)
  fi

  publish_dry_cmd=("${pub_cmd[@]}" publish --dry-run)
  publish_dry_cmd+=(--ignore-warnings)

  echo "=========================================================="
  echo "Publishing checks: $package_name"
  echo "=========================================================="

  (
    cd "$package_dir"
    "${pub_cmd[@]}" get
    "${analyze_cmd[@]}"
    if [[ -d test ]] && find test -type f -name '*_test.dart' -print -quit | grep -q .; then
      "${test_cmd[@]}"
    else
      echo "No tests found; skipping test step."
    fi
    "${publish_dry_cmd[@]}"

    if [[ "$DRY_RUN_ONLY" == false ]]; then
      "${pub_cmd[@]}" publish --force
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
