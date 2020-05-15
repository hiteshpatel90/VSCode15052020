global class AuditBatchClass implements Database.Batchable<sObject>{

    Audit_Trail_Settings__c atc = Audit_Trail_Settings__c.getValues('Main');
    public Datetime dts = atc.Last_Batch_Run__c;
    List<Setup_Audit_Trail__c> ATILoad = new List<Setup_Audit_Trail__c>();
    String query,query1;
    
    global AuditBatchClass(){
        query = 'SELECT Id,Action,CreatedById,CreatedDate,Display,Section,DelegateUser FROM SetupAuditTrail';
        query1 = 'SELECT Id,Action, CreatedById,CreatedDate,Display,Section,DelegateUser FROM SetupAuditTrail where CreatedDate >: dts';
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(atc.Batch_Sync__c == true && atc.Last_Batch_Run__c==null){
            return Database.getQueryLocator(query);
        }else if(atc.Batch_Sync__c == true && atc.Last_Batch_Run__c != null){
            return Database.getQueryLocator(query1);
        }else{
            return null;
        }
    }
        

    global void execute(Database.BatchableContext BC, List<SetupAuditTrail> scope){

        for(SetupAuditTrail sat: scope){
        system.debug('class fired-->');
        //if(sat.Display == 'Manage Territories' || sat.Display == 'Manage Users' || sat.Display == 'Partner Relationship Management'){
            Setup_Audit_Trail__c at = new Setup_Audit_Trail__c();
            at.Action__c = sat.Action;
            at.Audit_Component__c = sat.Section;
            at.Audit_Created_Date__c = sat.CreatedDate;
            at.Audit_Delegated_User__c = sat.DelegateUser;
            at.Audit_Display__c = sat.Display;
            at.Audit_Id__c = sat.Id;
            at.Audit_Rec_User__c = sat.CreatedById;
            ATILoad.add(at);
            system.debug('values----->'+at.Audit_Rec_User__c);
        }
        if(ATILoad.size() > 0){
           insert ATILoad;
           
        }
        
    }
    global void finish(Database.BatchableContext BC){
        atc.Last_Batch_Run__c = system.now();
        update atc;
    }
}