@isTest
public class testctrlvolumebyCountry{
    private static testmethod void testctrlvolumebyCountry(){ 
        RecordType objRecordType = [select id from RecordType where DeveloperName ='Employee_Relations'];
        Case c = new Case();
        c.RecordtypeId = objRecordType.id ;
        c.Country__c ='test1';
        insert c;        
           
        ctrlvolumebyCountry controller = new ctrlvolumebyCountry();
        List<ctrlvolumebyCountry.barWedgeData> lst =  controller.getBarchartData();
    }    
}