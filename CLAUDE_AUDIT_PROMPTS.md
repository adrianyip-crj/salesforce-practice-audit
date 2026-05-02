# Claude Audit Prompts - Example Queries

Use these prompts when analyzing the Coastal Community Food Bank metadata with Claude. These are designed to help you discover the 7 intentional problems systematically.

---

## Initial Setup Prompts

### Upload All Metadata
```
I've uploaded Salesforce metadata for a nonprofit organization. This is a practice org with intentional problems built in for audit training. I want you to analyze this metadata and identify:

1. Broken automations (Flows, Process Builders, triggers)
2. Unused custom fields
3. Permission set misconfigurations
4. Redundant automations
5. Data import/integration issues
6. Apex code drift (code built for deprecated processes)
7. Low code coverage and weak test classes

Let's start by analyzing the Flows.
```

---

## Flow Analysis Prompts

### Discover Broken Flow (#1)
```
Analyze all the Flow files in this metadata. For each Flow:
1. What object does it trigger on?
2. What are the trigger conditions?
3. Are there any logic errors in the trigger conditions (e.g., wrong field types, impossible comparisons)?
4. What actions does the Flow perform?

Pay special attention to any trigger conditions that seem illogical or would never evaluate to true.
```

**Expected Discovery**: Send_Donation_Thank_You_Email flow checks if StageName > 0 (text field compared to number)

### Discover Redundant Flows (#4)
```
Looking at all the Flows, are there any that:
- Trigger on the same object and event?
- Perform the same or very similar actions?
- Would result in duplicate records being created?

List any redundant automations you find.
```

**Expected Discovery**: Both Grant task creation Flows trigger on Grant__c insert and create Tasks

---

## Field Analysis Prompts

### Discover Unused Fields (#2)
```
Analyze all custom field definitions. For each field:
1. Does the description indicate it's deprecated or no longer used?
2. Is the field referenced in any Flows, Apex classes, or validation rules in this metadata?
3. Are there any fields that appear to have been replaced by newer fields?

Create a list of fields that appear to be unused or deprecated.
```

**Expected Discovery**: 
- Old_Volunteer_Category__c (replaced by Volunteer_Type__c)
- Deprecated_Grant_Status__c (replaced by Status__c)
- Legacy_Donor_ID__c (from old data migration)

---

## Permission Set Analysis Prompts

### Discover Permission Set Misconfiguration (#3)
```
Analyze the Volunteer_Portal_User permission set:
1. What object permissions does it grant?
2. What field permissions does it grant?
3. Are there any fields with permissions granted where the parent object has no permissions?
4. Based on the field permissions, what objects should have permissions that might be missing?

Specifically, look at fields that start with "Volunteer_Shift__c."
```

**Expected Discovery**: Field permissions reference Volunteer_Shift__c but no object permissions exist for that object

---

## Data Model & Integration Analysis Prompts

### Discover Data Import Issue (#5)
```
Analyze the Donation_Import__c object:
1. What fields are marked as required?
2. Based on the object's description and purpose (Stripe integration staging), are there any required fields that might not be populated by the external integration?
3. Look at the field descriptions - do any mention integration problems?

Pay special attention to the Campaign__c field.
```

**Expected Discovery**: Campaign__c is required but Stripe integration doesn't populate it

---

## Apex Code Analysis Prompts

### Discover Code/Process Drift (#6)
```
Analyze the Apex trigger and classes:
1. Are there any triggers or classes with comments indicating they're deprecated or built for old processes?
2. Are there any Flows that appear to perform the same function as Apex triggers?
3. Look at VolunteerApplicationTrigger specifically - what does it do, and is there a Flow that does the same thing?
4. If both the trigger and a Flow are active, what would happen when a record is created?
```

**Expected Discovery**: VolunteerApplicationTrigger (2019) and Process_Volunteer_Application Flow (2022) both create tasks and send emails

### Discover Low Code Coverage (#7)
```
Analyze DonationProcessor.cls and DonationProcessorTest.cls:
1. What methods exist in DonationProcessor?
2. What methods are called in DonationProcessorTest?
3. Are there any methods in DonationProcessor that appear to have no test coverage?
4. Look at the test assertions - are they checking actual data values or just existence?
5. What error handling paths exist in DonationProcessor that aren't tested?

Estimate the code coverage percentage.
```

**Expected Discovery**: 
- validateDonationImport() method has 0% coverage
- Test assertions are weak (checking size > 0 instead of actual values)
- Error handling paths not tested
- Estimated ~60% coverage

---

