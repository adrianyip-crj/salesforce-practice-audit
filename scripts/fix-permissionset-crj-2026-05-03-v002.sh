#!/bin/bash
# fix-permissionset-crj-2026-05-03.sh
# Fixes duplicate fieldPermissions error in Volunteer_Portal_User permission set
# Run from ~/salesforce-practice/

python3 << 'PYTHON'
import xml.etree.ElementTree as ET

path = "force-app/main/default/permissionsets/Volunteer_Portal_User.permissionset-meta.xml"

ET.register_namespace('', 'http://soap.sforce.com/2006/04/metadata')
tree = ET.parse(path)
root = tree.getroot()
ns = 'http://soap.sforce.com/2006/04/metadata'

# Collect all existing field and object permission references so we don't duplicate
existing_fields = set()
for fp in root.findall(f'{{{ns}}}fieldPermissions'):
    field = fp.find(f'{{{ns}}}field')
    if field is not None:
        existing_fields.add(field.text)

existing_objects = set()
for op in root.findall(f'{{{ns}}}objectPermissions'):
    obj = op.find(f'{{{ns}}}object')
    if obj is not None:
        existing_objects.add(obj.text)

print(f"Existing field permissions: {existing_fields}")
print(f"Existing object permissions: {existing_objects}")

# Add object permission for Volunteer_Shift__c if missing
if 'Volunteer_Shift__c' not in existing_objects:
    op = ET.SubElement(root, f'{{{ns}}}objectPermissions')
    ET.SubElement(op, f'{{{ns}}}allowCreate').text = 'false'
    ET.SubElement(op, f'{{{ns}}}allowDelete').text = 'false'
    ET.SubElement(op, f'{{{ns}}}allowEdit').text = 'false'
    ET.SubElement(op, f'{{{ns}}}allowRead').text = 'true'
    ET.SubElement(op, f'{{{ns}}}modifyAllRecords').text = 'false'
    ET.SubElement(op, f'{{{ns}}}object').text = 'Volunteer_Shift__c'
    ET.SubElement(op, f'{{{ns}}}viewAllRecords').text = 'false'
    print("✓ Added object permissions for Volunteer_Shift__c")
else:
    print("- Object permissions for Volunteer_Shift__c already present")

# Add field permissions only if missing
fields_to_add = [
    'Volunteer_Shift__c.Shift_Date__c',
    'Volunteer_Shift__c.Shift_Status__c',
    'Volunteer_Shift__c.Hours_Worked__c',
]

for field_name in fields_to_add:
    if field_name not in existing_fields:
        fp = ET.SubElement(root, f'{{{ns}}}fieldPermissions')
        ET.SubElement(fp, f'{{{ns}}}editable').text = 'false'
        ET.SubElement(fp, f'{{{ns}}}field').text = field_name
        ET.SubElement(fp, f'{{{ns}}}readable').text = 'true'
        print(f"✓ Added field permission for {field_name}")
    else:
        print(f"- Field permission for {field_name} already present")

tree.write(path, encoding='unicode', xml_declaration=True)
print("\nPermission set updated cleanly.")
PYTHON
