# Org Health Audit — Standard Operating Procedure

**Owner:** Adrian Yip | Cloud4Good  
**Last Updated:** 2026-05-03  
**Status:** Proven on Developer Edition practice org — not yet validated on real client orgs

---

## Before You Start

This SOP is the single operational reference for running an audit. Read the limitations section before your first real client engagement.

**What has been proved:**
- Metadata export works via the retrieval script
- Claude can trace field references across Apex, Flows, Layouts, Profiles, and PermissionSets
- The analysis finds structural problems: broken flow logic, permission gaps, redundant automations, code/process drift
- The full fix cycle works end-to-end: CLI deploy, UI fixes, Apex deploy, field deletion, verify via diff

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
mkdir -p scripts docs
git init
git add .
git commit -m "Initial project setup - [Client Name]"
git remote add origin https://github.com/adrianyip-crj/[client-name]-audit.git
git push -u origin main
```

Copy `crj-retrieve.sh` from the methodology repo into the client directory root and make it executable:

```bash
cp ~/path-to-methodology-repo/crj-retrieve.sh ~/[client-name]/
chmod +x ~/[client-name]/crj-retrieve.sh
```

**File placement:**
- `scripts/` — dated, client-specific fix scripts
- `docs/` — documentation, handoff notes, findings reports
- Project root — reusable methodology scripts like `crj-retrieve.sh`

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

**Important CLI flags:**
- Always use `--source-dir` for retrieve and deploy on non-source-tracked orgs, not `--source-path`
- Example: `sf project retrieve start --source-dir force-app/main/default`
- Example: `sf project deploy start --source-dir force-app/main/default`

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
- Custom fields (unused, deprecated, no references across all metadata — including FLS check, see Unused Field Analysis section)
- Permission sets (missing object or field access)
- Apex triggers vs. Flows (drift and duplication)
- Apex test coverage (weak assertions, uncovered methods)
- Integration staging objects (required fields that may not be populated)

---

## Step 6: Review and Tier the Findings

**Before writing the client report, classify every finding:**

- **Confirmed** — directly visible in metadata, no further verification needed (broken flow conditions, permission gaps, duplicate active automations)
- **Likely** — strongly suggested by metadata patterns, worth a quick check
- **Flag for investigation** — requires client input or org access to confirm

**Special rule for unused fields:** Confidence tier cannot be Confirmed based on metadata reference tracing alone. FLS verification is always required. See Unused Field Analysis section.

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
- Fix type classification (CLI deploy / UI only / Apex deploy / investigation required)
- Priority order
- Effort estimates
- File placement instructions (where generated scripts and files go)

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

## Script Naming Convention

All dated fix scripts follow this pattern:

```
[type]-[client]-[env]-[date]-v[NNN].sh
```

| Component | Definition | Example |
|-----------|-----------|---------|
| type | Script purpose | `fix`, `dedup`, `snapshot` |
| client | My Domain prefix of the org | `crj`, `helpinghands` |
| env | Actual sandbox name or `prod` | `dev`, `uat`, `fullcopy`, `prod` |
| date | ISO date | `2026-05-03` |
| version | Sequential per client-env per day | `v001`, `v002` |

Use the **actual sandbox name**, not a generic label. Version resets to `v001` each new day per client-env combination.

Reusable methodology scripts (like `crj-retrieve.sh`) live at the project root and do not follow the dated naming convention.

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

**Profile metadata is required.** Without it, field utility analysis is incomplete — Claude cannot assess FLS and unused field findings will be unreliable.

---

## Fix Type Classification

Every finding in a handoff document must be classified by fix type before implementation:

| Fix Type | When to Use | Example |
|----------|------------|---------|
| **CLI deploy** | Edit XML locally, deploy via `sf project deploy start` | Field required → not required, trigger active → inactive |
| **UI only** | Changes Salesforce doesn't support via metadata deploy | Field deletion, Flow activation/deactivation |
| **Apex deploy** | Edit `.cls` locally, deploy via CLI (runs tests) | New test class, updated Apex logic |
| **Investigation required** | Verify in org before choosing fix path | Ambiguous findings, data dependency unclear |

**Field deletion is always UI only.** There is no CLI equivalent.

---

## Unused Field Analysis — FLS-First Workflow

Unused field findings require FLS verification before SOQL queries or deletion.

### Step 1: Check FLS in Profile Metadata
Search retrieved profile files for `fieldPermissions` entries for the field:
- **No profile has Read access** → field is inaccessible, no data can exist → proceed directly to deletion
- **One or more profiles have Read access** → run SOQL check first

### Step 2: SOQL Data Check (only if FLS exists)

Run queries **one at a time** in **Workbench** (`workbench.developerforce.com`), not Developer Console:

```sql
SELECT COUNT() FROM Object__c WHERE Field__c != null
```

- COUNT = 0 → safe to delete
- COUNT > 0 → export data before deleting

### Confidence Tier for Unused Fields

| FLS Status | Metadata References | Confidence | Action |
|-----------|-------------------|-----------|--------|
| No FLS in any profile | No references | **Confirmed** | Proceed to deletion |
| FLS exists | No references | **Likely** | Run SOQL check first |
| No FLS | References exist | **Flag for investigation** | FLS accidentally removed, or reference is stale |
| FLS exists | References exist | Not unused | Remove from list |

**Unused field findings should never be Confirmed based on metadata reference tracing alone.**

### Deletion Workflow (UI only)
1. Remove field from all page layouts
2. Setup → Object Manager → [Object] → Fields & Relationships → [Field] → Delete
3. Retrieve metadata and commit — "cannot be found" warnings confirm successful deletion

---

## Developer Console vs Workbench

**Always use Workbench for pre-deletion SOQL queries.** Developer Console caches object schemas and returns false "no such column" errors after recent deployments.

### Interpreting "No Such Column" Errors

This error has three possible causes:
1. The field genuinely doesn't exist in the org
2. The field exists but no FLS is granted — SOQL respects FLS and hides inaccessible fields
3. Developer Console schema cache is stale

**Diagnostic sequence:**
- Does the field appear in Object Manager? → field exists in the org
- Does the field appear in Workbench's field picker? → field has FLS
- Field in Object Manager but not Workbench → exists, no FLS → no data possible, safe to delete

---

## FLS Implications for Audit Analysis

### The Blind Spot
Profiles are retrieved by the standard script, so Claude has the data. The gap is in the analysis prompts — Claude must be explicitly instructed to cross-reference field references against profile FLS. Without that prompt, unused field findings may be incomplete or incorrectly tiered.

### FLS as Severity Signal
- **No FLS + no references** = stronger deletion candidate (field is completely inaccessible — no user can read, write, or query it)
- **Has FLS + no references** = standard unused field finding (run Workbench check before deleting)

### Client Report Caveat
When FLS exists on a field being recommended for deletion, include: "Based on metadata analysis — verify no reports or list views reference this field before deleting."

---

## Permission Set XML Rules

When editing permission set XML, these rules apply or deployment will fail:

1. **Elements must be grouped by type.** All `fieldPermissions` entries together, all `objectPermissions` entries together. Mixed ordering causes deployment failures.

2. **Required fields cannot have explicit FLS entries.** Query required fields first:
```sql
SELECT QualifiedApiName, IsRequired 
FROM FieldDefinition 
WHERE EntityDefinition.QualifiedApiName = 'Object__c'
```
Exclude `IsRequired = true` fields before writing `fieldPermissions` entries.

3. **When hitting "cannot deploy to required field" errors:** Remove all `fieldPermissions` entries for that object entirely. Object-level Read access is sufficient — required fields are automatically accessible.

4. **Fix required field FLS errors in bulk.** Identify all required fields for an object before retrying, not one error at a time.

---

## Field Creation Standard

When deploying new custom fields, always set FLS explicitly. A field with no FLS is invisible to all users and all API calls — it will appear in Object Manager but cannot be read, written, or queried.

**Field deployment checklist:**
- [ ] Field XML created with correct type and label
- [ ] Profile or permission set updated to grant appropriate FLS
- [ ] FLS verified post-deploy
- [ ] Tab created if the object needs UI access

**Custom objects without tabs are not accessible through the standard UI.** Create tabs during initial object setup, not as an afterthought.

---

## Git Commit Message Conventions

```bash
# Initial setup
git commit -m "Initial metadata snapshot — [Client] — [Date]"

