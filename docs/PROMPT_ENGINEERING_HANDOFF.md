# Drift Pattern Detection - Prompt Engineering Handoff

**Date:** May 5, 2026  
**Purpose:** Define the Claude prompts that will systematically detect org drift patterns  
**Previous Context:** We've validated the drift patterns exist in CRJ org and defined detection methodology  
**Next Phase:** Build the specific prompts that generate tiered findings

---

## What We've Decided

### 1. Confidence Tier Framework

**Tier 1: CONFIRMED (High Confidence)**
- Structural contradictions provable from metadata alone
- No business context needed
- Safe to act on immediately
- Examples: FLS gaps, duplicate automations, permission contradictions

**Tier 2: LIKELY (Medium Confidence)**  
- Strong signals from metadata
- Single verification step needed (usually: check reports/list views in org)
- Examples: Fields with FLS but no references in automations

**Tier 3: NEEDS INVESTIGATION (Pattern Detected)**
- Pattern suggests issue but requires business context to confirm
- Client must validate intent
- Examples: Naming patterns suggesting deprecation, integration field mapping

---

### 2. Analysis Workflow

**Step 0: Business Discovery (BEFORE metadata pull)**
- Comprehensive business analysis already complete
- Captures: processes, user groups, tech stack, org structure
- Becomes the "theory" of how they think they operate today
- **This context is available during analysis**

**Step 1: Structural Analysis (Metadata + Business Context)**
- Compare business theory vs metadata reality
- Detect drift, contradictions, gaps
- Produce tiered findings

**Step 2: Client Review**
- Present findings by tier
- Ask targeted questions for FLAG items
- Validate LIKELY items

**Step 3: Prioritized Recommendations**
- Combine analysis + client input
- Prioritize by business impact

---

### 3. Field Usage - Complete Detection Scope

**Metadata to Check:**
- ✅ FLS (Profiles, Permission Sets) - **strongest signal**
- ✅ Flows (all types including Process Builders)
- ✅ Workflow Rules
- ✅ Validation Rules
- ✅ Sharing Rules (criteria can reference fields)
- ✅ Apex classes
- ✅ Page Layouts
- ✅ Formula fields / Roll-up Summaries

**Cannot Check (not in metadata):**
- ❌ Reports
- ❌ List Views  
- ❌ Dashboards

**Always caveat: "Cannot verify Report/List View usage - check in org"**

---

### 4. Field Usage - Tiered Detection

**Tier 1 - CONFIRMED UNUSED:**
```
Signal: No FLS granted to ANY profile or permission set
Meaning: Literally nobody can access this field
Action: Safe deletion after data verification
```

**Tier 2 - LIKELY UNUSED:**
```
Signal: Has FLS BUT no references in:
  - Flows, Workflows, Validation Rules, Sharing Rules
  - Apex, Layouts, Formulas
Cannot verify: Reports, List Views
Action: Check reports in org, verify no data, delete
```

**Tier 3 - NEEDS INVESTIGATION:**
```
Signal: Naming pattern suggests deprecation
Patterns to detect:
  - Explicit: Legacy_*, Old_*, Deprecated_*, Backup_*
  - Date: 2019_Campaign_ID__c vs 2024_Campaign_ID__c
  - Version: Status_v1__c vs Status_v2__c
  - Cluster: project1234_* all unused, project5678_* all used
Action: Confirm with client, then delete
```

---

### 5. Drift Patterns - Detection Requirements

**Can Detect from Metadata Alone (CONFIRMED):**
1. Duplicate automations (trigger + Flow on same object/event)
2. Permission gaps (FLS without object permission)
3. Low code coverage (methods not tested, weak assertions)
4. Flow fault path missing (external action with no fault connector)
5. Record type filter missing (Flow on multi-RT object without filter)
6. Unused fields (Tier 1 - no FLS)

**Requires Business Context (FLAG FOR INVESTIGATION):**
7. Integration + required fields (need field mapping document)
8. Sharing rule drift (need org structure confirmation)
9. Process migration (need confirmation old process replaced)
10. Unused fields (Tier 3 - naming patterns need client confirmation)

---

### 6. Sophistication Features to Implement

**Naming Pattern Detection:**
- Detect explicit deprecation words in API names
- Detect date/version progression patterns
- Cluster analysis (fields with same prefix, all unused vs all used)

**Call Graph Analysis:**
- Apex classes only called by test class
- Methods never invoked by production code
- Flows referencing non-existent Apex

**Cross-Component Impact:**
- Permission sets: FLS granted but object blocked
- Flow conditions that can never be true
- Required fields on integration staging objects

---

### 7. Finding Format (Standardized)

```
[TIER] - [Issue Type]

[Technical Details]
Field/Object/Component: [name]
Status/Signal: [what we detected]
References: [where it appears or doesn't appear]

Business Impact: [what breaks or what's at risk]

Recommendation: [specific action]
```

