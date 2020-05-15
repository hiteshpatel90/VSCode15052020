/**********************************************************
**Description: A test class for CS_ARContactsCC controller class
**Parameters:   None
**Returns:   None
**Author:    JBANDOJO - CloudSherpas Inc.
**Date Created:  16-FEB-2015
**********************************************************/
@IsTest
public class CS_ARContactsCCTest {
    private static User adminUser;
    private static Account practitioner;
     
    @TestSetup 
    static void setupData(){
        adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex.com', 'testadmin');
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        adminUser.UserRoleId = portalRole.Id;
        insert adminUser;
        system.runas(adminUser){
            DataFactoryCustomSetting.createCustomSettings();
            
            practitioner = DataFactoryAccount.createPractitionerAccount();
            insert practitioner;
            
            Account SurgeonContact = DataFactoryAccount.createSurgeonContact();
            insert SurgeonContact;
            
            Contact cont = new Contact();
            cont.FirstName='Test';
            cont.LastName='Test';
            insert cont;            
            
            Case caseObj = new Case();
            caseObj.ContactId = cont.id;
            caseObj.AccountId = practitioner.id;
            caseObj.Status = 'Working';
            caseObj.Origin = 'Phone';  
            caseObj.OwnerId = system.userinfo.getUserid();          
            insert caseObj;            
        }
    }
    
    
    @IsTest
    public static void testAllMethods() {
        User u = CS_TestDataBuilder.CreateUser();
        insert u;
        
        System.runAs(u){
            Test.startTest();
            list<String> lstProcedureIds = new list<String>();
            Default_Owner__c defaultOwner = new Default_Owner__c(Default_Owner__c=u.Id);
            insert defaultOwner;
            
            list<Territory2Type> terriType = [SELECT id, DeveloperName from Territory2Type where  DeveloperName = 'Arthrex' LIMIT 1];
            
            Territory2Model tm = CS_TestDataBuilder.CreateTerritoryModel();
            insert tm;
            
            Territory2 t = CS_TestDataBuilder.CreateTerritory(tm.Id, terriType[0].Id);
            insert t;
            
            UserTerritory2Association ua= CS_TestDataBuilder.CreateUserTerritoryAssociation(u.Id, t.Id);
            insert ua;
            
            Account practitioner = CS_TestDataBuilder.CreatePractitioner();
            insert practitioner;
            
            insertTestTerritory(practitioner.Id, u.Id, t.Id);
            Account provider = CS_TestDataBuilder.CreateProvider();         
            insert provider;

            insertTestTerritory(provider.Id,u.Id, t.Id);
            
            Product2 prod = CS_TestDataBuilder.CreateProduct();
            insert prod;
            
            Procedure__c procedure = CS_TestDataBuilder.CreateProcedure();
            insert procedure;
            lstProcedureIds.add( String.valueOf(procedure.Id) + '::' + String.valueOf(procedure.Id) + '::' + String.valueOf(procedure.Name) + '::' + String.valueOf(procedure.Name)  );
        
            
            Practitioner_Procedure__c practitionerprocedure = CS_TestDataBuilder.CreatePractitionerProcedure(practitioner.Id,procedure.Id );
            insert practitionerprocedure;

            CS_ARContactsCC.retrievePreferenceCards(practitioner.Id);
            
            
            Case__c c = CS_TestDataBuilder.CreateCases(practitioner.Id, provider.Id, prod.Id);
            insert c;
            
            Affiliation__c affiliation = CS_TestDataBuilder.CreateAffiliation(provider.Id ,practitioner.Id);
            insert affiliation;
            
            Affiliation__c affiliation1 = CS_TestDataBuilder.CreateAffiliation(provider.Id ,practitioner.Id);
            insert affiliation1;
            
            Note note = CS_TestDataBuilder.createNote(provider.Id, 'Test Note');
            insert note;
            
            List<Practitioner_Procedure_Products__c> prefCardProdList= CS_TestDataBuilder.createPrefCardProducts(prod.Id, practitionerprocedure.Id);
           
            
            
            CS_ARContactsCC.retrievePractitionerPrefCard(practitionerprocedure.Id);
            CS_ARContactsCC.retrievePreferenceCardProducts(practitionerprocedure.Id);
            
            CS_ARContactsCC.retrievePreferenceCards(practitioner.Id);
            CS_ARContactsCC.retrievePreferenceCards(practitioner.Id);

            CS_ARContactsCC.deletePractitionerProcedure(practitionerprocedure.Id);
                    
            Case_Products__c cproducts = CS_TestDataBuilder.CreateCaseProducts(c.Id,prod.Id);
            insert cproducts;
            
            CaseParticipant__c cparticipant = CS_TestDataBuilder.CreateCaseParticipant(c.Id,u.Id);
            insert cparticipant;

            String prefCardId = null;
            List<Id> productIds = new List<Id>();
            productIds.add(prod.Id);
            //Practitioner_Procedure__c newPrefCard
            
            CS_ARContactsService.CS_PreferenceCardWrapper  newPrefCard = CS_ARContactsCC.csavePractitionerProcedure(prefCardId, 
                                                                                                'testprefzz',
                                                                                                practitioner.Id, 
                                                                                                lstProcedureIds, //procedure.Id, 
                                                                                                null,
                                                                                                'disp', 
                                                                                                'equip',
                                                                                                'equipnotes', 
                                                                                                'meds', 
                                                                                                'sutures', 
                                                                                                'pos', 
                                                                                                productIds
                                                                                                );
                                                                                            
            prefCardId = newPrefCard.objPrefCard.Id;
            productIds.clear();
            newPrefCard = CS_ARContactsCC.csavePractitionerProcedure(prefCardId, practitioner.Id, 'testprefzz',
                                                                         lstProcedureIds, //procedure.Id, 
                                                                         null, 'disp', 'equip',
                'equipnotes', 'meds', 'sutures', 'pos', productIds);

            CS_ARContactsCC contact = new CS_ARContactsCC();
            CS_ARContactsCC.retrievePractitioners(1,1);
            CS_ARContactsCC.retrieveAreaOfInterestValues();
            CS_ARContactsCC.retrieveDesignationValues();
            CS_ARContactsCC.retrievePracticeFocusValues();
            CS_ARContactsCC.retrieveUserTypeValues();
            CS_ARContactsCC.retrieveSalutationValues();
            CS_ARContactsCC.retrieveGenderValues();
            CS_ARContactsCC.retrieveStateValues();
            
            CS_ARContactsCC.retrieveCasesByPractitioner(practitioner.Id);
            CS_ARContactsCC.retrieveProviders(1,1);
            
            CS_ARContactsCC.retrieveProviderContacts(provider.Id);
            // CS_ARContactsCC.searchUsers('Tes');
            CS_ARContactsCC.searchProducts('Tes');
            CS_ARContactsCC.searchProcedures('Tes');
            //CS_ARContactsCC.resolvePractitionerProcedureProducts(practitioner.Id,procedure.Id);
            CS_ARContactsCC.searchProviders('Tes');
            CS_ARContactsCC.retrieveCalendarEventDTOByCaseId(c.Id);
            CS_ARContactsCC.retrievePractitionerTasks(practitioner.Id);
           CS_ARContactsCC.searchPractitioners('Tes');
            CS_ARContactsCC.retrievePractitionerPrefCards(practitioner.Id);
            // CS_ARContactsCC.retrieveProductsByProcedure(procedure.Id);
            // CS_ARContactsCC.retrievePractitionerPrefCard(cpc.Id);
            CS_ARContactsCC.retrievePractitionersInTerritory();
            CS_ARContactsCC.retrieveProvidersInTerritory();
            CS_ARContactsCC.retrieveCaseParticipants(c.Id);
            CS_ARContactsCC.retrieveCaseProducts(c.Id);
            CS_ARContactsCC.retrieveCasePrefCards(c.Id);
            CS_ARContactsCC.saveNewSurgeonRequest('Tes','Tes','Tes');

            boolean isUnique = CS_ARContactsCC.isUniquePractitionerProcedureName(practitioner.Id, 'zzz');
            System.assertEquals(true, isUnique);

            List<Institution__c> insts = CS_ARContactsCC.searchInstitutions(null);
            System.assertEquals(0, insts.size());
            
            Map<String,Object> contactParams = new Map<String,Object>();
            contactParams.put('firstName','fname');
            contactParams.put('lastName','lname');
            contactParams.put('email','lname@somewhere.com');
            contactParams.put('accountId', provider.Id);
            Contact newContact = CS_ARContactsCC.saveContact(contactParams);

            //CS_ARContactsCC.deleteProviderContact(newContact.Id);


            Account pract = CS_ARContactsCC.retrievePractitioner(practitioner.Id);
            //System.assertNotEquals(null, pract);


            Map<String,Object> blank = new Map<String,Object>();
            blank.put('id', practitioner.Id);
            CS_ARContactsCC.updatePractitionerDemographics(blank);
            CS_ARContactsCC.updatePractitionerBio(blank);

            Map<String,Object> updateNick = new Map<String,Object>();
            updateNick.put('nickName','testnick');
            updateNick.put('id', provider.Id);
            CS_ARContactsCC.updateProvider(updateNick);
            
            //Code added by Mimansha for CID- 000064
            List<String> lstTerritory = CS_ARContactsCC.retrieveTerritoryForPractitioner(practitioner.Id);
            System.assertNotEquals(null, lstTerritory);
            
            //Retrieve Account Affiliations for Practitioner
            List<CS_ARContactsService.CS_AccountAffiliationWrapper> lstAffiliations = CS_ARContactsCC.retrieveAccountAffiliationsByPractitioner(practitioner.Id);
            
            System.assertNotEquals(null, lstAffiliations);
            
            //Save Account Affiliation Test
            list<Id> lstProviders = new list<Id>();
            lstProviders.add(provider.Id);            
            
            CS_ARContactsCC.saveAccountAffiliations(practitioner.Id, lstProviders); 
            
            //Delete Account Affiliation test
            CS_ARContactsCC.deleteAccountAffiliation(affiliation.Id);
            
            //Code added by Ansu for release 2.2/CID000065 code coverage
            CS_ARContactsCC.retrieveBusinessHourValues();
            CS_ARContactsCC.retrieveSterileProcessingHourValues();
            CS_ARContactsCC.retrieveFiscalYearMonthValues();
            CS_ARContactsCC.retrieveFiscalYearDayValues();
            //CS_ARContactsCC.retrieveSurgeonAffiliationsByAccount(provider.Id);
            CS_ARContactsCC.retrieveTerritoryForPractitioners(provider.Id);
            list<Id> lstSurgeons = new list<Id>();
            lstSurgeons.add(practitioner.Id);            
            
            CS_ARContactsCC.saveSurgeonAffiliations(provider.Id, lstSurgeons);
            CS_ARContactsCC.deleteSurgeonAffiliation(affiliation1.Id);
            //Code added by Ansu ends
            
            //Code added by Ansu for increasing code coverage release 2.2
            CS_ARContactsCC.retrieveProvider(provider.Id);
            CS_ARContactsCC cs=new CS_ARContactsCC();
            cs.getCurrentUserTimeZone();
            CS_ARContactsCC.searchSurgicalTechniques('A');
            CS_ARContactsCC.searchTaxonomy('A');
            CS_ARContactsCC.searchProcedures('A');
            CS_ARContactsCC.getAllProductTeams();
            CS_ARContactsCC.getAllRelatedProcedures(String.valueOf(procedure.Name));
            CS_ARContactsCC.getAllRelatedProcedures('Arthroplasty');
            CS_ARContactsCC.getAllRelatedProcedures('Orthobiologics');
            procedure.Product_Category__c='Shoulder';
            procedure.TaxonGroupId__c = 'procedure';
            update procedure;
            CS_ARContactsCC.getAllRelatedProcedures('Shoulder');
            CS_ARContactsCC.getAllRelatedSurgicalTechniques(String.valueOf(procedure.Name));
            CS_ARContactsCC.deleteProviderContact(newContact.Id);
            CS_ARContactsCC.retrievePractitionerPrefCardProducts(String.valueOf(practitionerprocedure.Id));
            Map<String,Object> params = new Map<String,Object>();
            params.put('encodedFileContents', 'data:image/jpeg;base64,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');
            params.put('fileMimeType', 'image/jpeg');
            params.put('fileName', 'prof1.jpg');
            //CS_ARContactsCC.updateProfilePicture(params ,practitioner.PersonEmail);
            //CS_ARContactsCC.retrievePractitionerPardotEmail(practitioner.PersonEmail);
            //CS_ARContactsCC.retrievePractitionerPardotActivities(practitioner.PersonEmail,false);
            //Code added by Ansu ends
            
            //Code added by Mimansha starts
            CS_ARContactsCC.deleteRelatedContact(newContact.Id);
            CS_ARContactsCC.retrieveOpportunitiesByAccountId(provider.Id);
            CS_ARContactsCC.checkIfProductActive(prod.Id);      
            CS_ARContactsCC.retrieveSurgeonRelatedContacts(provider.Id);
            CS_ARContactsCC.updateNote(note.Id, 'Updated Note Text');
            CS_ARContactsCC.deleteNote(note.Id); 
            CS_ARContactsCC.createNote(provider.Id, 'Create Test Note');
            Test.stopTest(); 
            newPrefCard = CS_ARContactsCC.csavePractitionerPreferenceCards(prefCardId, 'testprefzz',practitioner.Id,lstProcedureIds, //procedure.Id, 
                                                                                                null,'disp','equip',
                                                                                                'equipnotes','meds', 
                                                                                                'sutures','pos', prefCardProdList
                                                                                                );
            System.assertNotEquals(null, newPrefCard );
            /*
            String visitId = null;
            CS_ARContactsCC.retrievePractitionerPardotVisit(visitId);
            
            Map<String,Object> accountMap = new Map<String,Object>();
            accountMap.put('lastName','TestLastName');
            CS_ARContactsCC.saveRelatedContact(accountMap);
           */ 
           
            
            
            
            
        }
        
        //CS_ARContactsCC.retrievePractitioner(practitioner.Id);
    }
    private static void insertTestTerritory(Id AccId, Id uId, Id t2Id){
            
            ObjectTerritory2Association oT2A = new ObjectTerritory2Association(ObjectId = AccId, Territory2Id =t2Id, AssociationCause='Territory2Manual' );
            insert oT2A;
    }
    
