# Claude in Our Workflow: Value Proposition & Capabilities

**Internal Documentation**  
*Last Updated: May 3, 2026*  
*Owner: Adrian Yip*

---

## Executive Summary

Claude is not a replacement for consultant expertise. It's a force multiplier that translates massive technical metadata into business-intelligible insights, allowing our consultants to think strategically instead of getting bogged in technical details.

**The core value:** Our consultants can now ask "what contradictions exist between what the client *thinks* their org does and what it *actually* does?" and Claude surfaces those contradictions systematically.

---

## The Translator Role

### What Claude Does

Claude converts technical metadata (XML, JSON, configuration files) into semantic meaning that connects to business intent.

**Example:**
- **XML says:** Flow `Send_Donation_Thank_You_Email` has trigger condition `Amount = 0`
- **Business context:** "We want to thank every donor for their gift"
- **Claude observes:** Condition logic contradicts business intent. Donors with $0 gifts don't exist. This Flow never fires.
- **Output:** "Your thank-you email Flow has a logical error. It will never send emails."

### Why This Matters

A script or tool can flag unusual syntax. Only something that understands *intent* can spot the contradiction between configuration and reality.

**Manual consultant process (6+ hours):**
1. Click through Salesforce Setup
2. Read Flow triggers, conditions, actions
3. Compile notes
4. Cross-reference with business goals (requires memory/context)
5. Manually identify gaps and contradictions
6. Miss some issues because context is fragmented

**Claude-assisted process (30 minutes + Claude analysis):**
1. Consultant talks to client: "What are your key automation goals?"
2. Consultant feeds Claude the metadata + business context
3. Claude reads everything at once, traces dependencies, identifies contradictions
4. Consultant reviews Claude's findings for accuracy
5. Consultant focuses on *why* things are broken and *how to fix them*

---

## Specific Capabilities

### 1. Cross-System Pattern Recognition

Claude reads the entire org at once and traces how things connect:
- Which Flows reference which objects
- Which Apex classes fire on which triggers
- Which permission sets enable which features
- Which integrations depend on which fields

**Manual approach:** Consultant traces these one at a time, often misses connections.  
**Claude approach:** "Here are all the dependencies in your donation workflow. Here's where they break."

**The hardest class of problem:** Component A breaks because of component B it doesn't know exists. An Apex class inserting an Opportunity can be blocked by a Flow it never references — because the Flow fires as a trigger on Opportunity creation. Finding this requires holding Apex, DML behavior, Flow triggers, and email actions in context simultaneously. That's not a thread to follow — it's systemic awareness.

### 2. Semantic Contradiction Detection

Claude understands business logic and spots when configuration contradicts it:
- Flow conditions that will never be true
- Processes that do the same thing twice (redundancy)
- Permission sets that block intended features
- Fields that should be required but aren't
- Apex code that tests logic that no longer exists in the org

**Manual approach:** Requires consultant to hold all context in mind simultaneously.  
**Claude approach:** Systematic comparison of intent vs. reality across the entire org.

### 3. Technical Debt Identification

Claude can read code and understand what it does, then identify:
- Apex classes with low test coverage
- Test classes that don't actually test anything meaningful
- Code that was written for processes that have since changed
- Unused classes and fields cluttering the org
- Dependencies that make changes risky

**Manual approach:** Code review takes hours and requires context switching.  
**Claude approach:** "Here's what your code tests, here's what your org actually does, here's where they've drifted."

### 4. Prioritization Based on Impact

Claude can analyze:
- Which problems affect the most users
- Which issues block deployments or integrations
- Which failures cause data loss
- Which technical debt slows down future development

**Manual approach:** Consultant estimates impact based on experience.  
**Claude approach:** Data-driven prioritization based on actual usage and dependencies.

---

## Before and After: How Consultant Time Shifts

### Before (Manual Audit)

