@isTest 
public class CS_AROpportunityCC_test{
    
    private static Account HCPAccount;
    private static User adminUser;
    private static User portalUser;
    private static Contact portalUserContact;
    private static Account agencyAccount;
    private static Procedure__c oppProcedure;
    private static Product2 oppProduct2;
    private static Opportunity_Surgeons__c oppSurgeons;
    private static Account pracAccount;
    
    
    @testSetup static void testData(){
        
        //code added to increase  the code coverage 3.2 
        adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex.com', 'testadmin');
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        adminUser.UserRoleId = portalRole.Id;
        insert adminUser;
        system.runas(adminUser){
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
            
            oppProduct2 = DataFactoryProduct.createProduct('Test Material Number - Product');
            insert oppProduct2;
            
            List<UserTerritory2Association> lstNewUserTerritoryAssociations = new List<UserTerritory2Association>();
            
            UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(UserId = adminUser.Id,
                                                                                                   Territory2Id = objterritory1.Id);
            lstNewUserTerritoryAssociations.add(objUserTerritory2Association);
            objUserTerritory2Association = new UserTerritory2Association(UserId = portalUser.Id, Territory2Id = objterritory1.Id);
            lstNewUserTerritoryAssociations.add(objUserTerritory2Association);
            insert lstNewUserTerritoryAssociations;                   
            
            Opportunity objOpportunity = new Opportunity(Name = 'Test Opportunity',
                                                         AccountId = HCPAccount.Id,//changed by srinivas sattoor 04.21.2017
                                                         Procedure__c = oppProcedure.Id,
                                                         StageName = 'Closed - Won',
                                                         Type = 'Agreements',
                                                         Potential_Revenue_per_Case__c = 200.00,
                                                         Probability = 20.0,
                                                         Competitve_Conversion__c = 'No',
                                                         //Competitive_Company__c = 'Tornier',
                                                         Close_Lost_Reasons__c = '',
                                                         CloseDate = Date.newInstance(2015, 2, 17),
                                                         OwnerId = portalUser.Id,
                                                         Surgeon__c = pracAccount.Id,
                                                         Product_Category__c = 'Biologics');
            insert objOpportunity;
            
            Opportunity objOppo = new Opportunity(Name = 'Test1 Opportunity',
                                                         StageName = 'Closed - Won',
                                                         CloseDate = Date.newInstance(2015, 2, 17));
            insert objOppo;
            
            Product2 prod = new Product2(Name = 'Test - Product', 
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
            //code added to increase code coverage 3.2 
            Axis_Opportunity_Stages__c objAOS = new Axis_Opportunity_Stages__c();
            objAOS.Name = 'Agreements';
            objAOS.Opportunity_Stages__c = 'Test 1,Test 2,Test 3';
            insert objAOS;
            
            objAOS = new Axis_Opportunity_Stages__c();
            objAOS.Name = 'Instrument Purchase';
            objAOS.Opportunity_Stages__c = 'Test 1,Test 2, Test 3';
            insert objAOS;
            
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
        
    }// end of testData.
    
    public static testMethod void getOpportunityTypeValues_test() {
        CS_AROpportunityCC objCSARO = new CS_AROpportunityCC();
        objCSARO.getOpportunityTypeValues();
    }//end of getOpportunityTypeValues_test
    
    public static testMethod void getSubAgencyOrTeamDropDown_test() {
        CS_AROpportunityCC objCSARO = new CS_AROpportunityCC();
        objCSARO.getSubAgencyOrTeamDropDown();
    }//end of getSubAgencyOrTeamDropDown_test
    
    public static testMethod void getAssingedToMultipleTerritories_test() {
        CS_AROpportunityCC objCSARO = new CS_AROpportunityCC();
        objCSARO.getAssingedToMultipleTerritories();
    }//end of getAssingedToMultipleTerritories_test
    
    public static testMethod void retrieveAccountTeamTerritory_test() {
        Account healthCareProviderAccount = DataFactoryAccount.createHealthCareProviderAccount();
        healthCareProviderAccount.Account_group__c = 'Z002';            
        insert healthCareProviderAccount;
        
        healthCareProviderAccount=[Select Id,Account_group__c from Account where Account_group__c =: 'Z002' and RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_HEALTH_CARE_PROVIDER).getRecordTypeId() limit 1];
        Map<Id,List<ObjectTerritory2Association>> assocMap = new Map<Id,List<ObjectTerritory2Association>>();
        list<Id> lstHCPIds = new list<Id>();
        lstHCPIds.add(healthCareProviderAccount.Id);
        
        assocMap = CS_ARTerritoryService.mapObjectIdsToTerritories(lstHCPIds);
       // CS_AROpportunityCC.retrieveAccountTeamTerritory(healthCareProviderAccount.id);
    }//end of retrieveAccountTeamTerritory_test
    
    public static testMethod void retrieveMapParentTerritoryAndListTerritoryIds_test() {
        CS_AROpportunityCC.retrieveMapParentTerritoryAndListTerritoryIds();
    }//end of retrieveMapParentTerritoryAndListTerritoryIds_test
    
    public static testMethod void retrieveChildTerritories_test() {
         map<Id, list<Territory2>> mapparentTerritoryAndListTerritories = new  map<Id, list<Territory2>>();
         
         List<Territory2> lstTerritory = [SELECT id, ParentTerritory2Id from Territory2 LIMIT 1];
         mapparentTerritoryAndListTerritories.Put(lstTerritory[0].ParentTerritory2Id, lstTerritory);
         CS_AROpportunityCC.retrieveChildTerritories(lstTerritory[0].ParentTerritory2Id, mapparentTerritoryAndListTerritories);
    
    }//end of retrieveMapParentTerritoryAndListTerritoryIds_test
    
    public static testMethod void retrieveDefaultTerritory_test() {
          CS_AROpportunityCC.retrieveDefaultTerritory();
    }//end of retrieveDefaultTerritory_test
    
    public static testMethod void retrieveOpportunitiesInMyTeamTerritory_test() {
          CS_AROpportunityCC.retrieveOpportunitiesInMyTeamTerritory();
    }//end of retrieveDefaultTerritory_test
    
    public static testMethod void getCasesToBeLinked_test() {
        List<Opportunity> lstOpp = [select id from Opportunity LIMIT 1];
        
        Opportunity_Surgeons__c objOS = [select id, Opportunity__c, Surgeon__r.Name from Opportunity_Surgeons__c limit 1];
        Opportunity_Surgeons__History objOSH = new Opportunity_Surgeons__History();
        objOSH.Field = 'Created';
        objOSH.parentId = objOS.Id;
        Insert objOSH;
        list<string> lstsurgeonIds = new list<string>();
        lstsurgeonIds.add(objOSH.id);
        
        CS_AROpportunityCC.getCasesToBeLinked(lstsurgeonIds, lstOpp[0].id);
    }//end of getCasesToBeLinked_test
    
    public static testMethod void getOpportunitiesToBeLinked_test() {
        List<Opportunity> lstOpp = [select id from Opportunity LIMIT 1];
        
        Opportunity_Surgeons__c objOS = [select id, Opportunity__c, Surgeon__r.Name from Opportunity_Surgeons__c limit 1];
        Opportunity_Surgeons__History objOSH = new Opportunity_Surgeons__History();
        objOSH.Field = 'Created';
        objOSH.parentId = objOS.Id;
        Insert objOSH;
        list<string> lstsurgeonIds = new list<string>();
        lstsurgeonIds.add(objOSH.id);
        
        CS_AROpportunityCC.getOpportunitiesToBeLinked(lstsurgeonIds, lstOpp[0].id);
    }//end of getOpportunitiesToBeLinked_test
    
    public static testMethod void retreiveActivities_test() {
        List<Opportunity> lstOpp = [select id from Opportunity LIMIT 1];
        CS_AROpportunityCC.retreiveActivities('Logs', lstOpp[0].id);
    }//end of retreiveActivities_test
    
    public static testMethod void retrieveOpportunityStages_test() {
        List<Opportunity> lstOpp = [select id, Type from Opportunity LIMIT 1];
        CS_AROpportunityCC.retrieveOpportunityStages(lstOpp[0].type);
    }//end of retrieveOpportunityStages_test
    
    public static testMethod void getOpportunityTypes_test() {
        CS_AROpportunityCC objCSARO = new CS_AROpportunityCC();
        objCSARO.getOpportunityTypes();
    }//end of getOpportunityTypes_test
    
    public static testMethod void retrieveOpportunityTypeValues_test() {
        CS_AROpportunityCC.retrieveOpportunityTypeValues();
    }//end of retrieveOpportunityTypeValues_test
    
    public static testMethod void retrieveOpportunityContactRoleValues_test() {
        CS_AROpportunityCC.retrieveOpportunityContactRoleValues();
    }//end of retrieveOpportunityContactRoleValues_test
    
    public static testMethod void retrieveCompetitiveCompanyValues_test() {
        CS_AROpportunityCC.retrieveCompetitiveCompanyValues();
    }//end of retrieveCompetitiveCompanyValues_test
    
    
    public static testMethod void retrieveOpportunityTeamRoleValues_test() {
        CS_AROpportunityCC.retrieveOpportunityTeamRoleValues();
    }//end of retrieveOpportunityTeamRoleValues_test
    
    public static testMethod void retrieveOpportunityCloseLostReasons_test() {
        List<Opportunity> lstOpp = [select id, Type from Opportunity LIMIT 1];
        CS_AROpportunityCC.retrieveOpportunityCloseLostReasons(lstOpp[0].type);
    }//end of retrieveOpportunityCloseLostReasons_test
    
    public static testMethod void retrieveCompetitiveConversionValues_test() {
        CS_AROpportunityCC.retrieveCompetitiveConversionValues();
    }//end of retrieveCompetitiveConversionValues_test
    
    public static testMethod void retrieveOpportunityStageValues_test() {
        List<Opportunity> lstOpp = [select id, Type from Opportunity LIMIT 1];
        CS_AROpportunityCC.retrieveOpportunityStageValues(lstOpp[0].type);
    }//end of retrieveOpportunityStageValues_test
    
    public static testMethod void retrieveOpportunityProductCategoryValues_test() {
        List<Opportunity> lstOpp = [select id, Type from Opportunity LIMIT 1];
        CS_AROpportunityCC.retrieveOpportunityProductCategoryValues(lstOpp[0].type);
    }//end of retrieveOpportunityProductCategoryValues_test
    
    public static testMethod void saveOpportunityContactRole_test() {
        List<Opportunity> lstOpp = [select id, Type from Opportunity LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'PortalContact' LIMIT 1];
        CS_AROpportunityCC.saveOpportunityContactRole(lstOpp[0].id, cont.Id, 'Business User', TRUE);
    }//end of saveOpportunityContactRole_test
    
    public static testMethod void saveOpportunityTeamRole_test() {
        List<Opportunity> lstOpp = [select id, Type from Opportunity LIMIT 1];        
        User user = [Select Id from User where Profile.Name=:'System Administrator' and username=:'testadmin@arthrex.com.arthrex.com' limit 1];
        CS_AROpportunityCC.saveOpportunityTeamRole(lstOpp[0].id, user.Id, 'Owner');
    }//end of saveOpportunityTeamRole_test
    
    public static testMethod void deleteOpportunityContactRole_test() {
        OpportunityContactRole oppContRole = [SELECT Id FROM OpportunityContactRole LIMIT 1];
        CS_AROpportunityCC.deleteOpportunityContactRole(oppContRole.id);
    }//end of deleteOpportunityContactRole_test
    
    public static testMethod void deleteOpportunityTeamMember_test() {
        OpportunityTeamMember oppoTeamMember = [SELECT Id FROM OpportunityTeamMember LIMIT 1];
        CS_AROpportunityCC.deleteOpportunityTeamMember(oppoTeamMember.id);
    }//end of deleteOpportunityTeamMember_test
    
    public static testMethod void deleteOpportunitySurgeon_test() {
        Opportunity_Surgeons__c oppoSurgeon = [SELECT Id FROM Opportunity_Surgeons__c LIMIT 1];
        CS_AROpportunityCC.deleteOpportunitySurgeon(oppoSurgeon.id);
    }//end of deleteOpportunitySurgeon_test
    
    public static testMethod void cancelOpportunity_test() {
        List<Opportunity> lstOpp = [select id, Type from Opportunity LIMIT 1];
        CS_AROpportunityCC.cancelOpportunity(lstOpp[0].id, 'Test Reason');
    }//end of cancelOpportunity_test
    
    public static testMethod void createNote_test() {
        List<Opportunity> lstOpp = [select id, Type from Opportunity LIMIT 1];
        CS_AROpportunityCC.createNote(lstOpp[0].id, 'Test Note', null);
    }//end of createNote_test
    
    public static testMethod void saveOpportunityStage_test() {
        List<Opportunity> lstOpp = [select id, Stagename from Opportunity LIMIT 1];
        CS_AROpportunityCC.saveOpportunityStage(lstOpp[0].id, lstOpp[0].Stagename, 'Surgical Technique Issue');
    }//end of saveOpportunityStage_test
    
    public static testMethod void retrieveOpportunity_test() {
        List<Opportunity> lstOpp = [select id, Stagename from Opportunity LIMIT 1];
        CS_AROpportunityCC.retrieveOpportunity(lstOpp[0].id);
    }//end of retrieveOpportunity_test
    
    public static testMethod void saveLinkedOpportunities_test() {
        List<Opportunity> lstOpp = [select id, Stagename from Opportunity LIMIT 1];
        
        List<Linked_Opportunity__c> linkedOppoList = [SELECT Id, Opportunity__c FROM Linked_Opportunity__c ];
        List<String> linkedOppo = new List<String>();
        for(Linked_Opportunity__c linked : linkedOppoList){
            linkedOppo.add(linked.Opportunity__c);
        }
        
        CS_AROpportunityCC.saveLinkedOpportunities(lstOpp[0].id, linkedOppo);
    }//end of saveLinkedOpportunities_test
    
    public static testMethod void deleteLinkedOpportunity_test() {
        Linked_Opportunity__c linkedOppor = [SELECT Id FROM Linked_Opportunity__c LIMIT 1];
        CS_AROpportunityCC.deleteLinkedOpportunity(linkedOppor.id);
    }//end of deleteLinkedOpportunity_test
    
    public static testMethod void saveLinkedCases_test() {
        List<Opportunity> lstOpp = [select id, Stagename from Opportunity LIMIT 1];
        
        List<Opportunity_Case__c> linkedCaseList = [SELECT Id FROM Opportunity_Case__c ];
        List<String> linkedCase = new List<String>();
        for(Opportunity_Case__c linked : linkedCaseList){
            linkedCase.add(linked.Id);
        }
        
        CS_AROpportunityCC.saveLinkedCases(lstOpp[0].id, linkedCase);
    }//end of saveLinkedCases_test
    
    public static testMethod void saveOpportunitySurgeons_test() {
        List<Opportunity> lstOpp = [select id, Stagename from Opportunity LIMIT 1];
        
        Opportunity_Surgeons__c objOS = [select id, Opportunity__c, Surgeon__r.Name from Opportunity_Surgeons__c limit 1];
        Opportunity_Surgeons__History objOSH = new Opportunity_Surgeons__History();
        objOSH.Field = 'Created';
        objOSH.parentId = objOS.Id;
        Insert objOSH;
        list<string> lstsurgeonIds = new list<string>();
        lstsurgeonIds.add(objOSH.id);
        
        List<Account> acctList = [SELECT Id FROM Account WHERE name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        List<Id> surgeonId = new List<Id>();
        Account lstOwnerIds = [SELECT Id FROM Account WHERE Name = 'Test HCP Account'];
        for(Account acct : acctList){
            surgeonId.add(acct.Id);
        }
        
        CS_AROpportunityCC.saveOpportunitySurgeons(lstOpp[0].id, surgeonId);
    }//end of saveOpportunitySurgeons_test
    
    public static testMethod void deleteLinkedCase_test() {
        Opportunity_Case__c linkedCases = [SELECT Id FROM Opportunity_Case__c LIMIT 1];
        CS_AROpportunityCC.deleteLinkedCase(linkedCases.id);
    }//end of deleteLinkedCase_test
    
    public static testMethod void retrieveUserTeams_test() {
        CS_AROpportunityCC.retrieveUserTeams();
    }//end of retrieveUserTeams_test
    
    public static testMethod void saveOpportunityN_test() {
    
        Map<String,Object> mapOpp = new Map<String,Object>();
        List<Opportunity> oppoList = [SELECT Annual_Number_of_Procedures__c, Quote__c, CloseDate, Close_Lost_Reasons__c, Estimated_Install_Date__c, Id, Name, OwnerId, Quote_Date__c, StageName, Type FROM Opportunity];
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
        
        List<Account> acctList = [SELECT Id FROM Account WHERE name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        List<String> surgeonIds = new List<String>();
        for(Account accts : acctList){
            surgeonIds.add(accts.Id);
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
        CS_AROpportunityCC.saveOpportunityN(mapOpp, surgeonIds, lsSalesRep, surgeonIds, lsSalesRep, oppoLineItemList);
    }//end of retrieveUserTeams_test
    
    public static testMethod void saveOpportunity_test() {
        List<Opportunity> lstOpp = [select id, OwnerId, Name, AccountId, Closedate, Stagename from Opportunity LIMIT 1];
        
        Opportunity_Surgeons__c objOS = [select id, Opportunity__c, Surgeon__r.Name from Opportunity_Surgeons__c limit 1];
        Opportunity_Surgeons__History objOSH = new Opportunity_Surgeons__History();
        objOSH.Field = 'Created';
        objOSH.parentId = objOS.Id;
        Insert objOSH;
        list<string> lstsurgeonIds = new list<string>();
        lstsurgeonIds.add(objOSH.id);
        
        List<OpportunityTeamMember> oppoTMList = [SELECT Id, UserId, OpportunityId FROM OpportunityTeamMember WHERE TeamMemberRole = 'Account Manager'];
        List<String> lsSalesRep = new List<String>();
        for(OpportunityTeamMember oppoTM : oppoTMList){
            lsSalesRep.add(oppoTM.UserId);
        }
        
        List<Account> acctList = [SELECT Id FROM Account WHERE name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        List<String> surgeonIds = new List<String>();
        for(Account accts : acctList){
            surgeonIds.add(accts.Id);
        }
        
        List<OpportunityLineItem> oliList = [SELECT Id FROM OpportunityLineItem];
        List<OpportunityLineItem> oppoLineItemList = new List<OpportunityLineItem>();
        List<Id> lstLineItems = new List<Id>();
        for(OpportunityLineItem oppoLI : oppoLineItemList){
            lstLineItems.add(oppoLI.Id);
        }
        
        Procedure__c proc = [SELECT Id FROM Procedure__c WHERE Name = 'elbowTest' LIMIT 1];
         
        List<Quote> QuoteList = [select id from Quote  LIMIT 1];
        
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
                        
        //CS_AROpportunityCC.saveOpportunity(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,null, null, null, null, null, null, null, null, null, null, null, null, null, null);
          CS_AROpportunityCC.saveOpportunity(string.valueOf(lstOpp[0].Id), 
                                             string.valueOf(lstOpp[0].OwnerId), 
                                             lstOpp[0].Name, 
                                             string.valueOf(lstOpp[0].AccountId),                                             
                                             '12/27/2017', 
                                             surgeonIds, lsSalesRep, oppoLineItemList, 'Yes', 'Tornier', 'Agreements', 'Prospect', 
                                             string.valueOf(proc.Id), 1.0, 500.0, 1.0, 500.0, 2.0, 500.0, 1.0, 500.0, 1000.0, 2000.0, 
                                             2000.0, 
                                             '12/27/2017', QuoteList[0].id, 
                                             '12/27/2017', 2.0, 1.0, 5.0, string.valueOf(quote.Id), 'Biologics');
        
    }//end of retrieveUserTeams_test
    
    public static testMethod void deleteOpportunity_test() {
        List<Opportunity> lstOpp = [select id, Stagename from Opportunity LIMIT 1];
        CS_AROpportunityCC.deleteOpportunity(lstOpp[0].id);
    }//end of deleteOpportunity_test
    
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
    
    
}