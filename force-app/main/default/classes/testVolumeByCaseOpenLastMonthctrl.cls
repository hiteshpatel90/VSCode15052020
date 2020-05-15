@isTest
public class testVolumeByCaseOpenLastMonthctrl{
    private static testmethod void testVolumeByCaseOpenLastMonthctrl(){ 
        Case c = new Case();
        c.Last_Issued_Outcome__c ='test1';
        insert c;
        
        VolumeByCaseOpenLastMonthctrl controller = new VolumeByCaseOpenLastMonthctrl();
        List<VolumeByCaseOpenLastMonthctrl.PieWedgeData> lst =  controller.getpieData();
    }
    
}