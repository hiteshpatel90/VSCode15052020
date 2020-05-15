/**********************************************************
**Description: A test class for CS_ARAccountsCC controller class
**Parameters:   None
**Returns:   None
**Author:    Ansu Routray
**Date Created:  22-May-2017
**********************************************************/
@IsTest
public class CS_ARAccountCCTest {
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
            Account provider2 = CS_TestDataBuilder.CreateProvider();         
            insert provider2;

            insertTestTerritory(provider.Id,u.Id, t.Id);
            insertTestTerritory(provider2.Id,u.Id, t.Id);
            
            Product2 prod = CS_TestDataBuilder.CreateProduct();
            insert prod;
            
            Procedure__c procedure = CS_TestDataBuilder.CreateProcedure();
            insert procedure;
            lstProcedureIds.add( String.valueOf(procedure.Id) + '::' + String.valueOf(procedure.Id) + '::' + String.valueOf(procedure.Name) + '::' + String.valueOf(procedure.Name)  );
        
            
            Affiliation__c affiliation = CS_TestDataBuilder.CreateAffiliation(provider.Id ,practitioner.Id);
            insert affiliation;
            
            Affiliation__c affiliation1 = CS_TestDataBuilder.CreateAffiliation(provider.Id ,practitioner.Id);
            insert affiliation1;
            
            List<Id> productIds = new List<Id>();
            productIds.add(prod.Id);
            
            Note testNote=new Note();
            testNote.ParentId=provider.Id;
            testNote.Title='Account Note';
            testNote.Body='test notes';
            insert testNote;
            
            Contact cc=new Contact();
            cc.Firstname='Test';
            cc.LastName='Contact';
            cc.AccountId=provider.Id;
            insert cc;
            
            Affiliation__c aff=new Affiliation__c();
            aff.Account_p__c=practitioner.Id;
            aff.Account_hcp__c=provider.Id;
            insert aff;
            
            Account_Inventory__c accInv=new Account_Inventory__c();
            accInv.account__c=provider.Id;
            accInv.Low_Par__c=1;            
            insert accInv;
            
            Task newTask=new Task();
            newTask.Subject='Test Task22';
            insert newTask;
            
            CS_ARAccountsCC account = new CS_ARAccountsCC();
            CS_ARAccountsCC.retrieveProvider(provider.Id);
            CS_ARAccountsCC.retrieveProviders();
            CS_ARAccountsCC.retrieveOpportunitiesByAccountId(provider.Id);
            CS_ARAccountsCC.retrieveProviderContacts(provider.Id);
            CS_ARAccountsCC.retrieveSurgeonAffiliationsByAccount(provider.Id);
            CS_ARAccountsCC.retrieveTerritoryForPractitioners(provider.Id);
            CS_ARAccountsCC.retrieveTerritoryForPractitioner(provider.Id);
            CS_ARAccountsCC.retrieveBusinessHourValues();
            
            CS_ARAccountsCC.retrieveSterileProcessingHourValues();
            CS_ARAccountsCC.retrieveFiscalYearMonthValues();
            
            CS_ARAccountsCC.retrieveFiscalYearDayValues();
            CS_ARAccountsCC.retreiveActivities('All Activities',provider.Id);
            CS_ARAccountsCC.createNote(provider.Id,'Tes');
            CS_ARAccountsCC.updateNote(testNote.Id,'Tes');
            CS_ARAccountsCC.deleteNote(testNote.Id);
            list<Id> pracList=new list<Id>();
            pracList.add(practitioner.Id);
            CS_ARAccountsCC.saveSurgeonAffiliations(provider.Id,pracList);
            CS_ARAccountsCC.deleteSurgeonAffiliation(aff.Id);
            CS_ARAccountsCC.deleteProviderContact(cc.Id);
            Map<String,Object> conMap=new Map<String,Object>();
            conMap.put('Phone','9874563210');
            conMap.put('id',cc.Id);
            CS_ARAccountsCC.saveContact(conMap);
            CS_ARAccountsCC.retrieveAccountInventory(String.valueOf(provider.Id));
            CS_ARAccountsCC.searchProducts('ar-8');
            List<Account_Inventory__c> accInvList=new List<Account_Inventory__c>();
            //accInvList.add(accInv);
            CS_ARAccountsCC.csaveAccountInventory(provider.Id,'test','test','test','test','test',accInvList);
            Map<String,Object> accMap=new Map<String,Object>();
            accMap.put('Website','www.test.com');
            accMap.put('id',provider.Id);
            CS_ARAccountsCC.updateProvider(accMap);
            CS_ARAccountsCC.checkIfProductActive(prod.Id);
            CS_ARAccountsCC.retrievePractitioners();
            CS_ARAccountsCC.getTaskDetail(newTask.Id);
            CS_ARAccountsCC.updateTaskStatus(newTask.Id,'In Progress');
            List<Id> lstWhatIds=new List<Id>();
            List<Id> lstWhoIds=new List<Id>();
            lstWhatIds.add(provider.Id);
            lstWhoIds.add(u.Id);
            Task newTask2=new Task();
            newTask2.Subject='Test Task223';
            newTask2.Priority='High';
            newTask2.Status='In Progress';
            Map<String,String> taskDetails=new Map<String,String>();
            taskDetails.put('id',null);
            taskDetails.put('subject','Test Task223');
            taskDetails.put('priority','High');
            taskDetails.put('status','In Progress');
            taskDetails.put('ownerId',String.ValueOf(u.Id));
            taskDetails.put('type','LeadsApp');
            CS_ARAccountsCC.saveTask('General',lstWhatIds,null,taskDetails);
            Test.stopTest();
        }
        
        //CS_ARContactsCC.retrievePractitioner(practitioner.Id);
    }
    private static void insertTestTerritory(Id AccId, Id uId, Id t2Id){
            
            ObjectTerritory2Association oT2A = new ObjectTerritory2Association(ObjectId = AccId, Territory2Id =t2Id, AssociationCause='Territory2Manual' );
            insert oT2A;
    }
    
    
}