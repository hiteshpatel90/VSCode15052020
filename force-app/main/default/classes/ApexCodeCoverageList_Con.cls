/************************************************** 
* Name: ApexCodeCoverageList_Con
* Created by: Serge Kandukuri
* Description:  Apex test coverage using Tooling API
* Modified Date   : 2015.12.16 | Modified By: Serge Kandukuri 
**************************************************/

public class ApexCodeCoverageList_Con{
    
    private static FINAL String ORG_INSTANCE;
    private static FINAL String TOOLINGAPI_ENDPOINT;
    static{
        ORG_INSTANCE = getInstance();
        TOOLINGAPI_ENDPOINT = 'https://'+ORG_INSTANCE+'.salesforce.com/services/data/v29.0/tooling/';
    }
    
    @RemoteAction
    public static String fetchClassOrTriggerById( Id sobjId){
        String body='';
        String sObjectName = sobjId.getSobjectType().getDescribe().getName();
        for(Sobject sobj : Database.query('SELECT Body FROM '+sObjectName+' WHERE Id=:sobjId')){
            body = (String)sobj.get('Body');
        }
        return body;
    }

    @RemoteAction
    public static String fetchCodeCoverage(){
        return sendToolingQueryRequest('SELECT+NumLinesCovered,ApexClassOrTriggerId,ApexClassOrTrigger.Name,NumLinesUncovered,Coverage+FROM+ApexCodeCoverage');
        //return null;
    }
    
    @RemoteAction
    public static String fetchOrgCoverage(){
        return sendToolingQueryRequest('SELECT+PercentCovered+FROM+ApexOrgWideCoverage');
    }
    
    /*Method to send query request to tooling api endpoint*/
    private static String sendToolingQueryRequest(String queryStr){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOOLINGAPI_ENDPOINT+'query/?q='+queryStr);
        /*Set authorization by using current users session Id*/
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');        
        req.setMethod('GET');
        req.setTimeout(120000);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res.getBody();
    }
    
    /*Method to start Local Tests*/
    public static PageReference startLocalTests() {
        List<List<ApexClass>> searchList = [FIND '@isTest' IN ALL FIELDS RETURNING ApexClass (Id WHERE NamespacePrefix = NULL AND Status = 'Active')];
        ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
        for(ApexClass myResults : searchList[0]) {
            queueItems.add(new ApexTestQueueItem(ApexClassId=myResults.Id));
        }
        insert queueItems;
        PageReference newocp = new PageReference('/ui/setup/apex/ApexTestQueuePage');
        newocp.setRedirect(true);
        return newocp;
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