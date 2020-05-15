public with sharing class DataFactoryInstitution {
    
    public static Institution__c createInstitution(string institutionName){
        
        Institution__c objInstitution = new Institution__c(Name= institutionName);
                                                     
                                        
        return objInstitution;
    }// end of createInstitution

}