@isTest
public class testctrlVolumeByCaseOpenLastMonth{
    private static testmethod void testctrlVolumeByCaseOpenLastMonth(){ 
        Case c = new Case();
        c.Last_Issued_Outcome__c ='test1';
        insert c;
        
        ctrlVolumeByCaseOpenLastMonth controller = new ctrlVolumeByCaseOpenLastMonth();
        List<ctrlVolumeByCaseOpenLastMonth.PieWedgeData> lst =  controller.getpieData();
    }
    
}