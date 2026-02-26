#!/usr/bin/env bash
# Resets the example project to its initial state.
# For first-time setup, follow the instructions in README.md instead.
set -euo pipefail

if [[ ! -f pubspec.yaml ]]; then
  echo "Error: run this script from the example/ directory" >&2
  exit 1
fi

if [[ ! -d .git ]]; then
  echo "Error: no .git found — run first-time setup from README.md first" >&2
  exit 1
fi

echo "Resetting example project..."
rm -rf .git
sed -i '' 's/^version: .*/version: 1.0.0+1/' pubspec.yaml

git init -b main
git add .
git commit -m "chore: initial example project"
git tag prod-v0.9.0+3
git tag prod-us-v0.8.0+2

echo ""
echo "Reset complete. Seeded tags:"
git tag -l | sort
