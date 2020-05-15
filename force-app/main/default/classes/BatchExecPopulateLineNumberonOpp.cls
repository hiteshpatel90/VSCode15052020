///////////////////////////////////////////////////////////////////
//Name                   :  BatchExecPopulateLineNumberonOpp
//Created by             :  
/////////////////////////////////////////////////////////////////////

global class BatchExecPopulateLineNumberonOpp implements Database.Batchable<sObject>,  Database.AllowsCallouts{
    global final String Query; 
    global static string strURL;   
    global BatchExecPopulateLineNumberonOpp(String q){    
        this.query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(OpportunityLineItem oli: (List<OpportunityLineItem>)scope){
            oli.Line_Number__c = 0;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
               
    }      
}