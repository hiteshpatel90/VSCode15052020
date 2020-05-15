@isTest
public class testctrlVolumebyOwnerLastmonth{
    private static testmethod void testctrlVolumebyOwnerLastmonth(){ 
        RecordType objRecordType = [select id from RecordType where DeveloperName ='Employee_Relations'];
        Case c = new Case();
        c.RecordtypeId = objRecordType.id ;
        insert c;
        
        ctrlVolumebyOwnerLastmonth controller = new ctrlVolumebyOwnerLastmonth();
        List<ctrlVolumebyOwnerLastmonth.barWedgeData> lst =  controller.getBarchartData();
    }
    
}