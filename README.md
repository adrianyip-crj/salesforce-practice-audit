# Coastal Community Food Bank - Salesforce Org

## Fictional Nonprofit Organization

**Mission**: Serving coastal communities by distributing food to families in need, coordinating volunteers, and managing community partnerships.

**Tech Stack**:
- Salesforce for CRM and operations
- Stripe integration for online donations
- Mailchimp integration for donor communications
- Experience Cloud volunteer portal
- Weekly food distribution events tracked in Salesforce

---

## Intentional Problems (For Audit Practice)

This org has been deliberately configured with the following issues for you to discover during your org health audit:

### 1. **Broken Flow - Send Donation Thank You Email**
- **Location**: `flows/Send_Donation_Thank_You_Email.flow-meta.xml`
- **Problem**: The trigger condition checks if `StageName` (text field) is greater than 0, which will never be true. This prevents the Flow from ever firing.
- **Impact**: Donors are not receiving thank you emails when they make donations.

### 2. **Unused Custom Fields**
Multiple fields that exist but are no longer used:
- `Volunteer__c.Old_Volunteer_Category__c` - Replaced by `Volunteer_Type__c` in 2022
- `Grant__c.Deprecated_Grant_Status__c` - Replaced by `Status__c` in 2021
- `Contact.Legacy_Donor_ID__c` - Used during 2018 data migration, no longer needed

**Impact**: Clutter in the org, confusing for users, wasted licenses if field-level security is configured.

### 3. **Permission Set Misconfiguration - Volunteer Portal User**
- **Location**: `permissionsets/Volunteer_Portal_User.permissionset-meta.xml`
- **Problem**: Missing object permissions for `Volunteer_Shift__c`
- **Impact**: Volunteers accessing the portal can see their Volunteer record but cannot see their assigned shifts, making the portal essentially useless.

### 4. **Redundant Flows**
Two Flows doing the same thing:
- `Create_Grant_Follow_Up_Task.flow-meta.xml`
- `Create_Grant_Review_Task.flow-meta.xml`

Both trigger on Grant record creation and create Tasks. This results in duplicate Tasks every time a Grant is created.

**Impact**: Staff waste time deleting duplicate tasks, confusion about which task is the "real" one.

### 5. **Data Import Problem - Missing Required Field**
- **Location**: `Donation_Import__c.Campaign__c` field
- **Problem**: The `Campaign__c` lookup field is marked as required, but the Stripe import integration does not populate this field
- **Impact**: Donation imports are failing silently, dropping records. Donations are being received but not recorded in Salesforce.

### 6. **Code and Process Drift - Volunteer Application Trigger**
- **Location**: 
  - `triggers/VolunteerApplicationTrigger.trigger`
  - `classes/VolunteerApplicationTriggerTest.cls`
  - `flows/Process_Volunteer_Application.flow-meta.xml`
  
- **Problem**: 
  - The Apex trigger was built in 2019 to handle volunteer application processing
  - In 2022, this process was rebuilt as a Flow (`Process_Volunteer_Application`)
  - The old trigger was never deactivated and is still firing
  - Both the trigger and the Flow create tasks and send emails, causing duplicates
  - The test class still runs and passes with good coverage, but it's testing logic that no longer reflects how the org actually works

- **Impact**: 
  - Duplicate tasks created for every new volunteer
  - Duplicate welcome emails sent to volunteers
  - Test class gives false confidence - it passes but doesn't test the current process
  - The code and the business process have drifted apart

### 7. **Low Code Coverage - DonationProcessor**
- **Location**: 
  - `classes/DonationProcessor.cls`
  - `classes/DonationProcessorTest.cls`

- **Problem**:
  - DonationProcessor has meaningful business logic (~120 lines)
  - Test class achieves only ~60% coverage
  - The `validateDonationImport()` method has 0% coverage
  - Error handling paths are not tested
  - Assertions are weak - checking for existence but not data quality

- **Impact**:
  - Class is below the 75% threshold required for production deployment
  - Deployment to production will fail
  - When bugs occur in production, there are no tests to catch them during deployment

---

## How to Deploy

### Prerequisites
1. Salesforce Developer Edition org (free)
2. Salesforce CLI installed
3. Authenticated to your org: `sf org login web`

### Deployment Steps

From the `salesforce-metadata` directory:

```bash
# Deploy all metadata
sf project deploy start --source-path force-app/main/default

# Or deploy specific metadata types
sf project deploy start --metadata ApexClass,ApexTrigger
sf project deploy start --metadata Flow
sf project deploy start --metadata CustomObject
sf project deploy start --metadata PermissionSet
```

### Verify Deployment

After deployment, you can retrieve the metadata back to verify:

```bash
sf project retrieve start --source-path force-app/main/default
```

---

## Audit Workflow

Once deployed:

1. Pull metadata back from your org: `sf project retrieve start`
2. Commit to GitHub
3. Use Claude to analyze the metadata against the standard audit checklist
4. Claude should identify all 7 intentional problems listed above
5. Generate a findings report with specific recommendations
6. Practice writing fixes (new test classes, corrected Flows, etc.)

---

## Expected Audit Findings Summary

Your audit should catch:
- ✅ 1 broken Flow (thank you email)
- ✅ 3 unused custom fields
- ✅ 1 permission set misconfiguration
- ✅ 2 redundant Flows
- ✅ 1 data import mapping issue
- ✅ 1 Apex trigger demonstrating code/process drift
- ✅ 1 Apex class with low code coverage

---

## Notes

- This is a practice environment - feel free to experiment with fixes
- The problems are intentionally realistic but simplified for learning
- Real client orgs will have more complexity and subtlety
- Use this to validate your audit methodology before applying to client orgs
