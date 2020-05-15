@isTest
public class testctrlbarGraphCountry{
    private static testmethod void testctrlbarGraphCountry(){ 
        RecordType objRecordType = [select id from RecordType where DeveloperName ='Employee_Relations'];
        Case c = new Case();
        c.RecordtypeId = objRecordType.id ;
        c.Country__c ='UK';
        c.Work_city__c ='London';
        insert c;
        
        Case c1 = new Case();
        c1.RecordtypeId = objRecordType.id ;
        c1.Country__c ='US';
        c1.Work_city__c ='New York';
        insert c1;
        
        Case c2 = new Case();
        c2.RecordtypeId = objRecordType.id ;
        c2.Country__c ='test1';
        c2.Work_city__c ='Jalisco';
        insert c2;
        
        Case c3 = new Case();
        c3.RecordtypeId = objRecordType.id ;
        c3.Country__c ='test1';
        c3.Work_city__c ='Bari';
        insert c3;
        
        Case c4 = new Case();
        c4.RecordtypeId = objRecordType.id ;
        c4.Country__c ='test1';
        c4.Work_city__c ='Granada';
        insert c4;
        
        ctrlbarGraphCountry controller = new ctrlbarGraphCountry();
        List<ctrlbarGraphCountry.barWedgeData> lst =  controller.getBarchartData();
    }
    
}