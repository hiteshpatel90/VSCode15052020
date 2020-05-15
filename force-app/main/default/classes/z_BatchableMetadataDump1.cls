global with sharing class z_BatchableMetadataDump1 implements Database.Batchable<SObject>, Database.Stateful {

    global Boolean executeBatch2;
    
    global z_BatchableMetadataDump1() {
        // flag if z_BatchableMetadataDump2 is executed after this class is completed
        this(false);
    }
    
    global z_BatchableMetadataDump1(Boolean executeBatch2) {
        this.executeBatch2 = executeBatch2;
    }   
    
    global database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('Select objname__c from z_SchemaTemp__c');
    }

    global void execute(Database.BatchableContext BC, SObject[] scope){
        // Array size should be 1 because of governer limit
        z_SchemaTemp__c obj = (z_SchemaTemp__c) scope[0];
        Id recordid = z_DescribeHelper.insertSObjectDescriptionRecord(obj.objname__c);
        
        List<z_SchemaTemp__c> records = new List<z_SchemaTemp__c>();
        for(String field : z_DescribeHelper.getFieldNames(obj.objname__c)) {
            records.add(new z_SchemaTemp__c(objid__c = recordid, objname__c = obj.objname__c, fieldname__c = field));
        }
        // add multiple field descriptions to temporary table named z_SchemaTemp__c
        insert records;
        delete obj;
    }    

    global void finish(Database.BatchableContext BC){
        if(!executeBatch2)
            return;
        
        // after 2mins, z_BatchableMetadataDump2 class will be executed
        Datetime dt = System.now();
        String coreExpression = z_Util.convertToStringForScheduler(dt.addMinutes(2));
        System.schedule('z_BatchableMetadataDump2', coreExpression, new z_SchedulableBatchableMetadataDump2());
    }      
}