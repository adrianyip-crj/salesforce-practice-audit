# Deployment Gotchas Playbook

**Purpose:** This document captures all issues encountered during the practice deployment so they can be avoided in future Salesforce metadata generation and deployment projects.

**Created:** Based on first deployment of Coastal Community Food Bank practice org  
**Last Updated:** May 2, 2026

---

## Gotcha #1: Comment Lines in Terminal

**Problem:** Pasting bash commands with `#` comment lines triggers quote prompt in terminal  
**Symptom:** Terminal shows `quote>` instead of executing command  
**Example:**
```bash
# This is a comment - DON'T PASTE
cd ~/salesforce-practice  # ← PASTE THIS
```

**Solution:** Only paste actual commands, skip comment lines  
**For future docs:** Remove inline comments from all command blocks, or provide commands separately from explanatory text

---

## Gotcha #2: CLI Flag Syntax Changed

**Problem:** Documentation used `--source-path` but user's CLI version expects `--source-dir`  
**Command that failed:** `sf project deploy start --source-path force-app/main/default`  
**Command that worked:** `sf deploy metadata --source-dir force-app/main/default`  
**Root cause:** Salesforce CLI syntax changed between versions

**Solution:** Check CLI version first and provide correct syntax  
**Command to check version:** `sf --version`  
**For future docs:** 
- Always check `sf --version` in setup steps
- Provide both old and new syntax variants
- Use simpler `sf deploy metadata` command (more stable across versions)

---

## Gotcha #3: No Default Org Set

**Problem:** CLI didn't know which org to deploy to  
**Error:** `No default environment found. Use -o or --target-org to specify an environment.`  

**Solutions:**
1. Set default org: `sf config set target-org YOUR-ORG`
2. Use `--set-default` flag when authenticating: `sf org login web --set-default`
3. Specify org in each command: `--target-org YOUR-ORG`

**For future docs:** Add "set default org" as mandatory step immediately after authentication

---

## Gotcha #4: Lookup Fields Missing Delete Constraint

**Problem:** Required lookup fields need delete behavior specified  
**Error:** `field integrity exception: unknown (must specify either cascade delete or restrict delete for required lookup foreign key)`  
**Files affected:** Any lookup field with `<required>true</required>`

**Solution:** Add `<deleteConstraint>Restrict</deleteConstraint>` after `<referenceTo>` element

**Correct XML:**
```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Campaign__c</fullName>
    <label>Campaign</label>
    <referenceTo>Campaign</referenceTo>
    <deleteConstraint>Restrict</deleteConstraint>  ← ADD THIS
    <relationshipLabel>Donation Imports</relationshipLabel>
    <relationshipName>Donation_Imports</relationshipName>
    <required>true</required>
    <trackTrending>false</trackTrending>
    <type>Lookup</type>
</CustomField>
```

**For future templates:** Auto-add delete constraint to all required lookup field templates  
**Options:** `Restrict` (prevent deletion) or `Cascade` (delete related records)

---

## Gotcha #5: Flows Missing Location Coordinates

**Problem:** Flow `<start>` element requires `locationX` and `locationY` coordinates  
**Error:** `Required field is missing: locationX (14:12)`  
**Files affected:** All 4 Flow files

**Solution:** Add coordinates to `<start>` element

**Correct XML:**
```xml
<start>
    <locationX>50</locationX>      ← ADD THIS
    <locationY>0</locationY>       ← ADD THIS
    <object>Grant__c</object>
    <recordTriggerType>Create</recordTriggerType>
    <triggerType>RecordAfterSave</triggerType>
</start>
```

**For future templates:** Auto-generate location coordinates in all Flow templates  
**Standard values:** Start element: `<locationX>50</locationX>` `<locationY>0</locationY>`

---

## Gotcha #6: Flows Missing Connectors

**Problem:** Flow `<start>` element must connect to first action  
**Error:** `field integrity exception: unknown (The flow can't run because nothing is connected to the Start element.)`

**Solution:** Add `<connector>` element referencing first action

**Correct XML:**
```xml
<start>
    <locationX>50</locationX>
    <locationY>0</locationY>
    <connector>                                        ← ADD THIS BLOCK
        <targetReference>Create_Task</targetReference>
    </connector>
    <object>Grant__c</object>
    <recordTriggerType>Create</recordTriggerType>
    <triggerType>RecordAfterSave</triggerType>
</start>
```

