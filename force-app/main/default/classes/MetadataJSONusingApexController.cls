public class MetadataJSONusingApexController{
    public string strMetadataJSON {get; set;}
    private static FINAL String ORG_INSTANCE;
    private static FINAL String TOOLINGAPI_ENDPOINT;
    static{
        ORG_INSTANCE = getInstance();
        TOOLINGAPI_ENDPOINT = 'https://'+ORG_INSTANCE+'.salesforce.com/services/data/v34.0/tooling/';
    }
    
    public MetadataJSONusingApexController(){
        //string queryStr = 'SELECT+ID+FROM+customobject+limit+10';
        string queryStr = 'SELECT+ID,DeveloperName,Metadata,TableEnumOrId+FROM+customfield+limit+1';
        strMetadataJSON = sendToolingQueryRequest(queryStr);
    }
    
    /*Method to send query request to tooling api endpoint*/
    private String sendToolingQueryRequest(String queryStr){
        HttpRequest req = new HttpRequest();
        string strEndPointURL = TOOLINGAPI_ENDPOINT+'query/?q='+queryStr;
        //strEndPointURL = EncodingUtil.urlDecode(strEndPointURL,'UTF-8');
        req.setEndpoint(strEndPointURL);
        /*Set authorization by using current users session Id*/
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');        
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res.getBody();
    }
    
    /*Method to get org instance*/
    private static String getInstance(){
        String instance;
        List<String> parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api','').split('\\.');
        if (parts.size() == 3 ) Instance = parts[0];
        else if (parts.size() == 5 || parts.size() == 4) Instance = parts[1];
        else Instance = null;
        return instance;
    }
}