/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class CS_ARCasesServiceTest {
    
    private static User portalUser;
    private static User adminUser;
    private static Account agencyAccount;
    private static Account healthCareProviderAccount;
    private static Contact portalUserContact;
    private static Product2 objProduct;
    private static Procedure__c parentProcedure;
    private static Procedure__c childProcedure;
    private static Procedure_Relationships__c objProcedureRel;
    private static Account practitioner;
    private static Practitioner_Procedure__c practitionerprocedure;
    private static Case__c objCase;
    private static Procedure__c objProdTeamProcedure;
    
    @testSetup static void testData(){
        
        
        adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex.com', 'testadmin');
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        adminUser.UserRoleId = portalRole.Id;
        insert adminUser;
        
        system.runas(adminUser){
            DataFactoryCustomSetting.createCustomSettings();
            DataFactoryTerritory.setUpTerritoryForTestClasses();
            
            Territory2 objTerritory = [SELECT Id FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1'];
            agencyAccount = DataFactoryAccount.createAgencyAccount('Test Agency Account');
            insert agencyAccount;
            
            healthCareProviderAccount = DataFactoryAccount.createHealthCareProviderAccount();
            insert healthCareProviderAccount;
            
            ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = healthCareProviderAccount.Id,
                                                                                   Territory2Id = objTerritory.Id,
                                                                                   AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);
            insert objAssoc;
            
            portalUserContact = DataFactoryContact.createContacts('PortalContact');
            portalUserContact.AccountId = agencyAccount.Id;
            insert portalUserContact;
            
            portalUser = DataFactoryUser.preparePortalUser();
            portalUser.customer_number__c = 'ArthTest001';
            portalUser.ContactId = portalUserContact.Id;
            insert portalUser;
            
            UserTerritory2Association objTerrAssoc = new UserTerritory2Association(UserId = portalUser.Id,
                                                                                   Territory2Id = objTerritory.Id);
            insert objTerrAssoc;
            
            practitioner = DataFactoryAccount.createPractitionerAccount();
            insert practitioner;
            
            ObjectTerritory2Association objAssoc2 = new ObjectTerritory2Association(objectId = practitioner.Id,
                                                                                    Territory2Id = objTerritory.Id,
                                                                                    AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);
            insert objAssoc2;
            
            objProduct = DataFactoryProduct.createProduct('AR-Test001');
            insert objProduct;
            
            objProdTeamProcedure = DataFactoryProcedures.createProcedure();
            objProdTeamProcedure.TaxonGroupId__c = 'team';
            objProdTeamProcedure.TaxonId__c = 'test team procedure';
            objProdTeamProcedure.Procedure_Name__c = 'test team procedure';
            insert objProdTeamProcedure;
            
            parentProcedure = DataFactoryProcedures.createProcedure();
            insert parentProcedure;
            
            childProcedure = DataFactoryProcedures.createChildProcedure();
            childProcedure.TaxonGroupId__c='surgical_technique';
            insert childProcedure;
            
            objProcedureRel = new Procedure_Relationships__c(Child_Procedure__c = childProcedure.Id,
                                                             Parent_Procedure__c = parentProcedure.Id,
                                                             TaxonGroupId__c = 'surgical_technique');
            insert objProcedureRel;
            
            practitionerprocedure = CS_TestDataBuilder.CreatePractitionerProcedure(practitioner.Id, parentProcedure.Id );
            insert practitionerprocedure;
            
            objCase = CS_TestDataBuilder.CreateCases(practitioner.Id, healthCareProviderAccount.Id, objProduct.Id);
            objCase.OwnerId =portalUser.Id;
            insert objCase;
            
            Case_Procedure__c caseProc = new Case_Procedure__c();
            caseProc.Procedure__c = parentProcedure.Id;
            caseProc.Case__c = objCase.Id;
            insert caseProc;
            
            Case_Products__c cproducts = CS_TestDataBuilder.CreateCaseProducts(objCase.Id,objProduct.Id);
            insert cproducts;
            
            CaseParticipant__c cparticipant = CS_TestDataBuilder.CreateCaseParticipant(objCase.Id,portalUser.Id);
            cparticipant.ownerid = portalUser.Id;
            insert cparticipant;
            
            Case_Pref_Card__c cpc = CS_TestDataBuilder.CreateCasePrefCard(objCase.Id, practitionerprocedure.Id);
            cpc.ownerid = portalUser.Id;
            insert cpc;
            
            Opportunity objOpp = new Opportunity();
            objOpp.Name = 'Test Opp';
            objOpp.Accountid = agencyAccount.id;
            objOpp.StageName = 'Test';
            objOpp.closedate = system.today().adddays(3);
            insert objOpp;
            
            objOpp = new Opportunity();
            objOpp.Name = 'Test Opp New';
            objOpp.Accountid = agencyAccount.id;
            objOpp.StageName = 'Test';
            objOpp.closedate = system.today().adddays(3);
            insert objOpp;
            
            Opportunity_Case__c oc = new Opportunity_Case__c(Case__c = objCase.Id, Opportunity__c = objOpp.id);
            insert oc;
        }
        
    }// end of testData.
    
    static testMethod void testSubmitHelp(){
        
        //testData();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        system.runas(portalUserList[0]){
            Map<String,Object> m = new Map<String,Object>();
            m.put('email','someone@somewhere.com');
            m.put('phone','5555555555');
            m.put('name','John Doe');
            m.put('subject','Unit test');
            
            CS_ARCasesService.submitHelp(m);
            
        }
        
        list<Case> listCases = [SELECT Id FROM Case WHERE Subject = 'Unit test'];
        system.assertEquals(1, listCases.size());   
    }// end of testSubmitHelp
    
    static testMethod void testSearchProducts(){
        
        //testData();
        list<Product2> lstProducts =new list<Product2>();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        List<Procedure__c> lstProcedure = [select id from Procedure__c limit 1];
        system.runas(portalUserList[0]){
            lstProducts= CS_ARCasesService.searchProducts('AR-Test');
            
            lstProducts= CS_ARCasesService.searchProducts(lstProcedure[0].id + '::Test');
            //system.assertEquals(1, lstProducts.size());
        }
        
    }// end of testSearchProducts
    
    static testMethod void testSearchUsers(){
        
        //testData();
        list<User> lstUsers = new list<User>();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        system.runas(portalUserList[0]){
            lstUsers= CS_ARCasesService.searchUsers('Test');
           // system.assertEquals(1, lstProducts.size());
        }
        
    }//end of testSearchUsers
    
    static testMethod void testretrievePreferenceCards(){
        
        //testData();
        list<Practitioner_Procedure__c> lstPractitionerProcedures= new list<Practitioner_Procedure__c>();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001' limit 1];
        List<Account> lstAccPractitioner = [select id from Account limit 1];
        system.runas(portalUserList[0]){
            
            lstPractitionerProcedures= CS_ARCasesService.retrievePreferenceCards(string.valueof(lstAccPractitioner[0].Id));
          //  system.assertEquals(1, lstProducts.size());
        }
        
    }// end of testretrievePreferenceCards
    
    static testMethod void testsearchSurgicalTechniques(){
        
        //testData();
        list<Procedure_Relationships__c> lstProcedureRelationships = new list<Procedure_Relationships__c>();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001' limit 1];
        system.runas(portalUserList[0]){
            List<Procedure__c> lstProcedure = [select id from Procedure__c limit 1];
            lstProcedureRelationships= CS_ARCasesService.searchSurgicalTechniques(string.valueof(lstProcedure[0].Id));
           // system.assertEquals(1, lstProducts.size());
        }
        
    }//end of testsearchSurgicalTechniques
    
    static testMethod void testsearchProcedures(){
        
        //testData();
        list<Procedure__c> lstProcedureRelationships = new list<Procedure__c>();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001' limit 1];
        List<Account> lstAcc = [select id from Account];
        system.runas(portalUserList[0]){
        
            
            lstProcedureRelationships= CS_ARCasesService.searchProcedures(lstAcc[0].id);
            
            lstProcedureRelationships= CS_ARCasesService.searchProcedures(lstAcc[0].id + '::' + lstAcc[1].id);
            
            lstProcedureRelationships = CS_ARCasesService.searchTaxonomy('Test');
            lstProcedureRelationships = CS_ARCasesService.searchTaxonomy('Test1::Test2');
           // system.assertEquals(1, lstProducts.size());
        }
    }// end of testsearchProcedures
    
    static testMethod void testProductsForSelectedProcedures(){
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        //testData();
        
        list<ProcedureProduct__c> lstProcedureProducts = new list<ProcedureProduct__c>();
        system.runas(portalUserList[0]){
            List<Procedure__c> lstProcedure = [select id from  Procedure__c limit 1];
            lstProcedureProducts = CS_ARCasesService.productsForSelectedProcedures(string.valueof(lstProcedure[0].Id));         
            lstProcedureProducts = CS_ARCasesService.productsForSelectedProcedures('');
            lstProcedureProducts = CS_ARCasesService.productsForSelectedProcedures('test');
        }
    }// end of testProductsForSelectedProcedures
    
    static testMethod void testRetrievePreferenceCardProducts(){
        //testData();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        list<Product2> lstProducts = new list<Product2>();
        
        List<Practitioner_Procedure__c> lstPP = [select id from Practitioner_Procedure__c limit 1];
        List<Product2> lstPrpduct = [select id from Product2 LIMIT 1];
        Practitioner_Procedure_Products__c objPPP = new Practitioner_Procedure_Products__c();
        objPPP.Practitioner_Procedure__c = lstPP[0].id;
        objPPP.Product__c = lstPrpduct[0].id;
        insert objPPP;
        
        system.runas(portalUserList[0]){            
            lstProducts = CS_ARCasesService.retrievePreferenceCardProducts(string.valueof(lstPP[0].Id));
        }
    }// end of testRetrievePreferenceCardProducts
    
    static testMethod void testresolvePractitionerProcedureProducts(){
        //testData();
        list<Practitioner_Procedure_Products__c> lstPractitionerProcedureProducts = new list<Practitioner_Procedure_Products__c>();
                
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        List<Practitioner_Procedure__c> lstPP = [select Id, Practitioner__c, Procedure__c from Practitioner_Procedure__c limit 1];
        system.runas(portalUserList[0]){
            lstPractitionerProcedureProducts = CS_ARCasesService.resolvePractitionerProcedureProducts(null, null);
                      
            lstPractitionerProcedureProducts = CS_ARCasesService.resolvePractitionerProcedureProducts(string.valueof(lstPP[0].Practitioner__c), string.valueof(lstPP[0].Procedure__c));
        }
    }// end of testresolvePractitionerProcedureProducts
    
    static testMethod void testretrieveCasesByPractitioner(){
        //testData();
        list<Case__c> lstCases = new list<Case__c>();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        List<Account> lstAccPractitioner = [select id from Account limit 1];
        system.runas(portalUserList[0]){
            
            lstCases = CS_ARCasesService.retrieveCasesByPractitioner(string.valueof(lstAccPractitioner[0].Id));
        }
    }// end of testretrieveCasesByPractitioner
    
    static testMethod void testretrieveCalendarEventDTOByCaseId(){
        //testData();
        CS_ARCalendarEventDTO objCS_ARCalendarEventDTO = new CS_ARCalendarEventDTO();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        system.runas(portalUserList[0]){
            List<Case__c> caseList = [select id from Case__c limit 1];
            objCS_ARCalendarEventDTO = CS_ARCasesService.retrieveCalendarEventDTOByCaseId(string.valueof(caseList[0].Id));// need to pass case Id
        }
    }// end of testretrieveCalendarEventDTOByCaseId
    
    static testMethod void testupdateCaseStage(){
        //testData();
        List<Case__c> caseList = [select id from Case__c limit 1];
        CS_ARCasesService.updateCaseStage(string.valueOf(caseList[0].Id), 'Confirmed');
    }
    
    static testMethod void testcdeleteCase(){
        //testData();
        PortalUser = [SELECT Id FROM User WHERE contactId != null and customer_number__c = 'ArthTest001' LIMIT 1];
        objCase = [SELECT Id, OwnerId FROM Case__c LIMIT 1];
        system.debug('##--PortalUserId : '+ portalUser.Id + ' Case Owner Id: '+ objCase.OwnerId);
        CS_ARCasesService.cdeleteCase(string.valueof(objCase.Id));// need to pass caseId
        
        List<User> lstPortalUser = [SELECT Id FROM User WHERE contactId != null and Id =: objCase.OwnerId LIMIT 1];
        system.runas(lstPortalUser[0]){
            
            CS_ARCasesService.cdeleteCase(string.valueof(objCase.Id));// need to pass caseId
        }
        
    } // end of testcdeleteCase
    
    static testMethod void testupdateCaseDateTime(){
        //testData();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001' LIMIT 1];
        List<Case__c> caseList = [select id from Case__c limit 1];
        system.runas(portalUserList[0]){
            CS_ARCasesService.updateCaseDateTime(caseList[0].Id, 10312016,10312016);
        }
    }// end of testupdateCaseDateTime
    
    static testMethod void testcSaveCaseParticipant(){
        //testData();
        List<Case__c> caseList = [select id from Case__c limit 1];
        List<User> portalUserList = [select id from user where contactid != null and customer_number__c = 'ArthTest001' limit 1];
        CS_ARCasesService.cSaveCaseParticipant(caseList[0].Id, portalUserList[0].Id);
    }
    
    static testMethod void testupdateCase(){
        //testData();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        List<Case__c> caseList = [select id from Case__c limit 1];
        system.runas(portalUserList[0]){
            CS_ARCasesService.updateCase(caseList[0].Id, 10312016,10312016);
        }
    }// end of testupdateCase
    
    static testMethod void testcsaveCase(){
        //testData();
        list<string> lstProcedureIds = new list<String>();
        List<Procedure__c> lstProcedure = [select id from Procedure__c where TaxonGroupId__c = 'surgical_technique' limit 1];
        List<Procedure__c> lstProcedureTeam = [select id from Procedure__c limit 1];
        
        lstProcedureIds.add(string.valueof(lstProcedureTeam[0].Id + '::' + lstProcedure[0].Id));
        lstProcedureIds.add(string.valueof(lstProcedureTeam[0].Id + '::newId::' + lstProcedure[0].Id));
        
        list<string> lstProductIds = new list<String>();
        List<Product2> lstProduct = [select id from Product2 limit 1];
        
        lstProductIds.add(string.valueof(lstProduct[0].Id));
        
        list<string> surgicalIds = new list<string>();
        surgicalIds.add(string.valueof(lstProcedureTeam[0].Id + '::' + lstProcedure[0].Id));
        surgicalIds.add(string.valueof(lstProcedureTeam[0].Id + '::newId::' + lstProcedure[0].Id));
        
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        
        List<Case__c> caseList = [select id from Case__c limit 1];
        List<Account> lstHCProviderAcc = [select id from Account where Recordtype.name =: Constant.RECORDTYPE_NAME_HEALTH_CARE_PROVIDER limit 1];
        List<Account> lstAccPractitioner = [select id from Account where Recordtype.name = 'Practitioner' limit 1];
        
        
        Case_Procedure__c objCP = new Case_Procedure__c();
        objCP.Procedure__c = lstProcedure[0].id;
        objCP.Case__c = caseList[0].Id;
        insert objCP;
         
        //system.runas(portalUserList[0]){
            CS_ARCasesService.csaveCase(caseList[0].Id,  //String id
                                        string.valueof(lstHCProviderAcc[0].Id),  //String providerId
                                        string.valueof(lstAccPractitioner[0].Id),  //String practitionerId
                                        new list<string>(), //List<String> prefCardIdList
                                        '',  //String notes
                                        10312016, //Long startDateMs
                                        10312016, //Long endDateMs
                                        lstProductIds, //List<String> productIdList
                                        new list<string>(),  //List<String> participantIdList
                                        'Pending', //String status
                                        lstProcedureIds,  //List<String> procedureIdList
                                        surgicalIds,  //List<String> surgicalIds
                                        string.valueof(portalUserList[0].Id)); //String selectedOwnerId
        //}
    }// end of testcsaveCase
    
    static testMethod void testretrieveCaseParticipants(){
        //testData();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001' limit 1];
        List<Case__c> caseList = [select id from Case__c limit 1];
        system.runas(portalUserList[0]){
            CS_ARCasesService.retrieveCaseParticipants(caseList[0].Id);
        }
    }// end of testretrieveCaseParticipants  
    
    static testMethod void testRetrieveCaseProcedures(){
        //testData();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        system.runas(portalUserList[0]){
            List<Case__c> caseList = [select id from Case__c limit 1];
            CS_ARCasesService.retrieveCaseProcedures(caseList[0].Id);
        }
    }// end of testRetrieveCaseProcedures 
    
    static testMethod void testRetrieveCaseProducts(){
        //testData();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        system.runas(portalUserList[0]){
            List<Case__c> caseList = [select id from Case__c limit 1];
            CS_ARCasesService.retrieveCaseProducts(caseList[0].Id);
        }
    }// end of testRetrieveCaseProducts 
    
    static testMethod void testRetrieveCaseSurgicaProcedures(){
        //testData();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        system.runas(portalUserList[0]){
            List<Case__c> caseList = [select id from Case__c limit 1];
            CS_ARCasesService.retrieveCaseSurgicaProcedures(caseList[0].Id);
        }
    }// end of testRetrieveCaseSurgicaProcedures 
    
    static testMethod void testRetrieveCasePrefCards(){
        //testData();
        List<User> portalUserList = [select id from User where contactid != null and customer_number__c = 'ArthTest001'];
        system.runas(portalUserList[0]){
            List<Case__c> caseList = [select id from Case__c limit 1];
            CS_ARCasesService.retrieveCasePrefCards(caseList[0].Id);
        }
    }// end of testRetrieveCasePrefCards 
    
    static testMethod void testAddCasePreferenceCard(){
        //testData();
        List<Case__c> caseList = [select id from Case__c limit 1];
        List<Practitioner_Procedure__c> lstPP = [select id from Practitioner_Procedure__c limit 1];
        CS_ARCasesService.addCasePreferenceCard(string.valueOf(caseList[0].Id), string.valueOf(lstPP[0].Id));
    }//end of testAddCasePreferenceCard
    
    static testMethod void testRetrieveCaseActivity(){
        //testData();
        List<Case__c> caseList = [select id from Case__c limit 1];
        
        List<Case__History> lstCaseHistory = new List<Case__History>{};
        lstCaseHistory.add(new Case__History(ParentId =caseList[0].id, Field='Created'));
        lstCaseHistory.add(new Case__History(ParentId =caseList[0].id, Field='Name'));
        insert lstCaseHistory;
        
        Note objNote = new Note();
        objNote.ParentId = caseList[0].id;
        objNote.Body = 'test';
        objNote.Title = 'test';
        insert objNote;
        
        Task objTask = new Task();
        objTask.Subject = 'Test Subject';
        objTask.whatid = caseList[0].id;
        insert objTask;
        
        CS_ARCasesService.retrieveCaseActivity('All Activities', caseList[0].Id);
    }//end of testRetrieveCaseActivity
    
    static testMethod void testRetrieveCasesToBeLinked(){
        //testData();
        List<Account> lstAccPractitioner = [select id from Account where Recordtype.name = 'Practitioner' limit 1];
        List<Case__c> lstCase = [select id, Practitioner__c from Case__c LIMIT 1];
        CS_ARCasesService.retrieveCasesToBeLinked(lstCase[0].Practitioner__c);
    }//end of testRetrieveCasesToBeLinked
    
    static testMethod void testRetrieveOpportunitiesToBeLinked(){
        //testData();
        List<Account> lstAccPractitioner = [select id from Account where Recordtype.name = 'Practitioner' limit 1];
        
        List<Opportunity_Case__c> oppCaseList = [SELECT Opportunity__c, Case__c FROM Opportunity_Case__c LIMIT 1];
        List<Opportunity> lstOpp = [select id from Opportunity where id !=: oppCaseList[0].Opportunity__c LIMIT 1];
        Opportunity_Surgeons__c objOppSur = new Opportunity_Surgeons__c();
        objOppSur.Surgeon__c = lstAccPractitioner[0].id;
        objOppSur.Opportunity__c = lstOpp [0].id;
        insert objOppSur;
        
        CS_ARCasesService.retrieveOpportunitiesToBeLinked(lstAccPractitioner[0].Id, oppCaseList[0].Case__c);
    }//end of testRetrieveOpportunitiesToBeLinked
    
    static testMethod void testcSaveLinkedOpportunities(){
        //testData();
        List<Case__c> caseList = [select id from Case__c limit 1];
        List<Opportunity_Case__c> oppList = [SELECT Opportunity__c FROM Opportunity_Case__c LIMIT 1];
        List<String> lstLinkedOpportunityIds = new List<String>();
        CS_ARCasesService.cSaveLinkedOpportunities(string.valueOf(caseList[0].Id), lstLinkedOpportunityIds);
        for(Opportunity_Case__c oppLink : oppList){
            lstLinkedOpportunityIds.add(oppLink.Opportunity__c);
        }
        
        CS_ARCasesService.cSaveLinkedOpportunities(string.valueOf(caseList[0].Id), lstLinkedOpportunityIds);
    }//end of testcSaveLinkedOpportunities
    
    static testMethod void testCSaveLinkedCases(){
        //testData();
        
        List<Case__c> caseList = [SELECT Id FROM Case__c LIMIT 1];
        List<String> lstCaseIds = new List<String>();
        for(Case__c cases : caseList){
            lstCaseIds.add(cases.Id);
        }
        
        CS_ARCasesService.cSaveLinkedCases(string.valueOf(caseList[0].Id), lstCaseIds);
    }//end of testCSaveLinkedCases
    
    static testMethod void testcDeleteCaseParticipant(){
        //testData();
        
        CaseParticipant__c cp = [SELECT Id FROM CaseParticipant__c LIMIT 1];
        
        CS_ARCasesService.cDeleteCaseParticipant(string.valueOf(cp.Id));
    }//end of testcDeleteCaseParticipant
    
    static testMethod void testCreateCaseNote(){
        //testData();
        List<Case__c> caseList = [select id from Case__c limit 1];
        CS_ARCasesService.createCaseNote(string.valueOf(caseList[0].Id), 'Test Note');
    }//end of testCreateCaseNote
    
    static testMethod void testcDeletePreferenceCard(){
        //testData();
        
        Case_Pref_Card__c cpc = [SELECT Id FROM Case_Pref_Card__c LIMIT 1];
        CS_ARCasesService.cDeletePreferenceCard(string.valueof(cpc.Id));
    }//end of testcDeletePreferenceCard
    
    static testMethod void testcDeleteLinkedOpportunityCase(){
        //testData();
        
        Opportunity_Case__c oc = [SELECT Id FROM Opportunity_Case__c LIMIT 1];
        CS_ARCasesService.cDeleteLinkedOpportunityCase(string.valueOf(oc.Id));
    }//end of testcDeleteLinkedOpportunityCase
    
    static testMethod void testRetrieveFieldName(){
        //testData();
        
        CS_ARCasesService.retrieveFieldName('Case__c', 'Created');
    }//end of testRetrieveFieldName
    
     static testMethod void testMethodCommon(){
        //testData();
        
        CS_ARCasesService.CS_LinkOpportunity objCSLOpp = new CS_ARCasesService.CS_LinkOpportunity(null);
        
        List<Case__c> caseList = [select id, (select id, Procedure__r.Name from Case_Procedures__r) from Case__c where Health_Care_Provider__r.Recordtype.name =: Constant.RECORDTYPE_NAME_HEALTH_CARE_PROVIDER limit 1];
        CS_ARCasesService.CS_OpportunityCase objCSLOppCase = new CS_ARCasesService.CS_OpportunityCase(caseList[0]);
        
        Map<id, string> calendarColors = new Map<id, string>();
        calendarColors.Put(system.userinfo.getuserid(), 'Yellow');
        CS_ARCasesService.updateCalendarColor(calendarColors);
        List<User> userList = [select id from User];
        for(User u: userList){
            calendarColors.Put(u.id, 'Yellow');
        }
        List<Account> lstHCProviderAcc = [select id from Account where Recordtype.name =: Constant.RECORDTYPE_NAME_HEALTH_CARE_PROVIDER limit 1];
        
        Set<Id> userTerritoryIds = new Set<Id>(CS_ARTerritoryService.retrieveMyTerritoryIds());
        for(Id ut: userTerritoryIds){        
            ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = lstHCProviderAcc[0].Id,
                                                                                   Territory2Id = ut,
                                                                                   AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);
            insert objAssoc;
        }
        caseList[0].Health_Care_Provider__c = lstHCProviderAcc[0].id;
        update caseList[0];
        
        CS_ARCasesService.CalendarDTOForCase(caseList[0].id);     
    }//end of testMethodCommon
    
}