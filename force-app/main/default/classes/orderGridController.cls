public with sharing class orderGridController{
  
    // method for fetch account records list  
    @AuraEnabled
    public static List <Opportunity> fetchOpportunity(String strAccId) {
        
        List <Opportunity> returnList = new List <Opportunity> ();
        List <Opportunity> lstOfOpportunity = [select id, Name, StageName, Closedate, Amount, AccountId, Account.Name, (Select id, Product2.Name, Impressions__c, Domain__c, Quantity, Service_Start_Date__c, Service_End_Date__c, Program__c, Program_Year__c from OpportunityLineitems) from Opportunity WHERE AccountId =: strAccId];
        
        for (Opportunity opp: lstOfOpportunity) {
            returnList.add(opp);
        }
        return returnList;
    }
    
    // method for update records after inline editing  
    @AuraEnabled
    public static List <Opportunity> saveOpportunity(List<Opportunity> lstOpportunity, String strAccId) {
        
        update lstOpportunity;
        List <Opportunity> returnList = new List <Opportunity> ();
        List <Opportunity> lstOfOpportunity = [select id, Name, StageName, Closedate, Amount, AccountId, Account.Name, (Select id, Product2.Name, Impressions__c, Domain__c, Quantity, Service_Start_Date__c, Service_End_Date__c, Program__c, Program_Year__c from OpportunityLineitems) from Opportunity WHERE AccountId =: strAccId];
        
        for (Opportunity opp: lstOfOpportunity) {
            returnList.add(opp);
        }
        return returnList;
    }
    
    // method for fetch picklist values dynamic  
    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld) {
        system.debug('objObject --->' + objObject);
        system.debug('fld --->' + fld);
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        return allOpts;
    }
}