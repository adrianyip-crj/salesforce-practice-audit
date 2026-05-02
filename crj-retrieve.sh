#!/bin/bash
# crj-retrieve.sh — Run with: ./crj-retrieve.sh [org-alias]
ORG=${1:-my-practice-org}

echo "Retrieving metadata from $ORG..."

sf project retrieve start \
  --metadata ApexClass \
  --metadata ApexTrigger \
  --metadata Flow \
  --metadata CustomObject \
  --metadata PermissionSet \
  --metadata Layout \
  --metadata Profile \
  --target-org $ORG

echo "Committing..."
git add .
git commit -m "Metadata retrieval - $(date '+%Y-%m-%d')"

echo "Zipping for Claude upload..."
tar -czf crj-audit-$(date '+%Y-%m-%d').tar.gz force-app/

echo "Ready: crj-audit-$(date '+%Y-%m-%d').tar.gz"
