@isTest
public class ARPreferenceCardPDFController_Test{
    private static testmethod void testMethod1(){
        
        // Create Account
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;
        
        // Create Contact
        Contact objContact = new Contact();
        objContact.LastName = 'Test LastName';
        objContact.Email = 'test@test.com';
        objContact.AccountId = objAccount.id;
        insert objContact;
        
        // Create Procedure
        Procedure__c objProcedure = new Procedure__c();
        objProcedure.Name = 'Test Procedure';
        insert objProcedure;
        
        // Create Practitioner Procedure
        Practitioner_Procedure__c objPP = new Practitioner_Procedure__c();
        objPP.Practitioner__c = objContact.id;
        objPP.Procedure__c = objProcedure.id;
        insert objPP;
        
        //Create user
        Profile portalProfile = [SELECT Id FROM Profile where name like : '%portal%' limit 1];
        
        User objUser = new User();
        objUser.Username = 'test12345@test.com';
        objUser.ContactId = objContact.Id;
        objUser.ProfileId = portalProfile.Id;
        objUser.Alias = 'test123';
        objUser.Email = 'test12345@test.com';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.LastName = 'Test LastName';
        objUser.CommunityNickname = 'test12345';
        objUser.TimeZoneSidKey = 'America/Los_Angeles';
        objUser.LocaleSidKey = 'en_US';
        objUser.LanguageLocaleKey = 'en_US';
        insert objUser;
        
        system.runAs(objUser){
            apexpages.currentpage().getparameters().put('pid', objPP.id);
            ARPreferenceCardPDFController objARPDFController = new ARPreferenceCardPDFController();
        }
    }
    
}