/**********************************************************
**Description: A test class for CS_ARSearch class
**Parameters:   None
**Returns:   None
**Author:    JBANDOJO - CloudSherpas Inc.
**Date Created:  07-APR-2016
**********************************************************/
@IsTest
public class CS_ARSearchTest {
    
    @testSetup static void setupData() {
        
        User adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex.com', 'testadmin');
        insert adminUser;
        
        System.runAs(adminUser) {
            Default_Owner__c defaultOwner = new Default_Owner__c(Default_Owner__c=adminUser.Id);
            insert defaultOwner;

            Account provider = DataFactoryAccount.createHealthCareProviderAccount();
            provider.Account_group__c = 'Z002';
            provider.Active__c = true;
            provider.Preferred_Name__c = null;
            insert provider;

            Account practitioner = DataFactoryAccount.createPractitionerAccount();
            practitioner.Account_group__c = 'Z002';
            practitioner.Active__c = true;
            practitioner.Preferred_Name__c = null;
            insert practitioner;
            
            DataFactoryTerritory.setUpTerritoryForTestClasses();
            
            Territory2 objTerritory = [SELECT Id, Territory2ModelId FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1'];
            
            UserTerritory2Association objTerrAssoc = new UserTerritory2Association(UserId = adminUser.Id,
                                                                                   Territory2Id = objTerritory.Id);
            insert objTerrAssoc;
            
            ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = provider.Id,
                                                                                    Territory2Id = objTerritory.Id,
                                                                                    AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);
            insert objAssoc;
            
            objAssoc = new ObjectTerritory2Association(objectId = practitioner.Id,
                                                                                    Territory2Id = objTerritory.Id,
                                                                                    AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);
            insert objAssoc;
            
            Procedure__c procedure = CS_TestDataBuilder.CreateProcedure();
            insert procedure;
            
            Product2 objProduct = CS_TestDataBuilder.CreateProduct();
            insert objProduct;
            
            Case objCase = CS_TestDataBuilder.CreateCase();
            insert objCase;

            CaseParticipant__c participant = CS_TestDataBuilder.CreateCaseParticipant(objCase.Id,adminUser.Id);
            Case_Products__c caseProd = CS_TestDataBuilder.CreateCaseProducts(objCase.Id,objProduct.Id);
            Practitioner_Procedure__c pracProd = CS_TestDataBuilder.CreatePractitionerProcedure(provider.Id,procedure.Id);
            Contact objCont = CS_TestDataBuilder.CreateContact(provider.Id);
            Case__c customCase = CS_TestDataBuilder.CreateCases(provider.Id,provider.Id,objProduct.Id);
        }
    }

    public static testMethod void testSearch() {
        User u = [SELECT Id FROM User LIMIT 1];

        System.runAs(u){

            Test.startTest();

                CS_ARSearch.searchSurgeonsInMyTeamTerritory('');
                CS_ARSearch.searchSurgeonsInMyTeamTerritory('Health');
                CS_ARSearch.searchProvidersInMyTeamTerritory('');
                CS_ARSearch.searchProvidersInMyTeamTerritory('Health');

                CS_ARSearch.searchUsers('');
                CS_ARSearch.searchUsers('xyzzz');
                
                CS_ARSearch.searchInstitutions('');
                CS_ARSearch.searchInstitutions('pdqzz');


            Test.stopTest();
        }
    }

    @IsTest
    public static void testSearchQueryEscape() {

        String q = 'test';
        q = CS_ARSearch.escapeSearchTerm(q);
        System.assertEquals('test',q);

        q = 'test+';
        q = CS_ARSearch.escapeSearchTerm(q);
        System.assertEquals('test\\\\+',q);

        q = '!te-st+';
        q = CS_ARSearch.escapeSearchTerm(q);
        System.assertEquals('\\\\!te\\\\-st\\\\+',q);

        q = '';
        q = CS_ARSearch.escapeSearchTerm(q);
        System.assertEquals('',q);

        q = null;
        q = CS_ARSearch.escapeSearchTerm(q);
        System.assertEquals(null,q);
    }
    
    public static testMethod void searchProvidersInSelectedOwnerTerritorytest() {
        //CS_ARSearch.searchProvidersInSelectedOwnerTerritory(system.userinfo.getuserid());
        
        User adminUser = [Select Id from User where Profile.Name=:'System Administrator' and username=:'testadmin@arthrex.com.arthrex.com' limit 1];
        system.runAs(adminUser){
            Account objAcc = [select id from Account where Account_group__c = 'Z002' and Active__c = true LIMIT 1];
            
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
            
            CS_ARSearch.searchProvidersInSelectedOwnerTerritory(adminUser.id, lstTerritory2[0].Id);
            CS_ARSearch.searchSurgeonsInSelectedOwnerTerritory(adminUser.id, lstTerritory2[0].Id);
        }
    }//end of searchProvidersInSelectedOwnerTerritorytest
    
