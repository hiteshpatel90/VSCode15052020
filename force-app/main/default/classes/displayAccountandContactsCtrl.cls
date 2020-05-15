public class displayAccountandContactsCtrl{
    
    @AuraEnabled
    public static List<Account> getAccounts(){
        List<Account> lstAcc = [SELECT Id, Name, Type FROM Account LIMIT 10];
        return lstAcc;
    }
    
    @AuraEnabled
    public static List<Contact> getContacts(){
        List<Contact> lstCon = [SELECT Id, Name, Email, Phone FROM Contact LIMIT 10];
        return lstCon;
    }
}