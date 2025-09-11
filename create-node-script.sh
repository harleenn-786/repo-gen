#!/bin/bash
# Usage: ./create_repo.sh repo-name

if [ -z "$1" ]; then
  echo "❌ Please provide a repo name. Example: ./create_repo.sh my-node-app"
  exit 1
fi

REPO_NAME=$1
GITHUB_USER="your-username"   # <-- replace with your GitHub username or org
TOKEN=$GH_PAT                 # expects GH_PAT env variable (GitHub PAT)

# Step 1: Create repo via GitHub API
echo "🚀 Creating GitHub repo: $REPO_NAME"
curl -s -H "Authorization: token $TOKEN" \
     -d "{\"name\": \"$REPO_NAME\", \"private\": false}" \
     https://api.github.com/user/repos > /dev/null

# Step 2: Clone repo
git clone https://x-access-token:$TOKEN@github.com/$GITHUB_USER/$REPO_NAME.git
cd $REPO_NAME

# Step 3: Initialize Node.js project
npm init -y

cat > package.json <<EOL
{
  "name": "$REPO_NAME",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  }
}
EOL

echo 'console.log("Hello from '$REPO_NAME'!");' > index.js
echo "node_modules/" > .gitignore
echo "# $REPO_NAME" > README.md

# Step 4: Push to GitHub
git add .
git commit -m "Initial commit - Node.js boilerplate"
git branch -M main
git push origin main

echo "✅ Repo $REPO_NAME created and initialized!"
