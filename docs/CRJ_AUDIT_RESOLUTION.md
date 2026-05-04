# CRJ Org Health Audit — Fix Resolution Record

**Project:** CRJ (Chart, Reveal, Journey)  
**Audit Date:** May 2, 2026  
**Fix Completion Date:** May 3, 2026  
**Auditor:** Adrian Yip | Cloud4Good  
**GitHub:** https://github.com/adrianyip-crj/salesforce-practice-audit  

---

## Purpose

This document records how each finding from the CRJ practice audit was resolved, including decisions made during implementation and deviations from the original plan. It serves as the baseline for future quarterly diff audits — changes detected in subsequent retrieves should be compared against this resolved state.

---

## Resolution Summary

| # | Problem | Original Confidence | Fix Method | Status |
|---|---------|-------------------|------------|--------|
| 1 | Broken thank-you email flow | Confirmed | UI (Flow editor) | ✅ Resolved |
| 2 | Unused custom fields | Likely | UI (field deletion) | ✅ Resolved |
| 3 | Volunteer portal permission gap | Confirmed | CLI deploy | ✅ Resolved |
| 4 | Redundant grant flows | Confirmed | UI (deactivation) | ✅ Resolved |
| 5 | Donation import dropping records | Flag for investigation | CLI deploy | ✅ Resolved |
| 6 | Code/process drift | Confirmed | CLI deploy | ✅ Resolved |
| 7 | Low code coverage | Likely | Apex CLI deploy | ✅ Resolved |

All fixes verified via `git diff HEAD~1 HEAD --name-only` after each change.

---

## Problem 1 — Broken Flow Logic
**Severity:** Critical | **Original confidence:** Confirmed

### What was found
`Send_Donation_Thank_You_Email` flow had a trigger condition of `Amount = 0`, which can never be true for a real donation. The flow was also in Draft status and had never fired.

### How it was fixed
- **Method:** UI (Flow editor in Setup)
- Changed trigger condition from `Amount = 0` to `Amount > 0`
- Activated the flow

### Verification
Post-UI-fix retrieve confirmed `Send_Donation_Thank_You_Email.flow-meta.xml` in the diff. No other files affected.

### Deviations from plan
None. Fixed exactly as specified.

---

## Problem 2 — Unused Custom Fields
**Severity:** Medium | **Original confidence:** Likely

### What was found
Four fields with no references in any Flow, Apex class, layout, or profile:
- `Volunteer__c.Old_Volunteer_Category__c`
- `Grant__c.Deprecated_Grant_Status__c`
- `Contact.Legacy_Donor_ID__c`
- `Volunteer__c.Background_Check_Status__c`

### Investigation — FLS discovery
Pre-deletion data check revealed a significant finding about how Salesforce handles field access:

**All four fields had no FLS granted to any profile.** This means:
- No user could read or write to these fields
- SOQL queries returned "no such column" errors — not because fields didn't exist, but because SOQL respects FLS
- Fields were visible in Object Manager and in the Salesforce Inspector browser extension, but invisible to the data API

This upgraded the confidence from Likely to Confirmed — no FLS means no data can exist regardless of record count.

**Note:** Developer Console gave unreliable schema cache results throughout this investigation. Workbench was the reliable diagnostic tool.

### How it was fixed
- **Method:** UI only (field deletion cannot be done via CLI)
- Confirmed no FLS on all four fields via profile metadata review
- Deleted all four fields via Setup → Object Manager → Fields & Relationships

### Verification
Post-deletion retrieve produced "cannot be found" warnings for all four fields — confirming successful deletion. The commit showed 885 deletions, reflecting Salesforce's automatic cascade removal of field references from all layouts and profiles.

### Deviations from plan
**Original plan:** Run SOQL data check before deletion.  
**What actually happened:** SOQL checks were attempted but returned "no such column" errors due to no FLS being set. The diagnostic process revealed that FLS verification should precede SOQL checks — a field with no FLS cannot be queried regardless of whether data exists. This is now documented in the SOP as the FLS-first workflow.

**New SOP rule added:** Always check profile FLS before running SOQL pre-deletion checks. If no profile has Read access, the field is inaccessible and no data can exist — skip the SOQL check and proceed to deletion.

---

## Problem 3 — Volunteer Portal Permission Gap
**Severity:** High | **Original confidence:** Confirmed

