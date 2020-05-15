public class codeCoverageofTestClass{
    public static string TOOLINGAPI_ENDPOINT = 'https://na15.salesforce.com/services/data/v29.0/';
    public static void sendToolingQueryRequest(){
        string queryStr = 'SELECT+NumLinesCovered,ApexClassOrTriggerId,ApexClassOrTrigger.Name,NumLinesUncovered,Coverage+FROM+ApexCodeCoverage';
         
        HttpRequest req = new HttpRequest();
        string strUrl = URL.getSalesforceBaseUrl().toExternalForm();
        //https://na15.salesforce.com/services/data/v29.0/tooling/query/
        req.setEndpoint(strUrl + '/services/data/v29.0/tooling/query/?q='+queryStr);  
        /*Set authorization by using current users session Id*/  
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());  
        req.setHeader('Content-Type', 'application/json');      
        req.setMethod('GET');  
        Http http = new Http();  
        HTTPResponse res = http.send(req);
        system.debug('#######'+res.getBody());  
        //return res.getBody();  
    }  
}