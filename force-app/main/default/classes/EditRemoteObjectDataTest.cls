@isTest
private class EditRemoteObjectDataTest 
{
    static testMethod void myUnitTest() 
    {
    	String SESSION_ID = '00D90000000YYpr!AQkAQGItxGayPzRLb3g2z96MsVuJnidnW2fZAUpNEKcq_i5tjmV_oj.eZZHn90l0A9PbZtgvuTIVUlahKDPYqgXuhR5Y9Md4';
        String SERVER_URL = 'https://ap1-api.salesforce.com/services/Soap/u/21.0/00D90000000YYpr';
        
    	ApexPages.currentPage().getParameters().put('cid', '00190000000O9vC');
        ApexPages.currentPage().getParameters().put('sid', SESSION_ID);
        ApexPages.currentPage().getParameters().put('surl', SERVER_URL);
        ApexPages.currentPage().getParameters().put('client', 'Client');
        ApexPages.currentPage().getParameters().put('oname', 'Account');
        ApexPages.currentPage().getParameters().put('fields', 'Name');
        System.assertEquals(ApexPages.currentPage().getParameters().get('fields'), 'Name');
        Test.startTest();
        EditRemoteObjectData obj = new EditRemoteObjectData();
        obj.lstColumn.addAll(new List<String>{'Id, Name'});
        obj.updateRecord();
        Test.stopTest();
    }
}