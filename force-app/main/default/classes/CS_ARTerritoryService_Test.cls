/**********************************************************
**Description: A test class for CS_ARProfileCC class
**Parameters:   None
**Returns:   None
**Author:    JBANDOJO - CloudSherpas Inc.
**Date Created:  07-APR-2016
**********************************************************/
@IsTest
public class CS_ARTerritoryService_Test {
    
    private static User portalUser;
    private static User adminUser;
    private static Account agencyAccount;
    private static Account healthCareProviderAccount;
    private static Contact portalUserContact;
    private static Account practitioner;
    private static Practitioner_Procedure__c practitionerprocedure;
    private static Product2 objProduct;
    private static Procedure__c parentProcedure;
    private static Procedure__c childProcedure;
    private static Procedure_Relationships__c objProcedureRel;  
    private static Territory2 objTerritory;
    
    @testSetup static void testData(){

        adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex.com', 'testadmin');
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        adminUser.UserRoleId = portalRole.Id;
        insert adminUser;
            
        system.runas(adminUser){
            DataFactoryCustomSetting.createCustomSettings();
            
            DataFactoryTerritory.setUpTerritoryForTestClasses();
            
            objTerritory = [SELECT Id FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1'];
            agencyAccount = DataFactoryAccount.createAgencyAccount('Test Agency Account');
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
            
            portalUser = DataFactoryUser.preparePortalUser();
            portalUser.customer_number__c = 'ArthTest001';
            portalUser.ContactId = portalUserContact.Id;
            insert portalUser;
            
            UserTerritory2Association objTerrAssoc = new UserTerritory2Association(UserId = portalUser.Id,
                                                                                   Territory2Id = objTerritory.Id);
            insert objTerrAssoc;
            
            UserTerritory2Association objTerrAssoc1 = new UserTerritory2Association(UserId = adminUser.Id,
                                                                                   Territory2Id = objTerritory.Id);
            insert objTerrAssoc1;
        
            practitioner = DataFactoryAccount.createPractitionerAccount();
            insert practitioner;
            
            ObjectTerritory2Association objAssoc2 = new ObjectTerritory2Association(objectId = practitioner.Id,
                                                                                    Territory2Id = objTerritory.Id,
                                                                                    AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);
            insert objAssoc2;
            
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
        }
        
    }// end of testData.
    
    static testMethod void testRetrieveAccountIdsInMyTeamTerritory(){
        
        portalUser=[Select Id from User where Profile.Name=:'AXIS Partner Community User' and email=:'testsalesrep@arthrex.com' limit 1];
        Map<String,List<Id>> territoryMap = new Map<String,List<Id>>();
        System.runAs(portalUser)
        {
            Test.startTest();
            Account objAcc = [select id from Account LIMIT 1];
            
            List<Territory2> lstTerritory2 = [select id from Territory2 WHERE DeveloperName != 'TestTeamTerritory1' LIMIT 1];
            for(Territory2 tr: lstTerritory2){
                UserTerritory2Association objTerrAssoc3 = new UserTerritory2Association(UserId = portalUser.Id,
                                                                                   Territory2Id = tr.Id);
                insert objTerrAssoc3;
            
                ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = objAcc.Id,
                                                                                        Territory2Id = tr.id,
                                                                                        AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);  
                insert objAssoc;
            }
            Test.stopTest();
            territoryMap = CS_ARTerritoryService.retrieveAccountIdsInMyTeamTerritory();
            System.assertNotEquals(territoryMap, null);
        }                
    }// end of testRetrieveAccountIdsInMyTeamTerritory
    
