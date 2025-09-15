#!/bin/bash
set -e

echo "🚀 Running Latent Tests..."

API_KEY="${INPUT_API_KEY}"
PROJECT_ID="${INPUT_PROJECT_ID}"
WEBSITE_URL="${INPUT_WEBSITE_URL}"

echo "DEBUG API_KEY=${API_KEY:0:4}***"
echo "DEBUG PROJECT_ID=${PROJECT_ID:0:4}***"
echo "DEBUG WEBSITE_URL=${WEBSITE_URL}"

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
  https://api.latentqa.com/run-tests/run-ci-tests)

body=$(echo "$response" | head -n -1)
status=$(echo "$response" | tail -n 1)

echo "Response Status: $status"
echo "Response Body: $body"

if [ "$status" -ne 200 ]; then
  echo "❌ Latent API request failed with status $status"
  echo "Error details: $body"
  exit 1
fi

passed=$(echo "$body" | jq -r '.passed // 0')
failed=$(echo "$body" | jq -r '.failed // 0')
total=$(echo "$body" | jq -r '.total // 0')
execution_time=$(echo "$body" | jq -r '.execution_time // 0')

echo "passed=$passed" >> $GITHUB_OUTPUT
echo "failed=$failed" >> $GITHUB_OUTPUT
echo "total=$total" >> $GITHUB_OUTPUT
echo "execution-time=$execution_time" >> $GITHUB_OUTPUT

echo ""
echo "📊 Test Results:"
echo "   ✅ Passed: $passed"
echo "   ❌ Failed: $failed"
echo "   📈 Total: $total"
echo "   ⏱️  Execution Time: ${execution_time}s"

details=$(echo "$body" | jq -r '.details // empty')
if [ -n "$details" ] && [ "$details" != "null" ]; then
  echo ""
  echo "📋 Detailed Results:"
  echo "$body" | jq -r '.details[] | "   \(.status | ascii_upcase): \(.test_name) (\(.execution_time)s)"'
fi

if [ "$failed" -gt 0 ]; then
  echo ""
  echo "⚠️  Some tests failed, but workflow will continue (non-blocking)"
  # Uncomment the next line if you want failed tests to fail the workflow
  # exit 1
fi

echo ""
echo "🎉 Latent CI completed successfully!"
