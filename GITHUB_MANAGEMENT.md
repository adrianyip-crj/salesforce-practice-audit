# GitHub Documentation Management Guide

**For:** Adrian Yip | Cloud4Good
**Last Updated:** May 2, 2026

---

## Repo Structure

### Methodology Repo (this repo)
`https://github.com/adrianyip-crj/salesforce-practice-audit`

Contains everything needed to run an audit. Shared across all clients and all team members.

```
salesforce-practice-audit/
├── README.md                      ← Start here
├── PRODUCT_ROADMAP.md             ← Service strategy and pricing
├── AUDIT_SOP.md                   ← Operational workflow
├── CLAUDE_AUDIT_PROMPTS.md        ← Analysis prompts
├── FINDINGS_REPORT_TEMPLATE.md    ← Client deliverable template
└── crj-retrieve.sh                ← Retrieval script
```

**Does not contain:** Client metadata, client findings, or practice org files.

### Per-Client Repos
`https://github.com/adrianyip-crj/[client-name]-audit`

One repo per client. Contains their metadata and audit history.

```
[client-name]-audit/
├── force-app/                     ← Retrieved metadata (committed after each retrieve)
├── crj-retrieve.sh                ← Copy of retrieval script
└── [CLIENT]_AUDIT_HANDOFF.md      ← Findings and fix recommendations
```

---

## What to Do Right Now

You currently have the practice org files mixed in with the methodology docs in one repo. Here's how to clean it up.

### Step 1: Update the methodology repo

Replace the existing stale docs with the new ones. In your terminal:

```bash
cd ~/salesforce-practice

# Remove stale docs
rm AUDIT_SUMMARY_UPDATED.md
rm GOTCHAS_PLAYBOOK.md
rm QUICK_START.md
rm AUDIT_CHECKLIST.md
rm DEPLOYMENT_PHASED.md

# Add the new docs (copy from wherever you downloaded them)
# README.md
# PRODUCT_ROADMAP.md (replacing the existing one)
# AUDIT_SOP.md
# CLAUDE_AUDIT_PROMPTS.md (replacing the existing one)
# FINDINGS_REPORT_TEMPLATE.md (replacing the existing one)
# crj-retrieve.sh

chmod +x crj-retrieve.sh

git add .
git commit -m "Restructure docs - replace stale pre-audit docs with proven methodology"
git push
```

### Step 2: Decide what to do with the practice org metadata

The `force-app/` folder in this repo is from the practice org. Options:

**Option A (recommended):** Keep it. The practice org is a useful reference and test bed. The repo name (`salesforce-practice-audit`) makes it clear this isn't a client repo.

**Option B:** Move it to its own repo (`crj-practice-audit`) and keep this repo pure methodology.

Decide before your first real client, then don't change it.

---

## Ongoing Maintenance

### When to update docs

| Event | What to update |
|-------|---------------|
| Find a new gotcha | `AUDIT_SOP.md` → Gotchas section |
| Discover a new analysis limitation | `AUDIT_SOP.md` → Analysis Limitations section |
| Validate something on a real org | `AUDIT_SOP.md` → update Open Questions, update Status |
| Add a new audit prompt | `CLAUDE_AUDIT_PROMPTS.md` |
| Change pricing or positioning | `PRODUCT_ROADMAP.md` |
| Script changes | `crj-retrieve.sh` + update the script block in `AUDIT_SOP.md` |

### Commit message conventions

```bash
# Adding something new
git commit -m "Add [what] to [doc]"

# Fixing or updating something
git commit -m "Update [doc] - [what changed and why]"

# After a client audit
git commit -m "Update SOP with lessons from [client] pilot"
```

### Who updates what

Right now: Adrian only. When the team grows, establish a review process before merging changes to methodology docs — a bad SOP change affects every future audit.

---

## When You Add a New Client

```bash
# Create the client repo on GitHub first, then:
mkdir ~/[client-name]
cd ~/[client-name]
sf project generate --name [client-name] --default-package-dir force-app
git init
git add .
git commit -m "Initial project setup - [Client Name]"
git remote add origin https://github.com/adrianyip-crj/[client-name]-audit.git
git push -u origin main

# Copy the retrieval script
cp ~/salesforce-practice/crj-retrieve.sh ~/[client-name]/
chmod +x ~/[client-name]/crj-retrieve.sh
```

---

## Documentation Review Cadence

- **After every real client audit:** Update AUDIT_SOP with anything new learned
- **After pilot phase completes:** Full review of all docs — revisit this guide
- **Before adding team members:** Ensure AUDIT_SOP is accurate enough for someone new to follow without help

---

## Files to Retire (Delete from GitHub)

These existed before the methodology was proven and are now superseded:

| Old File | Replaced By |
|----------|------------|
| `AUDIT_SUMMARY_UPDATED.md` | `AUDIT_SOP.md` |
| `GOTCHAS_PLAYBOOK.md` | `AUDIT_SOP.md` (Gotchas section) |
| `QUICK_START.md` | `AUDIT_SOP.md` |
| `AUDIT_CHECKLIST.md` | `AUDIT_SOP.md` + `CLAUDE_AUDIT_PROMPTS.md` |
| `DEPLOYMENT_PHASED.md` | Not needed at this stage |
