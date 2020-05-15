@isTest
private class FetchRemoteObjectDataControllerTest {

    static testMethod void testFetchRemoteObjectDataController() 
    {
    	List<Client_Detail__c> lstCD = new List<Client_Detail__c>();
        Client_Detail__c objCD = new Client_Detail__c(Name = 'Client', UserName__c = 'test@test.com', Password__c = 'test1234');
        lstCD.add(objCD);
        Client_Detail__c objCD1 = new Client_Detail__c(Name = 'Client1', UserName__c = '', Password__c = 'test1234');
        lstCD.add(objCD1);
        insert lstCD;
        
        System.assertEquals(objCD1.Name, 'Client1');
        Test.startTest();
        
        ObjectMetadata objObjectMetadata = new ObjectMetadata();
        FieldMetadata objFieldMetadata = new FieldMetadata();
        Picklist objPicklist = new Picklist();
        ChildRelationshipMetadata objChildRelationshipMetadata = new ChildRelationshipMetadata();
        FetchRemoteObjectDataController objFRA = new FetchRemoteObjectDataController();
       	
       	objFRA.selectedClient = 'Test__Test';
        objFRA.fetchDetails();
        
        objFRA.selectedClient = '--None--';
        objFRA.fetchDetails();
        objFRA.selectedClient = 'Client1';
        objFRA.fetchDetails();
        objFRA.selectedClient = 'Client';
        objFRA.fetchDetails();
        
        objFRA.strRemoteObject = '--None--';
        objFRA.validateObjectWithUserOrg();
        objFRA.strRemoteObject = '--NoneAccount--';
        objFRA.validateObjectWithUserOrg();
        
        objFRA.strRemoteObject = 'Account';
        objFRA.validateObjectWithUserOrg();
        
        objFRA.addClassNameToTag();
        objFRA.lstSelectedFromRemoteObjectAllFieldName.addAll(new List<String>{'Id, Name'});
        objFRA.addClassNameToTag();
        
        objFRA.removeClassNameFromTag();
        objFRA.lstSelectedFieldName.addAll(new List<String>{'Id'});
        objFRA.removeClassNameFromTag();
        objFRA.lstColumn.addAll(new List<String>{'Id, Name'});
        objFRA.getResponse();
        Test.stopTest();
    }
}