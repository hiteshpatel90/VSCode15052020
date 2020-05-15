/**********************************************************
**Description: A test class for CS_ARAccountsService controller class
**Parameters:   None
**Returns:   None
**Author:    Ansu Routray
**Date Created:  22-May-2017
**********************************************************/
@IsTest
public class CS_ARAccountsServiceTest {
    private static Case__c objCase;
    private static User portalUser;
    private static User adminUser;
    private static Account agencyAccount;
    private static Account healthCareProviderAccount;
    private static Account healthCareProviderAccount2;
    private static Contact portalUserContact;
    private static Contact providerContact;
    private static Product2 objProduct;
    private static Account practitioner;
    private static Affiliation__c affiliation;
    private static Account_Inventory__c accInv;
    private static Account_Inventory__c accInv2;
    private static Task accTask;
    private static Note testNote;
    private static Territory2 objTerritory;
    private static Territory2 objTerritory2;
    
    @testSetup
    static void dataSetup() {
                        
        Id selfuser=UserInfo.getUserId();
        adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex.com', 'testadmin');
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        adminUser.UserRoleId = portalRole.Id;
        insert adminUser;
        system.runas(adminUser){
            
            DataFactoryCustomSetting.createCustomSettings();
            
            DataFactoryTerritory.setUpTerritoryForTestClasses();
            
            objTerritory = [SELECT Id,Name FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1'];
            objTerritory2 = [SELECT Id,Name FROM Territory2 WHERE DeveloperName = 'TestAgencyTerritory'];
            agencyAccount = DataFactoryAccount.createAgencyAccount('Test Agency Account');
            insert agencyAccount;
            
            List<Account> healthCareProviderAccountList=new List<Account>();
            healthCareProviderAccount = DataFactoryAccount.createHealthCareProviderAccount();
            healthCareProviderAccount.Active__c=true;
            healthCareProviderAccount.Account_group__c = 'Z002';
            healthCareProviderAccountList.add(healthCareProviderAccount);
            
            healthCareProviderAccount2 = DataFactoryAccount.createHealthCareProviderAccount();
            healthCareProviderAccount2.Active__c=true;
            healthCareProviderAccount2.Account_group__c = 'Z002';
            healthCareProviderAccountList.add(healthCareProviderAccount2);
            
            insert healthCareProviderAccountList;
            
            List<ObjectTerritory2Association> objAssocList=new List<ObjectTerritory2Association>();
            ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = healthCareProviderAccount.Id,
                                                                                    Territory2Id = objTerritory.Id,
                                                                                    AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);
            objAssocList.add(objAssoc);
            ObjectTerritory2Association objAssoc3 = new ObjectTerritory2Association(objectId = healthCareProviderAccount2.Id,
                                                                                    Territory2Id = objTerritory.Id,
                                                                                    AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);
            objAssocList.add(objAssoc3);
            insert objAssocList;
            
            portalUserContact = DataFactoryContact.createContacts('PortalContact');
            portalUserContact.AccountId = agencyAccount.Id;
            insert portalUserContact;
            
            providerContact = DataFactoryContact.createContacts('providerContact');
            providerContact.AccountId = healthCareProviderAccount.Id;
            insert providerContact;
            
            portalUser = DataFactoryUser.preparePortalUser();
            portalUser.customer_number__c = 'ArthTest001';
            portalUser.ContactId = portalUserContact.Id;
            insert portalUser;
            
            UserTerritory2Association objTerrAssoc = new UserTerritory2Association(UserId = portalUser.Id,
                                                                                   Territory2Id = objTerritory2.Id);
            insert objTerrAssoc;
            
            UserTerritory2Association objTerrAssoc1 = new UserTerritory2Association(UserId = adminUser.Id,
                                                                                   Territory2Id = objTerritory.Id);
            insert objTerrAssoc1;
            
            UserTerritory2Association objTerrAssoc3 = new UserTerritory2Association(UserId = selfuser,
                                                                                   Territory2Id = objTerritory.Id);
            insert objTerrAssoc3;
            
            practitioner = DataFactoryAccount.createPractitionerAccount();
            insert practitioner;
            
            ObjectTerritory2Association objAssoc2 = new ObjectTerritory2Association(objectId = practitioner.Id,
                                                                                    Territory2Id = objTerritory.Id,
                                                                                    AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);
            insert objAssoc2;
            
            objProduct = DataFactoryProduct.createProduct('AR-Test001');
            insert objProduct;
            
            affiliation = CS_TestDataBuilder.CreateAffiliation(healthCareProviderAccount.Id ,practitioner.Id);
            //insert affiliation;
            
            testNote=new Note();
            testNote.ParentId=healthCareProviderAccount.Id;
            testNote.Title='Account Note';
            testNote.Body='test notes';
            insert testNote;
            
            accInv=new Account_Inventory__c();
            accInv.account__c=healthCareProviderAccount.Id;
            accInv.Low_Par__c=1;
            accInv.High_Par__c=2;            
            
            
            accInv2=new Account_Inventory__c();
            accInv2.account__c=healthCareProviderAccount.Id;
            accInv2.Low_Par__c=1;
            accInv2.High_Par__c=2;            
            
            
            accTask=new Task();
            accTask.status='Not Started';
            accTask.WhatId=healthCareProviderAccount.Id;
            accTask.Subject='Test Task';
            
            insert accTask;
            
            Opportunity objOpportunity = new Opportunity(Name = 'Test Opportunity',
                                                         AccountId = healthCareProviderAccount.Id,
                                                         StageName = 'Closed - Won',
                                                         Type = 'Agreements',
                                                         Potential_Revenue_per_Case__c = 100.00,
                                                         Probability = 10.0,
                                                         Competitve_Conversion__c = 'No',
                                                         //Competitive_Company__c = 'Tornier',
                                                         Close_Lost_Reasons__c = '',
                                                         CloseDate = Date.newInstance(2016, 2, 17),
                                                         OwnerId = adminUser.Id,
                                                         Surgeon__c = practitioner.Id,
                                                         Product_Category__c = 'Biologics');
            insert objOpportunity;
            
            objCase = CS_TestDataBuilder.CreateCases(practitioner.Id, healthCareProviderAccount.Id,objProduct.Id);
            objCase.OwnerId =adminUser.Id;
            insert objCase;
            
            
            Affiliation__c affiliation = CS_TestDataBuilder.CreateAffiliation(healthCareProviderAccount.Id ,practitioner.Id);
            insert affiliation;
            
            Affiliation__c affiliation1 = CS_TestDataBuilder.CreateAffiliation(healthCareProviderAccount.Id ,practitioner.Id);
            insert affiliation1;
            
            Case__c newCase = new Case__c(Practitioner__c = practitioner.Id,
                                          Health_Care_Provider__c = healthCareProviderAccount.Id,
                                          Event_Start_Date__c = Date.newInstance(2016, 09, 09),
                                          Status__c = 'Pending');
            insert newCase;
            
            Event objEvent = new Event();
            objEvent.whatid = healthCareProviderAccount.id;
            objEvent.subject = 'test';
            objEvent.ActivityDate = system.today();
            objEvent.ActivityDateTime = system.now();
            objEvent.DurationInMinutes = 120;
            //objEvent.Event_Priority__c = 'Normal';
            insert objEvent;
        }
    }
        
