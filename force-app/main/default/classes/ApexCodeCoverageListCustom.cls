/************************************************** 
* Name: ApexCodeCoverageList_Con
* Created by: Serge Kandukuri
* Description:  Apex test coverage using Tooling API
* Modified Date   : 2016.01.04 | Modified By: Serge Kandukuri 
**************************************************/

/************************************************** 
* Name: ApexCodeCoverageList_Con
* Created by: Serge Kandukuri
* Description:  Apex test coverage using Tooling API
* Modified Date   : 2015.12.16 | Modified By: Serge Kandukuri 

************************************************** 
* Name: ApexCodeCoverageList_Con
* Created by: Serge Kandukuri
* Description:  Apex test coverage using Tooling API
* Modified Date   : 2016.1.28 | Modified By: Serge Kandukuri 

**************************************************/

public class ApexCodeCoverageListCustom{
    
    private static FINAL String ORG_INSTANCE;
    private static FINAL String TOOLINGAPI_ENDPOINT;
    static{
        ORG_INSTANCE = getInstance();
        TOOLINGAPI_ENDPOINT = 'https://'+ORG_INSTANCE+'.salesforce.com/services/data/v34.0/tooling/';
    }
    
    public List<wrapperTestCoverage> wrapperTestCoverageList {get; set;}
    //public List<Test_Class_Code_Coverage__c> TestClassCoverageListDisplay {get; set;}
    
    public ApexCodeCoverageListCustom() {
        wrapperTestCoverageList = new List<wrapperTestCoverage>();
    }
    
    public void populateCodeCoverage(){
        
        List<Test_Class_Code_Coverage__c> TestClassCoverageList = new List<Test_Class_Code_Coverage__c>();
        string strJSONCoverage = fetchCodeCoverage();
        
        system.debug('@@@@@@@@@@'+strJSONCoverage);
        
        List<Test_Class_Code_Coverage__c> TestClassCoverageListTemp = new List<Test_Class_Code_Coverage__c>();
        // Parse JSON response to get all the totalPrice field values.
        JSONParser parser = JSON.createParser(strJSONCoverage);
       
        System.JSONToken token;
        string text;
      
        
        parser.nextToken(); // Eat first START_OBJECT {
        parser.nextToken();     // Eat token = FIELD_NAME; text = postalcodes
        parser.nextToken();     // Eat first START_ARRAY [
        parser.nextToken();     // Eat the first object's START_OBJECT {
        Test_class_Code_Coverage__c objTestCoverage;
        while((token = parser.nextToken()) != null) {
            // Parse the object
            if ((token = parser.getCurrentToken()) != JSONToken.END_OBJECT) {
                text = parser.getText();               
                
                // Apex Class/ Trigger
                if (token == JSONToken.FIELD_Name && text == 'NumLinesCovered') {
                    objTestCoverage = new Test_class_Code_Coverage__c();
                    token=parser.nextToken();
                    
                    objTestCoverage.Lines_Covered__c = integer.valueOf(parser.getText());                                      
                    token=parser.nextToken();
                    text = parser.getText();
                    if (token == JSONToken.FIELD_Name && text == 'ApexClassOrTriggerId') {
                        token=parser.nextToken();
                        objTestCoverage.Apex_Class_Trigger_Id__c = parser.getText();
                    }
                    
                    // ApexClassOrTrigger
                    parser.nextToken();
                    parser.getText();
                    
                    // START_OBJECT
                    parser.nextToken();
                    parser.getText();
                    
                    // attributes
                    parser.nextToken();
                    parser.getText();
                    
                    // START_OBJECT
                    parser.nextToken();
                    parser.getText();
                    
                    // type
                    parser.nextToken();
                    parser.getText();
                    
                    // url
                    parser.nextToken();
                    parser.getText();
                    
                    parser.nextToken();
                    parser.getText();
                    
                    // END_OBJECT
                    parser.nextToken();
                    parser.getText();
                    
                    parser.nextToken();
                    parser.getText();
                    
                    // Name
                    token = parser.nextToken();
                    text = parser.getText();
                                                            
                    if (token == JSONToken.FIELD_Name && text == 'Name') {
                        token=parser.nextToken();
                        objTestCoverage.Apex_Class_Trigger__c = parser.getText();
                    }
                    
                    // END_OBJECT
                    parser.nextToken();
                    parser.getText();
                    
                    // NumLinesUncovered
                    token = parser.nextToken();
                    text = parser.getText();
                    
                    if (token == JSONToken.FIELD_Name && text == 'NumLinesUncovered') {
                        token=parser.nextToken();
                        objTestCoverage.Lines_Not_Covered__c = integer.valueOf(parser.getText());  
                    }
                    //objTestCoverage.Total_Lines__c = objTestCoverage.Lines_Covered__c + objTestCoverage.Lines_Not_Covered__c;
                    //objTestCoverage.Coverage_Percentage__c= (objwrapperTestCoverage.intLinesCovered/(objwrapperTestCoverage.intTotalLines));
                   
                    system.debug('#########parser.nextToken()'+parser.nextToken());
                    system.debug('#########parser.getText()'+parser.getText());
                    TestClassCoverageListTemp.add(objTestCoverage);
                }
                
            }
        }
        
        //List<Test_Class_Code_Coverage__c> TestClassCoverageListAll = [SELECT ID, Apex_Class_Trigger__c, Apex_Class_Trigger_Id__c, Coverage_Percentage__c, Lines_Covered__c, Lines_Not_Covered__c, Total_Lines__c FROM Test_Class_Code_Coverage__c];
        Map<Id, wrapperTestCoverage> mapDuplicateClass = new Map<Id, wrapperTestCoverage>();
        wrapperTestCoverage objwrapperTestCoverage;
        for(Test_Class_Code_Coverage__c tc: TestClassCoverageListTemp){
            if((tc.Lines_Covered__c != 0 || tc.Lines_Not_Covered__c != 0) && tc.Lines_Covered__c != null && tc.Lines_Not_Covered__c != null){
                if(mapDuplicateClass.containsKey(tc.Apex_Class_Trigger_Id__c) == false){
                    
                    objwrapperTestCoverage = new wrapperTestCoverage();
                    objwrapperTestCoverage.strComponentId = tc.Apex_Class_Trigger_Id__c;
                    objwrapperTestCoverage.strComponentName = tc.Apex_Class_Trigger__c;
                    objwrapperTestCoverage.intLinesNotCovered = integer.valueOf(tc.Lines_Not_Covered__c);
                    objwrapperTestCoverage.intLinesCovered = integer.valueOf(tc.Lines_Covered__c);
                    objwrapperTestCoverage.intTotalLines = integer.valueOf(tc.Lines_Covered__c + tc.Lines_Not_Covered__c);
                    objwrapperTestCoverage.intCoveragePercentage = (tc.Lines_Covered__c /( tc.Lines_Covered__c + tc.Lines_Not_Covered__c )*100).setScale(2);
                    wrapperTestCoverageList.add(objwrapperTestCoverage);
                    mapDuplicateClass.Put(tc.Apex_Class_Trigger_Id__c, objwrapperTestCoverage);
                    TestClassCoverageList.add(tc);
                }else if(mapDuplicateClass.containsKey(tc.Apex_Class_Trigger_Id__c)){
                    mapDuplicateClass.get(tc.Apex_Class_Trigger_Id__c).intCoveragePercentage += (tc.Lines_Covered__c /( tc.Lines_Covered__c + tc.Lines_Not_Covered__c )*100).setScale(2);
                    mapDuplicateClass.get(tc.Apex_Class_Trigger_Id__c).intLinesCovered = integer.valueOf(((tc.Lines_Covered__c + tc.Lines_Not_Covered__c) * mapDuplicateClass.get(tc.Apex_Class_Trigger_Id__c).intCoveragePercentage)/100);
                    mapDuplicateClass.get(tc.Apex_Class_Trigger_Id__c).intLinesNotCovered = integer.valueOf((tc.Lines_Covered__c + tc.Lines_Not_Covered__c) - mapDuplicateClass.get(tc.Apex_Class_Trigger_Id__c).intLinesCovered);
                }
            }
        }
        
        if(!TestClassCoverageList.isEmpty()){
            Schema.SObjectField extField = Test_Class_Code_Coverage__c.Fields.Apex_Class_Trigger_Id__c;
            database.upsert(TestClassCoverageList, extField );
        }
    }
 