| Activity | Time | Outcome |
|----------|------|---------|
| Navigate Salesforce UI, click through Setup | 3-4 hours | Incomplete picture, context fragmented |
| Read Flows, triggers, conditions | 1-2 hours | Understanding limited to individual components |
| Check permission sets | 30 min | Manual spot-checking |
| Review Apex code | 1-2 hours | Time-consuming, error-prone |
| Compile findings | 1-2 hours | Manual document creation |
| **Total** | **6-10 hours** | Limited accuracy, missed connections |

### After (Claude-Assisted Audit)

| Activity | Time | Outcome |
|----------|------|---------|
| Consultant provides business context to Claude | 30 min | Claude has full intent picture |
| Claude analyzes complete metadata (parallel) | 2-3 hours (async) | Comprehensive cross-system analysis |
| Consultant reviews Claude's findings | 1-2 hours | Validates accuracy, adds business judgment |
| Consultant develops implementation strategy | 1-2 hours | Prioritized, actionable recommendations |
| **Total** | **4-6 hours** | Comprehensive, accurate, prioritized |

**Key shift:** Consultant moves from *information gathering* to *strategic judgment and implementation planning*.

---

## Real Example: The 7 Practice Flaws

This is what Claude enables your team to see:

### Problem #1: Broken Flow Logic
- **XML:** Flow condition `Amount = 0` on donation trigger
- **Business context:** "We send thank you emails to all donors"
- **Claude finds:** Logical contradiction. Condition will never evaluate true.
- **Consultant impact:** Can immediately explain to client: "Your thank you emails aren't sending. Here's why. Here's the fix."
- **Without Claude:** Would spend 30 minutes clicking through the Flow, might miss the logic error entirely.

### Problem #6: Code/Process Drift
- **XML:** Both `VolunteerApplicationTrigger` (Apex) and `Process_Volunteer_Application` (Flow) are active
- **Business context:** "We process volunteer applications through our new Flow system"
- **Claude finds:** Both mechanisms firing simultaneously, creating duplicate tasks and emails
- **Consultant impact:** Can explain the risk and provide exact deactivation/cleanup plan
- **Without Claude:** Would need deep code review and Flow analysis to spot this, easy to miss the duplication

### Problem #7: Low Code Coverage
- **XML:** `DonationProcessor` class with 60% coverage, `validateDonationImport()` untested
- **Metadata:** Method exists in class but isn't called by any test
- **Claude finds:** Specific gap in what's tested, blocking production deployment, and explains the risk
- **Consultant impact:** Can deliver: "Your tests are incomplete. Here's the specific method with no coverage. Here's a test class to fix it."
- **Without Claude:** Would need to manually read test class, trace method calls, count coverage — 1-2 hours of tedious work

### Bonus: Cross-System Failure Chain (discovered during fix phase)
This example emerged during implementation and illustrates the deeper value of systemic analysis.

- **Situation:** New test class for `DonationProcessor` was written and deployed. Tests kept failing with zero Opportunities created, even after fixing the Apex code itself.
- **Root cause:** Inserting a `Closed Won` Opportunity with `Amount > 0` triggers `Send_Donation_Thank_You_Email`. That Flow has no fault handler on its email action. In test context, the email fails. The Flow throws an unhandled fault. Salesforce rolls back the entire Opportunity insert. The Apex class never errors — the DML is blocked upstream by an automation it knows nothing about.
- **What systemic analysis sees:** `DonationProcessor.cls` → inserts Opportunity → triggers Flow on Opportunity → Flow sends email → email fails → fault bubbles up → insert blocked. None of these files reference each other. The connection only exists at runtime.
- **What manual review misses:** A consultant reviewing `DonationProcessor.cls` in isolation would see clean code. A consultant reviewing the Flow in isolation would see an active automation. Neither would spot the interaction without holding the entire system in context.
- **The finding:** Flow with no fault path on an email action is also a latent production risk. If the email service is temporarily unavailable, Opportunity creation silently fails in production. No error, no alert — donations just stop being recorded.
- **Without systemic analysis:** This class of bug — where component A breaks because of component B it doesn't know exists — is nearly impossible to find in a manual review.

