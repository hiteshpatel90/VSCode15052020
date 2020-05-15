///////////////////////////////////////////////////////////////////
//Name                   :  BatchExecArchiveFieldhistoryDataCtrl
//Created by             :  
/////////////////////////////////////////////////////////////////////

global class BatchExecArchiveFieldhistoryDataCtrl implements Database.Batchable<sObject>,  Database.AllowsCallouts{
    global final String Query; 
    global static string strURL;   
    global BatchExecArchiveFieldhistoryDataCtrl(String q){    
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