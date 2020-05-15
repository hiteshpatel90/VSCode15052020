trigger BatchApexErrorTrigger on BatchApexErrorEvent (after insert) {
    List<BatchLeadConvertErrors__c> listleadConvertserr = new List<BatchLeadConvertErrors__c>();
    for (BatchApexErrorEvent evt:Trigger.new)
    {
        BatchLeadConvertErrors__c batleadconerror= new BatchLeadConvertErrors__c();
        batleadconerror.AsyncApexJobId__c=evt.AsyncApexJobId;
        batleadconerror.Records__c=evt.JobScope;
        batleadconerror.StackTrace__c=evt.StackTrace;
        listleadConvertserr.add(batleadconerror);
        
    }
    
    insert listleadConvertserr;
}