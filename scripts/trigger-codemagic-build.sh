#!/usr/bin/env bash
# Trigger a Codemagic build (you must add your Codemagic API token once).
# Get token: Codemagic -> Personal account -> Settings -> Integrations -> Codemagic API -> Show
set -euo pipefail

CM_API_TOKEN="${CM_API_TOKEN:-}"
APP_ID="${CODEMAGIC_APP_ID:-}"
WORKFLOW_ID="${CODEMAGIC_WORKFLOW_ID:-daily-expense-firebase}"
BRANCH="${1:-master}"

if [[ -z "$CM_API_TOKEN" ]]; then
  echo "Set your Codemagic API token first:"
  echo ""
  echo "  export CM_API_TOKEN=\"paste-from-codemagic-settings\""
  echo "  ./scripts/trigger-codemagic-build.sh"
  echo ""
  echo "Find token: codemagic.io -> avatar -> Personal account -> Settings -> Integrations -> Codemagic API -> Show"
  exit 1
fi

if [[ -z "$APP_ID" ]]; then
  echo "Set CODEMAGIC_APP_ID (from browser URL when you open the app on Codemagic):"
  echo "  https://codemagic.io/app/<THIS_PART_IS_APP_ID>"
  echo ""
  echo "  export CODEMAGIC_APP_ID=\"your-app-id-here\""
  exit 1
fi

echo "Starting build: workflow=$WORKFLOW_ID branch=$BRANCH"
RESPONSE=$(curl -sS -w "\n%{http_code}" -X POST "https://api.codemagic.io/builds" \
  -H "Content-Type: application/json" \
  -H "x-auth-token: $CM_API_TOKEN" \
  -d "{\"appId\":\"$APP_ID\",\"workflowId\":\"$WORKFLOW_ID\",\"branch\":\"$BRANCH\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "$BODY"
if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "201" ]]; then
  echo ""
  echo "Build started. Open codemagic.io -> Builds to watch progress."
else
  echo ""
  echo "Failed (HTTP $HTTP_CODE). Check token and APP_ID."
  exit 1
fi
