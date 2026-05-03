# Claude Audit Prompts

Use these prompts systematically during the analysis phase. Start with the opening context prompt, then work through each category. Don't skip categories — the value of this service is comprehensive coverage.

---

## Opening Context Prompt

Paste this at the start of every audit session after uploading the zip:

```
I've uploaded a zip of Salesforce metadata from [Client Name], a [nonprofit/business] 
that uses Salesforce for [brief description — e.g., donor management, volunteer tracking, 
grant management].

Known integrations: [e.g., Stripe for donation processing, Mailchimp for email marketing]

Please extract and analyze this metadata. I'll walk you through specific categories 
one at a time. Start by confirming what metadata types you can see in the uploaded files 
and how many files there are in each category.
```

---

## Category 1: Flows

```
Analyze all Flows in the metadata. For each Flow, identify:

1. Its status (Active vs Draft) — flag any Draft flows that appear to have business logic
2. What object and trigger event it fires on
3. What it does (creates records, sends emails, updates fields, etc.)
4. Any logical errors in trigger conditions or decision criteria
5. Any Flows that fire on the same object and event as another Flow — flag as potentially redundant

List your findings with the Flow name, status, trigger, what it does, and any issues found.
```

---

## Category 2: Custom Fields

```
For every custom field in the metadata, trace its references across all other metadata types:
- Flows
- Apex classes and triggers
- Permission sets
- Layouts
- Profiles

Flag any field that has zero references across all of these. Also flag any field whose 
name or description contains words like "deprecated", "old", "legacy", or "unused".

Present findings as a list: field name, object, and what references exist (or "none found").
```

---

## Category 3: Permission Sets

```
Analyze all permission sets. For each one:

1. List the objects it grants access to and the access level (read/edit/create/delete)
2. List the fields it grants access to
3. Cross-reference with the custom objects in the metadata — are there any custom objects 
   that exist but are missing from this permission set entirely?
4. Flag any cases where a permission set grants field access but not object access 
   (fields are inaccessible without object access)

Focus especially on permission sets with "portal" or "community" in the name, as these 
are typically assigned to external users where gaps cause visible problems.
```

---

## Category 4: Apex Triggers vs Flows

```
List all active Apex triggers and all active Flows, grouped by the object they fire on.

For each object that has BOTH an active trigger AND an active Flow:
1. What does the trigger do?
2. What does the Flow do?
3. Is there overlap — are they doing the same or similar things?
4. Flag as a code/process drift risk if they appear to duplicate each other.

Also flag any Apex trigger whose code comments suggest it has been replaced or deprecated.
```

---

## Category 5: Apex Test Coverage

```
Review all Apex test classes. For each test class:

1. Which Apex class or trigger is it testing?
2. What scenarios does it cover? (look at what records it creates and what it calls)
3. What scenarios are NOT covered? (error paths, edge cases, bulk operations)
4. Are the assertions meaningful? (assert specific values, not just that something exists 
   or that a status changed to anything other than its original value)
5. Are there any Apex classes that have NO corresponding test class at all?

Flag test classes with weak assertions as "passes but doesn't validate" — these give 
false confidence in coverage.
```

---

## Category 6: Integration Staging Objects

```
Look for any custom objects that appear to be integration staging tables — objects used 
to receive data from external systems before processing. Common patterns: objects with 
names containing "Import", "Staging", "Inbound", or "Queue"; objects with fields like 
"Status", "Error", "Transaction ID", or references to external system IDs.

For each staging object found:
1. List its required fields
2. Flag any required fields that an integration would typically need to populate
3. Note any fields that seem like they might not be mapped by the integration 
   (e.g., required lookup fields to objects the external system wouldn't know about)

Present these as integration risk flags, not confirmed problems.
```

---

## Category 7: Cross-System Summary

```
Based on everything you've analyzed, give me a cross-system summary:

1. What are the 3 most critical issues — things that are actively broken or causing 
   data loss right now?
2. What are the top 3 high-priority issues — things that should be fixed this month?
3. What are the top technical debt items — things that are messy but not breaking anything?
4. Are there any dependency risks — places where fixing one thing could break another?

For each finding, note your confidence level:
- Confirmed: directly visible in the metadata, no further verification needed
- Likely: strongly suggested but worth a quick check
- Flag for investigation: needs client input or org access to verify
```

---

## Follow-Up Prompts

Use these as needed during the analysis:

**To dig into a specific finding:**
```
Tell me more about [finding]. What exactly does the metadata show, and what would 
the fix look like?
```

**To check a specific field:**
```
Search all files for any reference to [field_name__c]. List every file that contains it 
and what the reference is.
```

**To check a specific flow:**
```
Read [Flow_Name] in full and explain what it does step by step, including the trigger 
conditions and all actions.
```

**To get fix recommendations:**
```
For [finding], write the specific fix — including what to change, where to change it, 
and what to test after the fix.
```

**To write test classes:**
```
Read [ClassName.cls] and write a complete, well-asserted test class that covers:
- The happy path
- The error/null path
- Bulk operations (200 records)
- Any validation logic in the class
```