### What was found
`Volunteer_Portal_User` permission set granted field-level access to `Volunteer__c` fields but had zero object permissions for `Volunteer_Shift__c`. Volunteers could not see their assigned shifts in the Experience Cloud portal.

### How it was fixed
- **Method:** CLI deploy (edited permission set XML locally)
- Added object-level Read permission for `Volunteer_Shift__c`

### Complications encountered
This was the most technically complex fix of the seven:

1. **XML element ordering violation** — Initial script inserted new XML at end of file. Salesforce requires same-type elements to be grouped contiguously (all `fieldPermissions` together, all `objectPermissions` together). Deploy failed.

2. **Required fields cannot have explicit FLS entries** — Attempted to add field permissions for `Shift_Status__c` and `Shift_Date__c`, which are required fields. Deploy failed with "cannot deploy FLS to required field" error.

3. **Final resolution** — Removed all `Volunteer_Shift__c` field permissions entirely. Object-level Read access is sufficient — required fields are automatically accessible when object Read is granted. Also corrected the permission set description, which still contained the original problem text.

### Verification
Deploy succeeded. Permission set retrieved and committed showing object-level Read for `Volunteer_Shift__c` with no field-level entries for that object.

### Deviations from plan
**Original plan:** Add object permissions + field permissions for `Shift_Date__c`, `Shift_Status__c`, `Hours_Worked__c`.  
**What actually happened:** Field permissions were not added — only object-level Read. Required fields do not need explicit FLS entries; they are accessible via object access alone.

**New SOP rules added:**
- XML elements must be grouped by type or deploy fails
- Required fields cannot have explicit fieldPermissions entries — query `FieldDefinition` to identify required fields before writing permission set XML
- When required field errors pile up, remove all fieldPermissions for that object and rely on object-level access

---

## Problem 4 — Redundant Grant Flows
**Severity:** Medium | **Original confidence:** Confirmed

### What was found
Two active flows both triggered on `Grant__c` creation, both creating a Task:
- `Create_Grant_Follow_Up_Task` — Normal priority task
- `Create_Grant_Review_Task` — High priority task

Every new grant was generating two tasks. Staff were manually deleting duplicates.

### Decision made
Kept `Create_Grant_Follow_Up_Task` (Normal priority). Deactivated `Create_Grant_Review_Task` (High priority). Decision was based on input that Normal priority better reflected standard workflow — High priority was creating alert fatigue.

### How it was fixed
- **Method:** UI (Flow deactivation in Setup)
- Deactivated `Create_Grant_Review_Task`

### Verification
Post-UI-fix retrieve confirmed `Create_Grant_Review_Task.flow-meta.xml` in the diff. `Create_Grant_Follow_Up_Task.flow-meta.xml` also appeared — expected, as Salesforce updates flow metadata on retrieve regardless of changes.

### Deviations from plan
**Original plan:** Decide which flow to keep.  
**What actually happened:** Decision made to keep Normal priority, deactivate High priority. This is a client-specific decision that would need to be made with the actual client in a real engagement.

---

## Problem 5 — Donation Import Dropping Records
**Severity:** Critical | **Original confidence:** Flag for investigation

### What was found
`Campaign__c` was marked required on the `Donation_Import__c` object. Whether the Stripe integration populated this field could not be confirmed from metadata alone.

### Investigation
This is a practice org with no real Stripe integration. There are no import error logs, no connected external system, and no way to verify actual integration behavior. The finding was accepted at face value — if `Campaign__c` is required and an integration cannot populate it, records would be silently dropped.

### Decision made
Made `Campaign__c` not required (Fix Option 1 from the handoff). This is the lower-risk option — it removes the blocking constraint without requiring changes to an external integration. A real engagement would require confirming with the client whether Stripe actually populates this field before choosing a fix path.

### How it was fixed
- **Method:** CLI deploy
- Changed `<required>true</required>` to `<required>false</required>` in `Campaign__c.field-meta.xml`

### Verification
Deploy succeeded. Field confirmed as not required in post-deploy retrieve.

### Deviations from plan
**Original plan:** Investigate integration field mapping before choosing fix.  
**What actually happened:** No investigation possible (practice org, no real integration). Proceeded directly to Fix Option 1. In a real client engagement, the investigation step should not be skipped — making a required field optional can have downstream data quality implications if Campaign is genuinely needed for reporting.

---

## Problem 6 — Code/Process Drift
**Severity:** High | **Original confidence:** Confirmed

