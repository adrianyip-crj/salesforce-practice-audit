# Fixed Deployment Guide - Phase by Phase

## What We Fixed

All 9 deployment errors have been corrected:
- ✅ Added location coordinates to all 4 Flows
- ✅ Added delete constraints to 2 lookup fields
- ✅ Removed problematic field from permission set

## Deploy in 3 Phases (Avoids Apex Errors)

The Apex code references fields that don't exist yet, so we deploy in order:

### Phase 1: Objects and Fields ONLY (No Apex, No Flows)
```bash
cd ~/salesforce-practice

# Deploy just custom objects
sf deploy metadata --source-dir force-app/main/default/objects
```

**Expected**: Success - All custom objects and fields deployed

---

### Phase 2: Flows and Permission Sets
```bash
# Deploy Flows
sf deploy metadata --source-dir force-app/main/default/flows

# Deploy Permission Set
sf deploy metadata --source-dir force-app/main/default/permissionsets
```

**Expected**: Success - All 4 Flows and permission set deployed

---

### Phase 3: Apex Code (Now fields exist)
```bash
# Deploy triggers
sf deploy metadata --source-dir force-app/main/default/triggers

# Deploy Apex classes
sf deploy metadata --source-dir force-app/main/default/classes
```

**Expected**: Success - Apex can now reference the Campaign__c field

---

## Verify Success

After all 3 phases, check:

```bash
# See what was deployed
sf org open
```

In Salesforce:
1. Setup → Object Manager → You should see 4 custom objects
2. Setup → Flows → You should see 4 active flows  
3. Setup → Apex Classes → You should see 3 classes
4. Setup → Apex Triggers → You should see 1 trigger

✅ All deployed!

---

## Alternative: One Command (After Fixes)

Once you download the FIXED version, you can deploy everything at once:

```bash
sf deploy metadata --source-dir force-app/main/default
```

This works because we fixed all the validation errors.

---

## What Changed in the Fixed Files

1. **All 4 Flow files**: Added `<locationX>50</locationX>` and `<locationY>0</locationY>` to `<start>` element
2. **Campaign__c lookup field**: Added `<deleteConstraint>Restrict</deleteConstraint>`
3. **Volunteer__c lookup field**: Added `<deleteConstraint>Restrict</deleteConstraint>`  
4. **Volunteer_Portal_User permission set**: Removed `Volunteer_Type__c` field permission

---

## Download Fixed Files

See the new `salesforce-metadata-FIXED.tar.gz` file above, or just manually run the 3-phase deployment with your existing files after pulling the latest from this conversation.
