@RestResource(urlMapping='/BoxRecords/*')  
global class extractBoxRESTService{
    
     @HttpGet
    global static Account[] extractAccountData() {  
        /*  
        RestContext Class - Allows us to access the RestRequest and RestResponse objects in your Apex REST methods.   
        RestRequest class - Allows us to pass request data into our Apex RESTful Web service method.  
        RestReponse class - Allows us to pass or send back response data from our Apex RESTful web service method  
        */  
        //Returns the RestRequest object for our Apex REST method.  
        RestRequest request = RestContext.request;  
        //Returns the RestResponse for our Apex REST method.  
        RestResponse response = RestContext.response;  
        //query the Box Folder  
        List<Account> lstAccount = new List<Account>();
        try{
            lstAccount = [SELECT Id, Name FROM Account];  
            system.debug('@@@@@ Box Folder ' + lstAccount.size() );
        }catch(Exception e){
            system.debug('@@@@@ Error ' + e.getMessage());
        }
        return lstAccount;  
    }  
    
   
   
}//END of BoxRESTService