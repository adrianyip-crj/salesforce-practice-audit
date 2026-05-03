# Org Health Audit — Standard Operating Procedure

**Owner:** Adrian Yip | Cloud4Good
**Last Updated:** May 2, 2026
**Status:** Proven on Developer Edition practice org — not yet validated on real client orgs

---

## Before You Start

This SOP is the single operational reference for running an audit. Read the limitations section before your first real client engagement.

**What has been proved:**
- Metadata export works via the retrieval script
- Claude can trace field references across Apex, Flows, Layouts, Profiles, and PermissionSets
- The analysis finds structural problems: broken flow logic, permission gaps, redundant automations, code/process drift

**What has not been proved yet:**
- The workflow on real production or managed services orgs (only tested on Developer Edition)
- The retrieval script syntax works identically on non-Dev orgs
- The Layout permissions warning doesn't block relevant data on real orgs
- Analysis is comprehensive — known gaps exist (see Analysis Limitations section)

**Analysis is still being tuned. Human review of all findings before client delivery is non-negotiable.**

---

## Step 1: Set Up a Client Project

Each client gets their own local directory and GitHub repo.

```bash
mkdir ~/[client-name]
cd ~/[client-name]
sf project generate --name [client-name] --default-package-dir force-app
git init
git add .
git commit -m "Initial project setup - [Client Name]"
git remote add origin https://github.com/adrianyip-crj/[client-name]-audit.git
git push -u origin main
```

Copy `crj-retrieve.sh` from the methodology repo into the client directory and make it executable:

```bash
cp ~/path-to-methodology-repo/crj-retrieve.sh ~/[client-name]/
chmod +x ~/[client-name]/crj-retrieve.sh
```

---

## Step 2: Authenticate

```bash
sf org login web --alias [client-org-alias] --set-default
sf org display --target-org [client-org-alias]
```

Confirm the org alias, username, and org ID before proceeding.

**Always authenticate as System Administrator.** Non-admin users may miss Layout data due to permissions.

**If you see `ERROR_HTTP_404`:** The session has expired. Re-run `sf org login web` to refresh.

---

## Step 3: Retrieve, Commit, and Package

```bash
cd ~/[client-name]
./crj-retrieve.sh [client-org-alias]
```

This single command retrieves all metadata types, commits to Git, and creates a timestamped zip ready for Claude upload. It takes approximately 30 seconds.

**Expected output:** `crj-audit-[date].tar.gz` in your client directory.

**Expected warnings:** Layout permission warnings may appear. These are normal on Developer Edition orgs. Note and investigate if they appear on real client orgs.

**What the script does not do:** Authenticate, upload to Claude, run analysis, or generate the report. Those steps are still manual.

---

## Step 4: Upload to Claude

1. Open Finder: **Cmd+Shift+G** → paste `~/[client-name]/`
2. Locate `crj-audit-[date].tar.gz`
3. Start a new Claude chat
4. Upload the zip file
5. Provide client context (see below)

**Client context to provide:**
- Organization name and type (nonprofit, business, etc.)
- Known integrations (Stripe, Mailchimp, etc.)
- Known pain points or areas of concern
- Any recent major changes (migrations, new implementations)
- Link to this SOP or the `CLAUDE_AUDIT_PROMPTS.md` for systematic analysis

---

## Step 5: Run the Analysis

Use the prompts in `CLAUDE_AUDIT_PROMPTS.md` to systematically work through:

- Flows (broken logic, draft status, redundancy)
- Custom fields (unused, deprecated, no references across all metadata)
- Permission sets (missing object or field access)
- Apex triggers vs. Flows (drift and duplication)
- Apex test coverage (weak assertions, uncovered methods)
- Integration staging objects (required fields that may not be populated)

---

## Step 6: Review and Tier the Findings

**Before writing the client report, classify every finding:**

- **Confirmed** — directly visible in metadata, no further verification needed (broken flow conditions, permission gaps, duplicate active automations)
- **Likely** — strongly suggested by metadata patterns, worth a quick check (fields labeled deprecated, low coverage based on code reading)
- **Flag for investigation** — requires client input or org access to confirm (integration field mapping, field usage in reports or list views not captured in metadata)

**Known blind spots** — Claude cannot see:
- Reports and list views (fields may be "unreferenced" in metadata but actively used here)
- External integration configs (what Stripe/Mailchimp actually sends)
- Actual Apex test coverage percentages (must check the org directly)
- Anything not in the retrieved metadata types

---

## Step 7: Write the Findings Report

Use `FINDINGS_REPORT_TEMPLATE.md` to structure the client deliverable.

---

## Step 8: Fix Handoff

Create `[CLIENT]_AUDIT_HANDOFF.md` in the client repo with:
- Each finding, its confidence tier, root cause, and specific fix
- Priority order
- Effort estimates

Start a new Claude chat with this document to begin implementing fixes.

---

## Step 9: Clean Up

```bash
rm ~/[client-name]/crj-audit-[date].tar.gz
```

Do not delete the GitHub repo — it is the source of truth for future quarterly diffs.

Optionally archive the zip to SharePoint before deleting.

**Data sensitivity:** Client metadata may contain configuration related to donor, volunteer, or financial data. Follow company data retention policy. Consider including metadata handling terms in client agreements.

---

## Quarterly Audit Workflow

For existing clients, after the initial audit:

```bash
cd ~/[client-name]
./crj-retrieve.sh [client-org-alias]
git diff HEAD~1 HEAD > quarterly-changes.diff
git diff --name-only HEAD~1 HEAD
```

Upload only the changed files to Claude (not the full zip). Reference the previous findings for context. Deliver a delta report showing what changed, what's new, and the status of previous recommendations.

---

## The Retrieval Script

```bash
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
```

---

## Analysis Limitations

**Field reference tracing** — Claude traces references across the retrieved metadata types. Fields only referenced in Reports, List Views, or external integrations will not be caught and may appear "unreferenced" incorrectly.

**Integration behavior** — What an external system sends or doesn't send is invisible in metadata. Required fields on staging objects are flagged as risks, but must be confirmed with the client.

**Deprecated field detection** — Fields explicitly labeled "DEPRECATED" will be caught. Unused fields without a label may be missed.

**Apex coverage** — Claude can identify weak test structure from reading the code, but cannot run tests or check live coverage percentages. Verify in the org.

**Layout permissions** — Some system layouts may be blocked on Developer Edition orgs. Behavior on production orgs is unconfirmed.

---

## Gotchas

**`sf project retrieve start` with no flags fails on Developer Edition** — Returns a `noSourceTracking` error. Use the retrieval script instead.

**`--metadata` comma-separated list doesn't work** — Each type needs its own `--metadata` flag. The script handles this.

**`sf project generate manifest --from-org` returns an empty file** — On Developer Edition orgs. Don't use this approach.

**Re-zip after every retrieve** — The zip must be regenerated after each retrieve. Don't upload a stale zip after a fresh retrieve.

**Blank `Error (1):` with no message** — Session has expired. Re-run `sf org login web`.

**Retrieve → commit → zip → upload is one atomic workflow** — Don't skip steps or do them out of order.

---

## Open Questions (To Resolve on First Real Client Audit)

1. Does the retrieval script work on production/managed services orgs without modification?
2. Does the Layout permissions warning appear on real orgs, and does it block relevant data?
3. Are there additional metadata types that should be added to the script?
4. What is the right process for verifying integration-related findings with the client?
5. Should we retrieve Reports and List Views to improve field reference tracing, and what is the file size impact?
