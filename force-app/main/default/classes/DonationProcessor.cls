/**
 * Processes donation imports from Stripe and creates Opportunity records
 */
public class DonationProcessor {
    
    public static void processDonationImports(List<Donation_Import__c> imports) {
        List<Opportunity> opportunitiesToCreate = new List<Opportunity>();
        List<Donation_Import__c> importsToUpdate = new List<Donation_Import__c>();
        
        // Collect emails and look up matching Contacts
        Set<String> emails = new Set<String>();
        for (Donation_Import__c imp : imports) {
            emails.add(imp.Donor_Email__c);
        }
        
        Map<String, Contact> contactsByEmail = new Map<String, Contact>();
        for (Contact c : [SELECT Id, Email, AccountId FROM Contact WHERE Email IN :emails]) {
            contactsByEmail.put(c.Email, c);
        }
        
        for (Donation_Import__c imp : imports) {
            Contact donor = contactsByEmail.get(imp.Donor_Email__c);
            
            if (donor == null) {
                imp.Import_Status__c = 'Error';
                importsToUpdate.add(imp);
                continue;
            }
            
            Opportunity opp = new Opportunity(
                Name = 'Donation from ' + donor.Email + ' - ' + Date.today().format(),
                AccountId = donor.AccountId,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Amount = imp.Donation_Amount__c,
                CampaignId = imp.Campaign__c,
                Description = 'Imported from Stripe: ' + imp.Stripe_Transaction_ID__c
            );
            opportunitiesToCreate.add(opp);
            
            imp.Import_Status__c = 'Completed';
            importsToUpdate.add(imp);
        }
        
        if (!opportunitiesToCreate.isEmpty()) {
            insert opportunitiesToCreate;
        }
        
        if (!importsToUpdate.isEmpty()) {
            update importsToUpdate;
        }
    }
    
    /**
     * Validates donation import data before processing
     */
    public static Boolean validateDonationImport(Donation_Import__c imp) {
        if (imp.Donation_Amount__c == null || imp.Donation_Amount__c <= 0) {
            return false;
        }
        
        if (String.isBlank(imp.Donor_Email__c)) {
            return false;
        }
        
        if (String.isBlank(imp.Stripe_Transaction_ID__c)) {
            return false;
        }
        
        List<Donation_Import__c> existingImports = [
            SELECT Id 
            FROM Donation_Import__c 
            WHERE Stripe_Transaction_ID__c = :imp.Stripe_Transaction_ID__c
            AND Id != :imp.Id
            LIMIT 1
        ];
        
        if (!existingImports.isEmpty()) {
            return false;
        }
        
        return true;
    }
}