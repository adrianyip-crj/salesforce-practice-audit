# Org Health Audit — Product Roadmap

**Owner:** Adrian Yip | Cloud4Good  
**Last Updated:** May 3, 2026  
**Next Review:** After first pilot client completion

> For operational workflow and step-by-step instructions, see `AUDIT_SOP.md`. This document covers service strategy, positioning, and business planning only.

> **Note:** This document reflects the state of the service after the CRJ practice audit. Sections marked with ⚠️ contain assumptions that have not yet been validated on real client orgs.

---

## Service Overview

A diagnostic service that pulls a client's complete Salesforce metadata, analyzes it using Claude AI, and delivers a findings report with specific, actionable recommendations. Optionally includes remediation of findings.

**Key differentiator:** Cross-system analysis that catches dependency chains, broken automations, security gaps, and code drift that manual UI reviews miss — in hours, not days.

**Target market:** Mid-sized nonprofits and businesses (80-85% of Salesforce orgs) ⚠️ *Assumption: not yet validated on real client orgs*

**Delivery model:** Quarterly recurring + project-based remediation

---

## Service Tiers

### Initial Org Health Audit
Comprehensive first-time audit of a new client's Salesforce org.

**Best for:** New managed services clients, orgs not audited in 12+ months, post-acquisition due diligence, pre-migration assessment

### Quarterly Health Check
Ongoing monitoring for existing clients. Analyzes only what changed since last audit using Git diff — uploads only changed files rather than the full org snapshot.

**Best for:** Existing managed services clients, compliance monitoring, change management validation

### Post-Fix Verification
After remediating findings, verify changes worked and didn't introduce new issues. Pull updated metadata, compare before/after via Git diff, confirm fixes resolved issues without side effects.

**Best for:** Before production deployments, compliance validation, client sign-off requirements

---

## Competitive Differentiation

**vs. Manual UI Reviews**
- Faster — hours not days ⚠️ *Time savings validated on practice org only, not real client orgs*
- Catches cross-system issues humans miss clicking through Setup
- Repeatable, documented, consistent across auditors

**vs. Gearset / Copado**
- Strategic analysis, not just deployment comparison
- Understands business logic, not just technical changes
- Finds the "why" not just the "what"

**vs. Salesforce Health Check**
- Org-specific recommendations, not generic best practices
- Finds drift and debt unique to the client's configuration

---

## Target Org Profile

**This service works well for:** ⚠️ *Based on Claude context window constraints — not yet validated on real client orgs*
- Mid-sized nonprofits and regional businesses
- Small to mid-market enterprises
- Orgs with ~20–100 MB of metadata (zipped)
- Typical profile: 50–200 custom objects, 50–200 Flows, 100–500 Apex classes

**Alternative approach needed for larger orgs:**
- Enterprise orgs, large financial institutions, large healthcare systems
- Orgs with >100 MB of metadata
- Solution: Domain-specific audits, phased approach, or hybrid with Gearset

---

## Service Constraints

### Org Size
Claude's context window limits how much metadata can be analyzed in a single session. Practical limit is approximately 100 MB of zipped metadata for a comprehensive audit. Quarterly diff audits bypass this limitation since only changed files are uploaded.

### Manual Upload Requirement
Files must be manually uploaded to Claude chat or project. There is no automated pipeline from GitHub to Claude — each audit session requires file selection and upload. This is a known workflow friction point and a candidate for future automation.

---

## Success Metrics

**Per-audit:** Issues found by severity, client satisfaction, percentage of recommendations acted on ⚠️ *No real-client data yet*

**Business:** Clients on quarterly contracts, repeat rate, referral rate ⚠️ *No real-client data yet*

**Technical:** Average org size audited, most common issue types, fix success rate, Claude token usage per audit ⚠️ *No real-client data yet*

---

## Implementation Roadmap

### Month 1: Build & Practice ✅
- ✅ Deploy practice org
- ✅ Run full practice audit (found all 7 intentional problems)
- ✅ Implement all 7 fixes end-to-end
- ✅ Verify all fixes via Git diff
- ✅ Build retrieval script (`crj-retrieve.sh`)
- ✅ Document methodology in `AUDIT_SOP.md`
- ✅ Build findings report template (`FINDINGS_REPORT_TEMPLATE.md`)
- ✅ Build audit prompts (`CLAUDE_AUDIT_PROMPTS.md`)
- ✅ Document CRJ resolution record (`CRJ_AUDIT_RESOLUTION.md`)
- ✅ Document Claude's role in workflow (`Claude_in_Our_Workflow.md`)
- [ ] Practice client presentation

### Month 2: Pilot
- [ ] Select 1–2 existing managed services clients (orgs you know well)
- [ ] Run initial comprehensive audits on real orgs
- [ ] Deliver findings reports
- [ ] Implement 2–3 fixes per client
- [ ] Measure time, outcomes, and methodology gaps
- [ ] Validate FLS-first unused field workflow on real orgs
- [ ] Document what breaks or behaves differently on real orgs vs practice org

### Month 3: Refine & Scale
- [ ] Update SOP based on real-org experience
- [ ] Remove ⚠️ assumption flags validated by pilot
- [ ] Establish standard pricing based on actual time measurements
- [ ] Pitch to leadership
- [ ] Add to service catalog

### Quarter 2: Growth
- [ ] Onboard 5–10 clients to quarterly program
- [ ] Build case studies
- [ ] Train additional team members
- [ ] Track ROI and client satisfaction

---

## Future Enhancements

**Diff-packaging script (High priority)** — Automatically zip only changed files for quarterly audit uploads. Currently handled manually.

**Claude project templates (Medium priority)** — Pre-configured Claude setups for each audit type for consistent quality across auditors.

**Automated reporting (Low priority)** — Generate formatted client reports from structured Claude output.

**Gearset integration (Low priority)** — Full end-to-end workflow from audit through validated deployment.

---

## Open Questions

1. **Multi-org clients** — Clients with production + UAT + sandbox (or multiple business units) present a workflow challenge. Each org is its own metadata universe needing a separate repo and separate audit session. Orgs can be in different states — fixes deployed to UAT but not prod, sandbox lagging behind both. Questions to resolve: which org do we audit first, how do we correlate findings across orgs, and how do we track the state of fixes across multiple environments?

2. **SLA for turnaround** — What is our committed turnaround time? Same day? 48 hours? Needs to be defined before going to market.

3. **Emergency audits** — Do we offer post-incident analysis on short notice? What does that look like operationally?

---

*Document Owner: Adrian Yip | Cloud4Good*  
*Last Updated: 2026-05-03*  
*Next Review: After first pilot client completion*
