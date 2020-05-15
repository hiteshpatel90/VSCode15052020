public class contactList{
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews = 
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Contact'];
    
        // Perform isAccessible() check here
        return listviews;
    }
}