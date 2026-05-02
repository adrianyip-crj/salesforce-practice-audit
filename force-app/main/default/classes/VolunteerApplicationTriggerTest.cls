/**
 * Test class for VolunteerApplicationTrigger
 * 
 * PROBLEM: This test class runs and passes with good coverage, BUT it's testing
 * logic that no longer reflects the current business process.
 * 
 * The trigger was built in 2019 when volunteer applications were processed via Apex.
 * In 2022, this was rebuilt as the "Process Volunteer Application" Flow.
 * 
 * This test validates that tasks are created and emails are sent by the trigger,
 * but the org doesn't rely on the trigger anymore - it relies on the Flow.
 * 
 * This is "code and process drift" - the code and tests pass, but they're testing
 * a process that has been replaced. The test gives false confidence.
 */
@isTest
private class VolunteerApplicationTriggerTest {
    
    @isTest
    static void testVolunteerApplicationCreation() {
        // Create test volunteer
        Volunteer__c testVolunteer = new Volunteer__c(
            Volunteer_Name__c = 'Test Volunteer',
            Email__c = 'test@example.com',
            Status__c = 'Active',
            Volunteer_Type__c = 'Food Distribution'
        );
        
        Test.startTest();
        insert testVolunteer;
        Test.stopTest();
        
        // Verify task was created
        List<Task> createdTasks = [
            SELECT Subject, WhatId, Status, Priority
            FROM Task
            WHERE WhatId = :testVolunteer.Id
        ];
        
        System.assertEquals(1, createdTasks.size(), 'Task should be created for new volunteer');
        System.assertEquals('Not Started', createdTasks[0].Status, 'Task status should be Not Started');
        System.assertEquals('High', createdTasks[0].Priority, 'Task priority should be High');
        System.assert(createdTasks[0].Subject.contains('Review new volunteer application'), 
                     'Task subject should reference volunteer application');
    }
    
    @isTest
    static void testMultipleVolunteersCreation() {
        // Create multiple volunteers
        List<Volunteer__c> volunteers = new List<Volunteer__c>();
        for (Integer i = 0; i < 5; i++) {
            volunteers.add(new Volunteer__c(
                Volunteer_Name__c = 'Test Volunteer ' + i,
                Email__c = 'test' + i + '@example.com',
                Status__c = 'Active',
                Volunteer_Type__c = 'Warehouse Operations'
            ));
        }
        
        Test.startTest();
        insert volunteers;
        Test.stopTest();
        
        // Verify tasks were created for all volunteers
        List<Task> createdTasks = [SELECT Id FROM Task WHERE Subject LIKE '%Review new volunteer application%'];
        System.assertEquals(5, createdTasks.size(), 'Should create task for each volunteer');
    }
}
