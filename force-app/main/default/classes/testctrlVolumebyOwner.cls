@isTest
public class testctrlVolumebyOwner{
    private static testmethod void testctrlVolumebyOwner(){ 
        RecordType objRecordType = [select id from RecordType where DeveloperName ='Employee_Relations'];
        Case c = new Case();
        c.RecordtypeId = objRecordType.id ;
        insert c;        
           
        ctrlVolumebyOwner controller = new ctrlVolumebyOwner();
        List<ctrlVolumebyOwner.barWedgeData> lst =  controller.getBarchartData();
    }    
}