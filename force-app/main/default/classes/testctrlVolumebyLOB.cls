@isTest
public class testctrlVolumebyLOB{
    private static testmethod void testctrlVolumebyLOB(){ 
        RecordType objRecordType = [select id from RecordType where DeveloperName ='Employee_Relations'];
        Case c = new Case();
        c.RecordtypeId = objRecordType.id ;
        c.Employee_LOB_static__c ='test';
        insert c;
        
        ctrlVolumebyLOB controller = new ctrlVolumebyLOB();
        List<ctrlVolumebyLOB.barWedgeData> lst =  controller.getBarchartData();
    }
    
}