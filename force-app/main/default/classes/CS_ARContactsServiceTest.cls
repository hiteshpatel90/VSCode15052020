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
 
 //code added to increase code coverage for 3.2 
@isTest
private class CS_ARContactsServiceTest implements HttpCalloutMock {

    private static User portalUser;
    private static User adminUser;
    private static Account agencyAccount;
    private static Account healthCareProviderAccount;
    private static Contact portalUserContact;
    private static Contact providerContact;
    private static Product2 objProduct;
    private static Procedure__c parentProcedure;
    private static Procedure__c childProcedure;
    private static Procedure_Relationships__c objProcedureRel;
    private static Account practitioner;
    private static Practitioner_Procedure__c practitionerprocedure;
    private static Case__c objCase;
    private static Institution__c objUnderGraduateInstitution;
    private static Institution__c objGraduateInstitution;
    private static Institution__c objDoctarateInstitution;
    //Code added by Ansu for release 2.2/CID000065
    private static Affiliation__c affiliation;
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://maps.googleapis.com/maps/api/geocode/json?address=1370+Creekside+Blvd.%2C+Naples%2C+Florida+34108%2C+United+States&key=AIzaSyBV1fTgLwFGMx3zNAU4UvcV8EEGJp0JANY', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"location":{'+'"lat":34.0,'+'"lng":44.0'+'}}');
        res.setStatusCode(200);
        return res;
    }

   //Code added by Ansu ends
    
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
            agencyAccount.Ownerid = adminUser.id;
            insert agencyAccount;
            
            healthCareProviderAccount = DataFactoryAccount.createHealthCareProviderAccount();
            healthCareProviderAccount.Account_group__c = 'Z002';
            insert healthCareProviderAccount;
            
            ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = healthCareProviderAccount.Id,
                                                                                    Territory2Id = objTerritory.Id,
                                                                                    AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);
            insert objAssoc;
            
            portalUserContact = DataFactoryContact.createContacts('PortalContact');
            portalUserContact.AccountId = agencyAccount.Id;
            insert portalUserContact;
            
            providerContact = DataFactoryContact.createContacts('providerContact');
            //providerContact.AccountId = agencyAccount.Id;
            providerContact.AccountId = healthCareProviderAccount.Id;
            insert providerContact;
            
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
            
            parentProcedure = DataFactoryProcedures.createProcedure();
            insert parentProcedure;
                        
            childProcedure = DataFactoryProcedures.createChildProcedure();
            childProcedure.TaxonGroupId__c='surgical_technique';
            insert childProcedure;
            
            objProcedureRel = new Procedure_Relationships__c(Child_Procedure__c = childProcedure.Id,
                                                                                        Parent_Procedure__c = parentProcedure.Id,
                                                                                        TaxonGroupId__c = 'surgical_technique');
            insert objProcedureRel;
            
            List<Account> lstAcc = [SELECT id FROM Account where Recordtype.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER];
            practitionerprocedure = CS_TestDataBuilder.CreatePractitionerProcedure(lstAcc[0].Id, parentProcedure.Id );
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
            
            objUnderGraduateInstitution = DataFactoryInstitution.createInstitution('Undergraduate Institution');
            insert objUnderGraduateInstitution;
            
            objGraduateInstitution = DataFactoryInstitution.createInstitution('Graduate Institution');
            insert objGraduateInstitution;
            
            objDoctarateInstitution = DataFactoryInstitution.createInstitution('Doctorate Institution');
            insert objDoctarateInstitution;
            
            //Code added by Ansu for release 2.2/CID000065
            affiliation = CS_TestDataBuilder.CreateAffiliation(healthCareProviderAccount.Id ,practitioner.Id);
            insert affiliation;
            
            
            Account SurgeonContact = DataFactoryAccount.createSurgeonContact();
            insert SurgeonContact;
            
            Surgeon_Related_Contacts__c objSRC = new Surgeon_Related_Contacts__c();
            objSRC.Surgeon__c = practitioner.id;
            objSRC.Surgeon_Contact__c = SurgeonContact.id;
            insert objSRC;
            
            Attachment objAttachment = new Attachment();
            objAttachment.ParentId = healthCareProviderAccount.id;
            objAttachment.Name = 'surgeon_Profile_Pic.png';
            objAttachment.body = blob.valueOf('test');
            insert objAttachment;
            
            
            Group objGroup = new Group();
            objGroup.Name = 'New Surgeons';
            objGroup.Type = 'Queue';
            insert objGroup;
            
            QueueSobject mappingObject = new QueueSobject(QueueId = objGroup.Id, SobjectType = 'Case');
            insert mappingObject;
            
        }
        
    }// end of testData.
    
    static testMethod void testRetrievePractitioners(){
        
        //testData();
        adminUser=[Select Id from User where Profile.Name=:'System Administrator' and username=:'testadmin@arthrex.com.arthrex.com' limit 1];
        Map<String,List<Id>> territoryMap = new Map<String,List<Id>>();
        System.runAs(adminUser)
        {
            Test.startTest();
            Account objAcc = [select id from Account where RecordType.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER LIMIT 1];
            
            List<Territory2> lstTerritory2 = [select id from Territory2 WHERE DeveloperName != 'TestTeamTerritory1' LIMIT 1];
            for(Territory2 tr: lstTerritory2){
                UserTerritory2Association objTerrAssoc3 = new UserTerritory2Association(UserId = adminUser.Id,
                                                                                   Territory2Id = tr.Id);
                insert objTerrAssoc3;
            
                ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = objAcc.Id,
                                                                                        Territory2Id = tr.id,
                                                                                        AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);  
                insert objAssoc;
            }
            List<Account> practitioners = CS_ARSearch.searchSurgeonsInMyTeamTerritory('');
            system.assertEquals(practitioners.size(), 1);
            //list<Account> lstPractitioners = new list<Account>();
            //lstPractitioners = CS_ARContactsService.retrievePractitioners();
        }
        list<Account> lstPractitioners = new list<Account>();
        lstPractitioners = CS_ARContactsService.retrievePractitioners();
        
        //System.assertEquals('TestPractitionerFirstName TestPractitionerLastName', lstPractitioners[0].FirstName);
        
    }// end of testRetrievePractitioners
    
    static testMethod void testRetrievePractitioner(){
        
        //testData();
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        Account practitionerAccount =new Account();
        practitionerAccount = CS_ARContactsService.retrievePractitioner(string.valueof(practitioner.Id));
        
        //System.assertEquals('TestPractitionerFirstName TestPractitionerLastName', practitionerAccount.FirstName );
        
    }// end of testRetrievePractitioner
    
    static testMethod void testUpdateProvider(){
        
        //testData();
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        Map<String,Object> m = new Map<String,Object>();
        m.put('id', healthCareProviderAccount.Id);
        m.put('nickName','test');
        m.put('website','www.google.com');
        //Code added by Ansu for release 2.2/CID000065
        m.put('credentialcompany','test Comp');
        m.put('RepresentativeParking','Test Rep Parking');
        m.put('RequiredtoChangeScrubs','No');
        m.put('SterileProcessingLocation','Test Sterile Location');
        m.put('OperatingRoomLocation','Test Operating Location');
        m.put('SignInLocation','Test Sign Location');
        m.put('OtherAttireNotes','Test Notes');
        m.put('businessHourStartTime','6:00AM');
        m.put('businessHourEndTime','12:00PM');
        m.put('SterileProcessingHourStartTime','6:00AM');
        m.put('SterileProcessingHourEndTime','12:00PM');
        m.put('AccountFiscalYearStartDay','1');
        m.put('AccountFiscalYearStartMonth','FEBRUARY');
        m.put('AccountFiscalYearEndDay','31');
        m.put('AccountFiscalYearEndMonth','DECEMBER');
        
        CS_ARContactsService.updateProvider(m);
        
        Account providerAccount =[select Id, Preferred_Name__c, Website from Account where Id=:healthCareProviderAccount.Id LIMIT 1];
        
        System.assertEquals('www.google.com', providerAccount.WebSite);
        
        m.put('RequiredtoChangeScrubs',' ');
        m.put('businessHourStartTime',' ');
        m.put('businessHourEndTime',' ');
        m.put('SterileProcessingHourStartTime',' ');
        m.put('SterileProcessingHourEndTime',' ');
        m.put('AccountFiscalYearStartDay',' ');
        m.put('AccountFiscalYearStartMonth',' ');
        m.put('AccountFiscalYearEndDay',' ');
        m.put('AccountFiscalYearEndMonth',' ');
        //Code added by Ansu ends
        
        CS_ARContactsService.updateProvider(m);
        
    }// end of testUpdateProvider
    
    static testMethod void testUpdatePractitionerDemographics(){
        
        //testData();
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        Map<String,Object> m = new Map<String,Object>();
        m.put('id', practitioner.Id);
        m.put('birthDate','0101980');
        m.put('npi','9292121212');
        m.put('firstName','testfirstName');
        m.put('lastName','testlastName');
        m.put('email','testfirstname_1111@test.com');
        m.put('hasOptedOutOfEmail',true);
        m.put('assignedSalesRepEmail','testassignedSalesRep_1111@test.com');
        m.put('practiceName','testPractice');
        m.put('lang','English');
        m.put('title','MD');
        m.put('salutation','Mr.');
        m.put('gender','Male');
        m.put('userType','Test');
        m.put('mState','Virginia');
        m.put('practiceFocus','TestPracticeFocus');
        m.put('designation','Manager');
        m.put('specialty','knee');
        m.put('phone','9989989999');
        m.put('mobilePhone','9989989998');
        m.put('mStreet','test street');
        m.put('mCity','test city');
        m.put('mZip','20171');
        m.put('arthrexMarkEmail',true);
        CS_ARContactsService.updatePractitionerDemographics(m);
        
        Account practitionerAccount =new Account();
        practitionerAccount = CS_ARContactsService.retrievePractitioner(string.valueof(practitioner.Id));
        //System.assertEquals('9292121212', practitionerAccount.NPI__pc );
        
    }// end of testUpdatePractitionerDemographics
    
    static testMethod void testUpdatePractitionerBio(){
        
        //testData();
        practitioner = [select id, Internship__c from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        objUnderGraduateInstitution = [select id from Institution__c where Name = 'Undergraduate Institution'];
        objGraduateInstitution = [select id from Institution__c where name = 'Graduate Institution'];
        objDoctarateInstitution = [select id from Institution__c where name = 'Doctorate Institution'];
                
        Map<String,Object> m = new Map<String,Object>();
        m.put('id', practitioner.Id);
        m.put('undergraduateId', objUnderGraduateInstitution.Id);
        m.put('graduateId', objGraduateInstitution.Id);
        m.put('doctorateId',objDoctarateInstitution.Id);
        m.put('internship','testInternship');
        m.put('residencies','testresidences');
        m.put('fellowships','testFellowships');
        m.put('certifications','testCertifications');
        m.put('awards','testAwards');
        m.put('professionalSocieties','testProfessionalSocieties');
        m.put('sportsTeamsAffiliations','testSportsTeamsAffiliations');
        m.put('personalInterest','testPersonalInterest');
        m.put('spouseAndChildren','testSpouseAndChildren');
        CS_ARContactsService.updatePractitionerBio(m);
        
        Account practitionerAccount = new Account();
        practitionerAccount = CS_ARContactsService.retrievePractitioner(string.valueof(practitioner.Id));
        //System.assertEquals('testInternship', practitionerAccount.Internship__c);

        
    }// end of testUpdatePractitionerBio
    
    static testMethod void testSaveContact(){
        
        //testData();
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        Map<String,Object> m = new Map<String,Object>();
        
        m.put('firstName','testfirstName');
        m.put('lastName','testlastName');
        m.put('email','testfirstname@test.com');
        m.put('phone','9989989999');
        m.put('mobile','9989989998');
        m.put('street','test street');
        m.put('city','test city');
        m.put('state','Virginia');
        m.put('country','United States');
        m.put('zip','20171');
        m.put('title','Mr.');
        m.put('notes','test notes');
        m.put('accountId', healthCareProviderAccount.Id);
        
        Contact cntct = CS_ARContactsService.saveContact(m);
        System.assertEquals('testfirstName', cntct.FirstName);
        
        
        Contact objContact = [select id, Accountid from Contact WHERE Accountid != null LIMIT 1];
        m.put('id', objContact.id);
        m.put('accountId', objContact.Accountid);
        cntct = CS_ARContactsService.saveContact(m);
        
    }// end of testSaveContact
    
    static testMethod void testRetrieveProviders(){
        
        //testData();
        list<Account> lstProviders = new list<Account>();
        lstProviders = CS_ARContactsService.retrieveProviders(1, 10);
        System.assertNotEquals(null, lstProviders);
        
    }// end of testRetrieveProviders
    
    static testMethod void testRetrieveProvider(){
        
        //testData();
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        Account retrieveProviderAccount = new Account();
        retrieveProviderAccount = CS_ARContactsService.retrieveProvider(healthCareProviderAccount.Id);
        
        Account providerAccount =[select Id, Name, Preferred_Name__c, Website from Account where Id=:healthCareProviderAccount.Id LIMIT 1];
        
        System.assertEquals('Test HCP Account', providerAccount.Name);
        
        
        adminUser=[Select Id from User where Profile.Name=:'System Administrator' and username=:'testadmin@arthrex.com.arthrex.com' limit 1];
        Map<String,List<Id>> territoryMap = new Map<String,List<Id>>();
        System.runAs(adminUser)
        {
            Test.startTest();
            healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' AND Recordtype.Name =: Constant.RECORDTYPE_NAME_HEALTH_CARE_PROVIDER AND Account_group__c = 'Z002' limit 1];
        
            List<Territory2> lstTerritory2 = [select id from Territory2 WHERE DeveloperName != 'TestTeamTerritory1' LIMIT 1];
            for(Territory2 tr: lstTerritory2){
                UserTerritory2Association objTerrAssoc3 = new UserTerritory2Association(UserId = adminUser.Id,
                                                                                   Territory2Id = tr.Id);
                insert objTerrAssoc3;
            
                ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = healthCareProviderAccount.Id,
                                                                                        Territory2Id = tr.id,
                                                                                        AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);  
                insert objAssoc;
            }
            retrieveProviderAccount = CS_ARContactsService.retrieveProvider(healthCareProviderAccount.Id);
            
            healthCareProviderAccount.Preferred_Name__c = null;
            update healthCareProviderAccount;
            retrieveProviderAccount = CS_ARContactsService.retrieveProvider(healthCareProviderAccount.Id);
        }        
    }// end of testRetrieveProvider
    
    static testMethod void testRetrieveProviderContacts(){
        
        //testData();
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        list<Contact> lstProviderContacts = new list<Contact>();
        lstProviderContacts = CS_ARContactsService.retrieveProviderContacts(healthCareProviderAccount.Id);
        System.assertNotEquals(null, lstProviderContacts );
        
    }// end of testRetrieveProviderContacts
    
    static testMethod void testDeleteProviderContact(){
        
        //testData();
        providerContact = [select id from Contact where Lastname = 'providerContact' LIMIT 1];
        CS_ARContactsService.deleteProviderContact(providerContact.Id);
        
        list<Contact> lstContacts = [select Id from Contact  where Id=:providerContact.Id];
        System.assertNotEquals(null, lstContacts );
        
        
        adminUser=[Select Id from User where Profile.Name=:'System Administrator' and username=:'testadmin@arthrex.com.arthrex.com' limit 1];
        Map<String,List<Id>> territoryMap = new Map<String,List<Id>>();
        System.runAs(adminUser)
        {
            Test.startTest();
            healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' AND Recordtype.Name =: Constant.RECORDTYPE_NAME_HEALTH_CARE_PROVIDER AND Account_group__c = 'Z002' limit 1];
        
            List<Territory2> lstTerritory2 = [select id from Territory2 WHERE DeveloperName != 'TestTeamTerritory1' LIMIT 1];
            for(Territory2 tr: lstTerritory2){
                UserTerritory2Association objTerrAssoc3 = new UserTerritory2Association(UserId = adminUser.Id,
                                                                                   Territory2Id = tr.Id);
                insert objTerrAssoc3;
            
                ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = healthCareProviderAccount.Id,
                                                                                        Territory2Id = tr.id,
                                                                                        AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);  
                insert objAssoc;
            }
            List<Id> availProviderIds = CS_ARTerritoryService.retrieveHealthCareProvidersInMyTeamTerritory();
            
            providerContact = [select id from Contact where Accountid IN: availProviderIds LIMIT 1];
       
            CS_ARContactsService.deleteProviderContact(providerContact.Id);
        }
    }// end of testDeleteProviderContact
    
    static testMethod void testdeleteRelatedContact() {
        Contact objCon = [select id from Contact LIMIT 1];
        CS_ARContactsService.deleteRelatedContact(objCon.id);
        
        adminUser=[Select Id from User where Profile.Name=:'System Administrator' and username=:'testadmin@arthrex.com.arthrex.com' limit 1];
        Map<String,List<Id>> territoryMap = new Map<String,List<Id>>();
        System.runAs(adminUser)
        {
            Test.startTest();
            healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' AND Recordtype.Name =: Constant.RECORDTYPE_NAME_HEALTH_CARE_PROVIDER AND Account_group__c = 'Z002' limit 1];
        
            List<Territory2> lstTerritory2 = [select id from Territory2 WHERE DeveloperName != 'TestTeamTerritory1' LIMIT 1];
            for(Territory2 tr: lstTerritory2){
                UserTerritory2Association objTerrAssoc3 = new UserTerritory2Association(UserId = adminUser.Id,
                                                                                   Territory2Id = tr.Id);
                insert objTerrAssoc3;
            
                ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = healthCareProviderAccount.Id,
                                                                                        Territory2Id = tr.id,
                                                                                        AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);  
                insert objAssoc;
            }
            List<Id> availProviderIds = CS_ARTerritoryService.retrieveHealthCareProvidersInMyTeamTerritory();
            
            providerContact = [select id from Contact where Accountid IN: availProviderIds LIMIT 1];
       
            CS_ARContactsService.deleteRelatedContact(healthCareProviderAccount.Id);
        }
        
    }// end of testdeleteRelatedContact
    
    static testMethod void testRetrievePractitionerPrefCards(){
        
        //testData();
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        list<Practitioner_Procedure__c> lstPractionerProcedures = new list<Practitioner_Procedure__c>();
        lstPractionerProcedures = CS_ARContactsService.retrievePractitionerPrefCards(practitioner.Id);
        System.assertNotEquals(null, lstPractionerProcedures );
        
    }// end of testRetrievePractitionerPrefCards
    
    //Code added by Ansu ends    
    static testMethod void testRetrievePractitionerPrefCardsFromCal(){
        
        //testData();
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        objCase = [select id from Case__c LIMIT 1];        
        list<Practitioner_Procedure__c> lstPractitionerProcedures = new list<Practitioner_Procedure__c>();
        lstPractitionerProcedures = CS_ARContactsService.retrievePractitionerPrefCardsFromCal(practitioner.Id, objCase.Id);
        
         List<Case_Pref_Card__c> lstCasePRefCard = [SELECT id, Practitioner_Procedure__c 
                                        FROM Case_Pref_Card__c 
                                        WHERE Case__c =: objCase.id];
        lstCasePRefCard[0].Practitioner_Procedure__c = null;
        update lstCasePRefCard;
        
        lstPractitionerProcedures = CS_ARContactsService.retrievePractitionerPrefCardsFromCal(practitioner.Id, objCase.Id);
        
    }// end of testGetAllRelatedSurgicalTechniques
    
    static testMethod void testRetrievePractitionerPrefCard(){
        
        //testData();
        Practitioner_Procedure__c objPractitionerProcedure = new Practitioner_Procedure__c();
        objPractitionerProcedure = [select id from Practitioner_Procedure__c LIMIT 1];
        CS_ARContactsService.retrievePractitionerPrefCard(objPractitionerProcedure.Id);
        
    }// end of testRetrievePractitionerPrefCard
    
    static testMethod void testRetrievePractitionerPrefCardProducts(){
        
        //testData();
        practitionerprocedure = [select id from Practitioner_Procedure__c LIMIT 1];
        list<Practitioner_Procedure_Products__c> lstPractitionerProcedureProducts = new list<Practitioner_Procedure_Products__c>();
        lstPractitionerProcedureProducts = CS_ARContactsService.retrievePractitionerPrefCardProducts(practitionerprocedure.Id);
        //System.assertNotEquals(null, lstPractitionerProcedureProducts );
        
    }// end of testRetrievePractitionerPrefCardProducts
    
    static testMethod void testRetrievePractitionerTasks(){
        
        //testData();
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        list<string> lstTasks = new list<string>();
        lstTasks = CS_ARContactsService.retrievePractitionerTasks(practitioner.Id);
        System.assertNotEquals(null, lstTasks);
        
    }// end of testRetrievePractitionerTasks
    
    static testMethod void testSaveNewSurgeonRequest(){
        
        //testData();        
        CS_ARContactsService.saveNewSurgeonRequest('9998883331', 'testFirstName' , 'testLastName');
        
        CS_ARContactsService.saveNewSurgeonRequest('', 'testFirstName' , 'testLastName');                
    }// end of testSaveNewSurgeonRequest

    static testMethod void testDeletePractitionerProcedure(){
        
        //testData();
        practitionerprocedure = [select id from Practitioner_Procedure__c LIMIT 1];
        CS_ARContactsService.deletePractitionerProcedure(practitionerprocedure.Id);
        
    }// end of testDeletePractitionerProcedure
    
    static testMethod void testRetrieveProductsByProcedure(){
        
        //testData();
        parentProcedure = [select id from Procedure__c where Parent_Name__c = null LIMIT 1];
        list<ProcedureProduct__c> lstProcProds  = new list<ProcedureProduct__c>();
        lstProcProds = CS_ARContactsService.retrieveProductsByProcedure(parentProcedure.Id);
        
    }// end of testRetrieveProductsByProcedure
    
    static testMethod void testIsUniquePractitionerProcedureName(){
        
        //testData();
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        boolean isUniquePractitionerProcedureName = false;
        isUniquePractitionerProcedureName = CS_ARContactsService.isUniquePractitionerProcedureName(practitioner.Id, 'Test');
        
    }// end of testIsUniquePractitionerProcedureName
    
    static testMethod void testCsavePractitionerProcedure(){
        
        //testData();
        list<String> lstProcedureIds = new list<String>();
        list<String> lstSurgTechIds = new list<String>();
       
        practitionerprocedure = [select id, Name, Practitioner_Procedure__c.Procedure__c from Practitioner_Procedure__c LIMIT 1];
        parentProcedure = [select id, Name from Procedure__c where Parent_Name__c = null LIMIT 1];
        lstProcedureIds.add(String.valueOf(parentProcedure.Id) + '::'  + String.valueOf(parentProcedure.Id) + '::' + String.valueOf(parentProcedure.Name) + '::' +  String.valueOf(parentProcedure.Name));        
        //Code added by Ansu R2.2 FOR increasing code coverage
        lstProcedureIds.add(String.valueOf(parentProcedure.Id) + '::'  + String.valueOf(parentProcedure.Id)+'newId' + '::' + String.valueOf(parentProcedure.Name) + '::' +  String.valueOf(parentProcedure.Name));        
        
        parentProcedure = [select id from Procedure__c where Parent_Name__c = null LIMIT 1];
       
        childProcedure = [select id, Name from Procedure__c WHERE id !=: parentProcedure.id LIMIT 1];
       
        lstSurgTechIds.add(String.valueOf(childProcedure.Id) + '::'+ String.valueOf(childProcedure.Id) + '::' + String.valueOf(childProcedure.Name) + '::' + String.valueOf(childProcedure.Name));
        //testData();
        
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        Practitioner_Procedure__c objPractitionerProcedure = new Practitioner_Procedure__c();
         
        Preference_Card_Procedures__c objPCP = new Preference_Card_Procedures__c();
        objPCP.Preference_Card__c = practitionerprocedure.id;
        objPCP.Product_Team__c = practitionerprocedure.Procedure__c;
        objPCP.Taxonomy__c = practitionerprocedure.Procedure__c;
        insert objPCP;
        
        objProduct = [select id from Product2 LIMIT 1];
        List<String> productIds = new List<String>();
        productIds.add(objProduct.id);
        
        Practitioner_Procedure_Products__c objPPP = new Practitioner_Procedure_Products__c();
        objPPP.Practitioner_Procedure__c = practitionerprocedure.id;
        objPPP.Product__c = objProduct.id;
        insert objPPP;
        
        CS_ARContactsService.CS_PreferenceCardWrapper objPrefCardWrapper = CS_ARContactsService.csavePractitionerProcedure(practitionerprocedure.Id,  //String id, 
                                                                    'Test PrefCardName', //String name, 
                                                                    practitioner.Id, //String practitionerId,  
                                                                    lstProcedureIds, //parentProcedure.Id, //String procedureId, 
                                                                    lstSurgTechIds, //childProcedure.Id, //string surgicalTechniqueId, 
                                                                    'test disposables', //String disposables,
                                                                    'test equipment', //String equipment,
                                                                    'test equipmentNotes', //String equipmentNotes, 
                                                                    'test medications', //String medications,
                                                                    'test sutures', //String sutures, 
                                                                    'test position', //String position, 
                                                                     productIds); //List<String> productIdList);
        
        objPrefCardWrapper = CS_ARContactsService.csavePractitionerProcedure(null,  //String id, 
                                                                    'Test PrefCardName', //String name, 
                                                                    practitioner.Id, //String practitionerId,  
                                                                    lstProcedureIds, //parentProcedure.Id, //String procedureId, 
                                                                    lstSurgTechIds, //childProcedure.Id, //string surgicalTechniqueId, 
                                                                    'test disposables', //String disposables,
                                                                    'test equipment', //String equipment,
                                                                    'test equipmentNotes', //String equipmentNotes, 
                                                                    'test medications', //String medications,
                                                                    'test sutures', //String sutures, 
                                                                    'test position', //String position, 
                                                                    new list<string>()); //List<String> productIdList);


    
    }// end of testCsavePractitionerProcedure
    
    static testMethod void testGeoCodeSync(){
       
        //testData();
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        
        test.startTest();
        CS_ARContactsService.geocodeAsync( healthCareProviderAccount.Id, //String id, 
                                                                                '1370 Creekside Blvd.', //String street, 
                                                                                'Florida', //String state, 
                                                                                'Naples', //String city, 
                                                                                '34108', //String postalCode,
                                                                                'United States');//String country );
        
        
        Test.setMock(HttpCalloutMock.class, new CS_ARContactsServiceTest());
        CS_ARContactsService.geocodeAsync( healthCareProviderAccount.Id, //String id, 
                                                                                '1370 Creekside Blvd.', //String street, 
                                                                                'Florida', //String state, 
                                                                                'Naples', //String city, 
                                                                                '34108', //String postalCode,
                                                                                'United States');//String country );
       
        test.stopTest();
        
    }// end of testGeoCodeSync
    
    static testMethod void testgetPickValues(){       
        CS_ARContactsService.getPickValues(new Account(), 'Business_Hours_Start__c', '1:00AM');
    }// end of testgetPickValues
    
    
    public static testMethod void testupdateProfilePicture() {
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        
        Map<String,Object> profile = new Map<String,Object>();
        profile.Put('encodedFileContents', 'data:image/png;base64,iVBORw0KGgoAAAAN');
        
        CS_ARContactsService.updateProfilePicture(profile, practitioner.id);
    }// end of testupdateProfilePicture
    
    //Coded added by Mimansha for release 2.2/CID000064 
    static testMethod void testRetrieveTerritoryForPractitioner(){
        
        //testData();
        practitioner = [select id from account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        list<String> lstTerritoryNames = new list<String>();
        lstTerritoryNames = CS_ARContactsService.retrieveTerritoryForPractitioner(practitioner.Id);
        System.assertNotEquals(null, lstTerritoryNames );
        
    }// end of testRetrieveTerritoryForPractitioner
    
    
    public static testMethod void testretrieveAccountAffiliationsByPractitionerNew() {
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        
        CS_ARContactsService.retrieveAccountAffiliationsByPractitioner(practitioner.id);
        
        practitioner.Preferred_Name__c = 'Test Preferred Name';
        update practitioner;
        
        CS_ARContactsService.retrieveAccountAffiliationsByPractitioner(practitioner.id);
        List<Affiliation__c> lstAff = [SELECT id, Account_hcp__c FROM Affiliation__c WHERE Account_p__c =: practitioner.id];
        
        adminUser=[Select Id from User where Profile.Name=:'System Administrator' and username=:'testadmin@arthrex.com.arthrex.com' limit 1];
       
        System.runAs(adminUser){
             List<Territory2> lstTerritory2 = [select id from Territory2 WHERE DeveloperName != 'TestTeamTerritory1' LIMIT 1];
          
             for(Territory2 tr: lstTerritory2){
                UserTerritory2Association objTerrAssoc3 = new UserTerritory2Association(UserId = adminUser.Id,
                                                                                       Territory2Id = tr.Id);
                insert objTerrAssoc3;
            
                ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = lstAff[0].Account_hcp__c,
                                                                                        Territory2Id = tr.id,
                                                                                        AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);  
                insert objAssoc;
            }
            
            CS_ARContactsService.retrieveAccountAffiliationsByPractitioner(practitioner.id);
        }
    }
    
    static testMethod void testDeleteAccountAffiliation(){
        
        //testData();
        affiliation = [select id from Affiliation__c LIMIT 1];
        CS_ARContactsService.deleteAccountAffiliation(affiliation.Id);
        list<Affiliation__c> lstAffiliations = [select Id, Name from Affiliation__c where Id=:affiliation.Id];
        System.assertEquals(0, lstAffiliations.size());
        
    }// end of testDeleteAccountAffiliation
    
    static testMethod void testcSaveAccountAffiliation(){
        
        //testData();
        agencyAccount = [select id, Ownerid from Account where name = 'Test Agency Account'];
        providerContact = [select id from Contact where AccountId =: agencyAccount.Id limit 1];
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        list<Id> lstProviders = new list<Id>();
        lstProviders.add(healthCareProviderAccount.Id);
        CS_ARContactsService.cSaveAccountAffiliation(practitioner.Id,lstProviders);
        
        Map<String,Object> contactMap= new Map<String,Object>();
        //contactMap.put('id', providerContact.Id);        
        contactMap.put('lastName', 'Test contact');
        CS_ARContactsService.saveContact(contactMap);
        
    }// end of testcSaveAccountAffiliation
    
    static testMethod void testRetrieveTerritoryForPractitioners(){
        
        //testData();
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        list<ObjectTerritory2Association> lstTerritories = new list<ObjectTerritory2Association>();
        lstTerritories = CS_ARContactsService.retrieveTerritoryForPractitioners(healthCareProviderAccount.Id);
        System.assertNotEquals(null, lstTerritories);
        
    }// end of testRetrieveTerritoryForPractitioners
    
    static testMethod void testDeleteSurgeonAffiliation(){
        
        //testData();
        affiliation = [select id from Affiliation__c LIMIT 1];
        CS_ARContactsService.deleteSurgeonAffiliation(affiliation.Id);
        list<Affiliation__c> lstAffiliations = [select Id, Name from Affiliation__c where Id=:affiliation.Id];
        System.assertEquals(0, lstAffiliations.size());
        
    }// end of testDeleteSurgeonAffiliation
    
    static testMethod void testcSaveSurgeonsAffiliation(){
        
        //testData();
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        
        list<Id> lstSurgeons = new list<Id>();
        lstSurgeons.add(practitioner.Id);
        CS_ARContactsService.cSaveSurgeonsAffiliation(healthCareProviderAccount.Id,lstSurgeons);
        
        List<Affiliation__c> listSurgeons = new List<Affiliation__c>();
        listSurgeons = [SELECT Id, Name, Full_Name__c, Account_p__r.Name, Surgeon_Designation__c, Surgeon_Phone__c,Surgeon_Type__c, Person_Email__c,Account_p__r.Id,Account_p__c FROM Affiliation__c where Account_hcp__r.Id=:healthCareProviderAccount.Id];
        System.assertNotEquals(0, listSurgeons.size());
        
    }// end of testcSaveSurgeonsAffiliation
    
    static testMethod void testbuildCS_AROpportunityWrapper(){
        Practitioner_Procedure__c objPP = [select id from Practitioner_Procedure__c LIMIT 1];
        CS_ARContactsService.buildCS_AROpportunityWrapper(objPP.id);
        
        CS_ARContactsService.buildCS_AROpportunityWrapper(null);
    }// end of testbuildCS_AROpportunityWrapper
    
    
    static testMethod void testBuildCS_AROpportunityWrapperListByObjectId(){
        //testData();
        
        practitionerprocedure = [select id, Procedure__c from Practitioner_Procedure__c LIMIT 1];
      
        Procedure__c parentProce=new Procedure__c();
        parentProce.Name='Arthroplasty';
        parentProce.Product_Category__c = 'Knee';
        parentProce.TaxonGroupId__c = 'Procedure';
        insert parentProce;  
        
        Preference_Card_Procedures__c objPCP = new Preference_Card_Procedures__c();
        objPCP.Preference_Card__c = practitionerprocedure.id;
        objPCP.Product_Team__c = practitionerprocedure.Procedure__c;
        objPCP.Taxonomy__c = parentProce.id;
        insert objPCP;
        
        // List of Practitioner Procedure Ids
        list<String> listIDs = new list<String>();
        listIds.add(practitionerprocedure.Id);
        CS_ARContactsService.buildCS_AROpportunityWrapperListByObjectId(listIds, 'Practitioner_Procedure__c');
        
        //List of Practioner Ids
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        list<String> listPractitionerIds = new list<String>();
        listPractitionerIds.add(practitioner.Id);
        CS_ARContactsService.buildCS_AROpportunityWrapperListByObjectId(listIds, 'Practitioner__c');
        
        objPCP.Taxonomy__c = practitionerprocedure.Procedure__c;
        update objPCP;
        CS_ARContactsService.buildCS_AROpportunityWrapperListByObjectId(listIds, 'Practitioner_Procedure__c');
        
    }
    
    static testMethod void testc_getAllRelatedProcedures(){
        // Arthroplasty
        Procedure__c parentProce=new Procedure__c();
        parentProce.Name='Arthroplasty';
        parentProce.Product_Category__c = 'Knee';
        parentProce.TaxonGroupId__c = 'Diagnosis';
        insert parentProce;  
        
        CS_ARContactsService.c_getAllRelatedProcedures(String.valueOf(parentProce.Name));
        
        // Orthobiologics
        parentProce=new Procedure__c();
        parentProce.Name='Orthobiologics';
        parentProce.Product_Category__c = 'Knee';
        parentProce.TaxonGroupId__c = 'Diagnosis';
        insert parentProce;  
        
        CS_ARContactsService.c_getAllRelatedProcedures(String.valueOf(parentProce.Name));
        
        // Shoulder
        parentProce=new Procedure__c();
        parentProce.Name='Shoulder';
        parentProce.Product_Category__c = 'Shoulder';
        parentProce.TaxonGroupId__c = 'procedure';
        insert parentProce;  
        
        CS_ARContactsService.c_getAllRelatedProcedures(String.valueOf(parentProce.Name));
        
        // Knee
        parentProce=new Procedure__c();
        parentProce.Name='Knee';
        parentProce.Product_Category__c = 'Knee';
        parentProce.TaxonGroupId__c = 'procedure';
        insert parentProce;  
        
        CS_ARContactsService.c_getAllRelatedProcedures(String.valueOf(parentProce.Name));
        
        // Orthobiologics
        Procedure__c parentProceOrtho =new Procedure__c();
        parentProceOrtho.Name='Osteoarthritis';
        parentProceOrtho.Product_Category__c = 'Shoulder';
        parentProceOrtho.TaxonGroupId__c = 'Diagnosis';
        insert parentProceOrtho;  
               
        Procedure_Relationships__c procRel= new Procedure_Relationships__c();        
        procRel.Parent_Procedure__c=parentProceOrtho.Id;
        insert procRel;
        
        CS_ARContactsService.c_getAllRelatedProcedures(String.valueOf(parentProce.Name));
        
        // Arthritis
        Procedure__c parentProceArth =new Procedure__c();
        parentProceArth.Name='Arthritis';
        parentProceArth.Product_Category__c = 'Knee';
        parentProceArth.TaxonGroupId__c = 'Diagnosis';
        insert parentProceArth;  
        
        Procedure_Relationships__c procRelArth = new Procedure_Relationships__c();        
        procRelArth.Parent_Procedure__c=parentProceArth.Id;
        insert procRelArth;
                
        CS_ARContactsService.c_getAllRelatedProcedures(String.valueOf(parentProce.Name));
        
        // Arthritis
        Procedure__c parentProceOs = new Procedure__c();
        parentProceOs.Name='Osteoarthritis';
        parentProceOs.Product_Category__c = 'Shoulder';
        parentProceOs.TaxonGroupId__c = 'Diagnosis';        
        insert parentProceOs;  
        
        List<Procedure__c> lstChildP = [SELECT Id FROM Procedure__c WHERE TaxonGroupId__c = 'procedure'   
                                                        AND Product_Category__c = 'Shoulder'
                                                        ORDER BY Name];
        Procedure_Relationships__c procRelArth1 = new Procedure_Relationships__c();        
        procRelArth1.Parent_Procedure__c=parentProceOs.Id;
        procRelArth1.Child_Procedure__c = lstChildP[0].id;
        insert procRelArth1;
        
        CS_ARContactsService.c_getAllRelatedProcedures('Shoulder');
        
        
        // Arthritis
        Procedure__c parentProceKnee = new Procedure__c();
        parentProceKnee.Name='Arthritis';
        parentProceKnee.Product_Category__c = 'Knee';
        parentProceKnee.TaxonGroupId__c = 'Diagnosis';        
        insert parentProceKnee;  
        
        List<Procedure__c> lstChildPKnee = [SELECT Id FROM Procedure__c WHERE TaxonGroupId__c = 'procedure'   
                                                        AND Product_Category__c = 'Knee'
                                                        ORDER BY Name];
        Procedure_Relationships__c procRelArth2 = new Procedure_Relationships__c();        
        procRelArth2.Parent_Procedure__c=parentProceKnee.Id;
        procRelArth2.Child_Procedure__c = lstChildPKnee[0].id;
        insert procRelArth2;
        
        CS_ARContactsService.c_getAllRelatedProcedures('Knee');
        
        
    }//end of testc_getAllRelatedProcedures
    
    static testMethod void testc_getAllRelatedSurgicalTechniques(){
        
        //testData();
        list<Procedure__c> lstProcedures = new list<Procedure__c>();
        lstProcedures = CS_ARContactsService.c_getAllRelatedSurgicalTechniques(null);
        System.assertNotEquals(null, lstProcedures );
    }// end of testc_getAllRelatedSurgicalTechniques
    
    static testMethod void testc_getAllProductTeams(){
        
        CS_ARContactsService.c_getAllProductTeams(); 
    }// end of testc_getAllProductTeams
    
    static testMethod void testc_CheckIfProcedureAlreadyExists(){
        
        //testData();
        parentProcedure = [select id, Name from Procedure__c where Parent_Name__c = null LIMIT 1];
        CS_ARContactsService.c_CheckIfProcedureAlreadyExists(parentProcedure.Id);
        Procedure__c proc = CS_ARContactsService.c_CheckIfProcedureAlreadyExists(parentProcedure.Name);
        System.assertNotEquals(proc , null);
        
    }// end of testc_CheckIfProcedureAlreadyExists
    
    static testMethod void testretrieveOpportunitiesByAccountId() {
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        CS_ARContactsService.retrieveOpportunitiesByAccountId(practitioner.id);
    }// end of testretrieveOpportunitiesByAccountId
    
    static testMethod void testcreateAccCaseHistoryWrapper() {  
        Case__History objAccCaseFieldHistory = new Case__History();
        objAccCaseFieldHistory.Field = 'created';
        CS_ARContactsService.createAccCaseHistoryWrapper(objAccCaseFieldHistory, null);
        
        objAccCaseFieldHistory = new Case__History();
        objAccCaseFieldHistory.Field = 'Owner';
        CS_ARContactsService.createAccCaseHistoryWrapper(objAccCaseFieldHistory, null);      
    }// end of testcreateAccCaseHistoryWrapper
    
    static testMethod void testretrieveAccountActivity() {        
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        
        List<Case__c> caseList = [select  id from Case__c];
        for(Case__c cs: caseList){
            cs.Health_Care_Provider__c = healthCareProviderAccount.id;
            cs.Practitioner__c = practitioner.id;
            Case__History objCaseHistory = new Case__History();
            objCaseHistory.ParentId = cs.Id;
            objCaseHistory.Field = 'created';
        }
        update caseList;
        
        Note objNote = new Note();
        objNote.ParentId = healthCareProviderAccount.id;
        objNote.body = 'test';
        objNote.Title = 'Test Title';
        insert objNote;
        
        Task objTask = new Task();
        objTask.Whatid = healthCareProviderAccount.id;
        objTask.OwnerId = UserInfo.getUserId();
        objTask.Subject='Donni';
        objTask.Status='Not Started';
        objTask.Priority='Normal';
        insert objTask;
        
        Opportunity opp = new Opportunity();
        opp.Accountid = healthCareProviderAccount.id;
        opp.name = 'test opp 1';
        opp.StageName = 'test';
        opp.LeadSource = 'Google';        
        opp.CloseDate = date.today();                                
        insert opp;
        
        Opportunity_Surgeons__c objOppSur = new Opportunity_Surgeons__c();
        objOppSur.Opportunity__c = opp.id;
        objOppSur.Surgeon__c = healthCareProviderAccount.id;
        insert objOppSur;
        
        CS_ARContactsService.retrieveAccountActivity('All Activities', healthCareProviderAccount.id);
        
        CS_ARContactsService.retrieveAccountActivity('Log', healthCareProviderAccount.id);
        
        List<Account> lstAcc = [select id, (select id from Cases1__r) from account where id =: practitioner.id];
        system.assertEquals(lstAcc[0].Cases1__r.size() > 0, true);
        CS_ARContactsService.retrieveAccountActivity('Surgical Case', practitioner.id);
        
        CS_ARContactsService.retrieveAccountActivity('Surgical Case', healthCareProviderAccount.id);
        
        CS_ARContactsService.retrieveAccountActivity('Note', healthCareProviderAccount.id);
        
        CS_ARContactsService.retrieveAccountActivity('Task', healthCareProviderAccount.id);
        
        CS_ARContactsService.retrieveAccountActivity('OPPORTUNITY', healthCareProviderAccount.id);
    }//end of testretrieveAccountActivity
    
    static testMethod void testcreateNote() {
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
           
        CS_ARContactsService.createNote(practitioner.id, 'Test Note');
    }//end of testcreateNote
    
    static testMethod void testupdateNote() {
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        
        Note objNote = new Note();
        objNote.ParentId = practitioner.id;
        objNote.body = 'test';
        objNote.Title = 'Test Title';
        insert objNote;
        CS_ARContactsService.updateNote(objNote.id, 'test note');
        
        CS_ARContactsService.deleteNote(objNote.id);
    }//end of testupdateNote
    
    static testMethod void testretrieveSurgeonRelatedContacts() {        
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        CS_ARContactsService.retrieveSurgeonRelatedContacts(healthCareProviderAccount.id);
        
        List<Surgeon_Related_Contacts__c> lstSurgeonRelatedCon = [select id, Surgeon__c from Surgeon_Related_Contacts__c LIMIT 1];
        CS_ARContactsService.retrieveSurgeonRelatedContacts(lstSurgeonRelatedCon[0].Surgeon__c);
        
    }//end of testretrieveSurgeonRelatedContacts
    
    static testMethod void testcsavePractitionerPreferenceCards() {        
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        
        List<String> lstProcedureIds = new List<STring>();
        List<String> lstSurgTechIds = new List<STring>();
        
        practitionerprocedure = [select id, Name from Practitioner_Procedure__c LIMIT 1];
        parentProcedure = [select id, Name from Procedure__c where Parent_Name__c = null LIMIT 1];
        lstProcedureIds.add(String.valueOf(parentProcedure.Id) + '::'  + String.valueOf(parentProcedure.Id) + '::' + String.valueOf(parentProcedure.Name) + '::' +  String.valueOf(parentProcedure.Name));        
        //Code added by Ansu R2.2 FOR increasing code coverage
        lstProcedureIds.add(String.valueOf(parentProcedure.Id) + '::'  + String.valueOf(parentProcedure.Id)+'newId' + '::' + String.valueOf(parentProcedure.Name) + '::' +  String.valueOf(parentProcedure.Name));        
        
        parentProcedure = [select id from Procedure__c where Parent_Name__c = null LIMIT 1];
       
        childProcedure = [select id, Name from Procedure__c WHERE id !=: parentProcedure.id LIMIT 1];
       
        lstSurgTechIds.add(String.valueOf(childProcedure.Id) + '::'+ String.valueOf(childProcedure.Id) + '::' + String.valueOf(childProcedure.Name) + '::' + String.valueOf(childProcedure.Name));
       
        List<Practitioner_Procedure_Products__c> prefCardProdList = [select id from Practitioner_Procedure_Products__c];
       
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        
        CS_ARContactsService.csavePractitionerPreferenceCards(null, 'Test Pref Card', practitioner.id, lstProcedureIds, lstSurgTechIds, null, null, null, null, null, null, prefCardProdList);
        
        List<Practitioner_Procedure__c> lstPP = [SELECT id FROM Practitioner_Procedure__c LIMIT 1];
        CS_ARContactsService.csavePractitionerPreferenceCards(lstPP[0].id, 'Test Pref Card', practitioner.id, lstProcedureIds, lstSurgTechIds, null, null, null, null, null, null, prefCardProdList);
    
        List<Preference_Card_Procedures__c> lstPCP = [SELECT Preference_Card__c FROM Preference_Card_Procedures__c WHERE Preference_Card__c != null];
        CS_ARContactsService.csavePractitionerPreferenceCards(lstPCP[0].Preference_Card__c, 'Test Pref Card', practitioner.id, lstProcedureIds, lstSurgTechIds, null, null, null, null, null, null, prefCardProdList);
    
    }//end of testcsavePractitionerPreferenceCards
    
    static testMethod void testcheckIfProductActive() {  
        string strproductId = '';
        CS_ARContactsService.checkIfProductActive(strproductId);
    }//end of testcheckIfProductActive
    
    static testMethod void testsaveRelatedContact() {
        
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        Account objSurgeonContact = [SELECT id FROM account WHERE Recordtype.Name =: Constant.RECORDTYPE_NAME_SURGEON_CONTACT];
        
        Map<String,Object> accountMap = new Map<String,Object>();
        //accountMap.Put('id', healthCareProviderAccount.id);
        accountMap.Put('firstName', 'test firstName');
        accountMap.Put('lastName', 'test lastName');
        accountMap.Put('email', 'test@test.com');
        accountMap.Put('phone', '1234567890');
        accountMap.Put('mobile', '1234567890');
        accountMap.Put('street', 'test street');
        accountMap.Put('city', 'test city');
        accountMap.Put('state', 'New York');
        accountMap.Put('zip', '12345');
        accountMap.Put('accountId', practitioner.id);
        accountMap.Put('title', 'test title');
        accountMap.Put('notes', 'test note');
        portalUser=[Select Id from User where Profile.Name=:'AXIS Partner Community User' and email=:'testsalesrep@arthrex.com' limit 1];
       
        System.runAs(portalUser){
            CS_ARContactsService.saveRelatedContact(accountMap);
            
            accountMap.Put('id', objSurgeonContact.id);
            accountMap.Put('email', 'testpracttt_1111@test.com');
            CS_ARContactsService.saveRelatedContact(accountMap);
        }
    }//end of testsaveRelatedContact
    
    static testMethod void testRetrieveAccountAffiliationsByPractitioner(){
        
        //testData();
        practitioner = [select id from Account where name = 'TestPractitionerFirstName TestPractitionerLastName' limit 1];
        
        list<Affiliation__c> lstAffilations = new list<Affiliation__c>();
        CS_ARContactsService.cls_RetrieveAccountAffiliationsByPractitioner clsaccountwrap= new CS_ARContactsService.cls_RetrieveAccountAffiliationsByPractitioner();
        lstAffilations = clsaccountwrap.c_retrieveAccountAffiliationsByPractitioner(practitioner.Id);
        System.assertNotEquals(null, lstAffilations );
        
        lstAffilations = clsaccountwrap.c_retrieveAccountAffiliationsByPractitioner(null);
    } // end of testRetrieveAccountAffiliationsByPractitioner
    
    //Coded added by Ansu for release 2.2/CID000065 
    static testMethod void testRetrievePractitionersRelatedToAccount(){
        
        //testData();
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        list<Affiliation__c> lstAffilations = new list<Affiliation__c>();
        CS_ARContactsService.cls_RetrieveSurgeonAffiliationsByAccount cls_surgeonwrap=new CS_ARContactsService.cls_RetrieveSurgeonAffiliationsByAccount();
        lstAffilations = cls_surgeonwrap.retrieveSurgeonAffiliationsByAccount(healthCareProviderAccount.Id);
        
        System.assertNotEquals(null, lstAffilations );
        lstAffilations = cls_surgeonwrap.retrieveSurgeonAffiliationsByAccount(null);
    }// end of testRetrievePractitioners
   
    static testMethod void testDeleteProviderContactc(){
        
        //testData();
        providerContact = [select id from Contact where Lastname = 'providerContact' LIMIT 1];
        List<Id> availProviderIds = CS_ARTerritoryService.retrieveHealthCareProvidersInMyTeamTerritory();
        if(!availProviderIds.isEmpty())
        {
            CS_ARContactsService.retrieveProvider(String.valueOf(availProviderIds[0]));
            System.debug('Enters=======');
        }
        // CS_ARContactsService.deleteProviderContact(providerContact.Id);
        CS_ARContactsService.deleteProviderContactc delCon=new  CS_ARContactsService.deleteProviderContactc();
         delCon.deleteContacts(providerContact);
        list<Practitioner_Procedure_Products__c> lstPractitionerProcedureProducts = new list<Practitioner_Procedure_Products__c>();
        list<CS_ARContactsService.CS_PreferenceCardProceduresWrapper> p_lstPrefCardProcs= new list<CS_ARContactsService.CS_PreferenceCardProceduresWrapper> ();
        
        practitionerprocedure = [select id from Practitioner_Procedure__c LIMIT 1];
        CS_ARContactsService.retrievePractitionerPrefCard(practitionerprocedure.Id);
        CS_ARContactsService.CS_PreferenceCardWrapper prefwrap= new CS_ARContactsService.CS_PreferenceCardWrapper(practitionerprocedure,p_lstPrefCardProcs);
        Procedure__c parentProce=new Procedure__c();
        parentProce.Name='Arthritis';
        parentProce.Product_Category__c = 'Knee';
        parentProce.TaxonGroupId__c = 'Diagnosis';
        insert parentProce;        
        childProcedure = [select id from Procedure__c where Name = 'elbowTest' and Parent_Name__c = null LIMIT 1];
        childProcedure.Parent_Name__c=parentProce.Id;
        update childProcedure;
        
        Procedure_Relationships__c procRel= new Procedure_Relationships__c();        
        procRel.Parent_Procedure__c=parentProce.Id;
        procRel.Child_Procedure__c=childProcedure.Id;
        insert procRel;
        
       
        List<Procedure__c> lstOrigProds = new List<Procedure__c>();        
        parentProce.Name='Shoulder';
        parentProce.TaxonGroupId__c = 'team';
        childProcedure.Name='Knee&Hip';
        childProcedure.TaxonGroupId__c = 'team';
        lstOrigProds.add(parentProce);
        lstOrigProds.add(childProcedure);
        update lstOrigProds;        
        
        CS_ARContactsService.getPickValues(new Account(), 'Business_Hours_Start__c', '1:00AM');
        CS_ARContactsService.CS_PreferenceCardProceduresWrapper prefProcWrap= new CS_ARContactsService.CS_PreferenceCardProceduresWrapper();
           
    }// end 
    static testMethod void testgeoCodeFakeRes(){
        
         test.startTest();
        Test.setMock(HttpCalloutMock.class, new CS_ARContactsServiceTest());
        CS_ARContactsService.geocodeAsync( null, //String id, 
                                                                                '1370 Creekside Blvd.', //String street, 
                                                                                'Florida', //String state, 
                                                                                'Naples', //String city, 
                                                                                '34108', //String postalCode,
                                                                                'United States');//String country );
         test.stopTest();
    }
    
    static testMethod void testAccountWrapper(){
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        
        CS_ARContactsService.CS_AccountActivityWrapper accWrapp = new CS_ARContactsService.CS_AccountActivityWrapper(null, null, system.now(), null, null, null);
       
        CS_ARContactsService.AccountWrapper objAccWrap = new CS_ARContactsService.AccountWrapper(accWrapp);

        objAccWrap.compareTo(objAccWrap);
    }//end of testAccountWrapper
    
    static testMethod void testdeletePractitionerProcProds(){
        list<Practitioner_Procedure_Products__c> lstPractitionerProcedureProds = new List<Practitioner_Procedure_Products__c>();
        CS_ARContactsService.deletePractitionerProcProds objDelPP = new CS_ARContactsService.deletePractitionerProcProds();
        objDelPP.c_deletePractitionerProcProds(lstPractitionerProcedureProds);
    }//end of testdeletePractitionerProcProds
    
    static testMethod void testc_saveSurgeonProfilePicWrapper(){
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        
        CS_ARContactsService.saveSurgeonProfilePicWrapper objSaveSP = new CS_ARContactsService.saveSurgeonProfilePicWrapper();
        objSaveSP.c_saveSurgeonProfilePicWrapper(healthCareProviderAccount.id, 'test body');
    }//end of testc_saveSurgeonProfilePicWrapper
    
    static testMethod void testc_deleteSurgeonProfilePic(){
        healthCareProviderAccount = [select id from Account where name = 'Test HCP Account' limit 1];
        
        CS_ARContactsService.deleteSurgeonProfilePicWrapper objDelSP = new CS_ARContactsService.deleteSurgeonProfilePicWrapper();
        objDelSP.c_deleteSurgeonProfilePic(healthCareProviderAccount.id);
    }//end of testc_deleteSurgeonProfilePic
    
}