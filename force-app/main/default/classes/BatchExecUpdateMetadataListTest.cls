////////////////////////////////////////////////////////////////////
//Type                   :  Test Class
//Name                   :  BatchExecUpdateMetadataListTest
//Company                :
//Created By             :  
//Created Date           :  12/29/2015
//Last Modified By       :  
//Last Modified Date     :  
//Description            :  This test class of "BatchExecUpdateMetadataList".
/////////////////////////////////////////////////////////////////////
@istest
public class BatchExecUpdateMetadataListTest{
    Private Static testmethod void  myTestMethod(){
        
        List<Metadata_Type__c> lstMetadataTypeInsert = new List<Metadata_Type__c>();
        
        Metadata_Type__c objMetadataType = new Metadata_Type__c();
        objMetadataType.Name = 'Validation Rules';
        lstMetadataTypeInsert.add(objMetadataType);        
        
        insert lstMetadataTypeInsert;
        
        List<Object__c> objectListInsert = new List<Object__c>();
        
        Object__c obj = new Object__c();
        obj.Name = 'Test Validation';
        obj.Metadata_Type__c = lstMetadataTypeInsert[0].id;
        objectListInsert.add(obj);
        
        insert objectListInsert;
        
        
        Test.startTest();
        
        String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new ScheduleBatchExecUpdateMetadataList() );

        Test.stopTest();
    }    
}