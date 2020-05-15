@isTest
public class CS_AROpportunityCCTest {
  private static Account HCPAccount;
    private static User adminUser;
    private static User portalUser;
    private static Contact portalUserContact;
    private static Account agencyAccount;
    private static Procedure__c oppProcedure;
    private static Product2 oppProduct2;
    private static Opportunity_Surgeons__c oppSurgeons;
    private static Account pracAccount;
    @testSetup
    static void dataSetup() {
        
        adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex.com', 'testadmin');
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        adminUser.UserRoleId = portalRole.Id;
        insert adminUser; 
        System.runAs(adminUser){
            DataFactoryCustomSetting.createCustomSettings();
            DataFactoryTerritory.setUpTerritoryForTestClasses();
            
            Territory2 objterritory1 = [SELECT Id, DeveloperName FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1'];
            Territory2 objterritory2 = [SELECT Id, DeveloperName FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory2'];
            
            agencyAccount = DataFactoryAccount.createAgencyAccount('Test Agency Account');
            insert agencyAccount;
            
            HCPAccount = DataFactoryAccount.createHealthCareProviderAccount();
            HCPAccount.Z1__c= 'ArthTest001';
            HCPAccount.Z2__c= 'ArthTest002';
            HCPAccount.ZD__c= 'ArthTest003';
            
            insert HCPAccount;
            
            pracAccount = DataFactoryAccount.createPractitionerAccount();
            //pracAccount.Designation__pc = 'PhD';
            //pracAccount.Focus_of_my_practice__pc = 'Foot/Ankle;Sports Medicine/Arthroscopy;Trauma';
            
            insert pracAccount;
            
            portalUserContact = DataFactoryContact.createContacts('PortalContact');
            portalUserContact.AccountId = agencyAccount.Id;
            insert portalUserContact;
            
            portalUser = DataFactoryUser.preparePortalUser();
            portalUser.customer_number__c = 'ArthTest001';
            portalUser.ContactId = portalUserContact.Id;
            insert portalUser;
            
            oppProcedure = DataFactoryProcedures.createProcedure();
            insert oppProcedure;
            
            oppProduct2 = DataFactoryProduct.createProduct('Test Material Number');
            insert oppProduct2;
            
            List<UserTerritory2Association> lstNewUserTerritoryAssociations = new List<UserTerritory2Association>();
            
            UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(UserId = adminUser.Id,
                                                                                                   Territory2Id = objterritory1.Id);
            lstNewUserTerritoryAssociations.add(objUserTerritory2Association);
            objUserTerritory2Association = new UserTerritory2Association(UserId = portalUser.Id, Territory2Id = objterritory1.Id);
            lstNewUserTerritoryAssociations.add(objUserTerritory2Association);
            insert lstNewUserTerritoryAssociations;                   
            
            HCPAccount.Active__c=true;
            HCPAccount.Account_group__c = 'Z002';
            update HCPAccount;
            
            Opportunity objOpportunity = new Opportunity(Name = 'Test Opportunity',
                                                         AccountId = HCPAccount.Id,//changed by srinivas sattoor 04.21.2017
                                                         Procedure__c = oppProcedure.Id,
                                                         StageName = 'Closed - Won',
                                                         Type = 'Agreements',
                                                         Potential_Revenue_per_Case__c = 100.00,
                                                         Probability = 10.0,
                                                         Competitve_Conversion__c = 'No',
                                                         //Competitive_Company__c = 'Tornier',
                                                         Close_Lost_Reasons__c = '',
                                                         CloseDate = Date.newInstance(2016, 2, 17),
                                                         OwnerId = portalUser.Id,
                                                         Surgeon__c = pracAccount.Id,
                                                         Product_Category__c = 'Biologics');
            insert objOpportunity;
            
            Attachment objAttachment = new Attachment();
            objAttachment.body = blob.valueof('Test');
            objAttachment.Name = 'Test';
            objAttachment.Parentid = objOpportunity.id;
            insert objAttachment;
            Opportunity objOppo = new Opportunity(Name = 'Test1 Opportunity',
                                                         StageName = 'Closed - Won',
                                                         CloseDate = Date.newInstance(2016, 2, 17));
            insert objOppo;
            
            Product2 prod = new Product2(Name = 'Test', 
                                         Family = 'Hardware',
                                         Material_Number__c = 'AR-9510-06');
            insert prod;
            
            // Get standard price book ID.
            Id pricebookId = Test.getStandardPricebookId();
            
            // 1. Insert a price book entry for the standard price book.
            // Standard price book entries require the standard price book ID we got earlier.
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                              Product2Id = prod.Id,
                                                              UnitPrice = 10000, 
                                                              IsActive = true,
                                                              Unique_Id__c = 'AR-9510-06_US');
            insert standardPrice;
            
            // Create a custom price book
            Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', 
                                                 isActive=true,
                                                 PriceBook_Country_Code__c = 'CP');
            insert customPB;
            
            // 2. Insert a price book entry with a custom price.
            PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, 
                                                            Product2Id = prod.Id,
                                                            UnitPrice = 12000, 
                                                            IsActive = true, 
                                                            Unique_Id__c = 'AR-9510-06_CP');
            insert customPrice;
            
            OpportunityLineItem objOppLineItem = new OpportunityLineItem(PriceBookEntryId = standardPrice.Id,
                                                                         OpportunityId = objOpportunity.Id,
                                                                         Quantity = 2,
                                                                         TotalPrice = 3);
            insert objOppLineItem;
            
            OpportunityLineItem objOppoLineItem = new OpportunityLineItem(PriceBookEntryId = standardPrice.Id,
                                                                         OpportunityId = objOppo.Id,
                                                                         Quantity = 2,
                                                                         TotalPrice = 3);
            insert objOppoLineItem;
            
            OpportunityTeamMember objOppTeamMembers = new OpportunityTeamMember(OpportunityId = objOpportunity.Id,
                                                                                UserId = portalUser.Id,
                                                                                TeamMemberRole = 'Account Manager');
            insert objOppTeamMembers;
            
            Opportunity_Surgeons__c objOppSurgeons = new Opportunity_Surgeons__c(Opportunity__c = objOpportunity.Id,
                                                                                 Surgeon__c = pracAccount.Id);
            insert objOppSurgeons;
            
            Linked_Opportunity__c objLinkedOpp = new Linked_Opportunity__c(Linked_Opportunity__c = objOpportunity.Id,
                                                                           Opportunity__c = objOpportunity.Id);
            insert objlinkedOpp;        
            
            Case__c newCase = new Case__c(Practitioner__c = pracAccount.Id,
                                          Health_Care_Provider__c = HCPAccount.Id,
                                          Event_Start_Date__c = Date.newInstance(2016, 09, 09),
                                          Status__c = 'Pending');
            insert newCase;
            
            Case_Procedure__c newCaseProcedure = new Case_Procedure__c(Procedure__c = oppProcedure.Id,
                                                                       Case__c = newCase.Id);
            insert newCaseProcedure;
            
            Opportunity_Case__c newOppoCase = new Opportunity_Case__c(Case__c = newCase.Id,
                                                                      Opportunity__c = objOpportunity.Id);
            insert newOppoCase;
            
            Quote newQuote = new Quote(OpportunityId = objOpportunity.Id,
                                       Name = 'testQuote');
            insert newQuote;
            
            OpportunityFieldHistory newOppoFH = new OpportunityFieldHistory(OpportunityId = objOpportunity.Id);
            
            Contact objCon = DataFactoryContact.createContacts('PortalContact');
            objCon.AccountId = agencyAccount.Id;
            insert objCon;
            
            OpportunityContactRole objOCR = new OpportunityContactRole();
            objOCR.OpportunityId = objOpportunity.id;
            objOCR.ContactId = objCon.id;
            insert objOCR;
            
            Task task = new Task();
            task.WhatId = agencyAccount.id;
            task.WhoId = objCon.id;
            task.Subject = 'Other';
            task.status = 'Not Started';
            task.description = 'New  Work';
            insert task;   
       }
    }
    private static testmethod void testMethod1(){
        
        Opportunity oppo = [SELECT Id, Name, OwnerId, AccountId, CloseDate FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
       // User user = [SELECT Id FROM User WHERE FirstName = 'FName' LIMIT 1];
        
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'PortalContact' LIMIT 1];
        
        Opportunity_Case__c linkedCases = [SELECT Id FROM Opportunity_Case__c LIMIT 1];
        
        Linked_Opportunity__c linkedOppor = [SELECT Id FROM Linked_Opportunity__c LIMIT 1];
        
        Opportunity_Surgeons__c oppoSurgeon = [SELECT Id FROM Opportunity_Surgeons__c LIMIT 1];
        
        OpportunityTeamMember oppoTeamMember = [SELECT Id FROM OpportunityTeamMember LIMIT 1];
        
        Procedure__c proc = [SELECT Id FROM Procedure__c WHERE Name = 'elbowTest' LIMIT 1];
        
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        
         
        List<Opportunity> lstMyTeamOpportunities = [SELECT Id, Type, StageName, OwnerId, IsClosed FROM Opportunity];
        List<Id> lstOwnerId = new List<Id>();
        for(Opportunity oppor : lstMyTeamOpportunities){
            lstOwnerId.add(oppor.OwnerId);
        }
        
        //List<Account> acctList = [SELECT Id FROM Account WHERE LastName = 'TestPractitionerLastName'];
        List<Account> acctList = [SELECT Id FROM Account WHERE Name = 'TestPractitionerLastName'];
        List<String> surgeonIds = new List<String>();
        for(Account accts : acctList){
            surgeonIds.add(accts.Id);
        }
        
        List<Id> surgeonId = new List<Id>();
        Account lstOwnerIds = [SELECT Id FROM Account WHERE Name = 'Test HCP Account'];
        for(Account acct : acctList){
            surgeonId.add(acct.Id);
        }
        
        List<OpportunityTeamMember> oppoTMList = [SELECT Id, UserId, OpportunityId FROM OpportunityTeamMember WHERE TeamMemberRole = 'Account Manager'];
        List<String> lsSalesRep = new List<String>();
        for(OpportunityTeamMember oppoTM : oppoTMList){
            lsSalesRep.add(oppoTM.UserId);
        }
        
        List<OpportunityLineItem> oliList = [SELECT Id FROM OpportunityLineItem];
        List<OpportunityLineItem> oppoLineItemList = new List<OpportunityLineItem>();
        List<Id> lstLineItems = new List<Id>();
        for(OpportunityLineItem oppoLI : oppoLineItemList){
            lstLineItems.add(oppoLI.Id);
        }
        
        List<Linked_Opportunity__c> linkedOppoList = [SELECT Id, Opportunity__c FROM Linked_Opportunity__c ];
        List<String> linkedOppo = new List<String>();
        for(Linked_Opportunity__c linked : linkedOppoList){
            linkedOppo.add(linked.Opportunity__c);
        }
        
        List<Opportunity_Case__c> linkedCaseList = [SELECT Id FROM Opportunity_Case__c ];
        List<String> linkedCase = new List<String>();
        for(Opportunity_Case__c linked : linkedCaseList){
            linkedCase.add(linked.Id);
        }
        
        Map<String,Object> mapOpp = new Map<String,Object>();
        List<Opportunity> oppoList = [SELECT Annual_Number_of_Procedures__c, CloseDate, Close_Lost_Reasons__c, Estimated_Install_Date__c, Id, Name, OwnerId, Quote_Date__c, StageName, Type FROM Opportunity];
        for(Opportunity op : oppoList){
            mapOpp.put('opportunityName', op.Name);
            mapOpp.put('opportunityOwner', op.OwnerId);
            mapOpp.put('opportunityType', op.Type);
            mapOpp.put('opportunityStage', op.StageName);
            mapOpp.put('opportunityId', op.Id);
            mapOpp.put('opportunityCloseDate', '01/01/2017');
            mapOpp.put('estimatedInstallDate', '01/01/2017');
            mapOpp.put('quoteDate', '01/01/2017');
            mapOpp.put('annualNumberOfProcedures', '2.0');
            mapOpp.put('closedLostReason', 'Pricing Issue');
            break;
        }
        
        Test.startTest();
        //system.runAs(objUser){
          CS_AROpportunityCC.retrieveAccountTeamTerritory(oppo.AccountId);
          CS_AROpportunityCC.retrieveMapParentTerritoryAndListTerritoryIds();
          CS_AROpportunityCC.retrieveDefaultTerritory();
          CS_AROpportunityCC.retrieveOpportunitiesInMyTeamTerritory();
          CS_AROpportunityCC.retrieveOpportunityTypeValues();
          CS_AROpportunityCC.retrieveOpportunityContactRoleValues();
          CS_AROpportunityCC.retrieveCompetitiveCompanyValues();
          CS_AROpportunityCC.retrieveOpportunityTeamRoleValues();
          CS_AROpportunityCC.retrieveCompetitiveConversionValues();
          CS_AROpportunityCC.retrieveUserTeams();
          CS_AROpportunityCC.getCasesToBeLinked(surgeonIds,oppo.Id);
          CS_AROpportunityCC.getOpportunitiesToBeLinked(surgeonIds,oppo.Id);
          CS_AROpportunityCC.retreiveActivities('Logs',oppo.Id);
          CS_AROpportunityCC.retrieveOpportunityStages('Product Conversion');
          CS_AROpportunityCC.retrieveOpportunityCloseLostReasons('Closed - Lost');
          CS_AROpportunityCC.retrieveOpportunityStageValues('Product Conversion');
          CS_AROpportunityCC.retrieveOpportunityProductCategoryValues('Product Conversion');
          CS_AROpportunityCC.saveOpportunityContactRole(oppo.Id,cont.Id,'Manager',true);
          //CS_AROpportunityCC.saveOpportunityTeamRole(oppo.Id,user.Id,'Account Manager');
          OpportunityContactRole oppContRole = [SELECT Id FROM OpportunityContactRole LIMIT 1];
          CS_AROpportunityCC.deleteOpportunityContactRole(oppContRole.Id);
          CS_AROpportunityCC.deleteOpportunityTeamMember(oppoTeamMember.Id);
          CS_AROpportunityCC.deleteOpportunitySurgeon(oppoSurgeon.Id);
          CS_AROpportunityCC.cancelOpportunity(oppo.Id,'');
          //CS_AROpportunityCC.createNote(oppo.Id,'Test notes');
          CS_AROpportunityCC.saveOpportunityStage(oppo.Id,'Closed - Won','');
          CS_AROpportunityCC.retrieveOpportunity(oppo.Id);
          CS_AROpportunityCC.saveLinkedOpportunities(oppo.Id,linkedOppo);
          CS_AROpportunityCC.deleteLinkedOpportunity(linkedOppor.Id);
          CS_AROpportunityCC.saveLinkedCases(oppo.Id,linkedCase);
          CS_AROpportunityCC.saveOpportunitySurgeons(oppo.Id,surgeonIds);
          CS_AROpportunityCC.deleteLinkedCase(linkedCases.Id);
          CS_AROpportunityCC.saveOpportunityN(mapOpp,surgeonIds,lsSalesRep,surgeonIds,lsSalesRep,oppoLineItemList);
           CS_AROpportunityCC.saveOpportunity(string.valueOf(oppo.Id), string.valueOf(oppo.OwnerId), oppo.Name, string.valueOf(oppo.AccountId), '12/27/2016', surgeonIds, lsSalesRep, oppoLineItemList, 'Yes', 'Tornier', 'Agreements', NULL, string.valueOf(proc.Id), 1.0, 500.0, 1.0, 500.0, 2.0, 500.0, 1.0, 500.0, 1000.0, 2000.0, 2000.0,  '12/27/2016' , quote.id, '12/27/2016' , 2.0, 1.0, 5.0, string.valueOf(quote.Id), 'Biologics');
          CS_AROpportunityCC.deleteOpportunity(oppo.Id);
          CS_AROpportunityCC oppCC=new CS_AROpportunityCC();
          oppCC.getOpportunityTypeValues();
          oppCC.getSubAgencyOrTeamDropDown();
          oppCC.getAssingedToMultipleTerritories();
          oppCC.getOpportunityTypes();
          
        
        //}
        Test.stopTest();
    }
    private static void insertTestTerritory(Id AccId, Id uId, Id t2Id){
            
            ObjectTerritory2Association oT2A = new ObjectTerritory2Association(ObjectId = AccId, Territory2Id =t2Id, AssociationCause='Territory2Manual' );
            insert oT2A;
    }
    public static testmethod void testMethod2(){
        Opportunity oppo = [SELECT Id, Name, OwnerId, AccountId, CloseDate FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        CS_AROpportunityCC.saveOpportunityTeamRole(oppo.id, system.userinfo.getuserid(), 'test role');
    }
    
    public static testMethod void createNote_test() {
        List<Opportunity> lstOpp = [select id, Type from Opportunity LIMIT 1];
        CS_AROpportunityCC.createNote(lstOpp[0].id, 'Test Note', null);
    }//end of createNote_test
    
    public static testMethod void updateTaskStatus_test() {
        List<Task> lstTask = [select id from Task LIMIT 1];
        CS_AROpportunityCC.updateTaskStatus(lstTask[0].id, 'Test');
    }//end of updateTaskStatus_test
    
    public static testMethod void saveSFTask_test() {
        List<Task> lstTask = [select id from Task LIMIT 1];
        
        Map<String,String> taskDetails = new Map<String,String>();
        List<Account> acctList = [SELECT Id FROM Account WHERE name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
     
        taskDetails.Put('accountId', acctList[0].id);
        taskDetails.Put('ownerId', userinfo.getuserid());
        
        CS_AROpportunityCC.saveSFTask(null, null, taskDetails);
    }//end of saveSFTask_test
    
    public static testMethod void retrieveMyTaskDetail_test() {
        List<Task> lstTask = [select id from Task LIMIT 1];
        CS_AROpportunityCC.retrieveMyTaskDetail(lstTask[0].id);
    }//end of retrieveMyTaskDetail_test
    
     public static testMethod void linkEvents_test() {
        List<Opportunity> lstOpp = [select id, Type from Opportunity LIMIT 1];
        List<Event> lstEvent = [select id from Event LIMIT 1];
        List<String> eventIds = new List<String>();
        if(!lstEvent.isEmpty()){
            eventIds.add(lstEvent[0].id);
        }
        CS_AROpportunityCC.linkEvents(lstOpp[0].id, eventIds);
    }//end of linkEvents_test
    
    public static testMethod void unlinkEvents_test() {
        List<Opportunity> lstOpp = [select id, Type from Opportunity LIMIT 1];
        List<Event> lstEvent = [select id from Event LIMIT 1];
        List<String> eventIds = new List<String>();
        if(!lstEvent.isEmpty()){
            eventIds.add(lstEvent[0].id);
        }
        CS_AROpportunityCC.unlinkEvents(lstOpp[0].id, eventIds);
    }//end of unlinkEvents_test
    
    public static testMethod void saveOpportunityAttachment_test() {
        List<Opportunity> lstOpp = [select id, Type from Opportunity LIMIT 1];
        
        CS_AROpportunityCC.saveOpportunityAttachment(lstOpp[0].id, 'Test Body', 'Test name');
    }//end of saveOpportunityAttachment_test
    
    public static testMethod void updateOpportunityAttachment_test() {
        List<Attachment> lstAttachment = [select id from Attachment LIMIT 1];
        
        ContentVersion testContentInsert = new ContentVersion(); 
        testContentInsert.ContentURL='<a target="_blank" href="http://www.google.com/" rel="nofollow">http://www.google.com/</a>';
        testContentInsert.Title ='Google.com'; 
        insert testContentInsert; 
        
        CS_AROpportunityCC.updateOpportunityAttachment(testContentInsert.id, 'Test name 1');
    }//end of updateOpportunityAttachment_test
    
    public static testMethod void deleteOpportunityAttachment_test() {
        ContentVersion testContentInsert = new ContentVersion(); 
        testContentInsert.ContentURL='<a target="_blank" href="http://www.google.com/" rel="nofollow">http://www.google.com/</a>';
        testContentInsert.Title ='Google.com'; 
        insert testContentInsert; 
        List<Opportunity> lstOpp = [SELECT id FROM Opportunity LIMIT 1];
        CS_AROpportunityCC.deleteOpportunityAttachment(testContentInsert.id, lstOpp[0].id);
    }//end of deleteOpportunityAttachment_test
    
    public static testMethod void retrieveChildTerritories_test() {
         map<Id, list<Territory2>> mapparentTerritoryAndListTerritories = new  map<Id, list<Territory2>>();
         
         List<Territory2> lstTerritory = [SELECT id, ParentTerritory2Id from Territory2 LIMIT 1];
         mapparentTerritoryAndListTerritories.Put(lstTerritory[0].ParentTerritory2Id, lstTerritory);
         CS_AROpportunityCC.retrieveChildTerritories(lstTerritory[0].ParentTerritory2Id, mapparentTerritoryAndListTerritories);
    
    }//end of retrieveMapParentTerritoryAndListTerritoryIds_test
}