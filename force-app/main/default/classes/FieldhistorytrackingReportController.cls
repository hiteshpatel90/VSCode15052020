public class FieldhistorytrackingReportController{
    @AuraEnabled
    public static List<Field_History__c> getFieldHistories() {
        return [select id, Edit_Date__c, Record_Id__c, User__c,User__r.Name, Field_Event__c, New_Value__c, Old_Value__c, sObject_Name__c from Field_History__c order by Createddate LIMIT 10000];
    }
    
    @AuraEnabled
     public static List<Contact> getContacts() {
        return [Select Id, Name, Email, Title, Phone From Contact];
    }
}