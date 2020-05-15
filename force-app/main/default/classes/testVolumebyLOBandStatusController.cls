@isTest
public class testVolumebyLOBandStatusController{
    private static testmethod void testVolumebyLOBandStatusController(){ 
        RecordType objRecordType = [select id from RecordType where DeveloperName ='Employee_Relations'];
        Case c = new Case();
        c.RecordtypeId = objRecordType.id ;
        c.Employee_LOB_static__c ='test';
        c.LOB_Name__c = userinfo.getuserid();
        c.status = 'New';
        insert c;
        
        Case c1 = new Case();
        c1.RecordtypeId = objRecordType.id ;
        c1.Employee_LOB_static__c ='test';
        c1.status = 'Working';
        c1.LOB_Name__c = userinfo.getuserid();
        insert c1;
        
        Case c2 = new Case();
        c2.RecordtypeId = objRecordType.id ;
        c2.Employee_LOB_static__c ='test';
        c2.status = 'Escalated';
        c2.LOB_Name__c = userinfo.getuserid();
        insert c2;
        
        Case c3 = new Case();
        c3.RecordtypeId = objRecordType.id ;
        c3.Employee_LOB_static__c ='test';
        c3.status = 'Closed';
        c3.LOB_Name__c = userinfo.getuserid();
        insert c3;        
        
        VolumebyLOBandStatusController controller = new VolumebyLOBandStatusController();
        List<VolumebyLOBandStatusController.barWedgeData> lst =  controller.getBarchartData();
        
        VolumeByCaseOpenLastMonthctrl controller1 = new VolumeByCaseOpenLastMonthctrl();
        controller1.getpieData();
    }
    
}