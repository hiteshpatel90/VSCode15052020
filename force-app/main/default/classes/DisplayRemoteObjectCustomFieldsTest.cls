@isTest
private class DisplayRemoteObjectCustomFieldsTest 
{
    static testMethod void testDisplayRemoteObjectCustomFields() 
    {
    	String SESSION_ID = '00D90000000YYpr!AQkAQGItxGayPzRLb3g2z96MsVuJnidnW2fZAUpNEKcq_i5tjmV_oj.eZZHn90l0A9PbZtgvuTIVUlahKDPYqgXuhR5Y9Md4';
        String SERVER_URL = 'https://ap1-api.salesforce.com/services/Soap/u/21.0/00D90000000YYpr';
        
        ApexPages.currentPage().getParameters().put('oname', 'Account');  
        ApexPages.currentPage().getParameters().put('sid', SESSION_ID);
        ApexPages.currentPage().getParameters().put('surl', SERVER_URL);
        System.assertEquals(ApexPages.currentPage().getParameters().get('surl'), SERVER_URL);
        DisplayRemoteObjectCustomFieldsDetail obj = new DisplayRemoteObjectCustomFieldsDetail();
    }
}