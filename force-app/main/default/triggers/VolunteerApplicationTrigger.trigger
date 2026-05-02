/**
 * DEPRECATED TRIGGER - Created in 2019 when volunteer applications were processed via Apex.
 * 
 * PROBLEM: This trigger is still active, but the business process it was built for
 * has been replaced by the "Process Volunteer Application" Flow (created 2022).
 * 
 * The trigger creates Tasks and sends emails for new volunteer applications,
 * but this is now handled by the Flow. The trigger fires but may create duplicate
 * tasks or conflict with the Flow's logic.
 * 
 * The test class (VolunteerApplicationTriggerTest) still runs and passes, but it's
 * testing logic that no longer reflects how the org actually works - demonstrating
 * "code and process drift".
 */
trigger VolunteerApplicationTrigger on Volunteer__c (after insert) {
    List<Task> tasksToCreate = new List<Task>();
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    
    for (Volunteer__c vol : Trigger.new) {
        // Create a task for the volunteer coordinator to review the application
        Task reviewTask = new Task(
            Subject = 'Review new volunteer application: ' + vol.Volunteer_Name__c,
            WhatId = vol.Id,
            Status = 'Not Started',
            Priority = 'High',
            ActivityDate = Date.today().addDays(2)
        );
        tasksToCreate.add(reviewTask);
        
        // Send welcome email to volunteer
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { vol.Email__c });
        email.setSubject('Welcome to Coastal Community Food Bank Volunteers!');
        email.setPlainTextBody('Thank you for applying to volunteer with us. We will review your application and be in touch soon.');
        emailsToSend.add(email);
    }
    
    if (!tasksToCreate.isEmpty()) {
        insert tasksToCreate;
    }
    
    if (!emailsToSend.isEmpty()) {
        Messaging.sendEmail(emailsToSend);
    }
}