    @IsTest
    public static void testupdateProfilePicture() {
            practitioner = [Select name from Account where RecordType.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER limit 1];
             
            Map<String,Object> params = new Map<String,Object>();
            params.put('encodedFileContents', 'data:image/jpeg;base64,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');
            params.put('fileMimeType', 'image/jpeg');
            params.put('fileName', 'prof1.jpg');
            CS_ARContactsCC.updateProfilePicture(params ,practitioner.Id);
        
    }
    
    @IsTest
    public static void updateTaskStatus_Test(){
        List<Case> caseList = [SELECT id, Ownerid, Owner.ProfileId, Owner.Profile.Name FROM Case LIMIT 1];
        caseList[0].OwnerId = system.userinfo.getuserid();
        update caseList[0];
        CS_ARContactsCC.updateTaskStatus(caseList[0].id, 'New');        
    }// End of updateTaskStatus_Test 
   
    @IsTest
    public static void saveSFTask_Test(){
        List<Case> caseList = [SELECT id, accountId FROM Case LIMIT 1];
        
        Map<String,String> taskDetails = new Map<String,String>();
        taskDetails.Put('accountId', caseList[0].accountId);
        taskDetails.Put('ownerId', system.userinfo.getuserid());
        
        CS_ARContactsCC.saveSFTask(null, null, taskDetails);        
    }// End of saveSFTask_Test 
    
