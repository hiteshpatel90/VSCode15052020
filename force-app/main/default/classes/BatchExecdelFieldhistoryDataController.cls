///////////////////////////////////////////////////////////////////
//Name                   :  BatchExecdeleteFieldhistoryDataController
//Created by             :  
/////////////////////////////////////////////////////////////////////

global class BatchExecdelFieldhistoryDataController implements Database.Batchable<sObject>,  Database.AllowsCallouts{
    global final String Query;    
    global BatchExecdelFieldhistoryDataController(String q){    
        this.query = q;
    }    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Field_History__c> existingFHData = (List<Field_History__c>)scope;
        delete existingFHData;
    }
    global void finish(Database.BatchableContext BC) {       
    }      
}