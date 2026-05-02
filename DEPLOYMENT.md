# Deployment Guide

## Step-by-Step Instructions for Deploying to Your Dev Org

### 1. Authenticate to Your Salesforce Org

```bash
sf org login web
```

This will open a browser window. Log in to your Salesforce Developer Edition org.

### 2. Set Your Default Org (Optional)

```bash
sf config set target-org <your-username>
```

Replace `<your-username>` with your Salesforce username.

### 3. Navigate to the Project Directory

```bash
cd /path/to/salesforce-metadata
```

### 4. Validate the Deployment (Recommended First)

Before actually deploying, validate that everything will work:

```bash
sf project deploy start --source-path force-app/main/default --dry-run
```

This checks for errors without actually deploying.

### 5. Deploy All Metadata

```bash
sf project deploy start --source-path force-app/main/default
```

This will deploy:
- Custom Objects (Volunteer__c, Grant__c, Volunteer_Shift__c, Donation_Import__c)
- Custom Fields
- Flows (including the broken and redundant ones)
- Apex Classes and Triggers (including the deprecated trigger)
- Test Classes
- Permission Set (with the misconfiguration)

### 6. Verify Deployment

Check the deployment status:

```bash
sf project deploy report
```

You can also check in your Salesforce org:
- Setup → Custom Code → Apex Classes (you should see DonationProcessor, VolunteerApplicationTriggerTest)
- Setup → Process Automation → Flows (you should see 5 flows)
- Setup → Object Manager (you should see the custom objects)

---

## Deployment by Metadata Type

If you want to deploy specific types of metadata:

### Deploy Only Custom Objects and Fields
```bash
sf project deploy start --metadata CustomObject
```

### Deploy Only Flows
```bash
sf project deploy start --metadata Flow
```

### Deploy Only Apex
```bash
sf project deploy start --metadata ApexClass,ApexTrigger
```

### Deploy Only Permission Set
```bash
sf project deploy start --metadata PermissionSet
```

---

## After Deployment: Retrieve Metadata for Audit

Once everything is deployed, retrieve it back to practice the audit workflow:

```bash
# Retrieve all metadata
sf project retrieve start --source-path force-app/main/default

# Or retrieve specific types
sf project retrieve start --metadata CustomObject
sf project retrieve start --metadata Flow
sf project retrieve start --metadata ApexClass
```

---

## Troubleshooting

### "Invalid username, password, security token, or user locked out"
Run `sf org login web` again to re-authenticate.

### "Can't create a duplicate version of field"
You may have already deployed these fields. Either:
1. Delete the existing metadata from your org first, or
2. Skip the deployment of those specific items

### "Insufficient access rights on cross-reference id"
Check that you're deploying to an org where you have admin privileges.

### "Test coverage is insufficient"
This is expected! The DonationProcessorTest class intentionally has low coverage (~60%). This is one of the problems you'll find during the audit.

---

## Creating Sample Data (Optional)

After deployment, you may want to create some sample records to make the org feel more realistic:

1. Go to your Salesforce org
2. Navigate to the App Launcher → Volunteers
3. Create a few Volunteer records
4. Create some Volunteer Shift records
5. Create a Campaign record (needed for Donation Imports)
6. Create some Grant records

When you create Volunteer and Grant records, watch for the duplicate Tasks being created due to the redundant automations!

---

## Next Steps

Once deployed and verified:
1. Push to a GitHub repository
2. Use Claude to analyze the metadata
3. Practice identifying all 7 intentional problems
4. Generate a findings report
5. Write fixes (new test classes, corrected Flows, etc.)
