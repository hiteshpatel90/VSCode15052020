global with sharing class z_BatchableMetadataDump2 implements Database.Batchable<SObject>, Database.Stateful {

    global Boolean executeBatch3;

    global z_BatchableMetadataDump2() {
        // flag if z_BatchableMetadataDump2 is executed after this class is completed
        executeBatch3 = false;
    }
    
    global z_BatchableMetadataDump2(Boolean executeBatch3) {
        this.executeBatch3 = executeBatch3;
    }

    global database.querylocator start(Database.BatchableContext BC) {
        // z_BatchableMetadataDump1 should be executed before this call is called. Otherwize error
        return Database.getQueryLocator('Select objname__c, fieldname__c, objid__c from z_SchemaTemp__c');
    }

    global void execute(Database.BatchableContext BC, SObject[] scope){
        List<z_FieldDescription__c> records = new List<z_FieldDescription__c>();
        for(SObject record : scope) {
            z_SchemaTemp__c schema = (z_SchemaTemp__c) record;
            records.add(z_DescribeHelper.createFieldDescriptionRecord(schema.objid__c, schema.objname__c, schema.fieldname__c));
        }
        // create z_FieldDescritption__c records
        insert records;
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){
        if(!executeBatch3)
            return;
            
        Datetime dt = System.now();
        String coreExpression = z_Util.convertToStringForScheduler(dt.addMinutes(2));
        System.schedule('z_BatchableMetadataDump3', coreExpression, new z_SchedulableBatchableMetadataDump3());     
    }      
}