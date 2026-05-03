# Salesforce Org Health Audit — Findings Report

**Client:** [Client Name]
**Audit Date:** [Date]
**Auditor:** [Name] | Cloud4Good
**Report Version:** 1.0

---

## Executive Summary

[2–3 paragraphs. Cover: what we did, the overall health of the org, the most important things we found, and the recommended immediate next steps. Written for a non-technical audience — avoid jargon. Focus on business impact, not technical detail.]

**Audit scope:** [List the metadata types analyzed — e.g., Apex classes, Flows, custom objects and fields, permission sets, layouts, profiles]

**Files analyzed:** [Number] metadata files

---

## Summary of Findings

| # | Finding | Severity | Category | Confidence |
|---|---------|----------|----------|------------|
| 1 | [Short name] | Critical / High / Medium / Low | Automation / Permissions / Data / Code / Hygiene | Confirmed / Likely / Flag for investigation |
| 2 | | | | |
| 3 | | | | |

---

## Confidence Tier Definitions

All findings are classified by confidence before delivery:

- **Confirmed:** Directly visible in the metadata — no further verification needed. The problem exists as described.
- **Likely:** Strongly suggested by metadata patterns. Worth a quick check before implementing a fix.
- **Flag for investigation:** Requires client input or direct org access to confirm. Do not implement fixes until verified.

**Special case — Unused Fields:**
Field utility analysis requires both metadata reference tracing AND FLS verification against retrieved profiles. Confidence tiers for unused field findings are determined as follows:

- **Confirmed:** No references in metadata + No FLS in any retrieved profile. Field is completely inaccessible — no user can read or write to it, no automation can reference it.
- **Likely:** No references in metadata + FLS exists in one or more profiles. Users could theoretically have data in this field. Requires Workbench COUNT verification before deletion.
- **Flag for investigation:** References exist in metadata but no FLS — field is referenced but inaccessible. Investigate whether reference is stale or FLS was accidentally removed.

Unlike other finding types, unused field findings should never be classified as Confirmed based on metadata reference tracing alone. FLS verification is always required.

---

## Critical Issues
*These require immediate attention. They are actively causing problems.*

### [Finding Name]

**What's happening:** [Plain-English description of the problem]

**Business impact:** [What this means for the organization — lost data, broken processes, user frustration, compliance risk]

**Root cause:** [What in the org configuration is causing this]

**Recommended fix:** [Specific, actionable recommendation]

**Effort estimate:** [Hours/days]

**Confidence:** Confirmed / Likely / Flag for investigation

---

## High Priority
*These should be addressed this month. They are not actively breaking things but carry meaningful risk.*

### [Finding Name]

**What's happening:**

**Business impact:**

**Root cause:**

**Recommended fix:**

**Effort estimate:**

**Confidence:**

---

## Medium Priority
*These should be addressed this quarter. They are causing inefficiency or creating future risk.*

### [Finding Name — Unused Custom Field]

**What's happening:** The field [Field Label] on [Object Label] has no references in any Flow, Apex class, trigger, or page layout in the retrieved metadata.

**FLS Analysis:**
| Profile | Read Access | Edit Access |
|---------|------------|-------------|
| [Profile Name] | [Yes/No] | [Yes/No] |
| ... | | |

**FLS Summary:** [No profiles have access / X profiles have read access]

**Business impact:** [Clutter, confusion, wasted field license — tailor to client]

**Root cause:** [Field was deprecated / migrated / replaced but never cleaned up]

**Confidence:** [Confirmed / Likely — per decision tree above]

**Confidence rationale:** [No metadata references and no FLS in any profile — field is completely inaccessible. / No metadata references but FLS exists in X profiles — Workbench data check required before deletion.]

**Pre-deletion steps:**
- [ ] Confirm FLS status (see FLS Analysis above)
- [ ] If FLS exists: run Workbench COUNT query to confirm no data (`SELECT COUNT() FROM Object__c WHERE Field__c != null`)
- [ ] Remove field from all page layouts
- [ ] Delete field via Setup → Object Manager → [Object] → Fields & Relationships
- [ ] Retrieve metadata and commit to capture deletion

**Effort estimate:** 30 minutes (including data check)

---

## Technical Debt
*These are cleanup items with no immediate urgency, but left unaddressed they accumulate.*

- [Item 1] — [brief description and recommended action]
- [Item 2]
- [Item 3]

---

## Implementation Plan

| Priority | Finding | Effort | Recommended Timeline |
|----------|---------|--------|----------------------|
| 1 | | | Immediately |
| 2 | | | This week |
| 3 | | | This month |
| 4 | | | This quarter |

**Total estimated effort:** [X hours / Y days]

---

## About This Audit

This audit was conducted by retrieving your Salesforce org's metadata and analyzing it using Claude AI. The analysis covers configuration visible in the metadata — automations, field definitions, permission sets, page layouts, Apex code, and test classes.

**What this audit can and cannot detect:**

This analysis is based on metadata and cannot directly observe live data, actual test execution results, or external system behavior. Specifically:

- **Reports and list views** are not included in metadata retrieval — fields actively used in reports may appear unreferenced in this analysis. Verify before deleting any field.
- **External integration behavior** cannot be determined from metadata — integration-related findings are flagged for investigation and should be confirmed with your team before acting.
- **Live test coverage percentages** cannot be verified from metadata — structural coverage gaps are reliable findings, but exact percentages should be confirmed in the org.

Findings marked "Flag for investigation" require verification with your team or direct org access before implementing fixes. All findings should be reviewed by a qualified Salesforce administrator or developer before implementing changes.

---

## Next Steps

1. Review this report with your team
2. Confirm or investigate any findings marked "Flag for investigation"
3. Prioritize fixes based on business impact and available resources
4. Schedule implementation work with Cloud4Good
5. Plan a follow-up audit [timeframe] after fixes are implemented to verify resolution

---

*Report prepared by [Auditor Name] | Cloud4Good | [Date]*
*Questions? Contact [email]*
