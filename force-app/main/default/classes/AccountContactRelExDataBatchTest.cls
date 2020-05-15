/*
APEX Class Name: AccountContactRelationshipExDataBatch
Test Class Name: AccountContactRelationshipExDataBatchTest
Description    : This is test class for AccountContactRelationshipExDataBatch (Apex Class)
*/
@isTest
private class AccountContactRelExDataBatchTest {
    @testSetup static void createTestdata(){
        // Create Test Account Record        
        Account objAcc = new Account();
        objAcc.Name = 'Test Acc';
        insert objAcc;
        
        // Create Test Contact Record
        Contact objCon = new Contact();
        objCon.Lastname = 'Test Lname';
        objCon.AccountId = objAcc.Id;
        objCon.Email = 'test@test.com';
        insert objCon;
        
        // Create Test AccountContactRole Record
        AccountContactRole objACRole = new AccountContactRole();
        objACRole.AccountId = objAcc.Id;
        objACRole.ContactId = objCon.Id;
        objACRole.Role = 'Test Role';
        insert objACRole;
        
        // Create Test AccountContactRole Record
        objACRole = new AccountContactRole();
        objACRole.AccountId = objAcc.Id;
        objACRole.ContactId = objCon.Id;
        objACRole.Role = 'Test Role 1';
        insert objACRole;
        
        // Create Test Account record
        Account objAcc1 = new Account();
        objAcc1.Name = 'Test Acc 1';
        insert objAcc1;
        
        // Create Test Contact record
        Contact objCon1 = new Contact();
        objCon1.Lastname = 'Test Lname';
        objCon1.AccountId = objAcc1.Id;
        objCon1.Email = 'test@test.com';
        insert objCon1;
        
        // Create Test AccountContactRole Record
        objACRole = new AccountContactRole();
        objACRole.AccountId = objAcc.Id;
        objACRole.ContactId = objCon1.Id;
        objACRole.Role = 'Test Role 11';
        insert objACRole;
        
        // Create Test AccountContactRole Record
        objACRole = new AccountContactRole();
        objACRole.AccountId = objAcc.Id;
        objACRole.ContactId = objCon1.Id;
        objACRole.Role = 'Test Role 12';
        insert objACRole;
    }
    
    static testMethod void unitTestMethod1(){
        Test.startTest();
        // Call Batch class
        AccountContactRelationshipExDataBatch b = new AccountContactRelationshipExDataBatch();       
        database.executebatch(b,200);
        
        // Call Schedular Class
        AccountContactRelationshipExDataBatch sh1 = new AccountContactRelationshipExDataBatch();
        String CRON_EXP = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', CRON_EXP, sh1); 

        Test.stopTest();
        
        // Confirm Account Contact Relationship record gets created successfully.
        List<AccountContactRelation> lstACR = [SELECT Id FROM AccountContactRelation];
        system.assert(lstACR.size() > 0);
    }
}