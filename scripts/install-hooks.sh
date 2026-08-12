#!/bin/bash
set -e
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"
if [ ! -d ".githooks" ]; then
  echo "Error: .githooks directory not found."
  exit 1
fi
git config core.hooksPath .githooks
chmod +x .githooks/pre-push
echo "Git hooks installed."