    static testMethod void testretrieveAccountIdsInMyTeamTerritoryByRecordType(){
        
        objTerritory=[SELECT Id FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1' ];
        list<Id> lstHCPIds = new list<Id>();
        lstHCPIds = CS_ARTerritoryService.retrieveAccountIdsInMyTeamTerritoryByRecordType(string.Valueof(objTerritory.Id));
        System.assertNotEquals(lstHCPIds, null);
        
    }// end of testretrieveAccountIdsInMyTeamTerritoryByRecordType
    
    static testMethod void testRetrieveHealthCareProvidersInMyTeamTerritory(){
        
        list<Id> lstHCPIds = new list<Id>();
        lstHCPIds = CS_ARTerritoryService.retrieveHealthCareProvidersInMyTeamTerritory();
        System.assertNotEquals(lstHCPIds, null);
    }// end of testRetrieveHealthCareProvidersInMyTeamTerritory
    
    
    static testMethod void testRetrieveSurgeonsInMyTeamTerritory(){
        
        list<Id> lstHCPIds = new list<Id>();
        lstHCPIds = CS_ARTerritoryService.retrieveSurgeonsInMyTeamTerritory();
        System.assertNotEquals(lstHCPIds, null);
    }// end of testRetrieveHealthCareProvidersInMyTeamTerritory
    
    static testMethod void testMapObjectIdsToTerritories(){
        
        healthCareProviderAccount=[Select Id,Account_group__c from Account where Account_group__c =: 'Z002' and RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_HEALTH_CARE_PROVIDER).getRecordTypeId() limit 1];
        Map<Id,List<ObjectTerritory2Association>> assocMap = new Map<Id,List<ObjectTerritory2Association>>();
        list<Id> lstHCPIds = new list<Id>();
        lstHCPIds.add(healthCareProviderAccount.Id);
        assocMap = CS_ARTerritoryService.mapObjectIdsToTerritories(lstHCPIds);
        System.assertNotEquals(lstHCPIds, null);
        System.assertNotEquals(assocMap, null);
    }// end of testMapObjectIdsToTerritories
    
