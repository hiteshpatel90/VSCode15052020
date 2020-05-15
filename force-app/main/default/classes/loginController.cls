public with sharing class loginController{
    // Business Logic Layer
    @AuraEnabled
    public static boolean loginFun(String Username, String Password) {
        if(Username != null && Username != ''){
            Contact objCon = fetchExistingData.fetchContact(Username);
            if(objCon != null){
                return true;
            }
        }
        return false;
    }
    
    @AuraEnabled
    public static List <String> integrationLayer() {
        List<String> allOpts = new list<String>();
        allOpts.add('-- Select Layer --');
        List<Login_Integration_Layer__mdt> IntLayer = fetchExistingData.fetchIntLayer();
        for(Login_Integration_Layer__mdt li: IntLayer){
            allOpts.add(li.MasterLabel);
            
        }
        return allOpts;
        
    }
}