# Routine retrieve snapshots
git commit -m "snapshot: post-deploy metadata retrieve — [Date]"
git commit -m "snapshot: post-UI-fixes metadata retrieve — [Date]"

# Fix commits
git commit -m "fix: [description] — [Date]"
```

After UI changes, always retrieve and verify the diff:

```bash
sf project retrieve start --source-dir force-app/main/default
git add .
git commit -m "snapshot: post-UI-fixes metadata retrieve — [Date]"
git diff HEAD~1 HEAD --name-only
```

The `--name-only` diff is your verification. Expect to see only the files you changed. Unexpected files are worth investigating.

---

## Analysis Limitations

**Field reference tracing** — Claude traces references across retrieved metadata types. Fields only referenced in Reports, List Views, or external integrations will appear "unreferenced" incorrectly. FLS check partially mitigates this — a field with FLS but no metadata references should still get a Workbench data check before deletion.

**Integration behavior** — What an external system sends is invisible in metadata. Required fields on staging objects are flagged as risks but must be confirmed with the client.

**Deprecated field detection** — Fields explicitly labeled "DEPRECATED" will be caught. Unused fields without a label may be missed.

**Apex coverage** — Claude can identify weak test structure from reading the code, but cannot run tests or check live coverage percentages. Verify in the org.

**Layout permissions** — Some system layouts may be blocked on Developer Edition orgs. Behavior on production orgs is unconfirmed.

---

## Gotchas

**`sf project retrieve start` with no flags fails on Developer Edition** — Returns a `noSourceTracking` error. Use the retrieval script instead.

**`--metadata` comma-separated list doesn't work** — Each type needs its own `--metadata` flag. The script handles this.

**`sf project generate manifest --from-org` returns an empty file** — On Developer Edition orgs. Don't use this approach.

**Re-zip after every retrieve** — The zip must be regenerated after each retrieve. Don't upload a stale zip.

**Blank `Error (1):` with no message** — Session has expired. Re-run `sf org login web`.

**Developer Console schema cache** — Unreliable after recent deployments. Use Workbench for SOQL on recently deployed or deleted fields.

**"Cannot be found" warnings during retrieve after field deletion** — Expected and correct. Confirms the fields were successfully deleted.

**Large number of layout changes in retrieve output** — Normal after field deletions. Salesforce cascades field removal through all layouts automatically.

**Retrieve → commit → zip → upload is one atomic workflow** — Don't skip steps or do them out of order.

---

## Open Questions

1. Does the retrieval script work on production/managed services orgs without modification?
2. Does the Layout permissions warning appear on real orgs, and does it block relevant data?
3. Are there additional metadata types that should be added to the script?
4. What is the right process for verifying integration-related findings with the client?
5. Should we retrieve Reports and List Views to improve field reference tracing, and what is the file size impact?
6. How do we handle multi-org clients? (production + sandbox + multiple business units)
7. What is the SLA for audit turnaround? (same day? 48 hours?)
8. Do we offer emergency/urgent audits? (post-incident analysis)
9. How do we price very small orgs? (startups, tiny nonprofits)
10. Should we certify in Gearset for integrated deployment validation?
