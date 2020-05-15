@isTest
public class testctrlVolumeController{
    private static testmethod void testctrlVolumeController(){ 
        RecordType objRecordType = [select id from RecordType where DeveloperName ='Employee_Relations'];
        Case c = new Case();
        c.RecordtypeId = objRecordType.id ;
        c.Status ='test1';
        insert c;        
           
        ctrlVolumeController controller = new ctrlVolumeController();
        //List<ctrlVolumeController.WrapperData> lst =  controller.data();
    }    
}