    static testMethod void testAllMethods() {
            healthCareProviderAccount = [SELECT id, Name, Preferred_Name__c, BillingCity, BillingState, Phone, Customer_Number__c from Account where Account_group__c = 'Z002' LIMIT 1];
            List<Id> accIdList=new List<Id>();
            accIdList.add(healthCareProviderAccount.Id);
            CS_ARAccountsService.retrieveTerritoryForProviders(accIdList);
            CS_ARAccountsService.retrieveOpportunitiesByAccountId(healthCareProviderAccount.Id);
            
            AccountHistory acchist = new AccountHistory();
            acchist.AccountId = healthCareProviderAccount.id;
            acchist.Field = 'Created';
            insert acchist;
            
            acchist = new AccountHistory();
            acchist.AccountId = healthCareProviderAccount.id;
            acchist.Field = 'Phone';
            insert acchist;
            
            CS_ARAccountsService.retrieveAccountActivity('All Activities',healthCareProviderAccount.Id);
            CS_ARAccountsService.searchSurgeonsInMyTeamTerritory('jo');
            CS_ARAccountsService.retrieveProviders();
            List<Account_Inventory__c> accInvList=new List<Account_Inventory__c>();
            accInvList.add(accInv);   
            Test.startTest(); 
            CS_ARAccountsService.csaveAccountInventory(healthCareProviderAccount.Id,'test','test','test','test','test',accInvList);
            //insert accInv; 
            accInvList.remove(0);       
            accInvList.add(accInv2);            
            CS_ARAccountsService.csaveAccountInventory(healthCareProviderAccount.Id,'test','test','test','test','test',accInvList);
            CS_ARAccountsService.csaveAccountInventory(null,'test','test','test','test','test',accInvList); 
            
            objTerritory = [SELECT Id,Name FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1'];
            CS_ARAccountsService.CS_ARAccountWrapper accWrapper=new CS_ARAccountsService.CS_ARAccountWrapper(healthCareProviderAccount,objTerritory.Name);
            CS_ARAccountsService.CS_OpportunityActivityWrapper oppWrapper=new CS_ARAccountsService.CS_OpportunityActivityWrapper(DateTime.now(),'Test','Log');
            CS_ARAccountsService.CS_OpportunityActivityWrapper oppWrapper2=new CS_ARAccountsService.CS_OpportunityActivityWrapper(DateTime.now(),'Test2','Log');
            CS_ARAccountsService.OpportunityWrapper opyWrapper=new CS_ARAccountsService.OpportunityWrapper(oppWrapper);
            CS_ARAccountsService.OpportunityWrapper opyWrapper2=new CS_ARAccountsService.OpportunityWrapper(oppWrapper2);
            list<CS_ARAccountsService.OpportunityWrapper> lstSortedOpportunityWrapper= new list<CS_ARAccountsService.OpportunityWrapper>();
            lstSortedOpportunityWrapper.add(opyWrapper);
            lstSortedOpportunityWrapper.add(opyWrapper2);
            lstSortedOpportunityWrapper.sort();
            CS_ARAccountsService.cls_RetrieveSurgeonAffiliationsByAccount clssurgeon=new  CS_ARAccountsService.cls_RetrieveSurgeonAffiliationsByAccount();
            clssurgeon.retrieveAllSurgeonAffiliationsByAccount(healthCareProviderAccount.Id);
             
            adminUser = [SELECT id FROM User where email = 'testsalesrep@arthrex.com' and username = 'testadmin@arthrex.com.arthrex.com' LIMIT 1];
            system.runas(adminUser){
                CS_ARAccountsService.retrieveProviders();
            }
            Test.stopTest();
        
    }
    
    @isTest
    static void testWithAllDataAccess() {
        healthCareProviderAccount = [SELECT id, Name, Preferred_Name__c, BillingCity, BillingState, Phone, Customer_Number__c from Account where Account_group__c = 'Z002' LIMIT 1];
           
        AccountHistory acchist = new AccountHistory();
        acchist.AccountId = healthCareProviderAccount.id;
        acchist.Field = 'Created';
        insert acchist;
        
        //AccountHistory acchist=[SELECT Id, IsDeleted, AccountId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue FROM AccountHistory limit 1];    
        System.debug('hist=============='+acchist);
        CS_ARAccountsService.retrieveAccountActivity('Log',acchist.AccountId);
        
        Case__c objCustomCase = [select id from Case__c Limit 1];
                
        Case__History objOCH = new Case__History();
        objOCH.Field = 'Created';
        objOCH.ParentId = objCustomCase.Id;
        Insert objOCH;
        
        objOCH = new Case__History();
        objOCH.Field = 'Name';
        objOCH.ParentId = objCustomCase.Id;
        Insert objOCH;
        
        List<Case__History> caseHistList = [SELECT Id, IsDeleted, ParentId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue FROM Case__History]; 
        if(!caseHistList.isEmpty()){
            Case__History caseHist = caseHistList[0];            
            Case__c caseRec=[SELECT Id, CreatedDate, CreatedBy.Name,Health_Care_Provider__r.Name, Practitioner__c, Practitioner__r.Name, Event_Start_Date__c,Event_End_Date__c,Status__c from Case__c where Id=:caseHist.ParentId];
            CS_ARAccountsService.createAccCaseHistoryWrapper(caseHist,caseRec);
        }
         CS_ARAccountsService.retrieveProviders();
        
    }

    @isTest
    static void createNote_Test() {
        healthCareProviderAccount = [SELECT id from Account where Account_group__c = 'Z002' LIMIT 1];
       
        CS_ARAccountsService.createNote(healthCareProviderAccount.id, 'test');
        
        Note accountNote = [Select Id,Body from Note limit 1];
        CS_ARAccountsService.updateNote(accountNote.id, 'Test update');
        
        CS_ARAccountsService.deleteNote(accountNote.id);
    }
    
    @isTest
    static void retrieveSurgeonAffiliationsByAccount_Test() {
        healthCareProviderAccount = [SELECT id from Account where Account_group__c = 'Z002' LIMIT 1];
        CS_ARAccountsService.retrieveSurgeonAffiliationsByAccount(healthCareProviderAccount.id);
    }
    
    @isTest
    static void retrieveAccountInventory_Test() {
        healthCareProviderAccount = [SELECT id from Account where Account_group__c = 'Z002' LIMIT 1];
        CS_ARAccountsService.retrieveAccountInventory(healthCareProviderAccount.id);
    }
    
    
    
}