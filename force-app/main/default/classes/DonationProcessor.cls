/**
 * Processes donation imports from Stripe and creates Opportunity records
 * 
 * PROBLEM: This class has complex logic but low test coverage (around 60%).
 * The test class runs but doesn't cover the error handling paths or edge cases.
 */
public class DonationProcessor {
    
    /**
     * Processes a batch of donation imports and creates Opportunities
     */
    public static void processDonationImports(List<Donation_Import__c> imports) {
        List<Opportunity> opportunitiesToCreate = new List<Opportunity>();
        List<Donation_Import__c> importsToUpdate = new List<Donation_Import__c>();
        
        // Get all related Contacts by email
        Set<String> emails = new Set<String>();
        for (Donation_Import__c imp : imports) {
            emails.add(imp.Donor_Email__c);
        }
        
        Map<String, Contact> contactsByEmail = new Map<String, Contact>();
        for (Contact c : [SELECT Id, Email FROM Contact WHERE Email IN :emails]) {
            contactsByEmail.put(c.Email, c);
        }
        
        for (Donation_Import__c imp : imports) {
            try {
                // Find or create Contact
                Contact donor = contactsByEmail.get(imp.Donor_Email__c);
                
                if (donor == null) {
                    // Contact doesn't exist - mark import as error
                    imp.Import_Status__c = 'Error';
                    importsToUpdate.add(imp);
                    continue;
                }
                
                // Create Opportunity
                Opportunity opp = new Opportunity(
                    Name = 'Donation from ' + donor.Email + ' - ' + Date.today().format(),
                    ContactId = donor.Id,
                    StageName = 'Closed Won',
                    CloseDate = Date.today(),
                    Amount = imp.Donation_Amount__c,
                    CampaignId = imp.Campaign__c,
                    Description = 'Imported from Stripe: ' + imp.Stripe_Transaction_ID__c
                );
                opportunitiesToCreate.add(opp);
                
                // Mark import as completed
                imp.Import_Status__c = 'Completed';
                importsToUpdate.add(imp);
                
            } catch (Exception e) {
                // Error handling - mark as error
                imp.Import_Status__c = 'Error';
                importsToUpdate.add(imp);
                System.debug('Error processing donation import: ' + e.getMessage());
            }
        }
        
        // Insert opportunities
        if (!opportunitiesToCreate.isEmpty()) {
            try {
                insert opportunitiesToCreate;
            } catch (DmlException e) {
                // Handle bulk insert errors
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug('Error inserting opportunity: ' + e.getDmlMessage(i));
                }
            }
        }
        
        // Update import records
        if (!importsToUpdate.isEmpty()) {
            update importsToUpdate;
        }
    }
    
    /**
     * Validates donation import data before processing
     * This method is NOT covered by tests
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
        
        // Check for duplicate Stripe transaction
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