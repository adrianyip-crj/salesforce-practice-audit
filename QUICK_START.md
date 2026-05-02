# Quick Start Guide - Complete Audit Workflow

This guide walks you through the complete org health audit workflow from deployment to delivering client findings.

---

## Phase 1: Deploy Practice Org (15 minutes)

### Step 1: Authenticate to Your Dev Org
```bash
sf org login web
```
Log in to your Salesforce Developer Edition org in the browser.

### Step 2: Navigate to Project Directory
```bash
cd /path/to/salesforce-metadata
```

### Step 3: Deploy All Metadata
```bash
sf project deploy start --source-path force-app/main/default
```

**Expected Output:**
```
Deploying v60.0 metadata to [your-org]
Status: Succeeded
```

### Step 4: Verify Deployment
Check your org:
- Setup → Object Manager → You should see: Volunteer, Grant, Volunteer Shift, Donation Import
- Setup → Flows → You should see 4 active Flows
- Setup → Apex Classes → You should see 3 classes

✅ **Checkpoint**: All metadata successfully deployed

---

## Phase 2: Set Up Version Control (10 minutes)

### Step 1: Initialize Git Repository
```bash
git init
git add .
git commit -m "Initial commit - Coastal Food Bank practice org"
```

### Step 2: Create GitHub Repository
1. Go to github.com and create new repository
2. Name it: `salesforce-practice-audit`
3. Don't initialize with README (we already have files)

### Step 3: Push to GitHub
```bash
git remote add origin https://github.com/YOUR-USERNAME/salesforce-practice-audit.git
git branch -M main
git push -u origin main
```

✅ **Checkpoint**: Metadata is in GitHub and ready for analysis

---

## Phase 3: Retrieve Metadata for Analysis (5 minutes)

Even though we just deployed, practice the retrieval workflow you'd use with real client orgs:

```bash
# Retrieve all metadata back from the org
sf project retrieve start --source-path force-app/main/default

# Verify files were retrieved
ls -la force-app/main/default/flows/
ls -la force-app/main/default/objects/
```

Commit the retrieved metadata:
```bash
git add .
git commit -m "Retrieved metadata from dev org"
git push
```

✅ **Checkpoint**: Full org metadata snapshot captured

---

## Phase 4: Conduct the Audit with Claude (2-3 hours)

### Upload Files to Claude
In Claude.ai, upload these files from your local project:
1. All Flow files (`force-app/main/default/flows/*.flow-meta.xml`)
2. All custom object definitions
3. All custom field definitions
4. All Apex classes and triggers
5. Permission set files

### Follow the Audit Checklist
Use `AUDIT_CHECKLIST.md` as your guide. Work through each category:

1. **Flow Analysis** (30 min)
   - Find broken trigger condition
   - Identify redundant Flows

2. **Field Analysis** (20 min)
   - Identify unused fields

3. **Permission Set Analysis** (15 min)
   - Find missing object permissions

4. **Data Model Analysis** (20 min)
   - Discover required field mapping issue

5. **Apex Analysis** (60 min)
   - Identify code/process drift
   - Assess test coverage

6. **Generate Findings Report** (30 min)
   - Use `FINDINGS_REPORT_TEMPLATE.md`

### Example First Prompt
```
I've uploaded Salesforce metadata for a nonprofit food bank. 
Please analyze the Flows first. For each Flow:
1. What object does it trigger on?
2. What are the trigger conditions?
3. Are there any logic errors in the trigger conditions?
4. What actions does the Flow perform?

Look specifically for trigger conditions that don't make logical sense.
```

✅ **Checkpoint**: All 7 problems identified and documented

---

## Phase 5: Generate Client Deliverables (1-2 hours)

### Create Findings Report
1. Copy `FINDINGS_REPORT_TEMPLATE.md`
2. Fill in all 7 findings with:
   - Description
   - Impact
   - Root cause
   - Recommendation
   - Effort estimate

