public with sharing class overrideStandabuttonwithLC {
 
    @AuraEnabled
    public static ID saveCase(Case caseRec){
        try{
            insert caseRec;
        }
        catch(Exception e){
            system.debug('e-->' + e.getMessage());
        }
        
        return caseRec.Id;
    }  
       
}