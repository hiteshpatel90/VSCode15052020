@isTest(seeAllData=false)
private class Test_AuditBatchClass {

    public static User usr{get;set;}
    public static List<SetupAuditTrail> auditRec{get;set;}
    public static Setup_Audit_Trail__c AudCus {get;set;}
       
    static void setupData(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
            //usr = AuditBatchDataFactory.getAdminUser();
            //auditRec = AuditBatchDataFactory.getAuditRecords();
            //AudCus = AuditBatchDataFactory.getSyncDetails(); 
        }
    }
    static testMethod void test(){
        
        setupData();
        Test.startTest();
        Audit_Trail_Settings__c testvar = new Audit_Trail_Settings__c ();
        testvar.Last_Batch_Run__c = system.today();
        testvar.name = 'Main';
        testvar.Batch_Sync__c = true;
        insert testvar;

        AuditBatchClass c = new AuditBatchClass();
        c.dts = testvar.Last_Batch_Run__c;
        system.debug('testdts --> ' +c.dts);
        Database.executeBatch(c);

        Test.stopTest();
    }
}