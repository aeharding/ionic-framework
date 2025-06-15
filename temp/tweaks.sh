#!/bin/bash

# Check if TAG is provided as an argument, otherwise use the original logic
if [ -z "$TAG" ]; then
  # Navigate to the core directory
  cd core || exit

  # Fetch upstream changes and checkout the latest release
  git fetch upstream
  git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
else
  # Navigate to the core directory
  cd core || exit

  # Fetch upstream changes and checkout the specified tag
  git fetch upstream
  git checkout "$TAG"
fi

# Delete the existing "tweak" branch if it exists
git branch -D tweak 2>/dev/null || true

# Create a new branch called "tweak"
git checkout -b tweak

# Get the latest commit from the "mods" branch
latest_commit=$(git rev-parse mods)

# Cherry pick changes from the latest commit on "mods" branch
git cherry-pick "$latest_commit"

# Create a temporary file for the modified package.json
tmp_package_json=$(mktemp)
sed 's/"name": "@ionic\/core"/"name": "voyager-ionic-core"/' package.json > "$tmp_package_json"

# Move the temporary file back to package.json
mv "$tmp_package_json" package.json

# Install dependencies and build
npm install
npm run build

# Commit the changes
git commit -am "Update package.json name"

# Display instructions for the user to push changes and publish
echo "Changes have been committed to the 'tweak' branch."
echo "Please manually run the following commands to complete the process:"
echo "1. git push origin tweak -f"
echo "2. cd core && npm publish"
