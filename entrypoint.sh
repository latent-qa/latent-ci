#!/bin/bash
set -e

echo "🚀 Running Latent Tests..."

API_KEY="$1"
PROJECT_ID="$2"
WEBSITE_URL="$3"

# Collect GitHub context
REPO="${GITHUB_REPOSITORY}"
BRANCH="${GITHUB_REF_NAME}"
COMMIT="${GITHUB_SHA}"

echo "🔄 Sending request to Latent API..."
echo "   Repo: $REPO"
echo "   Branch: $BRANCH"
echo "   Commit: $COMMIT"
[ -n "$WEBSITE_URL" ] && echo "   Website: $WEBSITE_URL"

# Build JSON payload
payload=$(jq -n \
  --arg repo "$REPO" \
  --arg commit "$COMMIT" \
  --arg branch "$BRANCH" \
  --arg projectId "$PROJECT_ID" \
  --arg websiteUrl "$WEBSITE_URL" \
  '{
    repo: $repo,
    commit: $commit,
    branch: $branch,
    projectId: $projectId,
    websiteUrl: ($websiteUrl | select(. != ""))
  }')

# Call Latent API
response=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  https://api.latentqa.com/run-ci-tests)

body=$(echo "$response" | head -n1)
status=$(echo "$response" | tail -n1)

echo "Response: $body"

if [ "$status" -ne 200 ]; then
  echo "❌ Latent tests failed with status $status"
  exit 1
fi

echo "✅ Latent tests completed successfully"
