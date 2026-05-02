# Audit Checklist for Coastal Community Food Bank Org

## How to Use This Checklist

After deploying the metadata to your dev org and pulling it back into GitHub, use this checklist to practice your audit workflow. Try to find each issue using Claude analysis before looking at the answers.

---

## 1. Flow Analysis

### Check: Broken Flow Trigger Conditions
**What to look for**: Flows that have trigger conditions checking the wrong field type or impossible conditions

**Files to analyze**:
- `force-app/main/default/flows/Send_Donation_Thank_You_Email.flow-meta.xml`

**Questions to ask Claude**:
- "Analyze this Flow's trigger conditions - are there any logic errors?"
- "What field types are being checked in the trigger? Do they match the operators being used?"

**Expected finding**: 
- Flow checks if `StageName` (text field) > 0 (numeric comparison)
- This will never be true, so the Flow never fires
- Donors don't get thank you emails

---

## 2. Unused Fields Audit

### Check: Fields with No Data or References
**What to look for**: Custom fields that aren't populated and aren't referenced in any automations, validation rules, or code

**Files to analyze**:
- `force-app/main/default/objects/Volunteer__c/fields/Old_Volunteer_Category__c.field-meta.xml`
- `force-app/main/default/objects/Grant__c/fields/Deprecated_Grant_Status__c.field-meta.xml`
- `force-app/main/default/objects/Contact/fields/Legacy_Donor_ID__c.field-meta.xml`

**Questions to ask Claude**:
- "Which custom fields appear to be deprecated or unused based on their descriptions?"
- "Are any of these fields referenced in Flows, Apex, or validation rules?"

**Expected findings**:
- 3 fields with "DEPRECATED" in their descriptions
- None are referenced anywhere in the metadata
- Safe to delete (but should verify no data first in production scenario)

---

## 3. Permission Set Audit

### Check: Missing Object Permissions
**What to look for**: Permission sets that grant field permissions but are missing the underlying object permissions

**Files to analyze**:
- `force-app/main/default/permissionsets/Volunteer_Portal_User.permissionset-meta.xml`

**Questions to ask Claude**:
- "Does this permission set grant access to all objects referenced in its field permissions?"
- "What objects have field permissions but no object permissions?"

**Expected finding**:
- Permission set grants Volunteer__c object permissions and field permissions
- Permission set grants NO permissions for Volunteer_Shift__c object
- This means volunteers can't see their shifts in the portal

---

## 4. Redundant Automation Audit

### Check: Multiple Automations Doing the Same Thing
**What to look for**: Flows or Process Builders triggering on the same object/event and performing similar actions

**Files to analyze**:
- `force-app/main/default/flows/Create_Grant_Follow_Up_Task.flow-meta.xml`
- `force-app/main/default/flows/Create_Grant_Review_Task.flow-meta.xml`

**Questions to ask Claude**:
- "Which Flows trigger on the same object and event?"
- "Do any Flows perform duplicate or overlapping actions?"

**Expected finding**:
- Both Flows trigger on Grant__c record creation
- Both create Tasks related to the new Grant
- Results in duplicate Tasks every time a Grant is created

---

## 5. Data Import/Integration Audit

### Check: Required Fields Not Being Populated
**What to look for**: Required fields on staging/import objects that external systems may not populate

**Files to analyze**:
- `force-app/main/default/objects/Donation_Import__c/Donation_Import__c.object-meta.xml`
- `force-app/main/default/objects/Donation_Import__c/fields/Campaign__c.field-meta.xml`

**Questions to ask Claude**:
- "Which fields on Donation_Import__c are marked as required?"
- "Based on the field descriptions and object purpose, are there any required fields that an external integration might not populate?"

**Expected finding**:
- Campaign__c lookup field is marked required
- Field description indicates Stripe integration doesn't populate this field
- This causes import failures and dropped records

---

## 6. Code and Process Drift Audit

### Check: Apex Code Built for Deprecated Processes
**What to look for**: Triggers or classes with comments indicating they're for old processes, plus Flows that replaced them

**Files to analyze**:
- `force-app/main/default/triggers/VolunteerApplicationTrigger.trigger`
- `force-app/main/default/classes/VolunteerApplicationTriggerTest.cls`
- `force-app/main/default/flows/Process_Volunteer_Application.flow-meta.xml`

**Questions to ask Claude**:
- "Are there any Apex triggers that handle volunteer application processing?"
- "Are there any Flows that also handle volunteer application processing?"
- "Is there overlap or duplication between Apex and Flow automation?"

**Expected finding**:
- Apex trigger from 2019 still active and creating tasks/sending emails
- Flow from 2022 also creates tasks and sends emails for the same process
- Both fire on new Volunteer records → duplicate tasks and emails
- Test class passes but tests old logic, giving false confidence
- Classic case of drift: code works, tests pass, but process has evolved

---

## 7. Code Coverage Audit

### Check: Classes Below 75% Coverage and Weak Tests
**What to look for**: Test classes that run but don't cover all methods or don't have meaningful assertions

**Files to analyze**:
- `force-app/main/default/classes/DonationProcessor.cls`
- `force-app/main/default/classes/DonationProcessorTest.cls`

**Questions to ask Claude**:
- "What methods exist in DonationProcessor that aren't covered by tests?"
- "Do the test assertions validate actual data quality or just existence?"
- "What edge cases or error paths are not being tested?"

**Expected findings**:
- `validateDonationImport()` method has 0% coverage
- Error handling paths not tested
- Test assertions are weak (checking `size() > 0` instead of actual values)
- Estimated coverage ~60%, below 75% production deployment threshold
- Class would fail production deployment

---

## Summary Scorecard

After your audit, you should have found:

- [ ] 1 Flow with broken trigger condition (thank you email)
- [ ] 3 unused custom fields (Old_Volunteer_Category__c, Deprecated_Grant_Status__c, Legacy_Donor_ID__c)
- [ ] 1 permission set missing object permissions (Volunteer_Shift__c)
- [ ] 2 redundant Flows (Grant task creation)
- [ ] 1 data import issue (required Campaign__c field not populated)
- [ ] 1 case of code/process drift (Volunteer trigger + Flow both active)
- [ ] 1 class with low coverage (<75%) and weak tests

---

## Generating Findings Report

After identifying all issues, practice generating a findings report for a client:

**Report sections to include**:
1. Executive Summary (high-level problems and impact)
2. Critical Issues (broken automation, data loss)
3. Optimization Opportunities (unused fields, redundant Flows)
4. Technical Debt (low code coverage, drift)
5. Recommendations with Priority (High/Medium/Low)
6. Estimated Effort to Fix

**Example finding format**:
```
Finding #1: Donation Thank You Email Flow Not Functioning
Severity: High
Impact: Donors are not receiving acknowledgment emails, affecting donor retention
Root Cause: Flow trigger condition compares text field (StageName) using numeric operator (>)
Recommendation: Update trigger condition to check Amount > 0 instead of StageName > 0
Effort: 15 minutes
```

---

## Next Steps After Audit

1. Prioritize fixes based on impact
2. Write corrected metadata (Flows, permission sets)
3. Write new/improved test classes
4. Validate fixes in dev org
5. Deploy to client org via Gearset
6. Document changes for client
