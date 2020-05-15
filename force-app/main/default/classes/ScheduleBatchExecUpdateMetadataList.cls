////////////////////////////////////////////////////////////////////
//Type                   :  Schedule Class
//Name                   :  ScheduleBatchExecUpdateMetadataList
//Company                :
//Created By             :  
//Created Date           :  11/03/2015
//Last Modified By       :  
//Last Modified Date     :  
//Description            :  This apex class is used to schedule the batch class "BatchExecUpdateMetadataList".
/////////////////////////////////////////////////////////////////////
global class ScheduleBatchExecUpdateMetadataList implements schedulable{
    global void execute(SchedulableContext sc){
        List<Object__c> lstobj = new List<Object__c>();
        Object__c obj = new Object__c();
        lstobj.add(obj);
        BatchExecUpdateMetadataList batchApex = new BatchExecUpdateMetadataList(lstobj);
        Database.executeBatch(batchApex,200);           
    }
}