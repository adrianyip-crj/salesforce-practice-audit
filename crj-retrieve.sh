#!/bin/bash
# crj-retrieve.sh
# Retrieves Salesforce metadata, commits to Git, and packages for Claude upload
#
# Usage: ./crj-retrieve.sh [org-alias]
# Example: ./crj-retrieve.sh my-client-org
#
# Prerequisites:
#   - Salesforce CLI installed (sf)
#   - Authenticated to org: sf org login web --alias [org-alias] --set-default
#   - Git initialized in this directory
#   - Run from the client project directory

ORG=${1:-my-practice-org}

echo "=========================================="
echo "CRJ Org Health Audit — Metadata Retrieval"
echo "Org: $ORG"
echo "Date: $(date '+%Y-%m-%d')"
echo "=========================================="

echo ""
echo "Step 1: Retrieving metadata from $ORG..."

sf project retrieve start \
  --metadata ApexClass \
  --metadata ApexTrigger \
  --metadata Flow \
  --metadata CustomObject \
  --metadata PermissionSet \
  --metadata Layout \
  --metadata Profile \
  --target-org $ORG

if [ $? -ne 0 ]; then
  echo ""
  echo "ERROR: Metadata retrieval failed. Check your org authentication and try again."
  echo "Run: sf org login web --alias $ORG --set-default"
  exit 1
fi

echo ""
echo "Step 2: Committing to Git..."
git add .
git commit -m "Metadata retrieval - $(date '+%Y-%m-%d')"

echo ""
echo "Step 3: Packaging for Claude upload..."
FILENAME="crj-audit-$(date '+%Y-%m-%d').tar.gz"
tar -czf $FILENAME force-app/

echo ""
echo "=========================================="
echo "Done."
echo "Upload this file to Claude: $FILENAME"
echo "Find it in Finder: Cmd+Shift+G → $(pwd)"
echo "=========================================="
