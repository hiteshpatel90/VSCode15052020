@isTest
public class testctrlVolumeByLastIssuedOutcomeLM{
    private static testmethod void testctrlVolumeByLastIssuedOutcomeLastMonth(){ 
        Case c = new Case();
        c.Last_Issued_Outcome__c ='test1';
         insert c;
        
        ctrlVolumeByLastIssuedOutcomeLastMonth controller = new ctrlVolumeByLastIssuedOutcomeLastMonth();
        List<ctrlVolumeByLastIssuedOutcomeLastMonth.PieWedgeData> lst =  controller.getpieData();
    }
    
}