**No effort estimations** - too early to be confident

---

## What We Need to Build: The Prompts

### Prompt Categories Needed

**1. Field Usage Analysis Prompt**
- Generate Tier 1, 2, 3 findings
- Check all metadata types (FLS, Flows, Workflows, Validation, Sharing, Apex, Layouts)
- Detect naming patterns
- Output structured findings

**2. Automation Duplication Prompt**
- Find multiple automations on same object/event
- Compare actions between duplicates
- Flag overlapping behavior

**3. Permission Gap Prompt**
- Find FLS without object permission
- Find object permission without FLS (inverse case)
- Check permission set assignments (if available)

**4. Code Coverage Prompt**
- Find methods not called by tests
- Find weak test assertions (size > 0, != null only)
- Build call graph to identify dead code

**5. Flow Safety Prompt**
- Find external actions (email, callout, cross-object DML)
- Check for fault connector on each
- Flag missing fault paths

**6. Record Type Filter Prompt**
- Find objects with multiple record types
- Find Flows on those objects without RecordTypeId filter
- Flag potential unintended triggering

**7. Integration Risk Prompt**
- Find objects with integration naming patterns (*_Import__c, *_Staging__c)
- Find required fields on those objects
- Check if Apex/integration populates them
- Flag for investigation

**8. Sharing Rule Review Prompt**
- Extract current sharing model and role hierarchy
- Flag for review (cannot validate without business context)

---

## Validation Success Criteria

**Prompts are successful if they:**
- ✅ Catch 9/10 drift patterns in CRJ org
- ✅ Confidence tiers match reality (CONFIRMED vs LIKELY vs FLAG)
- ✅ Findings are specific and actionable
- ✅ False positive rate < 10%
- ✅ Findings reference exact files, line numbers where applicable

**Prompts need refinement if:**
- ❌ >2 patterns completely missed
- ❌ Findings too vague ("check this object")
- ❌ High false positive rate (>20%)
- ❌ Can't determine which tier to assign

---

## Context Available During Analysis

**From Business Discovery (Step 0):**
- Business process descriptions
- User roles and groups
- Integration platforms in use
- Expected automations
- Current org structure

**From Metadata:**
- All XML files from `sf project retrieve`
- File structure and relationships
- Field definitions, FLS grants, automation logic

**Not Available:**
- Actual execution logs
- Report/List View definitions
- User assignment data (who has which permission set)
- Integration platform field mappings

---

## Reference Materials

**Existing Documents:**
- `DRIFT_COVERAGE_SUMMARY.md` - How CRJ org maps to patterns
- `EXPECTED_FINDINGS_REFERENCE.md` - What Claude should find for each pattern
- `Common_Org_Drift_Patterns.md` - The 10 drift pattern definitions
- `Claude_in_Our_Workflow__Value_Proposition___Capabilities.md` - Why this matters

**CRJ Org Files:**
- Path: `~/salesforce-practice/force-app/`
- Contains: 7 intentional problems covering 8/10 drift patterns
- Use for prompt validation

---

## Next Steps (This Session)

1. **Define prompts** for each detection category
2. **Test prompts** against CRJ metadata (at least conceptually)
3. **Refine prompt structure** based on expected outputs
4. **Document prompt library** for SOP inclusion
5. **Identify gaps** - what can't be caught with prompts alone

---

## Questions to Answer During Prompt Development

**For each prompt:**
- What metadata files does it need to read?
- What's the analysis logic? (what to look for, what patterns to match)
- What's the output structure? (how to format findings)
- What tier does this finding belong in?
- What edge cases might create false positives?

**Overall workflow:**
- Should prompts run sequentially or can they be batched?
- How do we combine results across prompts?
- How do we de-duplicate findings? (same issue caught by multiple prompts)
- How do we present consolidated findings to client?

---

## Key Principles (Don't Forget)

1. **Tier assignment is critical** - CONFIRMED must be provable, FLAG must acknowledge what we don't know
2. **Business context matters** - Step 0 context informs analysis, but can't replace client validation
3. **Caveats are required** - Always note "cannot verify in Reports/List Views"
4. **Specificity over volume** - One specific finding > three vague ones
5. **Sophistication is optional** - Naming pattern detection is "nice to have", structural checks are must-have

---

## Success Looks Like

**Prompt library that produces:**
```
=== CONFIRMED ISSUES (Act Now) ===
5 findings - structural contradictions, safe to fix

=== LIKELY ISSUES (Verify First) ===
3 findings - strong signals, single verification step needed

=== NEEDS INVESTIGATION (Client Input Required) ===
2 findings - patterns detected, business context needed for confirmation

Total: 10 specific, actionable findings with clear next steps
```

**NOT this:**
```
Found 47 potential issues. Review the following objects...
[vague list of things to manually check]
```

---

**Ready to build the prompts?**
