public with sharing class DataFactoryProcedures {
    
    public static Procedure__c createProcedure(){
        
        Procedure__c objProcedure = new Procedure__c(Name='elbowTest', 
                                                    Procedure_Name__c = 'elbowTest',
                                                    Synched__c = true,
                                                    TaxonGroupId__c='team', 
                                                    TaxonId__c='elbowTest');
                                                     
                                        
        return objProcedure;
    }// end of createHealthCareProviderAccount
    
    public static Procedure__c createChildProcedure(){
        
        Procedure__c objProcedure = new Procedure__c(Name='childelbowTest', 
                                                    Procedure_Name__c='childelbowTest', 
                                                     TaxonGroupId__c='diagnosis', 
                                                     Synched__c = true,
                                                     TaxonId__c='childelbowTest');
                                        
        return objProcedure;
    }// end of createHealthCareProviderAccount

}