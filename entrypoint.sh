#!/bin/bash
set -e

echo "🚀 Running Latent Tests..."

API_KEY="${INPUT_API_KEY}"
PROJECT_ID="${INPUT_PROJECT_ID}"
WEBSITE_URL="${INPUT_WEBSITE_URL}"

if [ -z "$API_KEY" ] || [ -z "$PROJECT_ID" ]; then
  echo "❌ Missing required inputs (api-key, project-id)"
  exit 1
fi

REPO="${GITHUB_REPOSITORY}"
BRANCH="${GITHUB_REF_NAME}"
COMMIT="${GITHUB_SHA}"

echo "🔄 Sending request to Latent API..."
echo "   Repo: $REPO"
echo "   Branch: $BRANCH"
echo "   Commit: $COMMIT"
[ -n "$WEBSITE_URL" ] && echo "   Website: $WEBSITE_URL"

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

response=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  https://api.latentqa.com/run-ci-tests)

body=$(echo "$response" | head -n1)
status=$(echo "$response" | tail -n1)

echo "Response: $body"

if [ "$status" -ne 200 ]; then
  echo "❌ Latent API request failed with status $status"
  exit 1
fi

passed=$(echo "$body" | jq -r '.passed // empty')
failed=$(echo "$body" | jq -r '.failed // empty')

if [ -n "$passed" ] || [ -n "$failed" ]; then
  echo "✅ Passed: $passed"
  echo "❌ Failed: $failed"
else
  echo "ℹ️ Test results not included in response body."
fi

echo "🎉 Latent tests completed. (Note: workflow succeeded even if some tests failed.)"