### Create Fix Documentation
For each critical finding, document:
1. Current state (what's broken)
2. Proposed fix (exact steps or code)
3. Testing plan
4. Deployment steps

**Example**: Use `fixes/Fix_1_Thank_You_Email_Flow.md` as a template

### Prioritize Recommendations
Create a phased implementation plan:
- **Phase 1 (Week 1)**: Critical fixes
- **Phase 2 (Week 2-3)**: High priority fixes
- **Phase 3 (Week 4)**: Cleanup and optimization

✅ **Checkpoint**: Professional client deliverables ready

---

## Phase 6: Implement Fixes (Optional - 2-3 hours)

Practice creating the actual fixes:

### Fix #1: Corrected Thank You Email Flow
```bash
# Copy the corrected Flow from fixes folder
cp fixes/Send_Donation_Thank_You_Email_FIXED.flow-meta.xml force-app/main/default/flows/

# Deploy the fix
sf project deploy start --source-path force-app/main/default/flows/Send_Donation_Thank_You_Email_FIXED.flow-meta.xml
```

### Fix #7: Improved Test Class
```bash
# Create the improved test class
# (Already in fixes/Fix_7_DonationProcessor_Tests.md)

# Deploy and run tests
sf project deploy start --source-path force-app/main/default/classes/DonationProcessorTest_IMPROVED.cls
sf apex run test --class-names DonationProcessorTest_IMPROVED --code-coverage
```

### Fix #3: Corrected Permission Set
Create file: `force-app/main/default/permissionsets/Volunteer_Portal_User_FIXED.permissionset-meta.xml`

Add the missing object permissions:
```xml
<objectPermissions>
    <allowCreate>false</allowCreate>
    <allowDelete>false</allowDelete>
    <allowEdit>false</allowEdit>
    <allowRead>true</allowRead>
    <modifyAllRecords>false</modifyAllRecords>
    <object>Volunteer_Shift__c</object>
    <viewAllRecords>false</viewAllRecords>
</objectPermissions>
```

Deploy:
```bash
sf project deploy start --source-path force-app/main/default/permissionsets/
```

✅ **Checkpoint**: Fixes implemented and tested in dev org

---

## Phase 7: Practice Client Presentation (30 minutes)

### Prepare Your Pitch
Using your findings report, practice presenting:

**Opening** (2 minutes):
"We conducted a comprehensive health audit of your Salesforce org and identified 7 areas for improvement. I'm going to walk you through what we found, the business impact, and our recommendations."

**Critical Issues** (5 minutes):
"First, the critical issues that need immediate attention..."
- Broken thank you email
- Volunteers can't access portal
- Donations being dropped

**Impact Quantification** (3 minutes):
"Here's what this is costing you..."
- X hours of manual work per month
- Lost donor stewardship opportunities
- Staff frustration with duplicate tasks

**Solutions** (5 minutes):
"Here's how we fix it..."
- Phased implementation plan
- Effort estimates
- Quick wins vs. longer projects

**Investment & ROI** (3 minutes):
"Total effort: X hours over 4 weeks"
"Expected savings: Y hours per month ongoing"

**Q&A** (Remaining time)

✅ **Checkpoint**: Confident in delivering the pitch

---

## Complete Workflow Timeline

| Phase | Time | Output |
|-------|------|--------|
| 1. Deploy Practice Org | 15 min | Working Salesforce org |
| 2. Set Up Version Control | 10 min | GitHub repository |
| 3. Retrieve Metadata | 5 min | Local metadata snapshot |
| 4. Conduct Audit | 2-3 hours | 7 findings documented |
| 5. Generate Deliverables | 1-2 hours | Client-ready reports |
| 6. Implement Fixes | 2-3 hours | Working solutions |
| 7. Practice Presentation | 30 min | Polished pitch |
| **TOTAL** | **6-9 hours** | **Complete service offering** |

---

## Files You'll Create

By the end of this workflow, you'll have:

**Analysis Documents:**
- [ ] Findings report (7 problems documented)
- [ ] Impact assessment
- [ ] Prioritization matrix

**Fix Documentation:**
- [ ] Corrected Flow XML
- [ ] Improved test class
- [ ] Fixed permission set
- [ ] Implementation guide for each fix

**Client Deliverables:**
- [ ] Executive summary
- [ ] Technical findings report
- [ ] Phased implementation plan
- [ ] Effort estimates
- [ ] ROI analysis

**Supporting Materials:**
- [ ] Presentation deck (optional)
- [ ] Testing documentation
- [ ] Deployment runbook

---

## What Success Looks Like

After completing this practice:

✅ You can identify broken automations in minutes, not hours

✅ You can spot permission misconfigurations by cross-referencing metadata

✅ You can quantify business impact for technical findings

✅ You can write professional client deliverables

✅ You can create actual fixes (Flows, Apex, permission sets)

✅ You can confidently present findings to leadership or clients

✅ You have a repeatable, scalable process

---

## Next Steps: Real Client Pilot

Once you've completed this practice:

1. **Select pilot client** - Choose a familiar org
2. **Get approval** - Position as free health check
3. **Pull their metadata** - Same CLI commands
4. **Run the audit** - Use the same Claude prompts
5. **Deliver findings** - Use the templates you practiced with
6. **Implement fixes** - Start with quick wins
7. **Measure impact** - Document time saved, issues resolved
8. **Create case study** - Use for future sales

---

## Common Questions

**Q: How long does a real client audit take?**
A: For a typical nonprofit org: 4-6 hours analysis + 2-3 hours report writing = 1 business day

**Q: What if I find more than 7 problems in a real org?**
A: You will! Prioritize by business impact and effort. Deliver the top 10-15 findings.

**Q: Can I automate any of this?**
A: Yes - you can script the metadata retrieval and create templates for common findings. But the analysis and client communication still require human judgment.

**Q: What do I charge for this service?**
A: Suggested pricing:
- Health Audit Only: $2,500-$5,000
- Audit + Implementation: $5,000-$15,000 depending on complexity

**Q: How do I position this vs. regular managed services?**
A: "This is a deep-dive diagnostic that we recommend quarterly. It catches issues before they become problems and ensures you're getting maximum value from your Salesforce investment."

---

## Resources

- **Documentation**: All .md files in this project
- **Example Prompts**: `CLAUDE_AUDIT_PROMPTS.md`
- **Audit Checklist**: `AUDIT_CHECKLIST.md`
- **Report Template**: `FINDINGS_REPORT_TEMPLATE.md`
- **Example Fixes**: `fixes/` directory

---

## Support

If you get stuck or need clarification:
1. Review the relevant .md file in this project
2. Check the example fixes in the `fixes/` folder
3. Re-run the Claude audit prompts with more specific questions
4. Test your fixes in the dev org before documenting them

---

## You're Ready!

You now have everything you need to:
- Build the org health audit service offering
- Run your first practice audit
- Deliver professional findings to clients
- Implement fixes confidently
- Scale this as a repeatable service

**Go deploy that practice org and start auditing! 🚀**