    public String fetchCodeCoverage(){
        return sendToolingQueryRequest('SELECT+NumLinesCovered,ApexClassOrTriggerId,ApexClassOrTrigger.Name,NumLinesUncovered,Coverage+FROM+ApexCodeCoverage+limit+100');
        
    }
    
    @RemoteAction
    public static String fetchOrgCoverage(){
        return sendToolingQueryRequest('SELECT+PercentCovered+FROM+ApexOrgWideCoverage');
    }
    
    /*Method to send query request to tooling api endpoint*/
    private static String sendToolingQueryRequest(String queryStr){
        HttpRequest req = new HttpRequest();
        string strEndPointURL = TOOLINGAPI_ENDPOINT+'query/?q='+queryStr;
        //strEndPointURL = EncodingUtil.urlDecode(strEndPointURL,'UTF-8');
        req.setEndpoint(strEndPointURL);
        /*Set authorization by using current users session Id*/
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');        
        req.setMethod('GET');
        req.setTimeout(12000);
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
    
    // wrapper class for code coverage list
    public class wrapperTestCoverage{
        public string strComponentId {get; set;} // Apex class or Trigger
        public string strComponentName {get; set;} // Apex class or Trigger
        public integer intLinesNotCovered {get; set;}
        public integer intLinesCovered {get; set;}
        public integer intTotalLines {get; set;}
        public double intCoveragePercentage {get; set;}
        public wrapperTestCoverage(){
            intLinesNotCovered = 0;
            intLinesCovered = 0;
            intTotalLines = 0;
            intCoveragePercentage = 0;
        }
    }
}