    @IsTest
    public static void retrieveMyTaskDetail_Test(){
        List<Case> caseList = [SELECT id, Ownerid, Owner.ProfileId, Owner.Profile.Name FROM Case LIMIT 1];
        caseList[0].OwnerId = system.userinfo.getuserid();
        update caseList[0];
        system.assertEquals(caseList[0].Owner.Profile.Name, 'test');
        CS_ARContactsCC.retrieveMyTaskDetail(caseList[0].id);   
          
    }// End of retrieveMyTaskDetail_Test
    
    @IsTest
    public static void retreiveActivities_Test(){
        practitioner = [Select id from Account where RecordType.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER limit 1];          
        CS_ARContactsCC.retreiveActivities('Notes', practitioner.id);          
    }// End of retreiveActivities_Test
    
    @IsTest
    public static void retrievePractitionerPardotVisit_Test(){
        practitioner = [Select id from Account where RecordType.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER limit 1];          
        CS_ARContactsCC.retrievePractitionerPardotVisit(practitioner.id);          
    }// End of retrievePractitionerPardotVisit_Test
    
    
    @IsTest
    public static void saveSurgeonProfilePic_Test(){
        practitioner = [Select id from Account where RecordType.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER limit 1];          
        CS_ARContactsCC.saveSurgeonProfilePic(practitioner.id, 'Test');          
    }// End of deleteSurgeonProfilePic_Test
    
    @IsTest
    public static void deleteSurgeonProfilePic_Test(){
        practitioner = [Select id from Account where RecordType.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER limit 1];          
        CS_ARContactsCC.deleteSurgeonProfilePic(practitioner.id);          
    }// End of deleteSurgeonProfilePic_Test
}