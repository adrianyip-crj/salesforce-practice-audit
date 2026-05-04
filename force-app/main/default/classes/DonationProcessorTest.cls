/**
 * Comprehensive test class for DonationProcessor
 * Covers: processDonationImports (happy path, error paths, bulk), validateDonationImport (all branches)
 */
@isTest
private class DonationProcessorTest {

    // ─── Shared test data setup ───────────────────────────────────────────────

    @testSetup
    static void setup() {
        // Account is required for Opportunity creation
        Account acc = new Account(Name = 'Test Donor Org');
        insert acc;

        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Donor',
            Email = 'donor@example.com',
            AccountId = acc.Id
        );
        insert c;

        Campaign camp = new Campaign(
            Name = 'Spring Appeal',
            IsActive = true
        );
        insert camp;
    }

    // ─── processDonationImports ───────────────────────────────────────────────

    @isTest
    static void testProcessDonationImports_HappyPath() {
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

        Donation_Import__c imp = new Donation_Import__c(
            Donor_Email__c = 'donor@example.com',
            Donation_Amount__c = 250.00,
            Stripe_Transaction_ID__c = 'txn_happy_001',
            Campaign__c = camp.Id,
            Import_Status__c = 'New'
        );
        insert imp;

        Test.startTest();
        DonationProcessor.processDonationImports(new List<Donation_Import__c>{ imp });
        Test.stopTest();

        // Opportunity created with correct values
        Opportunity opp = [SELECT Amount, StageName, CampaignId FROM Opportunity LIMIT 1];
        System.assertEquals(250.00, opp.Amount, 'Amount should match donation');
        System.assertEquals('Closed Won', opp.StageName, 'Stage should be Closed Won');
        System.assertEquals(camp.Id, opp.CampaignId, 'Campaign should be linked');

        // Import marked Completed
        Donation_Import__c updated = [SELECT Import_Status__c FROM Donation_Import__c WHERE Id = :imp.Id];
        System.assertEquals('Completed', updated.Import_Status__c, 'Import should be marked Completed');
    }

    @isTest
    static void testProcessDonationImports_ContactNotFound() {
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

        Donation_Import__c imp = new Donation_Import__c(
            Donor_Email__c = 'nobody@nowhere.com',
            Donation_Amount__c = 100.00,
            Stripe_Transaction_ID__c = 'txn_noemail_001',
            Campaign__c = camp.Id,
            Import_Status__c = 'New'
        );
        insert imp;

        Test.startTest();
        DonationProcessor.processDonationImports(new List<Donation_Import__c>{ imp });
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Opportunity], 'No opportunity should be created');

        Donation_Import__c updated = [SELECT Import_Status__c FROM Donation_Import__c WHERE Id = :imp.Id];
        System.assertEquals('Error', updated.Import_Status__c, 'Import should be marked Error when contact missing');
    }

    @isTest
    static void testProcessDonationImports_BulkMixedResults() {
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

        List<Donation_Import__c> imports = new List<Donation_Import__c>();
        for (Integer i = 0; i < 5; i++) {
            imports.add(new Donation_Import__c(
                Donor_Email__c = 'donor@example.com',
                Donation_Amount__c = 50.00 * (i + 1),
                Stripe_Transaction_ID__c = 'txn_bulk_valid_' + i,
                Campaign__c = camp.Id,
                Import_Status__c = 'New'
            ));
        }
        for (Integer i = 0; i < 5; i++) {
            imports.add(new Donation_Import__c(
                Donor_Email__c = 'unknown' + i + '@nowhere.com',
                Donation_Amount__c = 75.00,
                Stripe_Transaction_ID__c = 'txn_bulk_err_' + i,
                Campaign__c = camp.Id,
                Import_Status__c = 'New'
            ));
        }
        insert imports;

        Test.startTest();
        DonationProcessor.processDonationImports(imports);
        Test.stopTest();

        System.assertEquals(5, [SELECT COUNT() FROM Opportunity], '5 opportunities for valid contacts');
        System.assertEquals(5, [SELECT COUNT() FROM Donation_Import__c WHERE Import_Status__c = 'Completed'], '5 completed imports');
        System.assertEquals(5, [SELECT COUNT() FROM Donation_Import__c WHERE Import_Status__c = 'Error'], '5 error imports');
    }

    // ─── validateDonationImport ───────────────────────────────────────────────
    // Note: these tests pass in-memory (non-inserted) objects to validateDonationImport.
    // The method checks field values before touching the DB, so no insert is needed
    // for null/blank field tests. Only the duplicate check requires a persisted record.

    @isTest
    static void testValidate_ValidRecord() {
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

        Donation_Import__c imp = new Donation_Import__c(
            Donor_Email__c = 'donor@example.com',
            Donation_Amount__c = 100.00,
            Stripe_Transaction_ID__c = 'txn_valid_001',
            Campaign__c = camp.Id,
            Import_Status__c = 'New'
        );
        insert imp;

        Test.startTest();
        Boolean result = DonationProcessor.validateDonationImport(imp);
        Test.stopTest();

        System.assertEquals(true, result, 'Valid record should pass validation');
    }

    @isTest
    static void testValidate_NullAmount() {
        Donation_Import__c imp = new Donation_Import__c(
            Donor_Email__c = 'donor@example.com',
            Donation_Amount__c = null,
            Stripe_Transaction_ID__c = 'txn_nullamt_001',
            Import_Status__c = 'New'
        );

        Test.startTest();
        Boolean result = DonationProcessor.validateDonationImport(imp);
        Test.stopTest();

        System.assertEquals(false, result, 'Null amount should fail validation');
    }

    @isTest
    static void testValidate_ZeroAmount() {
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

        Donation_Import__c imp = new Donation_Import__c(
            Donor_Email__c = 'donor@example.com',
            Donation_Amount__c = 0,
            Stripe_Transaction_ID__c = 'txn_zeroamt_001',
            Campaign__c = camp.Id,
            Import_Status__c = 'New'
        );
        insert imp;

        Test.startTest();
        Boolean result = DonationProcessor.validateDonationImport(imp);
        Test.stopTest();

        System.assertEquals(false, result, 'Zero amount should fail validation');
    }

    @isTest
    static void testValidate_BlankEmail() {
        Donation_Import__c imp = new Donation_Import__c(
            Donor_Email__c = '',
            Donation_Amount__c = 100.00,
            Stripe_Transaction_ID__c = 'txn_noemail_001',
            Import_Status__c = 'New'
        );

        Test.startTest();
        Boolean result = DonationProcessor.validateDonationImport(imp);
        Test.stopTest();

        System.assertEquals(false, result, 'Blank email should fail validation');
    }

    @isTest
    static void testValidate_BlankStripeId() {
        Donation_Import__c imp = new Donation_Import__c(
            Donor_Email__c = 'donor@example.com',
            Donation_Amount__c = 100.00,
            Stripe_Transaction_ID__c = '',
            Import_Status__c = 'New'
        );

        Test.startTest();
        Boolean result = DonationProcessor.validateDonationImport(imp);
        Test.stopTest();

        System.assertEquals(false, result, 'Blank Stripe ID should fail validation');
    }

    @isTest
    static void testValidate_DuplicateStripeId() {
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

        Donation_Import__c existing = new Donation_Import__c(
            Donor_Email__c = 'donor@example.com',
            Donation_Amount__c = 100.00,
            Stripe_Transaction_ID__c = 'txn_dupe_001',
            Campaign__c = camp.Id,
            Import_Status__c = 'Completed'
        );
        insert existing;

        // Pass duplicate as in-memory object — same Stripe ID, not inserted
        Donation_Import__c duplicate = new Donation_Import__c(
            Donor_Email__c = 'donor@example.com',
            Donation_Amount__c = 100.00,
            Stripe_Transaction_ID__c = 'txn_dupe_001',
            Campaign__c = camp.Id,
            Import_Status__c = 'New'
        );

        Test.startTest();
        Boolean result = DonationProcessor.validateDonationImport(duplicate);
        Test.stopTest();

        System.assertEquals(false, result, 'Duplicate Stripe transaction ID should fail validation');
    }
}