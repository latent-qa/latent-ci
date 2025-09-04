#!/bin/bash
set -e

echo "🚀 Running Latent Tests..."
API_KEY="$1"
PROJECT_ID="$2"

response=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"projectId\": \"$PROJECT_ID\"}" \
  https://api.latentqa.com/run-ci-tests)

body=$(echo "$response" | head -n1)
status=$(echo "$response" | tail -n1)

echo "Response: $body"

if [ "$status" -ne 200 ]; then
  echo "❌ Latent tests failed"
  exit 1
fi

echo "✅ Latent tests completed successfully"
