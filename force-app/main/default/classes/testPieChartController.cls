@isTest
public class testPieChartController{
    private static testmethod void testPieChartController(){ 
        Case c = new Case();
        c.Source_of_Case_Initiation__c = 'test';
        insert c;
        
        PieChartController controller = new PieChartController();
        List<PieChartController.PieWedgeData> lst =  controller.getpieData();
    }
    
}