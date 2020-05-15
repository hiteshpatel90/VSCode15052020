public with sharing class inlineEditCtrl {
  
    // method for fetch account records list  
    @AuraEnabled
    public static List <Opportunity> fetchOpportunity(String strAccId) {
        
        List <Opportunity> returnList = new List <Opportunity> ();
        List <Opportunity> lstOfOpportunity = [select id, Name, StageName, Closedate, Amount from Opportunity WHERE AccountId =: strAccId];
        
        for (Opportunity opp: lstOfOpportunity) {
            returnList.add(opp);
        }
        return returnList;
    }
    
  // method for update records after inline editing  
    @AuraEnabled
    public static List <Opportunity> saveOpportunity(List<Opportunity> lstOpportunity) {
        
        update lstOpportunity;
        return lstOpportunity;
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