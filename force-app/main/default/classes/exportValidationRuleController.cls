public class exportValidationRuleController{
    FINAL String ORG_INSTANCE;
    FINAL String TOOLINGAPI_ENDPOINT;
    public List<wrapperValidation> validationRuleList {get; set;}
    public exportValidationRuleController(){
        ORG_INSTANCE = getInstance();
        
        validationRuleList = new List<wrapperValidation>();
        TOOLINGAPI_ENDPOINT = 'https://'+ORG_INSTANCE+'.salesforce.com/services/data/v36.0/tooling/';
        
        string strValidationQuery = 'SELECT+id,ValidationName,createddate,Active,Description,ErrorMessage+FROM+ValidationRule+limit+99+OFFSET+0';
        string strValidationJSON = sendToolingQueryRequest(strValidationQuery);
        
        System.JSONToken token;
        string text;
    
        // Parse JSON response
        JSONParser parser = JSON.createParser(strValidationJSON);
        parser.nextToken(); // Eat first START_OBJECT {
        parser.nextToken();     // Eat token = FIELD_NAME; text = postalcodes
        parser.nextToken();     // Eat first START_ARRAY [
        parser.nextToken();     // Eat the first object's START_OBJECT {
        wrapperValidation objwrapperValidation;
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
         
                    objwrapperValidation = new wrapperValidation();  
                    objwrapperValidation.validationruleId = text;
                    
                    string strValidationQueryChild = 'SELECT+id,Metadata+FROM+ValidationRule+where+id=\'' + text + '\'';
                    string strValidationJSONChild = sendToolingQueryRequest(strValidationQueryChild);
                    if(strValidationJSONChild != null){
                        string[] arrErrorCondition = strValidationJSONChild.split('"errorConditionFormula":"');
                        system.debug('$$$$$$$$'+arrErrorCondition[1]);
                        if(arrErrorCondition[1] != null){
                            string[] arrErrorCondition1 = arrErrorCondition[1].split('","errorDisplayField"');
                            arrErrorCondition1[0] = arrErrorCondition1[0].replaceAll('"','\'');
                            objwrapperValidation.strerrorConditionFormula = '"' +  arrErrorCondition1[0] + '"';
                        }
                    }
                                        
                }
                if (token == JSONToken.FIELD_Name && text == 'ValidationName') {           
                    token=parser.nextToken();
                    text = parser.getText();
                    objwrapperValidation.strValidationName = text;
                    system.debug('########'+text);                    
                }
                if (token == JSONToken.FIELD_Name && text == 'CreatedDate') {           
                    token=parser.nextToken();
                    text = parser.getText();
                    objwrapperValidation.validationCreateddate = date.valueOf(text);
                    
                    system.debug('########'+text);
                }
                if (token == JSONToken.FIELD_Name && text == 'Active') {           
                    token=parser.nextToken();
                    text = parser.getText();
                    objwrapperValidation.isActive = boolean.valueOf(text);
                    
                    system.debug('########'+text);
                }
                if (token == JSONToken.FIELD_Name && text == 'Description') {           
                    token=parser.nextToken();
                    text = parser.getText();
                    if(text != null && text != 'null'){
                        text = text.replaceAll('"','\'');
                        objwrapperValidation.strDescription = '"' + text + '"';                        
                        system.debug('########description'+text);
                    }
                }
                if (token == JSONToken.FIELD_Name && text == 'Metadata') {           
                    token=parser.nextToken();
                    text = parser.getText();
                    
                    objwrapperValidation.strerrorConditionFormula = text;
                    
                    system.debug('########'+text);
                    
                }
                if (token == JSONToken.FIELD_Name && text == 'ErrorMessage') {           
                    token=parser.nextToken();
                    text = parser.getText();
                    text = text.replaceAll('"','\'');
                    objwrapperValidation.strErrorMessage = '"' + text + '"'; 
                    validationRuleList.add(objwrapperValidation);
                    system.debug('########'+text);
                }
                //system.debug('########'+text);
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
    
    public class wrapperValidation{
        public string strValidationName {get; set;}
        public string validationruleId {get; set;}
        public date validationCreateddate {get; set;}
        public boolean isActive {get; set;}
        public string strDescription {get; set;}
        public string strErrorMessage {get; set;}
        public string strerrorConditionFormula {get; set;}
    }
}