**For future templates:** Auto-add connector targeting the first action/element in the Flow

---

## Gotcha #7: Invalid Flow Status Value

**Problem:** Flow status `Inactive` is not valid  
**Error:** `'Inactive' is not a valid value for the enum 'FlowVersionStatus'`

**Valid Flow Status Values:**
- `Active` - Flow is running in production
- `Draft` - Flow saved but not activated
- `Obsolete` - Deprecated old version

**Solution:** Use `Draft` for flows you want saved but not running

**For future docs:** Document valid Flow statuses in templates

---

## Gotcha #8: Hard to See Code Changes in Markdown

**Problem:** When providing code to add/change, user couldn't easily see what to copy  
**User feedback:** "Can you highlight them in a specific colour so I know what I'm looking at?"

**Attempted solutions:**
1. Arrow comments: `← ADD THIS LINE` (cluttered copy/paste)
2. Bold formatting: `**ADD THIS**` (not available in code blocks)
3. Different color text: (not supported in markdown)

**Working solution:** Provide TWO versions:
1. **Clean copy block** - Just the lines to add (easy to copy/paste)
2. **Full context** - Shows where it goes (for verification)

**Example format:**
```
ADD THESE 3 LINES after <locationY>0</locationY>:

        <connector>
            <targetReference>Create_Task</targetReference>
        </connector>

VERIFY - Should look like:

    <start>
        <locationX>50</locationX>
        <locationY>0</locationY>
        <connector>
            <targetReference>Create_Task</targetReference>
        </connector>
        <object>Grant__c</object>
```

**For future docs:** Always provide clean copy block + verification context

---

## Gotcha #9: Code Indentation Lost on Copy/Paste

**Problem:** When pasting XML code from markdown, indentation spacing was lost  
**Symptom:** First line of pasted code not indented properly, rest fine  
**Root cause:** Terminal/markdown rendering stripping leading spaces

