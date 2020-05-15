public with sharing class fetchExistingData{
    // data Layer
    @AuraEnabled
    public static Contact fetchContact(String contactEmail) {
    
        List<Contact> lstCon = [SELECT id FROM Contact WHERE Email =: contactEmail LIMIT 1];
        if(!lstCon.isEmpty()){
            return lstCon[0];
        }        
        return null;
    }    
    
    // data Layer
    @AuraEnabled
    public static List<Login_Integration_Layer__mdt> fetchIntLayer() {    
        List<Login_Integration_Layer__mdt> IntLayer = [SELECT id, MasterLabel FROM Login_Integration_Layer__mdt];        
        return IntLayer;
    }    
}