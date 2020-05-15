@istest
public class trgAccountTrackingTest{
Private Static testmethod void myTestmethod(){
Account objABC = new Account();
objABC.Name = 'test';
insert objABC;
Field_History_Tracking_Admin__c objFHT = new Field_History_Tracking_Admin__c();
objFHT.Enable_for_Field_Tracking__c = true;
objFHT.sObject_Name__c = 'Account';
objFHT.Fields_For_Tracking__c = 'Name';
insert objFHT;
objABC.Name = 'test1';
update objABC;
}
}