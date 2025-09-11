#!/bin/bash
set -e

REPO_NAME=$1
TECHNOLOGY=$2
ORG_NAME=${ORG_NAME:-"your-org-name"}
TOKEN=$GITHUB_TOKEN

if [[ -z "$REPO_NAME" || -z "$TECHNOLOGY" || -z "$TOKEN" ]]; then
  echo "Missing required values: REPO_NAME, TECHNOLOGY, GITHUB_TOKEN"
  exit 1
fi

echo "---- Creating new GitHub repo: $ORG_NAME/$REPO_NAME ----"

# 1. Create repo via GitHub API
response=$(curl -s -H "Authorization: token $TOKEN" \
  -d "{\"name\":\"$REPO_NAME\", \"private\":true}" \
  https://api.github.com/orgs/$ORG_NAME/repos)

clone_url=$(echo $response | jq -r '.clone_url')

if [[ "$clone_url" == "null" ]]; then
  echo "Failed to create repo. Response:"
  echo $response
  exit 1
fi

echo "Repo created at: $clone_url"

# 2. Clone repo
git clone https://oauth2:$TOKEN@github.com/$ORG_NAME/$REPO_NAME.git
cd $REPO_NAME

# 3. Run Yeoman generator (Node template only)
yo @witsinnovationlab/wits-project-generator:$TECHNOLOGY --force

# 4. Commit + Push
git config user.email "actions@github.com"
git config user.name "GitHub Actions"

git add .
git commit -m "Initial scaffold for $REPO_NAME [skip ci]"
git push origin main

# 5. Create develop branch
git checkout -b develop
git push origin develop

echo "---- Repo $REPO_NAME setup complete ----"
