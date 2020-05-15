public class BatchExecSurgicalCase2Event implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc){
             
        String query ='SELECT Id from Case__c'; 
        return Database.getQueryLocator(query);
        
    }//End of start method
    
    public void execute(Database.BatchableContext bc,List<Case__c> casesToConvert){
        for ( Case__c objCase : casesToConvert ) {
            //CS_EventsService.standAloneSurgicalCase2EventBasedSurgicalCase(objCase.Id);        
        }
         
    }//End of Execute() method
  
    public void Finish(Database.BatchableContext bc)
    {
        
    }//End of finish method
    
    /*
    // Execute below two line in developer console
     BatchExecSurgicalCase2Event objBatch = new BatchExecSurgicalCase2Event ();
        database.executeBatch(objBatch, 25);
    */
}//End of BatchSLA_Notification class