---

## What Claude Enables Your Team To Do

### For Consultants

1. **See the whole org at once** — Instead of piecing together understanding from individual components
2. **Ask better questions** — Business context + metadata analysis = smarter investigation
3. **Find deeper problems** — Cross-system dependencies and contradictions that manual review misses
4. **Move to strategic thinking faster** — Spend less time gathering data, more time on recommendations
5. **Provide specific fixes** — Claude can draft actual corrected Flows, test classes, permission sets

### For Clients

1. **Faster turnaround** — Comprehensive audit in 1 day instead of 1 week
2. **More comprehensive findings** — Catches cross-system issues manual review misses
3. **Better recommendations** — Prioritized by actual impact, not guessing
4. **Specific fixes, not just problems** — "Here's what's broken" + "Here's how to fix it"

### For the Business

1. **Higher-margin service** — Faster delivery + AI leverage = better profit
2. **Repeatable methodology** — Standardized process across clients
3. **Competitive advantage** — Deeper analysis than competitors still doing manual reviews
4. **Scalable without linear hiring** — One consultant + Claude can handle more audits than one consultant alone

---

## Capabilities by Problem Type

| Problem Type | Claude Reliability | Manual Detection | Claude Advantage |
|--------------|-------------------|------------------|------------------|
| Unused fields | **Medium-High*** | Medium (easy to miss) | Systematic scan — but requires explicit FLS prompting |
| Broken Flow logic | High | Medium (requires reading) | Spots logical contradictions |
| Redundant automations | High | Medium (hard to spot across objects) | Cross-system pattern recognition |
| Permission set gaps | High | Low (tedious manual checking) | Traces requirements vs. permissions |
| Code/process drift | High | Low (requires code expertise) | Semantic understanding of intent vs. reality |
| Low test coverage | Very High | High (but tedious) | Specific gap identification + fix generation |
| Data integration issues | High | Medium (requires testing data) | Traces field requirements through flows |

**Key insight:** Claude is strongest where manual review is most tedious or error-prone (cross-system analysis, code understanding, logical contradictions).

*\*Unused field reliability is conditional. Profile metadata is retrieved and Claude has FLS data available, but Claude must be explicitly prompted to cross-reference field references against profile FLS settings. Without that prompt, unused field findings may be incomplete or incorrectly tiered. See AUDIT_SOP.md — Unused Field Analysis section.*

---

## Known Analysis Blind Spots

These are gaps discovered during the CRJ practice audit cycle that affect finding accuracy:

### 1. Field Usage Analysis - Three-Tier Methodology

Claude uses a tiered confidence framework for identifying unused fields:

**Tier 1 - CONFIRMED UNUSED (No FLS Granted)**  
Fields with no field-level security granted to any profile or permission set are provably unused — literally nobody in the org can access them. These are safe deletion candidates after data verification.

**Tier 2 - LIKELY UNUSED (Has FLS, No References)**  
Fields with FLS but no references in automations (Flows, Workflows, Process Builders, Validation Rules, Sharing Rules), Apex code, page layouts, or formulas are likely unused. Caveat: Report and List View usage cannot be determined from metadata and must be verified in the org before deletion.

**Tier 3 - NEEDS INVESTIGATION (Naming Patterns)**  
Fields with naming patterns suggesting deprecation (Legacy_*, Old_*, Deprecated_*, version numbers, date patterns) or cluster analysis showing multiple fields with the same prefix all unused require client confirmation of deprecation intent.

**This FLS-first methodology** makes field-level security analysis the foundation of unused field detection, with clear confidence tiers based on available metadata signals.

