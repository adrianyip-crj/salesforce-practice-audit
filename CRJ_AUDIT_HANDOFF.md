# CRJ Org Health Audit — Fix Recommendations Handoff

**Project:** CRJ (Chart, Reveal, Journey)
**Audit Date:** May 2, 2026
**Auditor:** Adrian Yip | Cloud4Good
**GitHub:** https://github.com/adrianyip-crj/salesforce-practice-audit
**Local path:** `~/salesforce-practice/force-app/`

---

## Context

This is a practice audit on a fictional nonprofit Salesforce org built with 7 intentional problems. The metadata was retrieved using the CRJ retrieval script and analyzed by Claude across 253 files including Apex classes, triggers, flows, custom objects, layouts, profiles, and permission sets.

This handoff is for the fix implementation phase. Start a new Claude chat, upload this document, and work through the findings in priority order.

---

## Confidence Tiers

Every finding is tagged:
- **Confirmed** — directly visible in metadata, fix without further verification
- **Likely** — strongly suggested, worth a quick check before fixing
- **Flag for investigation** — verify with client or org access before acting

---

## Findings

---

### PROBLEM 1 — CRITICAL | Confirmed
**Broken Flow Logic**
`force-app/main/default/flows/Send_Donation_Thank_You_Email.flow-meta.xml`

The flow trigger requires `Amount = 0` AND `StageName = Closed Won` simultaneously. No real donation will ever match this. The flow is also in Draft status — it has never been active.

**Business impact:** Donors never receive thank-you emails.

**Fix:** Change trigger condition to `Amount > 0` AND `StageName = Closed Won`. Activate the flow.

**Effort:** 30 minutes

---

### PROBLEM 2 — MEDIUM | Likely
**Unused Custom Fields (4 fields)**

Reference trace across all 253 metadata files found zero references in any flow, Apex class, layout, or profile:

- `Volunteer__c.Old_Volunteer_Category__c` — deprecated 2022, replaced by `Volunteer_Type__c`
- `Grant__c.Deprecated_Grant_Status__c` — deprecated 2021, replaced by `Status__c`
- `Contact.Legacy_Donor_ID__c` — leftover from 2018 data migration
- `Volunteer__c.Background_Check_Status__c` — no label, no references found

**Note:** Fields may still be used in Reports or List Views, which are not in the metadata. Verify in the org before deleting.

**Fix:** Confirm no data and no report/list view references, then delete. Remove from page layouts first.

**Effort:** 1–2 hours including data check

---

### PROBLEM 3 — HIGH | Confirmed
**Permission Set Misconfiguration**
`force-app/main/default/permissionsets/Volunteer_Portal_User.permissionset-meta.xml`

The permission set grants field-level access to `Volunteer__c` fields but has zero object permissions for `Volunteer_Shift__c`.

**Business impact:** Volunteers cannot see their assigned shifts in the Experience Cloud portal.

**Fix:** Add object permissions for `Volunteer_Shift__c` (Read = true minimum). Add field-level permissions for `Shift_Date__c`, `Shift_Status__c`, `Hours_Worked__c`.

**Effort:** 30 minutes

---

### PROBLEM 4 — MEDIUM | Confirmed
**Redundant Flows**

Both flows are Active, both trigger on `Grant__c` creation, both create a Task:

- `force-app/main/default/flows/Create_Grant_Follow_Up_Task.flow-meta.xml` — Normal priority task
- `force-app/main/default/flows/Create_Grant_Review_Task.flow-meta.xml` — High priority task

**Business impact:** Every new grant creates two tasks. Staff manually delete duplicates.

**Fix:** Deactivate one. Decide which task type is correct and keep only that flow.

**Effort:** 30 minutes

---

### PROBLEM 5 — CRITICAL | Flag for Investigation
**Data Import Dropping Records**
`force-app/main/default/objects/Donation_Import__c/fields/Campaign__c.field-meta.xml`

`Campaign__c` is marked required on the `Donation_Import__c` object. Whether the Stripe integration populates this field cannot be confirmed from metadata alone.

**Business impact (if confirmed):** Donation records from Stripe are silently dropped.

**Before fixing:** Check integration field mapping or review import error logs to confirm whether Stripe populates `Campaign__c`.

**Fix options:**
1. Make `Campaign__c` not required, handle missing campaign downstream
2. Update Stripe integration to populate `Campaign__c` on every import

**Effort:** 1–2 hours depending on integration access

---

### PROBLEM 6 — HIGH | Confirmed
**Code/Process Drift**

Both are active and fire on `Volunteer__c` insert. Both create a review task and send a welcome email:

- `force-app/main/default/triggers/VolunteerApplicationTrigger.trigger` — built 2019, code comments say it was deprecated when the Flow was created
- `force-app/main/default/flows/Process_Volunteer_Application.flow-meta.xml` — built 2022 to replace the trigger

**Business impact:** Every new volunteer application generates duplicate tasks and duplicate welcome emails.

**Fix:**
1. Deactivate `VolunteerApplicationTrigger`
2. Verify `Process_Volunteer_Application` Flow covers all required steps
3. Update or delete `VolunteerApplicationTriggerTest` accordingly

**Effort:** 1–2 hours including testing

---

### PROBLEM 7 — HIGH | Likely
**Low Code Coverage**

- `force-app/main/default/classes/DonationProcessor.cls`
- `force-app/main/default/classes/DonationProcessorTest.cls`

`validateDonationImport()` is never called in any test. Existing test has weak assertions (`size() > 0`, status `!= 'New'`). Missing scenarios: Contact not found, duplicate Stripe transaction IDs, invalid amounts, bulk operations.

**Note:** Actual coverage percentage must be verified in the org. The structural gaps are real regardless.

**Business impact:** Likely below 75% deployment threshold, blocking production deployments.

**Fix:** Write additional test methods. Claude can write the complete updated test class from the `DonationProcessor.cls` file directly.

**Effort:** 2–3 hours (or ~20 minutes with Claude writing the tests)

---

## Priority Order

| # | Problem | Confidence | Effort |
|---|---------|------------|--------|
| 1 | Problem 5 — Stripe import dropping records | Investigate first | 1–2 hrs |
| 2 | Problem 1 — Broken thank-you email flow | Confirmed | 30 min |
| 3 | Problem 3 — Volunteer portal permission gap | Confirmed | 30 min |
| 4 | Problem 6 — Duplicate trigger + flow | Confirmed | 1–2 hrs |
| 5 | Problem 7 — Low code coverage | Likely | 2–3 hrs |
| 6 | Problem 4 — Redundant grant flows | Confirmed | 30 min |
| 7 | Problem 2 — Unused fields | Likely | 1–2 hrs |

---

## How to Use This Handoff

1. Start a new Claude chat
2. Upload this document
3. Optionally upload the metadata zip (`crj-audit-2026-05-02.tar.gz`) for Claude to reference the actual files
4. Work through problems in priority order
5. For each fix, ask Claude to write the corrected metadata or Apex code
6. Deploy fixes to the org using `sf project deploy start`
7. Re-run `./crj-retrieve.sh` after fixes to capture the updated state
8. Run a post-implementation verification using `git diff` to confirm what changed

---

*Prepared by Adrian Yip | Cloud4Good | May 2, 2026*
