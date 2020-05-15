////////////////////////////////////////////////////////////////////
//Type                   :  Schedule Class
//Name                   :  SchBatchExecUpdateBusHoursDepartment
//Company                :
//Created By             :  
//Created Date           :  12/09/2016
//Last Modified By       :  
//Last Modified Date     :  
//Description            :  This apex class is used to schedule the batch class "SchBatchExecUpdateBusHoursDepartment".
/////////////////////////////////////////////////////////////////////
global class SchBatchExecUpdateBusHoursDepartment implements schedulable{
    global void execute(SchedulableContext sc){
        string strSOQL = 'SELECT id, LiveChatButtonId, Requesttime  from LiveChatTranscript';
        BatchExecUpdateBusinessHoursDepartment batchApex = new BatchExecUpdateBusinessHoursDepartment(strSOQL);
        Database.executeBatch(batchApex,200);           
    }
}