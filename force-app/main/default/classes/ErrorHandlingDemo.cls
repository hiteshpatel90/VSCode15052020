public class ErrorHandlingDemo{
    public Contact objCon {get; set;}
    public ErrorHandlingDemo(){
        objCon = new Contact();
    }
    
    public pagereference saveContactRecord(){
        // Server-side errors -- START
        // Basic error handling -- START
        try{
            insert objCon;
            pagereference pr = new pagereference('/'+objCon.id);
            return pr;
        }catch (Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + ex.getMessage());
            ApexPages.addMessage(myMsg);
            
            // Custom error handling -- START        
            ErrorLogger logger = new ErrorLogger();
            logger.log(ex, '', 'Erro On Contact Insert');
            // Custom error handling -- END
            return null;
        }
        //Basic error handling -- END
        
        
        // Server-side errors -- END
    }
    
    @AuraEnabled
    public static String saveContactRecordFrom_LC(String strLastName, string strPhonenumber){
        
        //DML Exception
        contact objCon = new contact();
        if(strLastName != null){
            objCon.LastName = strLastName;
        }
        if(strPhonenumber != null){
            objCon.Phone = strPhonenumber;
        }
        insert objCon;
        return 'Success';        
    }
    
    public void cancelRecord(){
       
    }
}