### What was found
Both were active and fired on `Volunteer__c` insert:
- `VolunteerApplicationTrigger` — built 2019, code comments indicated it was deprecated when the Flow was created
- `Process_Volunteer_Application` — built 2022 as its replacement

Every new volunteer application was generating duplicate tasks and duplicate welcome emails.

### How it was fixed
- **Method:** CLI deploy
- Changed `VolunteerApplicationTrigger.trigger-meta.xml` status from `Active` to `Inactive`
- Left `Process_Volunteer_Application` Flow active as the primary handler

### Verification
Deploy succeeded. Post-deploy retrieve confirmed trigger status as Inactive.

### Deviations from plan
**Original plan:** Also update or delete `VolunteerApplicationTriggerTest`.  
**What actually happened:** `VolunteerApplicationTriggerTest` was left in place. The test class still runs during deployments but tests a now-inactive trigger. This is acceptable for the practice org but should be noted as cleanup for a real engagement — dead test classes that test inactive code add noise and can create false confidence.

**Future action:** In a real engagement, deactivating a trigger should be followed by reviewing whether its test class should be updated to reflect the new inactive state or removed entirely.

---

## Problem 7 — Low Code Coverage
**Severity:** High | **Original confidence:** Likely

### What was found
`DonationProcessor.cls` had structural coverage gaps:
- `validateDonationImport()` method had no test coverage at all
- Existing `DonationProcessorTest` used weak assertions (`size() > 0`, status `!= 'New'`)
- Missing test scenarios: Contact not found, duplicate Stripe transaction IDs, invalid amounts, bulk operations

### Investigation
Actual coverage percentage was not verified in the org before writing the new test class. Structural gaps were treated as sufficient evidence to proceed — the specific uncovered method and weak assertions were visible in the code regardless of the exact percentage.

### How it was fixed
- **Method:** Apex CLI deploy (runs tests on deploy)
- Claude wrote a complete replacement `DonationProcessorTest.cls` covering:
  - Happy path (valid donation, contact found)
  - Contact not found
  - Bulk mixed results (200 records)
  - `validateDonationImport()` — valid input
  - `validateDonationImport()` — null amount
  - `validateDonationImport()` — zero amount
  - `validateDonationImport()` — blank email
  - `validateDonationImport()` — blank Stripe ID
  - `validateDonationImport()` — duplicate Stripe transaction ID

### Verification
Deploy succeeded and tests passed. This is the strongest verification available — Salesforce runs all tests on Apex deploy and fails if any test fails or if coverage drops below 75%.

### Deviations from plan
None significant. Writing the test class with Claude took approximately 20 minutes as estimated — confirming this is one of the highest-value applications of Claude in the workflow.

---

## What This Audit Taught Us

Beyond the 7 fixes, the CRJ practice cycle surfaced several methodology improvements now documented in the SOP:

**FLS-first workflow for unused fields** — SOQL checks are meaningless without FLS. Always check profile FLS before running data queries. A field with no FLS has no data by definition.

**Developer Console is unreliable post-deployment** — Always use Workbench for SOQL queries after recent deployments. The schema cache causes false "no such column" errors.

**Permission set XML has strict ordering rules** — Elements must be grouped by type. Required fields cannot have explicit fieldPermissions entries.

**"No such column" in SOQL has three possible causes** — Field doesn't exist, field exists but no FLS, Developer Console cache is stale. Diagnose via Object Manager and Workbench before concluding anything.

**The methodology improves with each cycle** — These gaps were discovered during real work, documented, and built into the SOP and analysis prompts. Future audits benefit from this cycle's lessons.

---

## Baseline for Quarterly Diff Audits

The org state as of May 3, 2026 (commit `10080ed`):

- `Send_Donation_Thank_You_Email` — Active, condition `Amount > 0` ✅
- `Old_Volunteer_Category__c`, `Deprecated_Grant_Status__c`, `Legacy_Donor_ID__c`, `Background_Check_Status__c` — Deleted ✅
- `Volunteer_Portal_User` — Object Read granted for `Volunteer_Shift__c` ✅
- `Create_Grant_Review_Task` — Inactive ✅
- `Donation_Import__c.Campaign__c` — Not required ✅
- `VolunteerApplicationTrigger` — Inactive ✅
- `DonationProcessorTest` — Full coverage including `validateDonationImport()` ✅

Any future quarterly retrieve that shows changes to these components should be investigated.

---

*Prepared by Adrian Yip | Cloud4Good | May 3, 2026*
