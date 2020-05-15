@isTest
public class HistoryExtensionTest{
    Private Static testmethod void myTestmethod(){
        Field_History_Tracking_Admin__c objFHT = new Field_History_Tracking_Admin__c();
        objFHT.Enable_for_Field_Tracking__c = true;
        objFHT.sObject_Name__c = 'Account';
        objFHT.Fields_For_Tracking__c = 'Name';
        insert objFHT;
        
        Account objAcc = new Account();
        objAcc.Name = 'test acc';
        insert objAcc;
        
        List<Field_History__c> lstFH = new List<Field_History__c>();
        for(integer i = 0;i<10;i++){
            Field_History__c objFH = new Field_History__c();
            objFH.Edit_Date__c = system.today();
            objFH.Field_Event__c = 'Edit';
            objFH.New_Value__c = 'test' + i;
            objFH.Old_Value__c = 'test1' + i;
            objFH.sObject_Name__c = 'Account';
            objFH.Record_Id__c = objAcc.id;
            lstFH.add(objFH);
        }
        insert lstFH;
        
        ApexPages.currentPage().getParameters().put('id', objAcc.id);
        ApexPages.currentPage().getParameters().put('showMore', 'true');
        ApexPages.StandardController stdCon = new ApexPages.StandardController(objAcc);
        
        HistoryExtension objextFHR = new HistoryExtension(stdCon);
        objextFHR.showMoreHistoryRecord();
        ApexPages.currentPage().getParameters().put('showMore', 'false');
        
        HistoryExtension objextFHR1 = new HistoryExtension(stdCon);
    }
}