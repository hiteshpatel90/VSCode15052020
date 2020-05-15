@isTest
public class extFieldhistorytrackingReportTest{
    Private Static testmethod void myTestmethod(){
        Field_History_Tracking_Admin__c objFHT = new Field_History_Tracking_Admin__c();
        objFHT.Enable_for_Field_Tracking__c = true;
        objFHT.sObject_Name__c = 'Account';
        objFHT.Fields_For_Tracking__c = 'Name';
        insert objFHT;
        
        List<Field_History__c> lstFH = new List<Field_History__c>();
        for(integer i = 0;i<10;i++){
            Field_History__c objFH = new Field_History__c();
            objFH.Edit_Date__c = system.today();
            objFH.Field_Event__c = 'Edit';
            objFH.New_Value__c = 'test' + i;
            objFH.Old_Value__c = 'test1' + i;
            objFH.sObject_Name__c = 'Account';
            lstFH.add(objFH);
        }
        insert lstFH;
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(lstFH[0]);
        
        extFieldhistorytrackingReport objextFHR = new extFieldhistorytrackingReport(stdCon);
        objextFHR.strSelFilterOption = 'Show archived data';
        objextFHR.hasNext = true;
        objextFHR.hasPrevious = true;
        objextFHR.pageNumber = 1;
        objextFHR.getFieldHistories();
        objextFHR.refresh();
        objextFHR.first();
        objextFHR.last();
        objextFHR.previous();
        objextFHR.next();
        objextFHR.getFilterOptions();
        objextFHR.exportFieldTracking();
        
        objextFHR = new extFieldhistorytrackingReport(stdCon);
        objextFHR.strSelFilterOption = 'Hide archived data';
        objextFHR.getFieldHistories();
    }
}