    static testMethod void testRetrieveChildTerritories(){
        
        objTerritory=[SELECT Id FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1' ];
        list<Id> lstTerritoryIds = new list<Id>();
        lstTerritoryIds = CS_ARTerritoryService.retrieveChildTerritories(objTerritory.Id);
        System.assertNotEquals(lstTerritoryIds, null);
    }// end of testRetrieveChildTerritories
    
    static testMethod void testRetreiveMyTerritoryNames(){
        
        list<string> lstTerritoryNames = new list<string>();
        lstTerritoryNames = CS_ARTerritoryService.retreiveMyTerritoryNames();
        System.assertNotEquals(lstTerritoryNames, null);
    }// end of testRetreiveMyTerritoryNames
    
    static testMethod void testMyTerritoryType(){
        portalUser=[Select Id from User where Profile.Name=:'AXIS Partner Community User' and email=:'testsalesrep@arthrex.com' limit 1];
        system.runas(portalUser){
            string territoryType = '';
            territoryType = CS_ARTerritoryService.myTerritoryType();
            System.assertEquals(territoryType, null);
        }
    }// end of testMyTerritoryType
    
    static testMethod void testParentTerritoryAndListTerritories(){
        
        map<Id, list<Territory2>> mapParentTerritoryAndListTerritories = new map<Id, list<Territory2>>();
        mapParentTerritoryAndListTerritories = CS_ARTerritoryService.parentTerritoryAndListTerritories();
        System.assertNotEquals(mapParentTerritoryAndListTerritories, null);
    }// end of testParentTerritoryAndListTerritories
    
    static testMethod void testTerritoryMapOfGivenIds(){
        
        objTerritory=[SELECT Id FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1' ];
        set<Id> setTerritoryIds = new set<Id>();
        setTerritoryIds.add(objTerritory.Id);
        Map<ID, Territory2> mapTerritories = new Map<ID, Territory2>();
        mapTerritories = CS_ARTerritoryService.TerritoryMapOfGivenIds(setTerritoryIds);
        System.assertNotEquals(mapTerritories, null);
    }// end of testTerritoryMapOfGivenId
    
    static testMethod void testRetreiveMyTerritoriess(){
        
        objTerritory=[SELECT Id FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1' ];
        list<string> lstMyTerritories= new list<string>();
        lstMyTerritories = CS_ARTerritoryService.retreiveMyTerritories(objTerritory.Id);
        System.assertNotEquals(lstMyTerritories, null);
    }// end of testRetreiveMyTerritoriess
    
    static testMethod void testRetrieveTerritoryNamesByUserId(){
        
        portalUser=[Select Id from User where Profile.Name=:'AXIS Partner Community User' and email=:'testsalesrep@arthrex.com' limit 1];
        list<string> lstMyTerritories= new list<string>();
        lstMyTerritories = CS_ARTerritoryService.retrieveTerritoryNamesByUserId(portalUser.Id);
        System.assertNotEquals(lstMyTerritories, null);
    }// end of testRetrieveTerritoryNamesByUserId
    
    static testMethod void testRetrieveUsersInMyTerritory(){
        
        list<User> lstUsersInMyTerritories= new list<User>();
        lstUsersInMyTerritories = CS_ARTerritoryService.retrieveUsersInMyTerritory();
        System.assertNotEquals(lstUsersInMyTerritories, null);
    }// end of testRetrieveUsersInMyTerritory
    
    static testMethod void testRetrieveUserIdsInMyTerritory(){
        
        objTerritory=[SELECT Id FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1' ];
        list<Id> lstUserIdsInMyTerritories= new list<Id>();
        lstUserIdsInMyTerritories = CS_ARTerritoryService.retrieveUserIdsInMyTerritory(objTerritory.Id);
        System.assertNotEquals(lstUserIdsInMyTerritories, null);
        lstUserIdsInMyTerritories = CS_ARTerritoryService.retrieveUserIdsInMyTerritory(null);
        System.assertNotEquals(lstUserIdsInMyTerritories, null);
    }// end of testRetrieveUserIdsInMyTerritory
    
    static testMethod void testRetrieveMyTerritoryIds(){
        User objUser = [select id from User where Username = 'testadmin@arthrex.com.arthrex.com'];
        system.runas(objUser){         
            list<Id> lstTerritoryIds = new list<Id>();
            lstTerritoryIds = CS_ARTerritoryService.retrieveMyTerritoryIds();
            System.assertNotEquals(lstTerritoryIds, null);
        }        
    }// end of testRetrieveMyTerritoryIds
    
    static testMethod void testRetrieveMyTerritoryIdsBoolean(){
        User objUser = [select id from User where Username = 'testadmin@arthrex.com.arthrex.com'];
        system.runas(objUser){         
            list<Id> lstTerritoryIds = new list<Id>();
            lstTerritoryIds = CS_ARTerritoryService.retrieveMyTerritoryIds(true);
            System.assertNotEquals(lstTerritoryIds, null);
        }
    }// end of testRetrieveMyTerritoryIdsBoolean
    
    static testMethod void testMapUserIdsToTerritories(){
        
        portalUser=[Select Id from User where Profile.Name=:'AXIS Partner Community User' and email=:'testsalesrep@arthrex.com' limit 1];
        list<Id> lstUserIds = new list<Id>();
        lstUserIds.add(portalUser.Id);
        Map<Id,List<UserTerritory2Association>> userAssocMap = new Map<Id,List<UserTerritory2Association>>();
        userAssocMap = CS_ARTerritoryService.mapUserIdsToTerritories(lstUserIds);
        System.assertNotEquals(userAssocMap, null);
    }// end of testMapUserIdsToTerritories
    
    /*public static testMethod void testprofile() {
        User u = CS_TestDataBuilder.CreateUser();
        insert u;
        
        System.runAs(u){
            Test.startTest();
            list<Territory2Type> terriType = [SELECT id, DeveloperName from Territory2Type where  DeveloperName = 'Arthrex'];
            
            Territory2Model tm = CS_TestDataBuilder.CreateTerritoryModel();
            insert tm;
            
            Territory2 t = CS_TestDataBuilder.CreateTerritory(tm.Id, terriType[0].Id);
            insert t;
            
            UserTerritory2Association ua= CS_TestDataBuilder.CreateUserTerritoryAssociation(u.Id, t.Id);
            insert ua;
            
            Default_Owner__c defaultOwner = new Default_Owner__c(Default_Owner__c=u.Id);
            insert defaultOwner;

            Account provider = CS_TestDataBuilder.CreateProvider();
            insert provider;
            
            Account practitioner = CS_TestDataBuilder.CreatePractitioner();
            insert practitioner;
            
            Product2 prod = CS_TestDataBuilder.CreateProduct();
            insert prod;
            
            Procedure__c procedure = CS_TestDataBuilder.CreateProcedure();
            insert procedure;
            
            Practitioner_Procedure__c practitionerprocedure = CS_TestDataBuilder.CreatePractitionerProcedure(practitioner.Id,procedure.Id );
            insert practitionerprocedure;
            
            Case__c cases = CS_TestDataBuilder.CreateCases(practitioner.Id, provider.Id, prod.Id);
            insert cases;
            
            list<Id> cList = new List<Id>();
            cList.add(cases.Id);
            
            CS_ARTerritoryService.retrieveMyTerritoryIds();
            CS_ARTerritoryService.retrieveAccountIdsInMyTeamTerritoryByRecordType(provider.RecordType.Name);
            CS_ARTerritoryService.retrieveHealthCareProvidersInMyTeamTerritory();
            CS_ARTerritoryService.retrieveSurgeonsInMyTeamTerritory();
            CS_ARTerritoryService.mapObjectIdsToTerritories(cList);
            
            Test.stopTest();
        }

    }*/
    
    static testMethod void testRetreiveMyTerritoryID(){
        User objUser = [select id from User where Username = 'testadmin@arthrex.com.arthrex.com'];
        system.runas(objUser){
            Id territoryId;
            territoryId = CS_ARTerritoryService.retrieveMyTerritoryId();
            System.assertNotEquals(territoryId, null);
        }
    }// end of testRetreiveMyTerritoryIDs
    
    static testMethod void testRetrieveMyTerritory(){
        
        Territory2 terr;
        terr = CS_ARTerritoryService.retrieveMyTerritory();
        System.assertNotEquals(terr, null);
    }// end of testRetrieveMyTerritory
    
    static testMethod void testRetrieveTerritoryForUser(){
        
        portalUser=[Select Id from User where Profile.Name=:'AXIS Partner Community User' and email=:'testsalesrep@arthrex.com' limit 1];
        List<String> terrlist=new List<String>() ;
        terrlist = CS_ARTerritoryService.retrieveTerritoryForUser(String.ValueOf(portalUser.Id));
        System.assertNotEquals(terrlist, null);
    }// end of testRetrieveMyTerritory

    static testMethod void testRetreiveMyTerritoryIDs(){
        
        List<String> terrlist=new List<String>() ;
        terrlist = CS_ARTerritoryService.retreiveMyTerritoryIDs();
        System.assertNotEquals(terrlist, null);
    }// end of testRetreiveMyTerritoryIDs
    static testMethod void testRetrieveMyTerritories(){
        
        List<Territory2> terrlist=new List<Territory2>() ;
        terrlist = CS_ARTerritoryService.retrieveMyTerritories();
        System.assertNotEquals(terrlist, null);
    }// end of testRetrieveMyTerritories
    static testMethod void testRetrieveMyParentTerritories(){
        
        List<Id> terrIdlist=new List<Id>() ;
        terrIdlist = CS_ARTerritoryService.retrieveMyParentTerritories();
        System.assertNotEquals(terrIdlist, null);
    }// end of testRetrieveMyTerritories
    
    static testMethod void testRetrieveTerritoryIdsForUser(){
        
        set<Id> terrIdSet = new set<Id>();
        terrIdSet = CS_ARTerritoryService.retrieveTerritoryIdsForUser(system.userinfo.getuserid());
        System.assertNotEquals(terrIdSet, null);
    }// end of testRetrieveMyTerritories
    
    static testMethod void testRetrieveAccountIdsForGivenTerritories(){
        set<Id> setTerritoryIds = new set<Id>();
        List<Territory2> lstTerritory2 = [select id from Territory2];
        for(Territory2 t2: lstTerritory2){
            setTerritoryIds.add(t2.id);
        }        
        
        set<Id> setAccIds = new set<Id>();
        setAccIds = CS_ARTerritoryService.retrieveAccountIdsForGivenTerritories(setTerritoryIds);
        System.assertNotEquals(setAccIds, null);
    }// end of testRetrieveMyTerritories   
}