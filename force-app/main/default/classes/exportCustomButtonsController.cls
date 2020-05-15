public class exportCustomButtonsController{
    FINAL String ORG_INSTANCE;
    FINAL String TOOLINGAPI_ENDPOINT;
    public List<wrapperCustomButton> customButtonList {get; set;}
    public exportCustomButtonsController(){
        ORG_INSTANCE = getInstance();
        customButtonList = new List<wrapperCustomButton>();
        TOOLINGAPI_ENDPOINT = 'https://'+ORG_INSTANCE+'.salesforce.com/services/data/v36.0/tooling/';
        
        string strButtonQuery = 'SELECT+id,name,description,url,masterlabel,linktype,displaytype,entitydefinitionId,manageablestate,createddate+FROM+weblink+where+EntityDefinitionId=\'Opportunity\'+and+displaytype=\'B\'+and+manageablestate=\'unmanaged\'';
        string strButtonJSON = sendToolingQueryRequest(strButtonQuery);
        
        System.JSONToken token;
        string text;
    
        // Parse JSON response
        JSONParser parser = JSON.createParser(strButtonJSON);
        parser.nextToken(); // Eat first START_OBJECT {
        parser.nextToken();     // Eat token = FIELD_NAME; text = postalcodes
        parser.nextToken();     // Eat first START_ARRAY [
        parser.nextToken();     // Eat the first object's START_OBJECT {
       
        wrapperCustomButton objwrapperCustomButton;
        Boolean isNewApexClass = false;
        
        while((token = parser.nextToken()) != null) {           
             
            // Parse the object
            if ((token = parser.getCurrentToken()) != JSONToken.END_OBJECT) {
               
                text = parser.getText();
                system.debug('%%%%%%%'+text );
                system.debug('%%%%%%%'+token );
                if (token == JSONToken.FIELD_Name && text == 'Id') {           
                    token=parser.nextToken();
                    text = parser.getText();
         
                    objwrapperCustomButton = new wrapperCustomButton();  
                    objwrapperCustomButton.strCustomButtonId = text;
                    
                                                          
                }
                if (token == JSONToken.FIELD_Name && text == 'Name') {           
                    token=parser.nextToken();
                    text = parser.getText();
                    objwrapperCustomButton.strCustomButtonAPIName = text;
                    system.debug('########'+text); 
                                    
                }
                
                if (token == JSONToken.FIELD_Name && text == 'Description') {           
                    token=parser.nextToken();
                    text = parser.getText();
                    if(text != null && text != 'null'){
                        text = text.replaceAll('"','\'');
                        objwrapperCustomButton.strDescription = '"' + text + '"';                        
                        system.debug('########description'+text);
                    }
                    
                }
                
               system.debug('&&&&&&&&&&&&&&&'+text);
               if (token == JSONToken.FIELD_Name && text.equals('Url')) {           
                    token=parser.nextToken();
                    text = parser.getText();
                    text = text.replaceAll('"','\'');
                    objwrapperCustomButton.strURL = '"' +  text + '"';                    
                    system.debug('########'+text);
                    
                }
              
                if (token == JSONToken.FIELD_Name && text == 'MasterLabel') {           
                    token=parser.nextToken();
                    text = parser.getText();
                    objwrapperCustomButton.strCustomButtonLabel = text;
                    
                    system.debug('########'+text);
                }
                
                if (token == JSONToken.FIELD_Name && text == 'LinkType') {           
                    token=parser.nextToken();
                    text = parser.getText();                    
                    objwrapperCustomButton.strButtonLinkType = text;
                            
                }
                
                if (token == JSONToken.FIELD_Name && text == 'CreatedDate') {           
                    token=parser.nextToken();
                    text = parser.getText();                    
                    objwrapperCustomButton.buttonCreateddate = date.valueOf(text);                    
                    system.debug('########'+text);
                    customButtonList.add(objwrapperCustomButton);
                }              
            }
        }
    }
    
    public String sendToolingQueryRequest(String queryStr){
        system.debug('###########');
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOOLINGAPI_ENDPOINT+'query/?q='+queryStr);
        //req.setEndpoint('https://edysp123-dev-ed.my.salesforce.com/'+queryStr);
        /*Set authorization by using current users session Id*/
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');        
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('###########'+res.getBody());
        return res.getBody();
    }
    
    /*Method to get org instance*/
    public static String getInstance(){
        String instance;
        List<String> parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api','').split('\\.');
        if (parts.size() == 3 ) Instance = parts[0];
        else if (parts.size() == 5 || parts.size() == 4) Instance = parts[1];
        else Instance = null;
        return instance;
    }
    
    public class wrapperCustomButton{
        public string strCustomButtonId {get; set;}
        public string strCustomButtonAPIName {get; set;}
        public string strCustomButtonLabel {get; set;}
        public string strDescription {get; set;}
        public string strURL {get; set;}
        public string strButtonLinkType {get; set;}
        public date buttonCreateddate {get; set;}      
    }
}