### 2. Reports and List Views Are Invisible
Fields actively used in reports or list views will not appear in any retrieved metadata type. A field may look completely unused in metadata while being referenced in a key operational report. Always include this caveat when recommending field deletion to clients.

### 3. Integration Behavior Is Invisible
What an external system (Stripe, Mailchimp, etc.) actually sends or doesn't send cannot be determined from metadata alone. Integration-related findings should always be classified as "Flag for investigation" and confirmed with the client before acting.

### 4. Live Test Coverage Cannot Be Verified
Claude can identify weak test structure by reading code, but cannot run tests or check actual coverage percentages. Structural issues (uncovered methods, weak assertions) are reliable findings. Specific coverage percentages must be verified in the org.

---

## How This Scales

### Phase 1: Single Consultant + Claude (Current)
- 2-3 audits per quarter
- Comprehensive analysis + human review + recommendations
- Cost: Claude license (~$20-30/month)
- ROI: Faster delivery, better quality, consultant upleveled

### Phase 2: Multiple Consultants + Claude
- 10+ audits per quarter
- Standardized methodology across team
- Claude handles analysis, consultants do validation + strategy
- Cost: Claude license + time to scale process
- ROI: Scales without hiring proportionally

### Phase 3: Recurring Quarterly Checks
- Diff-based analysis (only changed files)
- Lower token usage, faster turnaround
- Automated packaging and reporting (future enhancement)
- Cost: Minimal (small diffs, fast analysis)
- ROI: High margin recurring revenue

---

## Limitations & Safeguards

### What Claude Can't Do

1. **Guarantee 100% accuracy** — Findings need human validation before client delivery
2. **Replace consultant judgment** — Business context and risk assessment are human decisions
3. **Handle extremely large orgs** (>100 MB metadata) — Orgs beyond mid-market size need different approach
4. **Automate implementation** — Fixes still require careful deployment and testing
5. **Assess field utility without explicit FLS prompting** — Claude has profile metadata but must be asked to cross-reference it against field references. Unused field findings produced without this step should be treated as Likely, not Confirmed.
6. **See reports, list views, or live integration behavior** — These are invisible in metadata and require client input to assess

### Quality Safeguards

1. **Human review gate** — All findings validated by consultant before delivery
2. **Confidence labeling** — Flag findings that need extra review vs. high-confidence issues
3. **Context requirement** — Claude needs business context from consultant to be effective
4. **Validation in pilots** — First 2-3 audits prove methodology before scaling

---

## Next Steps

### Practice Audit (Complete ✅)
- [x] Find all 7 intentional problems in test org
- [x] Document what Claude caught vs. missed
- [x] Note where human judgment was needed
- [x] Document accuracy of analysis
- [x] Implement all 7 fixes end-to-end
- [x] Verify fixes via Git diff
- [x] Build and validate SOP

### Pilot Clients (Next)
- [ ] Run audits on real client orgs you know well
- [ ] Compare Claude findings to your own knowledge
- [ ] Measure client perception of value
- [ ] Document ROI (time saved, problems found, fixes delivered)
- [ ] Validate FLS-first unused field workflow on real orgs

### Scaling (Methodology)
- [ ] Standardize findings report format
- [ ] Build quality gates and validation checklists
- [ ] Document which problem types need extra review
- [ ] Train team on new workflow

---

## Key Takeaway

Claude transforms consultant work from *information gathering* (time-intensive, error-prone) to *strategic analysis and implementation* (higher-value, higher-margin).

The license isn't just a tool cost — it's an investment in making your team more capable and your service delivery faster and deeper.

The practice audit also revealed something important: **the methodology improves with use.** Gaps discovered during real work — like the FLS blind spot in unused field analysis — get documented, added to the SOP, and built into future analysis prompts. The system gets better each cycle.

---

**Document Owner:** Adrian Yip  
**Last Updated:** 2026-05-03  
**Next Review:** After first pilot client completion
