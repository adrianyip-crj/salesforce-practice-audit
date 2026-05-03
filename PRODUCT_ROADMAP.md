# Org Health Audit — Product Roadmap

**Owner:** Adrian Yip | Cloud4Good
**Last Updated:** May 2, 2026
**Next Review:** After first pilot client completion

> For operational workflow and step-by-step instructions, see `AUDIT_SOP.md`. This document covers service strategy, positioning, and business planning only.

---

## Service Overview

A diagnostic service that pulls a client's complete Salesforce metadata, analyzes it using Claude AI, and delivers a findings report with specific, actionable recommendations. Optionally includes implementation of fixes.

**Key differentiator:** Cross-system analysis that catches dependency chains, broken automations, security gaps, and code drift that manual UI reviews miss — in hours, not days.

**Target market:** Mid-sized nonprofits and businesses (80-85% of Salesforce orgs)

**Delivery model:** Quarterly recurring + project-based implementations

---

## Service Tiers

### Initial Org Health Audit
Comprehensive first-time audit of a new client's Salesforce org.

**Timeline:** 1 business day
**Price:** $2,500 – $5,000 (report only) | $5,000 – $15,000 (with implementation)
**Best for:** New managed services clients, orgs not audited in 12+ months, post-acquisition due diligence, pre-migration assessment

### Quarterly Health Check
Ongoing monitoring for existing clients. Analyzes only what changed since last audit.

**Timeline:** 2–3 hours
**Price:** $1,500 – $2,500 per quarter | $5,000 – $8,000 annual contract (20% discount)
**Best for:** Existing managed services clients, compliance monitoring, change management validation

### Post-Implementation Verification
After implementing fixes, verify changes worked and didn't introduce new issues.

**Timeline:** 1–2 hours
**Price:** $500 – $1,000 (usually included in Audit + Implementation)
**Best for:** Before production deployments, compliance validation, client sign-off requirements

---

## Pricing Summary

| Service | Timeline | Price |
|---------|----------|-------|
| Initial Audit (report only) | 1 day | $2,500 – $5,000 |
| Initial Audit + Implementation | 1–2 weeks | $5,000 – $15,000 |
| Quarterly Health Check | 2–3 hours | $1,500 – $2,500 |
| Annual Contract (4 quarters) | Quarterly | $5,000 – $8,000 |
| Post-Implementation Verification | 1–2 hours | $500 – $1,000 |

---

## Competitive Differentiation

**vs. Manual UI Reviews**
- 10x faster (hours vs days)
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

**This service works for 80–85% of orgs:**
- Mid-sized nonprofits and regional businesses
- Small to mid-market enterprises
- Orgs with ~20–100 MB of metadata (zipped)
- Typical profile: 50–200 custom objects, 50–200 Flows, 100–500 Apex classes

**Alternative approach needed for 15–20% of orgs:**
- Fortune 500 enterprises, large financial institutions, large healthcare systems
- Orgs with >100 MB of metadata
- Solution: Domain-specific audits, phased approach, or hybrid with Gearset

---

## Success Metrics

**Per-audit:** Issues found by severity, time to complete, client satisfaction, % of recommendations acted on

**Business:** Clients on quarterly contracts, revenue per audit, repeat rate, referral rate

**Technical:** Average org size audited, most common issue types, fix success rate, Claude token usage per audit

---

## Implementation Roadmap

### Month 1: Build & Practice ✅
- ✅ Deploy practice org
- ✅ Run full practice audit (found all 7 intentional problems)
- ✅ Build retrieval script (`crj-retrieve.sh`)
- ✅ Document methodology in `AUDIT_SOP.md`
- [ ] Build findings report template
- [ ] Practice client presentation

### Month 2: Pilot
- [ ] Select 1–2 existing managed services clients
- [ ] Run initial comprehensive audits on real orgs
- [ ] Deliver findings reports
- [ ] Implement 2–3 fixes per client
- [ ] Measure time, outcomes, and methodology gaps

### Month 3: Refine & Scale
- [ ] Document lessons learned from pilot
- [ ] Update SOP based on real-org experience
- [ ] Establish standard pricing
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

1. How do we handle multi-org clients? (production + sandbox + multiple business units)
2. What is our SLA for audit turnaround? (same day? 48 hours?)
3. Do we offer emergency audits? (post-incident analysis)
4. How do we price for very small orgs? (startups, tiny nonprofits)
5. Should we certify in Gearset to offer an integrated service?
6. Do we need professional liability insurance for audit recommendations?
