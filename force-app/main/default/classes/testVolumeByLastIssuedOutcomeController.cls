@isTest
public class testVolumeByLastIssuedOutcomeController{
    private static testmethod void testVolumeByLastIssuedOutcomeController(){ 
        Case c = new Case();
        c.Last_Issued_Outcome__c ='test1';
        insert c;
        
        VolumeByLastIssuedOutcomeController controller = new VolumeByLastIssuedOutcomeController();
        List<VolumeByLastIssuedOutcomeController.PieWedgeData> lst =  controller.getpieData();
    }
    
}