# Org Health Audit and Optimization — Methodology Repo

**Owner:** Adrian Yip | Cloud4Good
**Service:** Salesforce Org Health Audit and Optimization
**Status:** Active development — methodology proven in practice, not yet validated on real client orgs

---

## What This Is

This repo contains the methodology, tooling, and templates for running Salesforce Org Health Audits. It is the shared source of truth for anyone delivering this service.

The service pulls a client's Salesforce metadata, analyzes it using Claude AI, and delivers a findings report with specific, actionable recommendations. It catches broken automations, security gaps, unused clutter, and code drift that manual UI reviews miss.

---

## Repo Contents

| File | Purpose |
|------|---------|
| `README.md` | This file — orientation and repo guide |
| `PRODUCT_ROADMAP.md` | Service vision, pricing, competitive positioning |
| `AUDIT_SOP.md` | Step-by-step audit workflow — start here for every engagement |
| `CLAUDE_AUDIT_PROMPTS.md` | Prompts to use during Claude analysis |
| `FINDINGS_REPORT_TEMPLATE.md` | Client-facing findings report template |
| `crj-retrieve.sh` | Shell script — retrieves and packages metadata in one command |

---

## Where to Start

**Running an audit:** Read `AUDIT_SOP.md` from top to bottom before your first engagement.

**Pitching the service:** Read `PRODUCT_ROADMAP.md`.

**Analyzing metadata:** Use `CLAUDE_AUDIT_PROMPTS.md` during the Claude analysis phase.

**Delivering findings:** Use `FINDINGS_REPORT_TEMPLATE.md` to structure the client report.

---

## Per-Client Repos

Each client gets their own GitHub repo containing:
- Retrieved metadata (`force-app/`)
- Client-specific findings handoff (`[CLIENT]_AUDIT_HANDOFF.md`)
- Git history tracking metadata changes over time

Client repos are separate from this methodology repo. Do not store client metadata here.

---

## Current Limitations

This methodology has been proven on a Salesforce Developer Edition org. It has **not yet been validated on a real client org**. Key open questions are documented in `AUDIT_SOP.md`. Do not use this on a client without reading the limitations section first.

---

**Last Updated:** May 2, 2026
**Next Review:** After first real client pilot completion
