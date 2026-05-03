#!/bin/bash
# dedup-permissionset-crj-2026-05-03-v003.sh
# Removes duplicate fieldPermissions and objectPermissions entries
# from Volunteer_Portal_User.permissionset-meta.xml
# Run from ~/salesforce-practice/

python3 << 'PYTHON'
import xml.etree.ElementTree as ET

path = "force-app/main/default/permissionsets/Volunteer_Portal_User.permissionset-meta.xml"

ET.register_namespace('', 'http://soap.sforce.com/2006/04/metadata')
tree = ET.parse(path)
root = tree.getroot()
ns = 'http://soap.sforce.com/2006/04/metadata'

def dedup_elements(root, ns, tag, key_child):
    seen = set()
    to_remove = []
    for el in root.findall(f'{{{ns}}}{tag}'):
        key_el = el.find(f'{{{ns}}}{key_child}')
        if key_el is not None:
            key = key_el.text
            if key in seen:
                to_remove.append(el)
                print(f"  Removing duplicate {tag}: {key}")
            else:
                seen.add(key)
    for el in to_remove:
        root.remove(el)
    return len(to_remove)

print("Deduplicating permission set...")
fp_removed = dedup_elements(root, ns, 'fieldPermissions', 'field')
op_removed = dedup_elements(root, ns, 'objectPermissions', 'object')

if fp_removed == 0 and op_removed == 0:
    print("No duplicates found.")
else:
    print(f"\nRemoved {fp_removed} duplicate fieldPermissions, {op_removed} duplicate objectPermissions.")

tree.write(path, encoding='unicode', xml_declaration=True)
print("File written cleanly.")
PYTHON
