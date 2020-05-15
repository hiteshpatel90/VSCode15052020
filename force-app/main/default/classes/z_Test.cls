@isTest
private class z_Test {
    
    // Insert z_MetaDumpSetting__c records
    static public void init1() {
        List<SObject> objs = [Select id from z_MetaDumpSetting__c];
        System.debug('---------metadumosetting rows:'+objs.size());
        if(objs.size() != 0) {
            delete objs;
            System.debug('Delete DML');
        }
        System.debug('---------metadumosetting rows:'+objs.size());        
        System.assert(objs.size()==0);        
        
        objs = [Select id from z_SchemaTemp__c];
        System.debug('---------SchemaTemp rows:'+objs.size());
        if(objs.size() != 0) {
            delete objs;
        }     
        System.debug('---------SchemaTemp rows:'+objs.size());          
        System.assert(objs.size()==0);        
        
        objs = [Select id from z_SObjectDescription__c];
        System.debug('---------SObjectDescription rows:'+objs.size());        
        if(objs.size() != 0) {
            delete objs;
        }
        System.debug('---------SObjectDescription rows:'+objs.size());  
        System.assert(objs.size()==0);

        z_MetaDumpSetting__c setting = new z_MetaDumpSetting__c(name__c = 'Account');
        insert setting;
    }
    
    // Insert z_SchemaTemp__c records for Object
    static public void init2() {
        init1();
        
        // same as _Util.prepareMetadataDump()
        List<z_MetaDumpSetting__c> settings = [Select id, name__c From z_MetaDumpSetting__c limit 10000];

        List<z_SchemaTemp__c> records = new List<z_SchemaTemp__c>();        
        for(z_MetaDumpSetting__c setting : [Select id, name__c From z_MetaDumpSetting__c]) {
            records.add(new z_SchemaTemp__c(objname__c = setting.name__c));
        }
        //System.assert(records.size() != 0);
        insert records;

    }   
    
    // Insert z_SchemaTemp__c records for Field
    static public void init3() {
        init2();

        z_SchemaTemp__c obj = [Select objname__c from z_SchemaTemp__c][0];
        Id recordid = z_DescribeHelper.insertSObjectDescriptionRecord(obj.objname__c);
        
        List<z_SchemaTemp__c> records = new List<z_SchemaTemp__c>();
        for(String field : z_DescribeHelper.getFieldNames(obj.objname__c)) {
            records.add(new z_SchemaTemp__c(objid__c = recordid, objname__c = obj.objname__c, fieldname__c = field));
        }

        //System.assert(records.size() != 0);        
        // add multiple field descriptions to temporary table named z_SchemaTemp__c
        insert records;
        delete obj;     
    }
    
    static public void init4() {
        init3();
        
        z_SchemaTemp__c schema = [Select objname__c, fieldname__c, objid__c from z_SchemaTemp__c][0];

        List<z_FieldDescription__c> records = new List<z_FieldDescription__c>();
        records.add(z_DescribeHelper.createFieldDescriptionRecord(schema.objid__c, schema.objname__c, schema.fieldname__c));
        System.assert(records.size() != 0);
        // create z_FieldDescritption__c records
        insert records;
        delete schema;      
    }

   
    static testMethod void testDumpFrontPageCont() {
        z_DumpFrontPageCont cont = new z_DumpFrontPageCont();
        init1();
        Test.StartTest();       
        cont.executeDump();
        cont.getJobs();
        cont.updateProgress();

        cont.batch1Status = cont.PROCESSING;
        cont.batch2Status = cont.PROCESSING;
        cont.batch3Status = cont.PROCESSING;
        
        System.assert(cont.getDisableDumpBtn());
        System.assert(cont.getShowProgressBar());
        System.assert(cont.getShowStatusBlock());
        
        cont.batch1Status = cont.NOT_START;
        cont.batch2Status = cont.NOT_START;
        cont.batch3Status = cont.NOT_START;     
        
        System.assert(!cont.getDisableDumpBtn());
        System.assert(!cont.getShowProgressBar());
        System.assert(!cont.getShowStatusBlock());
        
        Test.StopTest();        
    }

    static testMethod void testBatch1() {
        Test.StartTest();   
        init2();
    
        Id id = z_Util.executeBatchableMetadataDump1(false);
        System.debug('id-----------'+id);
        System.assert(id != null);
        Test.StopTest();        
    }   

    static testMethod void testBatch2() {
        init3();
        Test.StartTest();       
        Id id = z_Util.executeBatchableMetadataDump2(false);
        System.assert(id != null);
        Test.StopTest();        
    }   
    
    static testMethod void testBatch3() {
        init4();
        Test.StartTest();       
        Id id = z_Util.executeBatchableMetadataDump3();
        System.assert(id != null);
        Test.StopTest();        
    }
    
    static testMethod void testUtil() {
        String str = z_Util.convertToStringForScheduler(Date.today());
        System.assert(str != null);
    }
    
    static testMethod void testMetadataSettingCont() {
        z_MetaDumpSetting__c record = new z_MetaDumpSetting__c(name__c='test');
        insert record;

        List<z_MetaDumpSetting__c> records = [SELECT name FROM z_MetaDumpSetting__c LIMIT 20];
        System.assert(records.size()!=0);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(records);     

        z_MetadataSettingCont cont = new z_MetadataSettingCont(ssc);
        Test.StartTest();       
        cont.loadMetadata();
        cont.deleteSelected();
        cont.deleteAll();
        Test.stopTest();
    }
  

}