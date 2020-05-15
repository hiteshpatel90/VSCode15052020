/*
@isTest
public class Test_AuditBatchSchedule{  

    public static testmethod void first1(){
        Test.startTest();
        AuditBatchSchedule sh1 = new AuditBatchSchedule();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        }  

}*/
@isTest(seeAllData=true)
public class Test_AuditBatchSchedule{
    static testMethod void myUnitTest() {
        // Added by Swetha - Create custom setting record - Audit_Trail_Settings__c - START
        Audit_Trail_Settings__c objATS = new Audit_Trail_Settings__c();
        objATS.Name = 'Main';
        objATS.Batch_Sync__c = true;
        objATS.Last_Batch_Run__c = system.now();
        insert objATS;
        // Added by Swetha - Create custom setting record - Audit_Trail_Settings__c - END
        
        test.startTest();
        AuditBatchSchedule sh1 = new AuditBatchSchedule();
        String schedule = '0 0 23 * * ?';
        system.schedule('Nightly Update', schedule, sh1);
        test.stopTest();
        //System.assertEquals(null, sh1);
    }

}