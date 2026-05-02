# Example Fix #1: Corrected Thank You Email Flow

## Problem
The original `Send_Donation_Thank_You_Email` Flow has a broken trigger condition that checks if `StageName` (a text field) is greater than 0 (a numeric comparison). This will never evaluate to true, so the Flow never fires.

**Original broken trigger condition:**
```xml
<filters>
    <field>StageName</field>
    <operator>EqualTo</operator>
    <value>
        <stringValue>Closed Won</stringValue>
    </value>
</filters>
<filters>
    <field>StageName</field>  <!-- WRONG: Text field -->
    <operator>GreaterThan</operator>  <!-- WRONG: Numeric operator -->
    <value>
        <numberValue>0.0</numberValue>  <!-- WRONG: Comparing to number -->
    </value>
</filters>
```

## Solution
The second filter should check if `Amount` (the donation amount) is greater than 0, not `StageName`.

---

## Corrected Flow XML

Save this as: `force-app/main/default/flows/Send_Donation_Thank_You_Email_FIXED.flow-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Flow xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>60.0</apiVersion>
    <description>Sends thank you email to donors when donation is received. FIXED: Corrected trigger condition to check Amount instead of StageName.</description>
    <interviewLabel>Send Donation Thank You Email {!$Flow.CurrentDateTime}</interviewLabel>
    <label>Send Donation Thank You Email (FIXED)</label>
    <processMetadataValues>
        <name>BuilderType</name>
        <value>
            <stringValue>LightningFlowBuilder</stringValue>
        </value>
    </processMetadataValues>
    <processType>AutoLaunchedFlow</processType>
    <start>
        <filterLogic>and</filterLogic>
        <filters>
            <field>StageName</field>
            <operator>EqualTo</operator>
            <value>
                <stringValue>Closed Won</stringValue>
            </value>
        </filters>
        <filters>
            <!-- FIXED: Now checking Amount field instead of StageName -->
            <field>Amount</field>
            <operator>GreaterThan</operator>
            <value>
                <numberValue>0.0</numberValue>
            </value>
        </filters>
        <object>Opportunity</object>
        <recordTriggerType>Create</recordTriggerType>
        <triggerType>RecordAfterSave</triggerType>
    </start>
    <status>Active</status>
    <actionCalls>
        <name>Send_Thank_You_Email</name>
        <label>Send Thank You Email</label>
        <locationX>176</locationX>
        <locationY>276</locationY>
        <actionName>emailSimple</actionName>
        <actionType>emailSimple</actionType>
        <flowTransactionModel>CurrentTransaction</flowTransactionModel>
        <inputParameters>
            <name>emailBody</name>
            <value>
                <stringValue>Thank you for your generous donation to Coastal Community Food Bank! Your support helps us serve families in need.</stringValue>
            </value>
        </inputParameters>
        <inputParameters>
            <name>emailSubject</name>
            <value>
                <stringValue>Thank You for Your Donation</stringValue>
            </value>
        </inputParameters>
        <inputParameters>
            <name>emailAddresses</name>
            <value>
                <elementReference>$Record.Contact.Email</elementReference>
            </value>
        </inputParameters>
    </actionCalls>
</Flow>
```

---

## Deployment Steps

### Option 1: Deploy via CLI
```bash
# Deploy the fixed Flow
sf project deploy start --source-path force-app/main/default/flows/Send_Donation_Thank_You_Email_FIXED.flow-meta.xml

# Deactivate the old broken Flow in the Salesforce UI
# (Can't have two Flows with same trigger)
```

### Option 2: Fix in Salesforce UI
1. Go to Setup → Flows
2. Open "Send Donation Thank You Email"
3. Edit the Flow
4. Click on the Start element
5. Edit the second filter condition:
   - Change Field from "StageName" to "Amount"
   - Keep Operator as "Greater Than"
   - Keep Value as 0
6. Save and Activate

---

## Testing the Fix

### Test Case 1: Donation with Amount
1. Create a new Opportunity
2. Set StageName = "Closed Won"
3. Set Amount = $100
4. Set Contact with valid email
5. Save

**Expected Result**: Thank you email is sent to the Contact

### Test Case 2: Donation with No Amount
1. Create a new Opportunity
2. Set StageName = "Closed Won"
3. Leave Amount blank or set to $0
4. Set Contact with valid email
5. Save

**Expected Result**: No email is sent (Amount filter blocks it)

### Test Case 3: Non-Donation Opportunity
1. Create a new Opportunity
2. Set StageName = "Prospecting"
3. Set Amount = $100
4. Set Contact with valid email
5. Save

**Expected Result**: No email is sent (StageName filter blocks it)

---

## Verification Checklist

After deploying the fix:
- [ ] Flow appears in Active Flows list
- [ ] Flow trigger shows correct object (Opportunity)
- [ ] Flow trigger shows correct conditions (StageName = "Closed Won" AND Amount > 0)
- [ ] Test Case 1 sends email successfully
- [ ] Test Case 2 does NOT send email
- [ ] Test Case 3 does NOT send email
- [ ] No errors in Debug Logs
- [ ] Old broken Flow is deactivated

---

## Impact

**Before Fix**:
- Donors receive NO acknowledgment emails
- Manual follow-up required for every donation
- Poor donor experience
- Lost stewardship opportunity

**After Fix**:
- Automatic thank you email for every donation
- Improved donor retention
- Reduced manual work for staff
- Professional donor experience

**Estimated Time Saved**: 5 minutes per donation × 200 donations/month = **16.7 hours/month**

---

## Documentation for Client

### What We Fixed
Your donation thank you email Flow wasn't working because it was checking the wrong field. It was trying to see if the donation stage name was greater than zero (which doesn't make sense for a text field). We corrected it to check if the donation amount is greater than zero instead.

### What This Means
Now when someone makes a donation (Opportunity marked as "Closed Won" with an amount), they'll automatically receive a thank you email. This happens immediately when the donation is recorded in Salesforce.

### What You Need to Do
Nothing! The fix is automatic. However, you may want to:
1. Customize the email message text to match your organization's voice
2. Add your logo to the email template (optional)
3. Monitor sent emails for the first week to ensure it's working as expected

### Questions?
Contact [Your Name] if you notice any issues or want to customize the email content.
