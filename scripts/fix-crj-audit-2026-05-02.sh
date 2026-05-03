#!/bin/bash
# fix-crj-audit-2026-05-02.sh
# Applies metadata fixes from the CRJ org health audit (May 2, 2026)
# Covers: Problems 3, 5, 6 (Problem 7 is a file replacement — see DonationProcessorTest.cls)
#
# Usage: run from ~/salesforce-practice/
#   chmod +x scripts/fix-crj-audit-2026-05-02.sh
#   ./scripts/fix-crj-audit-2026-05-02.sh

set -e
BASE="force-app/main/default"

echo "Applying CRJ audit fixes — $(date '+%Y-%m-%d %H:%M')"
echo ""

# ── Problem 5: Make Campaign__c not required ──────────────────────────────────
# Context: Required field not populated by Stripe integration, silently dropping
# donation import records. Fix: remove required constraint, handle downstream.
FILE="$BASE/objects/Donation_Import__c/fields/Campaign__c.field-meta.xml"
sed -i '' 's/<required>true<\/required>/<required>false<\/required>/' "$FILE"
echo "✓ Problem 5: Campaign__c no longer required"

# ── Problem 6: Deactivate VolunteerApplicationTrigger ────────────────────────
# Context: Apex trigger from 2019 still active alongside 2022 Flow replacement.
# Both firing simultaneously, creating duplicate tasks and emails.
# Fix: deactivate trigger, Flow covers all required steps.
FILE="$BASE/triggers/VolunteerApplicationTrigger.trigger-meta.xml"
sed -i '' 's/<status>Active<\/status>/<status>Inactive<\/status>/' "$FILE"
echo "✓ Problem 6: VolunteerApplicationTrigger deactivated"

# ── Problem 3: Add Volunteer_Shift__c permissions to permission set ───────────
# Context: Volunteer_Portal_User permission set missing object permissions for
# Volunteer_Shift__c, blocking volunteers from seeing shifts in Experience Cloud.
# Fix: add Read object permissions + FLS for Shift_Date__c, Shift_Status__c,
# Hours_Worked__c.
python3 << 'PYTHON'
path = "force-app/main/default/permissionsets/Volunteer_Portal_User.permissionset-meta.xml"

with open(path, "r") as f:
    content = f.read()

new_permissions = """
    <objectPermissions>
        <allowCreate>false</allowCreate>
        <allowDelete>false</allowDelete>
        <allowEdit>false</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>false</modifyAllRecords>
        <object>Volunteer_Shift__c</object>
        <viewAllRecords>false</viewAllRecords>
    </objectPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Volunteer_Shift__c.Shift_Date__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Volunteer_Shift__c.Shift_Status__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Volunteer_Shift__c.Hours_Worked__c</field>
        <readable>true</readable>
    </fieldPermissions>"""

updated = content.replace("</PermissionSet>", new_permissions + "\n</PermissionSet>")

with open(path, "w") as f:
    f.write(updated)

print("✓ Problem 3: Volunteer_Shift__c permissions added")
PYTHON

echo ""
echo "Script complete. Remaining steps:"
echo "  - Confirm DonationProcessorTest.cls is in force-app/main/default/classes/"
echo "  - git add ."
echo "  - git commit -m 'fix: CRJ audit problems 3, 5, 6, 7 — $(date +%Y-%m-%d)'"
echo "  - sf project deploy start --source-path force-app/main/default"
