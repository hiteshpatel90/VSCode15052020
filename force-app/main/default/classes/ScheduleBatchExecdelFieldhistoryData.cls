global class ScheduleBatchExecdelFieldhistoryData implements schedulable{
    global void execute(SchedulableContext sc){
        //String sQuery='select id from Field_History__c where createddate = LAST_MONTH';
        String sQuery='select id from Field_History__c where Integration_Status__c = \'Exported\'';
        BatchExecdelFieldhistoryDataController batchApex = new BatchExecdelFieldhistoryDataController(sQuery);      
    }
}