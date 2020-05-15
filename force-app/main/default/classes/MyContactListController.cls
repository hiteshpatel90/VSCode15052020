public class MyContactListController{
    
    public class newClass{
       
    }
    public class newClass1{
       
    }
    
    @AuraEnabled
    public static List<Contact> getContacts() {
        return [Select Id, Name, Email, Title, Phone From Contact];
    }
    
    @AuraEnabled
    public static List<String> getPicklistValues() {
        List<String> lstString = new List<String>();
        lstString.add('-- None --');
        lstString.add('Submitted');
        lstString.add('Not Submitted');
    
        
        return lstString;
        
    }
    
    @AuraEnabled
    public static List<Contact> getContactsByPicklist(String picklistValue) {
        if(picklistValue != '-- None --'){
            return [Select Id, Name, Email, Title, Phone From Contact where Contact_Approval_Status__c =: picklistValue];
        }else{
            return [Select Id, Name, Email, Title, Phone From Contact where Contact_Approval_Status__c = null];
        }
    }
}