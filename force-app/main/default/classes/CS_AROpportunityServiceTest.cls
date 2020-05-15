@isTest 
public class CS_AROpportunityServiceTest {
    
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
            
            HCPAccount.Active__c=true;
            HCPAccount.Account_group__c = 'Z002';
            update HCPAccount;
            
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
            
        }
        
    }// end of testData.
    
    public static testMethod void testRetrieveOpportunitiesInMyTeamTerritory() {
        //testData();        
        test.startTest();
        CS_AROpportunityService.retrieveOpportunitiesInMyTeamTerritory();
        
        
        adminUser=[Select Id from User where Profile.Name=:'System Administrator' and username=:'testadmin@arthrex.com.arthrex.com' limit 1];
        system.runAs(adminUser){
            CS_AROpportunityService.retrieveOpportunitiesInMyTeamTerritory();
        }
        test.stopTest();            
    }//end of testRetrieveOpportunitiesInMyTeamTerritory
    
    public static testMethod void testAllMethods() {
        //testData();
        
        Opportunity oppo = [SELECT Id, Name, OwnerId, AccountId, CloseDate FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        User user = [SELECT Id FROM User WHERE FirstName = 'CRM' LIMIT 1];
        
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'PortalContact'];
        
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
        
        List<Account> acctList = [SELECT Id FROM Account WHERE name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
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
        
        test.startTest();
        CS_AROpportunityService.retrieveOpportunityTypeDashboardWrapper(lstMyTeamOpportunities, lstOwnerId);
        CS_AROpportunityService.retrieveCasesToBeLinked(surgeonIds, lstOwnerIds.Id);
        CS_AROpportunityService.cdeleteLinkedCase(linkedCases.Id);
        CS_AROpportunityService.retrieveOpportunitiesToBeLinked(surgeonIds, lstOwnerIds.Id);
        CS_AROpportunityService.cdeleteLinkedOpportunity(linkedOppor.Id);
        CS_AROpportunityService.cSaveOpportunityContactRole(oppo.Id, cont.Id, 'Business User', TRUE);
        OpportunityContactRole oppContRole = [SELECT Id FROM OpportunityContactRole LIMIT 1];
        CS_AROpportunityService.cDeleteOpportunityContactRole(oppContRole.Id);
        CS_AROpportunityService.cSaveOpportunitySurgeons(oppo.Id, surgeonId);
        CS_AROpportunityService.cDeleteOpportunitySurgeon(oppoSurgeon.Id);
        CS_AROpportunityService.cSaveOpportunityTeamRole(oppo.Id, user.Id, 'Owner');
        CS_AROpportunityService.cDeleteOpportunityTeamMember(oppoTeamMember.Id);
        CS_AROpportunityService.cSaveCancelledOpportunity(oppo.Id, 'Test');
        CS_AROpportunityService.cSaveOpportunityStage(oppo.Id, 'Qualified', 'Surgical Technique Issue');
        CS_AROpportunityService.saveNote(oppo.Id, 'Test', null);
        CS_AROpportunityService.cSaveOpportunity(mapOpp, surgeonIds, lsSalesRep, surgeonIds, lsSalesRep, oppoLineItemList);
        
        List<Quote> QuoteList = [select id from Quote  LIMIT 1];
        CS_AROpportunityService.cSaveOpportunity(string.valueOf(oppo.Id), string.valueOf(oppo.OwnerId), oppo.Name, string.valueOf(oppo.AccountId), oppo.CloseDate, surgeonIds, lsSalesRep, oppoLineItemList, 'Yes', 'Tornier', 'Agreements', NULL, string.valueOf(proc.Id), 1.0, 500.0, 1.0, 500.0, 2.0, 500.0, 1.0, 500.0, 1000.0, 2000.0, 2000.0, Date.newInstance(2016, 9, 18), QuoteList[0].id, Date.newInstance(2016, 9, 18), 2.0, 1.0, 5.0, string.valueOf(quote.Id), 'Biologics');
        
        CS_AROpportunityService.cSaveOpportunity(string.valueOf(oppo.Id), string.valueOf(oppo.OwnerId), oppo.Name, string.valueOf(oppo.AccountId), oppo.CloseDate, surgeonIds, lsSalesRep, oppoLineItemList, 'Yes', 'Tornier', 'SOS', NULL, string.valueOf(proc.Id), 1.0, 500.0, 1.0, 500.0, 2.0, 500.0, 1.0, 500.0, 1000.0, 2000.0, 2000.0, Date.newInstance(2016, 9, 18), QuoteList[0].id, Date.newInstance(2016, 9, 18), 2.0, 1.0, 5.0, string.valueOf(quote.Id), 'Biologics');
        CS_AROpportunityService.cSaveLinkedOpportunities(string.valueOf(oppo.Id), linkedOppo);
        CS_AROpportunityService.cSaveLinkedCases(string.valueOf(oppo.Id), linkedCase);
        CS_AROpportunityService.retrieveExistingOpportunityLineItems(oppo.Id);
        CS_AROpportunityService.retrieveOpportunityActivity('All Activities', oppo.Id);
        CS_AROpportunityService.searchPriceBookEntries('AR', false);
        
        List<Account> lstAgencyAcc = [select id from Account where Name = 'Test Agency Account'];
        CS_AROpportunityService.retrieveProvidersContacts(lstAgencyAcc[0].Id, oppo.Id);
        CS_AROpportunityService.retrieveFieldName('Account','Created');
        CS_AROpportunityService.retrieveFieldName('Account','Owner');
        CS_AROpportunityService.retrieveFieldName('Account','Account');
        CS_AROpportunityService.retrieveOpportunityStages('Agreements');
        CS_AROpportunityService.retrieveOpportunityStages('Instrument Purchase');
        CS_AROpportunityService.retrieveOpportunityProductCategories('Agreements');
        CS_AROpportunityService.retrieveOpportunityProductCategories('SOS');
        CS_AROpportunityService.retrieveOpportunityProductCategories('Synergy Video');
        CS_AROpportunityService.retrieveOpportunityProductCategories('Test');
        CS_AROpportunityService.retrieveClosedLostReason('SOS');
        CS_AROpportunityService.retrieveClosedLostReason('Instrument Purchase');
        CS_AROpportunityService.retriveRecordNameForLookUps('Test');
        CS_AROpportunityService.retriveRecordNameForLookUps(NULL);
        CS_AROpportunityService.checkIfFieldValueIsId('Test');
        Contact objCon = [select id from Contact Limit 1];
        Opportunity_Surgeons__c objOS = [select id, Opportunity__c, Surgeon__r.Name from Opportunity_Surgeons__c limit 1];
       // User objUser = [select id, Name from user where id =: userinfo.getuserid()];
        Opportunity_Surgeons__History objOSH = new Opportunity_Surgeons__History();
        objOSH.Field = 'Created';
        objOSH.parentId = objOS.Id;
        Insert objOSH;
        CS_AROpportunityService.createOpptySurgeonHistoryWrapper(objOSH, objOS);
         objOSH = new Opportunity_Surgeons__History();
        objOSH.Field = 'Owner';
         objOSH.parentId = objOS.Id;
        //Insert objOSH;
        CS_AROpportunityService.createOpptySurgeonHistoryWrapper(objOSH, objOS);
        Case__c objCustomCase = [select id from Case__c Limit 1];
        Opportunity_Case__c objOC = new Opportunity_Case__c();
        objOC.Case__c = objCustomCase.id;
        objOC.Opportunity__c = objOS.Opportunity__c;
        insert objOC;
        
        Opportunity_Case__c objOCase = [select id, Name from Opportunity_Case__c limit 1];
        Opportunity_Case__History objOCH = new Opportunity_Case__History ();
        objOCH.Field = 'Created';
        objOCH.ParentId = objOCase.Id;
        Insert objOCH;
        
        CS_AROpportunityService.createOpptyCaseHistoryWrapper(objOCH, objOCase);
        objOCH = new Opportunity_Case__History ();
        objOCH.Field = 'Owner';

        CS_AROpportunityService.createOpptyCaseHistoryWrapper(objOCH, objOCase);
        CS_AROpportunityService.checkIfFieldValueIsId(null);
        CS_AROpportunityService.checkIfFieldValueIsId(objOCase.id);
        CS_AROpportunityService.retriveRecordNameForLookUps(objOCase.id);
        List<Opportunity> lstOpp = [select id from Opportunity limit 1];
        OpportunityFieldHistory objOFH = new OpportunityFieldHistory();
        objOFH.Field = 'Created';

        objOFH.OpportunityId = lstOpp[0].id;
        Insert objOFH ;
        objOFH = new OpportunityFieldHistory();
        objOFH.Field = 'Total_Annual_Potential__c';

        objOFH.OpportunityId = lstOpp[0].id;
        Insert objOFH;

        objOFH = new OpportunityFieldHistory();
        objOFH.Field = 'Total_Annual_Potential__c';

        objOFH.OpportunityId = lstOpp[0].id;
        Insert objOFH;
        OpportunityContactRole objOCR = new OpportunityContactRole();
        objOCR.OpportunityId = lstOpp[0].id;
        objOCR.ContactId = objCon.id;
        insert objOCR;
        Task objTask = new Task();
        objTask.Whatid = lstOpp[0].id;
        objTask.Subject = 'Test subject';
        insert objTask;
        CS_AROpportunityService.retrieveOpportunityActivity('All Activities', lstOpp[0].id);
        CS_AROpportunityService.retrieveOpportunityActivity('Log', lstOpp[0].id);
        CS_AROpportunityService.CS_OpportunityTypeDashboardWrapper objCOTDW = new CS_AROpportunityService.CS_OpportunityTypeDashboardWrapper('test', null, null, null, null);
        objCOTDW.ownerProviderTerritory = 'test';
        objCOTDW.ownerProviderTerritoryId = 'test';
        objCOTDW.ownerProviderParentTerritoryId= 'test';
        list<string> lstCaseIds = new list<string>();
        CS_AROpportunityService.cSaveLinkedCases(lstOpp[0].id, lstCaseIds);
        lstCaseIds.add(objCustomCase.id);
        CS_AROpportunityService.cSaveLinkedCases(lstOpp[0].id, lstCaseIds); 
        list<OpportunityLineItem> lstOppLineItems = [select id, PriceBookEntryId from OpportunityLineItem where Opportunityid =: lstOpp[0].id limit 1];

        list<OpportunityLineItem> lstLineItemsnew = new list<OpportunityLineItem>();

        // Get standard price book ID.
        Id pricebookId = Test.getStandardPricebookId();

        List<Product2> lstProduct = [SELECT id from Product2 LIMIT 1];
                
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                          Product2Id = lstProduct[0].Id,
                                                          UnitPrice = 10000, 
                                                          IsActive = true,
                                                          Unique_Id__c = 'Test_sp');
        insert standardPrice;

        OpportunityLineItem objOpp = new OpportunityLineItem();
        objOpp.Quantity = 2;
        objOpp.TotalPrice = 10;
        //objOpp.UnitPrice = 2;
        objOpp.PriceBookEntryId = standardPrice.Id;
        lstLineItemsnew.add(objOpp);
        list<string> lstsurgeonIds = new list<string>();
        lstsurgeonIds.add(objOSH.id);
        CS_AROpportunityService.cSaveOpportunity(lstOpp[0].id, system.userinfo.getuserid(), 'Test Opp', null, system.today(), lstsurgeonIds, lsSalesRep , lstLineItemsnew, null , null, 'Agreements', null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
        
        list<Opportunity> lstOppNew = [select id, Name, Account.Name, AccountId, Product_Category__c, 
                                            Owner.Profile.Name, Owner.IsActive,
                                            Integration_Type__c,Support_Plan__c, Billing_Method__c, Agreement_Start_Date__c, Agreement_End_Date__c,
                                            Total_Agreement_Value__c, Agreement_Term_Years__c, Customer_PO_Number__c,  SAP_Agreement_Number__c,
                                                
                                            Procedure__r.Name, Procedure__c, Annual_Number_of_Procedures__c, 
                                            Total_Annual_Potential__c, Potential_Revenue_per_Case__c, Type, StageName, CloseDate, 
                                            IsClosed, OwnerId, Owner.Name, Quote_Id__c, Probability, Competitve_Conversion__c, 
                                            Competitive_Company__c, Close_Lost_Reasons__c, Current_FY_Revenue__c, Patient_Volume__c, 
                                            Potential_User_Number__c, Total_of_Towers__c, Potential_Revenue_Per_Tower__c, Total_of_OR_s__c, 
                                            Equipment_Cost__c, Labor_and_Materials__c, Total_Budgetary__c, Final_PO_Amount__c, 
                                            Estimated_Install_Date__c, No_Charge_Equipment_Value__c, Disposable_Purchase_Value__c, 
                                            Contract_Years__c, Quote__c, Quote_Date__c, Enrollment_Forms_Sent__c,Enrollment_Form_Type__c,
                                            LastModifiedDate, CreatedDate, 
                                            (select id, Product2.Name from OpportunityLineItems) 
                                            FROM Opportunity];
        List<User> lstUser = [select id from User where email = 'testadmin@arthrex.com' limit 10];
        list<Id> lstUserIds = new List<Id>();
        for(User u: lstUser){
            lstUserIds.add(u.id);
        }
        list<Id> lstMyTeamOpportunityIds = new list<Id>();
        //system.debug('##--HCPAccountId: '+ HCPAccount);
        list<Id> lstHCPAccountIds = new list<Id>();
        //lstHCPAccountIds.add(HCPAccount.Id);
        CS_AROpportunityService.retrieveOpportunityIdsInMyTeamTerritory(lstMyTeamOpportunityIds,
                                                                        lstOppNew, 
                                                                        lstUserIds,
                                                                        lstHCPAccountIds);
        
        List<OpportunityLineItem> lstOLI = new List<OpportunityLineItem>();
        
        map<String,Object> objOpportunity = new map<String,Object>();
        objOpportunity.Put('opportunityOwner', system.userinfo.getuserid());
        objOpportunity.Put('opportunityType', 'SOS');
        objOpportunity.Put('opportunityName', 'Test Opportunity');
        objOpportunity.Put('opportunityCloseDate', '10/11/2018');
        
        OpportunityLineItem objOppLineItem = new OpportunityLineItem(PriceBookEntryId = standardPrice.Id,
                                                                         Quantity = 2,
                                                                         TotalPrice = 3);
        lstOLI.add(objOppLineItem);                                                              
        CS_AROpportunityService.cSaveOpportunity(objOpportunity, null, null, null, null, lstOLI);
        
        test.stopTest();
    }
    
    public static testMethod void testretrieveFieldType() {
        //testData();        
        test.startTest();
        CS_AROpportunityService.retrieveFieldType('Account', 'Created');
        CS_AROpportunityService.retrieveFieldType('Account', 'Owner');
        CS_AROpportunityService.retrieveFieldType('Opportunity', 'Account');
        CS_AROpportunityService.retrieveFieldType('Opportunity', 'Name');
        test.stopTest();            
    }//end of testretrieveFieldType
    
    public static testMethod void testOpportunityActivityWrapper() {
        //testData();        
        test.startTest();
        CS_AROpportunityService.CS_OpportunityActivityWrapper ow = new CS_AROpportunityService.CS_OpportunityActivityWrapper(null, null, null, null, null, null);
        
        test.stopTest();            
    }//end of testOpportunityActivityWrapper
    
    public static testMethod void testCS_AROpportunityWrapper() {
        //testData();        
        test.startTest();
        Opportunity objOpp = [SELECT Id, Name, Account.Name, Procedure__c, Procedure__r.Name, Account.Preferred_Name__c, Owner.Profile.Name, Owner.IsActive,
                                                Integration_Type__c,Support_Plan__c, Billing_Method__c, Agreement_Start_Date__c, Agreement_End_Date__c,
                                                Total_Agreement_Value__c, Agreement_Term_Years__c, Customer_PO_Number__c,  SAP_Agreement_Number__c,
                                                (SELECT Id, Product2.Material_Number__c, Product2.Description, Quantity, TotalPrice, UnitPrice, Product2Id, 
                                                                PriceBookEntryId, Product2.Name FROM OpportunityLineItems),// opportunity line items.
                                                Annual_Number_of_Procedures__c, Type, Potential_Revenue_per_Case__c, Product_Category__c,isClosed,
                                                (SELECT Id, ContactId, Contact.Name, Role, IsPrimary FROM OpportunityContactRoles),
                                                (SELECT Id, UserId, User.Name, User.Title ,OpportunityId, TeamMemberRole FROM OpportunityTeamMembers),//additional sales reps
                                                (SELECT Id, Surgeon__c, Surgeon__r.Name, Opportunity__c 
                                                              FROM Opportunity_Surgeons__r),// opportunity surgeons
                                                (SELECT Id, StageName, Name, Type, Potential_Revenue_per_Case__c, CloseDate  FROM  Opportunities__r),// linked Oppotunities
                                                (SELECT Id, Opportunity__c, Linked_Opportunity__c, Linked_Opportunity__r.Name, Linked_Opportunity__r.Type, 
                                                                        Linked_Opportunity__r.Potential_Revenue_per_Case__c, Linked_Opportunity__r.CloseDate  
                                                                        FROM  Linked_Opportunities__r),// linked Oppotunities
                                                    StageName, CloseDate, Owner.Name, probability, Competitve_Conversion__c, Competitive_Company__c, Close_Lost_Reasons__c,
                                                    Current_FY_Revenue__c, Total_Annual_Potential__c, Quote_Id__c, OwnerId, Patient_Volume__c, Potential_User_Number__c,
                                                    Total_of_Towers__c,Potential_Revenue_Per_Tower__c,Total_of_OR_s__c,Equipment_Cost__c,Labor_and_Materials__c, 
                                                    Total_Budgetary__c, Final_PO_Amount__c, Estimated_Install_Date__c, No_Charge_Equipment_Value__c, Disposable_Purchase_Value__c, 
                                                    Contract_Years__c, Quote__c, Quote_Date__c, Enrollment_Forms_Sent__c, Enrollment_Form_Type__c, lastModifiedDate, CreatedDate 
                                                    FROM Opportunity LIMIT 1];
                                                    
        CS_AROpportunityService.CS_AROpportunityWrapper objCARW = new CS_AROpportunityService.CS_AROpportunityWrapper(objOpp);
        
        Territory2 objterritory1 = [SELECT Id, DeveloperName FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1'];
        Territory2 objterritory2 = [SELECT Id, DeveloperName FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory2'];
            
        objCARW.accountTerritory = objterritory1.DeveloperName;
        objCARW.accountTerritoryId = objterritory1.id;
        objCARW.accountParentTerritoryId = objterritory2.id;
        objCARW.opportunitySurgeonIds = 'Test';
        test.stopTest();            
    }//end of testDecimalValueOf
    
    public static testMethod void testCS_OpportunityCase() {
        //testData();        
        test.startTest();
        Case__c objCase = [select id, (select id, Procedure__r.Name from Case_Procedures__r) from Case__c LIMIT 1];
        
        CS_AROpportunityService.CS_OpportunityCase objCARW = new CS_AROpportunityService.CS_OpportunityCase(objCase);
        
        test.stopTest();            
    }//end of testCS_OpportunityCase
    
    
}