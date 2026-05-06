# Claude Audit Prompts

Use these prompts systematically during the analysis phase. Start with the opening context prompt, then work through each category. Don't skip categories — the value of this service is comprehensive coverage.

---

## Opening Context Prompt

Paste this at the start of every audit session after uploading the zip:
I've uploaded a zip of Salesforce metadata from [Client Name], a [nonprofit/business]
that uses Salesforce for [brief description — e.g., donor management, volunteer tracking,
grant management].
Known integrations: [e.g., Stripe for donation processing, Mailchimp for email marketing]
Please extract and analyze this metadata. I'll walk you through specific categories
one at a time. Start by confirming what metadata types you can see in the uploaded files
and how many files there are in each category.

---

## Category 1: Flows
Analyze all Flows in the metadata. For each Flow, identify:

Its status (Active vs Draft) — flag any Draft flows that appear to have business logic
What object and trigger event it fires on
What it does (creates records, sends emails, updates fields, etc.)
Any logical errors in trigger conditions or decision criteria
Any Flows that fire on the same object and event as another Flow — flag as potentially redundant

List your findings with the Flow name, status, trigger, what it does, and any issues found.

---

## Category 2: Custom Fields

### Step 1 — Identify field references across metadata
For every custom field in the metadata, trace its references across all other metadata types:

Flows
Apex classes and triggers
Permission sets
Layouts
Profiles (field-level security)
Validation rules (check errorConditionFormula for field API names)
Workflow rules (check criteriaItems.field and fieldUpdates.field)
Formula fields (check formula element — note that lookup fields appear as FieldName__r
in cross-object formulas, not FieldName__c. Check both notations.)

Flag any field that has zero references across all of these. Also flag any field whose
name or description contains words like "deprecated", "old", "legacy", or "unused".
Present findings as a list: field name, object, and what references exist (or "none found").

### Step 2 — FLS cross-reference for flagged fields

For each field flagged as potentially unused in Step 1, run this prompt:
For the field [Object__c.Field__c], search all retrieved profile metadata files for
fieldPermissions entries referencing this field. List every profile that grants Read
or Edit access. If no profiles grant access, confirm this explicitly.

### Step 3 — Classify each finding

Use this decision tree:

| Condition | Classification | Action |
|-----------|---------------|--------|
| No metadata references + No FLS in any profile | **Confirmed** — safe to delete | Proceed to deletion workflow |
| No metadata references + FLS exists in one or more profiles | **Likely** — verify before deleting | Run Workbench COUNT check first |
| Has metadata references + No FLS | **Flag for investigation** | Determine if reference is stale or FLS was accidentally removed |
| Has metadata references + FLS exists | Not unused — remove from list | Do not recommend deletion |

**Unused field findings should never be Confirmed based on metadata reference tracing alone. FLS verification is always required.**

### Step 4 — Document in findings report

For each unused field finding, include:
- List of profiles checked
- FLS status (none / read-only / read-write) per profile
- Metadata references found (or confirmed none)
- Confidence tier based on decision tree above
- Pre-deletion steps required (see Pre-Deletion Workflow below)

---

## Category 3: Permission Sets
Analyze all permission sets. For each one:

List the objects it grants access to and the access level (read/edit/create/delete)
List the fields it grants access to
Cross-reference with the custom objects in the metadata — are there any custom objects
that exist but are missing from this permission set entirely?
Flag any cases where a permission set grants field access but not object access
(fields are inaccessible without object access)
Flag any cases where a permission set grants object access but no field-level permissions
for that object (object visible but all fields blank for assigned users)

Focus especially on permission sets with "portal" or "community" in the name, as these
are typically assigned to external users where gaps cause visible problems.

---

## Category 4: Apex Triggers vs Flows
List all active Apex triggers and all active Flows, grouped by the object they fire on.
For each object that has BOTH an active trigger AND an active Flow:

What does the trigger do?
What does the Flow do?
Is there overlap — are they doing the same or similar things?
Flag as a code/process drift risk if they appear to duplicate each other.

Also flag any Apex trigger whose code comments suggest it has been replaced or deprecated.
For triggers where no explicit deprecation comment exists, look for these signals:

A Flow whose description names this trigger as what it replaced
The trigger's API version compared to the Flow's API version (older = likely legacy)
Test classes that assert exactly N records were created — if both trigger and Flow
are active, the test should see 2N. A passing test expecting N suggests it predates
the duplication.