    public static testMethod void retriveMapAccountIdAndTerrirtoryNametest() {
        Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT id FROM Account]);
        CS_ARSearch.retriveMapAccountIdAndTerrirtoryName(mapAccount.keyset());
    }//end of searchProvidersInSelectedOwnerTerritorytest
    
    public static testMethod void searchSurgeonsInMyTeamTerritorytest() {
        Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT id FROM Account]);
        CS_ARSearch.searchSurgeonsInMyTeamTerritory();
        
    }//end of searchSurgeonsInMyTeamTerritorytest
    
    public static testMethod void searchSurgeonsInSelectedOwnerTerritorytest() {
        User adminUser = [Select Id from User where Profile.Name=:'System Administrator' and username=:'testadmin@arthrex.com.arthrex.com' limit 1];
        system.runAs(adminUser){
            Account objAcc = [select id from Account where RecordType.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER and Account_group__c = 'Z002' and Active__c = true LIMIT 1];
            
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
            
            CS_ARSearch.searchSurgeonsInSelectedOwnerTerritory(adminUser.id, lstTerritory2[0].id);
            CS_ARSearch.searchSurgeonsInSelectedOwnerTerritory(adminUser.id, '');
            CS_ARSearch.searchSurgeonsInSelectedOwnerTerritory('', '');
            CS_ARSearch.searchProvidersInSelectedOwnerTerritory(adminUser.id, lstTerritory2[0].id);
        }
        
    }//end of searchSurgeonsInSelectedOwnerTerritorytest
    
    
    public static testMethod void searchProvidersInMyTeamTerritorytest() {
      
        User adminUser = [Select Id from User where Profile.Name=:'System Administrator' and username=:'testadmin@arthrex.com.arthrex.com' limit 1];
        system.runAs(adminUser){
            Account provider = [select id from Account where Account_group__c = 'Z002' and Active__c = true LIMIT 1];
            
            List<Territory2> lstTerritory2 = [select id from Territory2 WHERE DeveloperName != 'TestTeamTerritory1' LIMIT 1];
            for(Territory2 tr: lstTerritory2){
                UserTerritory2Association objTerrAssoc3 = new UserTerritory2Association(UserId = adminUser.Id,
                                                                                   Territory2Id = tr.Id);
                insert objTerrAssoc3;
            
                ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = provider.Id,
                                                                                        Territory2Id = tr.id,
                                                                                        AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);  
                insert objAssoc;
            }
            
            CS_ARSearch.searchProvidersInMyTeamTerritory('');
            CS_ARSearch.searchProvidersInMyTeamTerritory('Health');
        }
        
    }//end of searchProvidersInMyTeamTerritorytest
    
    
    public static testMethod void searchHCOInMyTeamTerritorytest() {
        User adminUser = [Select Id from User where Profile.Name=:'System Administrator' and username=:'testadmin@arthrex.com.arthrex.com' limit 1];
        system.runAs(adminUser){
            List<UserTerritory2Association> lstUserTerritory = [SELECT Id, Territory2Id, Territory2.Territory2TypeId, Territory2.Territory2ModelId, UserId from UserTerritory2Association where IsActive = true and UserId =: userinfo.getUserId()];
            set<Id> sUserTerritoties = new set<Id>();
            
            Territory2 objTeamTerritory1 = new Territory2(DeveloperName = 'TestTeamTerritory_child1', 
                                                Territory2ModelId=lstUserTerritory[0].Territory2.Territory2ModelId, 
                                                Name='TestTeamTerritory_child1',  
                                                PARENTTERRITORY2ID = lstUserTerritory[0].Territory2Id,
                                                Territory2TypeId=lstUserTerritory[0].Territory2.Territory2TypeId,
                                                ACCOUNTACCESSLEVEL ='Edit',
                                                OPPORTUNITYACCESSLEVEL = 'Edit',
                                                CASEACCESSLEVEL = 'Edit');
            insert objTeamTerritory1;
            
            Territory2 objTeamTerritory2 = new Territory2(DeveloperName = 'TestTeamTerritory_child2', 
                                                Territory2ModelId=lstUserTerritory[0].Territory2.Territory2ModelId, 
                                                Name='TestTeamTerritory_child2',  
                                                PARENTTERRITORY2ID = objTeamTerritory1.id,
                                                Territory2TypeId=lstUserTerritory[0].Territory2.Territory2TypeId,
                                                ACCOUNTACCESSLEVEL ='Edit',
                                                OPPORTUNITYACCESSLEVEL = 'Edit',
                                                CASEACCESSLEVEL = 'Edit');
            insert objTeamTerritory2;
            
            Territory2 objTeamTerritory3 = new Territory2(DeveloperName = 'TestTeamTerritory_child3', 
                                                Territory2ModelId=lstUserTerritory[0].Territory2.Territory2ModelId, 
                                                Name='TestTeamTerritory_child3',  
                                                PARENTTERRITORY2ID = objTeamTerritory2.id,
                                                Territory2TypeId=lstUserTerritory[0].Territory2.Territory2TypeId,
                                                ACCOUNTACCESSLEVEL ='Edit',
                                                OPPORTUNITYACCESSLEVEL = 'Edit',
                                                CASEACCESSLEVEL = 'Edit');
            insert objTeamTerritory3;
            
            Territory2 objTeamTerritory4 = new Territory2(DeveloperName = 'TestTeamTerritory_child4', 
                                                Territory2ModelId=lstUserTerritory[0].Territory2.Territory2ModelId, 
                                                Name='TestTeamTerritory_child4',  
                                                PARENTTERRITORY2ID = objTeamTerritory3.id,
                                                Territory2TypeId=lstUserTerritory[0].Territory2.Territory2TypeId,
                                                ACCOUNTACCESSLEVEL ='Edit',
                                                OPPORTUNITYACCESSLEVEL = 'Edit',
                                                CASEACCESSLEVEL = 'Edit');
            insert objTeamTerritory4;
            
            Territory2 objTeamTerritory5 = new Territory2(DeveloperName = 'TestTeamTerritory_child5', 
                                                Territory2ModelId=lstUserTerritory[0].Territory2.Territory2ModelId, 
                                                Name='TestTeamTerritory_child5',  
                                                PARENTTERRITORY2ID = objTeamTerritory4.id,
                                                Territory2TypeId=lstUserTerritory[0].Territory2.Territory2TypeId,
                                                ACCOUNTACCESSLEVEL ='Edit',
                                                OPPORTUNITYACCESSLEVEL = 'Edit',
                                                CASEACCESSLEVEL = 'Edit');
            insert objTeamTerritory5;
            
            
            Territory2 objTeamTerritory6 = new Territory2(DeveloperName = 'TestTeamTerritory_child6', 
                                                Territory2ModelId=lstUserTerritory[0].Territory2.Territory2ModelId, 
                                                Name='TestTeamTerritory_child6',  
                                                PARENTTERRITORY2ID = objTeamTerritory5.id,
                                                Territory2TypeId=lstUserTerritory[0].Territory2.Territory2TypeId,
                                                ACCOUNTACCESSLEVEL ='Edit',
                                                OPPORTUNITYACCESSLEVEL = 'Edit',
                                                CASEACCESSLEVEL = 'Edit');
            insert objTeamTerritory6;
            
            Territory2 objTeamTerritory7 = new Territory2(DeveloperName = 'TestTeamTerritory_child7', 
                                                Territory2ModelId=lstUserTerritory[0].Territory2.Territory2ModelId, 
                                                Name='TestTeamTerritory_child7',  
                                                PARENTTERRITORY2ID = objTeamTerritory6.id,
                                                Territory2TypeId=lstUserTerritory[0].Territory2.Territory2TypeId,
                                                ACCOUNTACCESSLEVEL ='Edit',
                                                OPPORTUNITYACCESSLEVEL = 'Edit',
                                                CASEACCESSLEVEL = 'Edit');
            insert objTeamTerritory7;
            
            Territory2 objTeamTerritory8 = new Territory2(DeveloperName = 'TestTeamTerritory_child8', 
                                                Territory2ModelId=lstUserTerritory[0].Territory2.Territory2ModelId, 
                                                Name='TestTeamTerritory_child8',  
                                                PARENTTERRITORY2ID = objTeamTerritory7.id,
                                                Territory2TypeId=lstUserTerritory[0].Territory2.Territory2TypeId,
                                                ACCOUNTACCESSLEVEL ='Edit',
                                                OPPORTUNITYACCESSLEVEL = 'Edit',
                                                CASEACCESSLEVEL = 'Edit');
            insert objTeamTerritory8;
         
                
            CS_ARSearch.searchHCOInMyTeamTerritory();
        }
    }//end of searchHCOInMyTeamTerritorytest
    
}