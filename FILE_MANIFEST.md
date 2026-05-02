# File Manifest - Coastal Community Food Bank Salesforce Metadata

This document lists all generated files organized by category and purpose.

---

## Project Configuration Files

| File Path | Purpose |
|-----------|---------|
| `sfdx-project.json` | Main Salesforce DX project configuration |
| `.forceignore` | Files to ignore during retrieve/deploy operations |
| `.gitignore` | Files to ignore in Git version control |
| `README.md` | Main documentation for the fictional org and intentional problems |
| `DEPLOYMENT.md` | Step-by-step deployment instructions |
| `AUDIT_CHECKLIST.md` | Practice audit checklist with expected findings |

---

## Custom Objects

### Volunteer__c
| File Path | Purpose |
|-----------|---------|
| `force-app/main/default/objects/Volunteer__c/Volunteer__c.object-meta.xml` | Main object definition |
| `force-app/main/default/objects/Volunteer__c/fields/Volunteer_Name__c.field-meta.xml` | Name field (active) |
| `force-app/main/default/objects/Volunteer__c/fields/Email__c.field-meta.xml` | Email field (active) |
| `force-app/main/default/objects/Volunteer__c/fields/Phone__c.field-meta.xml` | Phone field (active) |
| `force-app/main/default/objects/Volunteer__c/fields/Status__c.field-meta.xml` | Status field (active) |
| `force-app/main/default/objects/Volunteer__c/fields/Volunteer_Type__c.field-meta.xml` | Type field (active, replaced old category field) |
| `force-app/main/default/objects/Volunteer__c/fields/Background_Check_Status__c.field-meta.xml` | Background check field (active) |
| `force-app/main/default/objects/Volunteer__c/fields/Total_Hours_Volunteered__c.field-meta.xml` | Total hours field (active) |
| `force-app/main/default/objects/Volunteer__c/fields/Old_Volunteer_Category__c.field-meta.xml` | **UNUSED** - Deprecated field (audit finding #2) |

### Volunteer_Shift__c
| File Path | Purpose |
|-----------|---------|
| `force-app/main/default/objects/Volunteer_Shift__c/Volunteer_Shift__c.object-meta.xml` | Main object definition |
| `force-app/main/default/objects/Volunteer_Shift__c/fields/Volunteer__c.field-meta.xml` | Lookup to Volunteer |
| `force-app/main/default/objects/Volunteer_Shift__c/fields/Shift_Date__c.field-meta.xml` | Shift date field |
| `force-app/main/default/objects/Volunteer_Shift__c/fields/Hours_Worked__c.field-meta.xml` | Hours worked field |
| `force-app/main/default/objects/Volunteer_Shift__c/fields/Shift_Status__c.field-meta.xml` | Status field |

### Grant__c
| File Path | Purpose |
|-----------|---------|
| `force-app/main/default/objects/Grant__c/Grant__c.object-meta.xml` | Main object definition |
| `force-app/main/default/objects/Grant__c/fields/Grant_Amount__c.field-meta.xml` | Amount field (active) |
| `force-app/main/default/objects/Grant__c/fields/Status__c.field-meta.xml` | Status field (active) |
| `force-app/main/default/objects/Grant__c/fields/Funder_Name__c.field-meta.xml` | Funder field (active) |
| `force-app/main/default/objects/Grant__c/fields/Application_Due_Date__c.field-meta.xml` | Due date field (active) |
| `force-app/main/default/objects/Grant__c/fields/Award_Date__c.field-meta.xml` | Award date field (active) |
| `force-app/main/default/objects/Grant__c/fields/Deprecated_Grant_Status__c.field-meta.xml` | **UNUSED** - Deprecated field (audit finding #2) |

### Donation_Import__c
| File Path | Purpose |
|-----------|---------|
| `force-app/main/default/objects/Donation_Import__c/Donation_Import__c.object-meta.xml` | Main object definition |
| `force-app/main/default/objects/Donation_Import__c/fields/Donor_Email__c.field-meta.xml` | Donor email field |
| `force-app/main/default/objects/Donation_Import__c/fields/Donation_Amount__c.field-meta.xml` | Amount field |
| `force-app/main/default/objects/Donation_Import__c/fields/Stripe_Transaction_ID__c.field-meta.xml` | Stripe ID field |
| `force-app/main/default/objects/Donation_Import__c/fields/Import_Status__c.field-meta.xml` | Status field |
| `force-app/main/default/objects/Donation_Import__c/fields/Campaign__c.field-meta.xml` | **PROBLEM** - Required but not populated (audit finding #5) |

### Contact (Standard Object Extensions)
| File Path | Purpose |
|-----------|---------|
| `force-app/main/default/objects/Contact/fields/Legacy_Donor_ID__c.field-meta.xml` | **UNUSED** - Deprecated field from migration (audit finding #2) |

---

## Flows

| File Path | Purpose | Status |
|-----------|---------|--------|
| `force-app/main/default/flows/Send_Donation_Thank_You_Email.flow-meta.xml` | Thank you email automation | **BROKEN** - Trigger condition error (audit finding #1) |
| `force-app/main/default/flows/Create_Grant_Follow_Up_Task.flow-meta.xml` | Grant task creation | **REDUNDANT** - Duplicates other flow (audit finding #4) |
| `force-app/main/default/flows/Create_Grant_Review_Task.flow-meta.xml` | Grant task creation | **REDUNDANT** - Duplicates other flow (audit finding #4) |
| `force-app/main/default/flows/Process_Volunteer_Application.flow-meta.xml` | Volunteer application processing | Active (but conflicts with trigger - audit finding #6) |

---

## Apex Code

### Triggers
| File Path | Purpose | Status |
|-----------|---------|--------|
| `force-app/main/default/triggers/VolunteerApplicationTrigger.trigger` | Volunteer application automation | **DEPRECATED** - Replaced by Flow (audit finding #6) |
| `force-app/main/default/triggers/VolunteerApplicationTrigger.trigger-meta.xml` | Trigger metadata | - |

### Classes
| File Path | Purpose | Status |
|-----------|---------|--------|
| `force-app/main/default/classes/DonationProcessor.cls` | Donation import processing | **LOW COVERAGE** - ~60% (audit finding #7) |
| `force-app/main/default/classes/DonationProcessor.cls-meta.xml` | Class metadata | - |

### Test Classes
| File Path | Purpose | Status |
|-----------|---------|--------|
| `force-app/main/default/classes/VolunteerApplicationTriggerTest.cls` | Tests for deprecated trigger | Passes but tests old logic (audit finding #6) |
| `force-app/main/default/classes/VolunteerApplicationTriggerTest.cls-meta.xml` | Test class metadata | - |
| `force-app/main/default/classes/DonationProcessorTest.cls` | Tests for DonationProcessor | **WEAK** - Low coverage, weak assertions (audit finding #7) |
| `force-app/main/default/classes/DonationProcessorTest.cls-meta.xml` | Test class metadata | - |

---

## Permission Sets

| File Path | Purpose | Status |
|-----------|---------|--------|
| `force-app/main/default/permissionsets/Volunteer_Portal_User.permissionset-meta.xml` | Portal user access | **MISCONFIGURED** - Missing object permissions (audit finding #3) |

---

## File Count Summary

| Category | Count |
|----------|-------|
| **Project Config Files** | 6 |
| **Custom Object Definitions** | 4 |
| **Custom Fields** | 21 |
| **Flows** | 4 |
| **Apex Triggers** | 1 + metadata |
| **Apex Classes** | 1 + metadata |
| **Apex Test Classes** | 2 + metadata |
| **Permission Sets** | 1 |
| **TOTAL FILES** | 43 |

---

## Intentional Problems Summary

| # | Problem Type | File(s) Affected | Severity |
|---|--------------|------------------|----------|
| 1 | Broken Flow Trigger | Send_Donation_Thank_You_Email.flow | High |
| 2 | Unused Fields (3) | Old_Volunteer_Category__c, Deprecated_Grant_Status__c, Legacy_Donor_ID__c | Medium |
| 3 | Permission Set Misconfiguration | Volunteer_Portal_User.permissionset | High |
| 4 | Redundant Flows (2) | Create_Grant_Follow_Up_Task, Create_Grant_Review_Task | Medium |
| 5 | Data Import Issue | Donation_Import__c.Campaign__c | High |
| 6 | Code/Process Drift | VolunteerApplicationTrigger + Process_Volunteer_Application Flow | High |
| 7 | Low Code Coverage | DonationProcessor + DonationProcessorTest | High |

---

## Deployment Order Recommendation

For smooth deployment, deploy in this order:

1. **Custom Objects** (without triggers/flows)
   - Volunteer__c
   - Volunteer_Shift__c
   - Grant__c
   - Donation_Import__c

2. **Custom Fields on Standard Objects**
   - Contact.Legacy_Donor_ID__c

3. **Apex Classes** (without triggers)
   - DonationProcessor
   - DonationProcessorTest
   - VolunteerApplicationTriggerTest

4. **Apex Triggers**
   - VolunteerApplicationTrigger

5. **Flows**
   - All flows

6. **Permission Sets**
   - Volunteer_Portal_User

Or simply deploy everything at once:
```bash
sf project deploy start --source-path force-app/main/default
```

---

## Ready for Audit Practice

All files are now ready to:
1. Deploy to your Salesforce Developer Edition org
2. Retrieve back to your local project
3. Commit to GitHub
4. Analyze with Claude using the audit checklist

Good luck with your audit practice!