**Attempted solutions:**
1. Use explicit spaces in markdown (didn't work)
2. Provide as code fences (partially worked)
3. Tell user to manually indent (tedious)

**Working solution:** Provide full section replacement as backup option  
**For future docs:** 
- Offer to replace entire XML block instead of inserting lines
- Provide both "add these lines" and "replace this section" options

---

## Gotcha #10: Permission Sets Can't Reference Required Fields

**Problem:** Permission sets cannot grant field-level permissions on required fields  
**Error:** `You cannot deploy to a required field: Volunteer__c.Volunteer_Type__c`

**Solution:** Remove all required fields from permission set field permissions  
**Required fields affected:**
- `Volunteer__c.Email__c`
- `Volunteer__c.Volunteer_Name__c`
- `Volunteer__c.Status__c`
- `Volunteer__c.Volunteer_Type__c`

**Why:** Required fields are always accessible; specifying permissions is redundant and causes deployment error

**For future templates:** Automatically exclude required fields from permission set generation

---

## Gotcha #11: Deployment Order Matters (Apex References)

**Problem:** Apex code references fields that don't exist yet during deployment  
**Error:** `Variable does not exist: Campaign__c`  
**Root cause:** Deploying everything at once - Apex tries to compile before objects/fields exist

**Solution:** Deploy in phases:
1. **Phase 1:** Objects and fields only
2. **Phase 2:** Flows and permission sets
3. **Phase 3:** Apex code (now fields exist)

**Commands:**
```bash
sf deploy metadata --source-dir force-app/main/default/objects
sf deploy metadata --source-dir force-app/main/default/flows
sf deploy metadata --source-dir force-app/main/default/permissionsets
sf deploy metadata --source-dir force-app/main/default/triggers
sf deploy metadata --source-dir force-app/main/default/classes
```

**For future docs:** Provide phased deployment guide as default approach

---

## Gotcha #12: Blank Errors Need Verbose Flag

**Problem:** CLI returned `Error (1):` with no actual error message  
**Solution:** Add `--verbose` flag to see real error details

**Commands:**
```bash
# Original (unhelpful error)
sf deploy metadata --source-dir force-app/main/default/flows

# With verbose (shows actual problem)
sf deploy metadata --source-dir force-app/main/default/flows --verbose
```

**For future docs:** Include `--verbose` flag in all deployment commands by default

---

## Gotcha #13: GitHub Authentication Requires Token

**Problem:** GitHub no longer accepts password authentication  
**Error:** `Invalid username or token. Password authentication is not supported for Git operations.`

**Solution:** Create Personal Access Token (PAT)

**Steps:**
1. GitHub → Settings → Developer settings
2. Personal access tokens → Tokens (classic)
3. Generate new token (classic)
4. Name: `Salesforce Practice`
5. Expiration: 90 days
6. Scopes: Check `repo` only
7. Generate and copy token
8. Use token as password when pushing

**For future docs:** 
- Add PAT creation to setup steps
- Warn that token is only shown once
- Recommend saving token securely

---

## Gotcha #14: Assumed User Has GitHub Account

**Problem:** Documentation assumed user already had GitHub account  
**Reality:** User needed to create one for work project

**Solution:** Add GitHub account creation to prerequisites

**For future docs:**
- Check if user has GitHub account in setup steps
- Provide account creation instructions
- Note to use work email for work projects
- Suggest email aliases for separation (e.g., `user+project@email.com`)

---

## Summary: Template Improvements for Future

### Salesforce Metadata Templates
1. ✅ Add `<deleteConstraint>Restrict</deleteConstraint>` to all required lookup fields
2. ✅ Add `<locationX>50</locationX>` and `<locationY>0</locationY>` to all Flow start elements
3. ✅ Add `<connector>` elements linking Flow start to first action
4. ✅ Set Flow status to `Active` or `Draft` (never `Inactive`)
5. ✅ Exclude required fields from permission set field permissions
6. ✅ Generate valid Flow XML that passes all Salesforce validation rules

### Documentation Templates
1. ✅ Remove inline comments from bash command blocks
2. ✅ Provide clean copy blocks + verification context
3. ✅ Offer full section replacement as backup for indentation issues
4. ✅ Include `--verbose` flag in all CLI commands
5. ✅ Provide both old and new CLI syntax variants
6. ✅ Add GitHub account creation and PAT setup to prerequisites
7. ✅ Include phased deployment guide as default approach

### Deployment Workflow
1. ✅ Check CLI version: `sf --version`
2. ✅ Authenticate with default flag: `sf org login web --set-default`
3. ✅ Verify authentication: `sf org display`
4. ✅ Deploy in phases: objects → flows → apex
5. ✅ Use verbose flag: `--verbose` for troubleshooting
6. ✅ Verify in Salesforce UI after each phase

---

## Testing Checklist for Future Metadata Generations

Before declaring metadata "ready to deploy":

**Metadata Validation:**
- [ ] All required lookup fields have `<deleteConstraint>`
- [ ] All Flows have location coordinates on start element
- [ ] All Flows have connectors linking start to first action
- [ ] All Flows use valid status (`Active` or `Draft`)
- [ ] Permission sets exclude required fields
- [ ] No Apex references to fields that don't exist yet

**Documentation Validation:**
- [ ] No inline comments in bash command blocks
- [ ] Clean copy blocks provided for all code changes
- [ ] Verification context shown after each change
- [ ] Phased deployment guide included
- [ ] CLI version check in setup steps
- [ ] GitHub account + PAT setup in prerequisites

**Deployment Testing:**
- [ ] Test phased deployment in fresh org
- [ ] Verify all components deploy without errors
- [ ] Check verbose output for warnings
- [ ] Verify components in Salesforce UI

---

## Quick Reference: Common Fixes

### Fix Lookup Field
```xml
<deleteConstraint>Restrict</deleteConstraint>
```
Add after `<referenceTo>ObjectName</referenceTo>`

### Fix Flow Start Element
```xml
<start>
    <locationX>50</locationX>
    <locationY>0</locationY>
    <connector>
        <targetReference>FirstActionName</targetReference>
    </connector>
    <object>ObjectName__c</object>
    ...
</start>
```

### Fix Permission Set
Remove any `<fieldPermissions>` blocks that reference required fields

### Phased Deployment Commands
```bash
sf deploy metadata --source-dir force-app/main/default/objects --verbose
sf deploy metadata --source-dir force-app/main/default/flows --verbose
sf deploy metadata --source-dir force-app/main/default/permissionsets --verbose
sf deploy metadata --source-dir force-app/main/default/triggers --verbose
sf deploy metadata --source-dir force-app/main/default/classes --verbose
```

---

**This playbook should be updated with any new gotchas encountered in future deployments.**