---

## Category 5: Apex Test Coverage
Review all Apex test classes. For each test class:

Which Apex class or trigger is it testing?
What scenarios does it cover? (look at what records it creates and what it calls)
What scenarios are NOT covered? (error paths, edge cases, bulk operations)
Are the assertions meaningful? (assert specific values, not just that something exists
or that a status changed to anything other than its original value)
Are there any Apex classes that have NO corresponding test class at all?
For each public method in each Apex class, identify whether it is called by any
production code (non-test classes or triggers). Flag methods called only by test
classes — these may have no production invocation path.

Flag test classes with weak assertions as "passes but doesn't validate" — these give
false confidence in coverage.

---

## Category 6: Integration Staging Objects
Look for any custom objects that appear to be integration staging tables — objects used
to receive data from external systems before processing. Common patterns: objects with
names containing "Import", "Staging", "Inbound", or "Queue"; objects with fields like
"Status", "Error", "Transaction ID", or references to external system IDs (e.g.,
Stripe_Transaction_ID__c).
For each staging object found:

List its required fields
Flag any required fields that an integration would typically need to populate
Note any fields that seem like they might not be mapped by the integration
(e.g., required lookup fields to objects the external system wouldn't know about)
Check whether any Apex class reads these fields without explicitly setting them —
if a field has no internal code path that populates it, it must come from the
integration or be null
Check any validation rules on this object — verify the formula logic direction.
A rule labeled "X is required" should fire (block save) when X IS null, not when
X has a value. Flag inverted validation rule logic as a confirmed finding.

Present these as integration risk flags, not confirmed problems — except inverted
validation logic, which is Confirmed from metadata alone.

---

## Category 7: Drift Patterns
Analyze the metadata for these 10 drift patterns. For each pattern, classify findings
as CONFIRMED, LIKELY, or FLAG FOR INVESTIGATION.
PATTERN 1 — DUPLICATE AUTOMATION
Find active automations (Apex triggers, Flows) that fire on the same object and event.
Flag where both perform similar actions (create tasks, send emails, update fields).
PATTERN 2 — INTEGRATION + VALIDATION MISMATCH
Find objects with integration-suggestive names (*_Import__c, *_Staging__c). For each:

Identify fields that are read by Apex but never set by any internal code path
Check whether those fields have null guards before use
Flag fields that must be populated by the integration but have no fallback if missing
Do not rely on embedded description text — infer from code structure.

PATTERN 3 — PERMISSION GAPS
Find permission sets with field-level permissions but missing object-level permissions
for the same object. Also find permission sets with object-level access but no
field-level permissions (object visible, all fields blank).
PATTERN 4 — DEPRECATED CODE WITH ACTIVE TESTS
Find Apex classes or triggers with deprecation comments. Also check: if Pattern 1 found
duplicate automation, identify which component is older using API version as a proxy.
Check if any test class asserts a record count that would fail if both components fired
simultaneously — a passing test with that assertion predates the duplication.
PATTERN 5 — FLOWS WITHOUT FAULT PATHS
Find Flows with external actions (Send Email via emailSimple, HTTP Callout) where the
action element has no faultConnector. Flag as a latent production risk — if the external
service fails, the Flow throws an unhandled fault and rolls back the triggering DML.
PATTERN 6 — RECORD TYPE FILTER MISSING
Find objects with multiple record types. For each active Flow on those objects, check
whether entry criteria filter by RecordTypeId. Flag active Flows with no record type
filter on multi-record-type objects.
PATTERN 7 — INTEGRATION REQUIRED FIELDS
Same as Pattern 2 — if these collapse to the same finding on this org, report once.
PATTERN 8 — SHARING DRIFT
Describe all sharing rules and the role hierarchy. Before flagging any sharing rule as
problematic, check the object's OWD (sharingModel in object metadata). If OWD is
ReadWrite, a sharing rule granting Read access is redundant — flag as configuration
overhead, not a broken rule. Flag sharing rules that reference roles that appear
unused or that grant access already provided by OWD.
PATTERN 9 — LOW COVERAGE / ORPHANED CODE
Find Apex classes where public methods are called only by test classes with no
production invocation path visible in metadata. Note: the method may be called
externally via API or Batch not in the metadata — classify as LIKELY, not CONFIRMED.
Also find test classes with weak assertions (size > 0 only, status != original value only).
PATTERN 10 — DEPRECATED FIELDS
Find fields with deprecated naming (Legacy_, Old_, Deprecated_) with no references in
Flows, Apex, Layouts, Validation Rules, Workflow Rules, or Formula fields.
Apply three-tier classification:

Tier 1 (CONFIRMED): No FLS granted to any profile — field is inaccessible
Tier 2 (LIKELY): Has FLS but no references in any metadata type
Tier 3 (NEEDS INVESTIGATION): Naming pattern only, no FLS check completed

Note: when scanning formula fields for field references, check both FieldName__c
(direct reference) and FieldName__r (cross-object relationship traversal). A lookup
field used in a cross-object formula appears only as FieldName__r — a search for
FieldName__c alone will miss it.

---

## Category 8: Cross-System Summary
Based on everything you've analyzed, give me a cross-system summary:

What are the 3 most critical issues — things that are actively broken or causing
data loss right now?
What are the top 3 high-priority issues — things that should be fixed this month?
What are the top technical debt items — things that are messy but not breaking anything?
Are there any dependency risks — places where fixing one thing could break another?

For each finding, note your confidence level:

Confirmed: directly visible in the metadata, no further verification needed
Likely: strongly suggested but worth a quick check
Flag for investigation: needs client input or org access to verify


---

## Pre-Deletion Workflow (Unused Fields)

Run this before deleting any field flagged as unused:

1. **Check FLS** in retrieved profile metadata (see Category 2, Step 2 prompt)
2. **If no FLS** → field is inaccessible, no data can exist → proceed to UI deletion
3. **If FLS exists** → run a Workbench SOQL count check:
   - Open `workbench.developerforce.com` → Queries → SOQL
   - Run queries one at a time (never comma-separated):

```sql
SELECT COUNT() FROM Object__c WHERE Field__c != null
```

   - COUNT = 0 → safe to delete
   - COUNT > 0 → export data before deleting

4. **Always use Workbench, not Developer Console.** Developer Console caches object schemas and returns false "no such column" errors after recent deployments.

5. **"No such column" in SOQL does not confirm a field doesn't exist.** If a field has no FLS, SOQL will return this error even though the field physically exists. Check Object Manager and Workbench field picker to confirm field existence before concluding it's missing.

---

## Follow-Up Prompts

Use these as needed during the analysis:

**To dig into a specific finding:**
Tell me more about [finding]. What exactly does the metadata show, and what would
the fix look like?

**To check a specific field:**
Search all files for any reference to [field_name__c]. Include:

Direct API name references (field_name__c)
Relationship traversal references (field_name__r)
References in Flows, Apex, Layouts, Validation Rules, Workflow Rules, and Formula fields
List every file that contains a reference and what the reference is.


**To check a specific flow:**
Read [Flow_Name] in full and explain what it does step by step, including the trigger
conditions and all actions. Note whether any email or callout actions have fault connectors.

**To get fix recommendations:**
For [finding], write the specific fix — including what to change, where to change it,
and what to test after the fix.

**To write test classes:**
Read [ClassName.cls] and write a complete, well-asserted test class that covers:

The happy path
The error/null path
Bulk operations (200 records)
Any validation logic in the class


**To run call graph analysis:**
For each public method in [ClassName.cls], identify every location in the metadata
where that method is called. Separate callers into two groups: test classes and
production code (non-test Apex, triggers, Flows). Flag any method with no production
callers — these have no visible invocation path in the org and may be orphaned.

**To run cluster analysis on deprecated fields:**
Group all flagged unused/deprecated fields by naming prefix (Legacy_, Old_, Deprecated_,
or other patterns you identify). For each cluster, note how many fields share the prefix
and how many of those have zero references. A cluster where all members are unused
strengthens each individual finding — note this in your confidence assessment.

**To run cross-component impact analysis:**
For each permission gap found, trace the downstream user experience: what can the
assigned user see and not see? For each field exposed via FLS to portal or community
users, verify that a calculation mechanism (formula, roll-up, Apex, or Flow) exists
to populate it. Flag fields that are visible to users but have no backing calculation.

**To check validation rule logic:**
For each validation rule on [Object__c], read the errorConditionFormula and verify
the logic direction. A rule named "X is required" should evaluate to TRUE (block save)
when X IS NULL — not when X has a value. Flag any rule where the label/error message
implies one requirement but the formula logic does the opposite.