## Comprehensive Analysis Prompts

### Full Audit Summary
```
Based on your analysis of all the metadata files, create a comprehensive audit findings report with these sections:

1. **Executive Summary** - High-level overview of findings
2. **Critical Issues** (High Priority) - Broken automations, data loss risks
3. **Optimization Opportunities** (Medium Priority) - Unused fields, redundant processes
4. **Technical Debt** (Medium Priority) - Code coverage, drift issues
5. **Recommendations** - Specific fixes for each issue with estimated effort

For each finding, include:
- Finding title
- Severity (Critical/High/Medium/Low)
- Impact on the organization
- Root cause
- Recommendation
- Estimated effort to fix
```

### Dependency Mapping
```
Create a dependency map showing:
1. Which Flows trigger on which objects
2. Which Apex triggers fire on which objects
3. Where there are conflicts or overlaps
4. What would happen if we deactivated the deprecated VolunteerApplicationTrigger

Visualize this as a table or diagram.
```

### Generate Fix Recommendations
```
For the broken thank you email Flow, provide:
1. Exact description of what's wrong
2. The correct trigger condition that should be used
3. Step-by-step instructions for fixing it in the Salesforce UI
4. The corrected Flow XML if we were to fix it via metadata
```

---

## Advanced Analysis Prompts

### Cross-Reference Analysis
```
Compare the Volunteer_Portal_User permission set against the actual custom objects and fields that exist. Create a matrix showing:
- Objects that exist
- Field permissions granted
- Object permissions granted
- Gaps where field permissions exist but object permissions don't
```

### Test Class Quality Assessment
```
For each test class, assess:
1. What percentage of the parent class's methods are tested?
2. Are edge cases tested (null values, exceptions, bulk operations)?
3. Are assertions meaningful (checking actual values) or weak (checking only existence)?
4. What specific gaps exist in test coverage?
5. Write an example of what a proper test method should look like

Do this for both VolunteerApplicationTriggerTest and DonationProcessorTest.
```

### Write Example Fixes
```
Write the corrected code/metadata for:
1. The broken thank you email Flow (fix the trigger condition)
2. A new comprehensive test class for DonationProcessor that achieves 90%+ coverage
3. The corrected Volunteer_Portal_User permission set with proper object permissions

Provide these as actual Salesforce metadata XML or Apex code that could be deployed.
```

---

## Prompt Sequencing Strategy

**Recommended Order:**
1. Start with Flow analysis (finds problems #1 and #4)
2. Move to field analysis (finds problem #2)
3. Analyze permission sets (finds problem #3)
4. Review data model for integration issues (finds problem #5)
5. Deep dive on Apex code (finds problems #6 and #7)
6. Generate comprehensive findings report
7. Request specific fix recommendations

**Why this order?**
- Flows are easiest to spot issues in (visual logic errors)
- Fields are straightforward (check descriptions)
- Permission sets require cross-referencing
- Apex requires deeper analysis and code review
- Finish with synthesis and recommendations

---

## Tips for Effective Prompting

1. **Be specific about what you're looking for** - Don't just ask "what's wrong?" Ask targeted questions about specific aspects.

2. **Ask Claude to show its work** - Request that Claude quote the specific lines of XML or code that demonstrate the problem.

3. **Request comparisons** - Ask Claude to compare old vs. new approaches (e.g., trigger vs. Flow).

4. **Ask for impact analysis** - Don't just find problems; ask what the business impact is.

5. **Request actionable fixes** - Ask for specific steps to resolve each issue, not just identification.

6. **Iterate on findings** - If Claude finds something interesting, drill deeper with follow-up questions.

---

## Sample Follow-Up Questions

After Claude identifies a problem:
```
For this finding, provide:
- Step-by-step instructions for how to verify this issue in the Salesforce UI
- The exact error message or symptom a user would see
- Which users/processes are affected
- Whether this is blocking critical functionality or just causing inefficiency
- A prioritization recommendation (fix now vs. schedule for later)
```

```
Write the "Before and After" view of this fix:
- What the metadata/code looks like now (the problem)
- What it should look like after the fix
- How to test that the fix worked
```

---

## Generating Client-Facing Reports

```
Take your findings and rewrite them in client-friendly language:
- Remove technical jargon
- Focus on business impact, not technical details
- Use analogies if helpful ("This is like having two people doing the same job - wasteful and confusing")
- Prioritize by ROI and business risk
- Include effort estimates in hours, not technical complexity
```

---

These prompts will help you systematically discover all 7 intentional problems and generate a professional audit deliverable!
