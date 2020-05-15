@isTest
public class testDashboardComponentDisplayController{
    private static testmethod void testDashboardComponentDisplayController(){ 
        
        DashboardComponentDisplayController controller = new DashboardComponentDisplayController();
        controller.getRecordTypes();
        
        controller.Component();
        controller.getTypes();
        controller .selected='ER Case Volume Summary Dashboard - Current Year';
        controller.getRecordTypes();
        controller.selectedComponent = 'PieChart';
        controller.updateComponent();
        controller.selectedComponent = 'VolumebyLOB';
        controller.updateComponent();
        controller.selectedComponent = 'VolumeByOwner';
        controller.updateComponent();
        controller.selectedComponent = 'VolumeByCountry';
        controller.updateComponent();
        controller.selectedComponent = 'barGraphType';
        controller.updateComponent();
        controller.selectedComponent = 'VolumeCaseStatus';
        controller.updateComponent();
        controller.selectedComponent = 'VolumeByLastIssuedOutcome';
        controller.updateComponent();
        controller.selectedComponent = 'VolumeByCaseOpenLastMonth';
        controller.updateComponent();
        controller.selectedComponent = 'VolumeByLastIssuedOutcomeLastMonth';
        controller.updateComponent();
        controller.selectedComponent = 'VolumebyOwnerLastmonth';
        controller.updateComponent();        
    }
    
}