////////////////////////////////////////////////////////////////////
//Name                   :  BatchExecUpdateMetadataList
//Created by             :  
/////////////////////////////////////////////////////////////////////

global class BatchExecUpdateMetadataList implements Database.Batchable<sObject>,  Database.AllowsCallouts{
    SObject[] source;
    FINAL String ORG_INSTANCE;
    FINAL String TOOLINGAPI_ENDPOINT;
    global BatchExecUpdateMetadataList(SObject[] source) {
        this.source = source;
        ORG_INSTANCE = getInstance();
        TOOLINGAPI_ENDPOINT = 'https://'+ORG_INSTANCE+'.salesforce.com/services/data/v29.0/tooling/';
    }
    
    global Iterable<SObject> start(Database.BatchableContext bc) {
        BatchSObjectFeeder bf = new BatchSObjectFeeder(source);
        return bf;
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        UpdateMetadataList(scope);
    }
    public void UpdateMetadataList(List<sObject> scope) {
        // Insert Metadata Type records
        List<Metadata_Type__c> MetadataTypeListInsert = new List<Metadata_Type__c>();
        List<Metadata_Type__c> MetadataTypeList = [select id, Name from Metadata_Type__c];
        Map<String, ID> mapMetadataType = new Map<String, ID>();
        for(Metadata_Type__c mt: MetadataTypeList){
            mapMetadataType.Put(mt.Name, mt.Id);
        }
        
        // Insert Object records
        List<Object__c> objectList = [select id, Name from Object__c];
        Map<String, ID> mapObject = new Map<String, ID>();
        for(Object__c obj: objectList){
            mapObject.Put(obj.Name, obj.Id);
        }
        List<Object__c> ObjectListUpsert = new List<Object__c>();
        
        string strApexClassQuery = '/services/data/v34.0/tooling/query/?q=SELECT+name,id,createddate+FROM+ApexClass+limit+10';
        string strApexClassesJSON = sendToolingQueryRequest(strApexClassQuery);
        
        System.JSONToken token;
        string text;
    
        // Parse JSON response
        JSONParser parser = JSON.createParser(strApexClassesJSON);
        parser.nextToken(); // Eat first START_OBJECT {
        parser.nextToken();     // Eat token = FIELD_NAME; text = postalcodes
        parser.nextToken();     // Eat first START_ARRAY [
        parser.nextToken();     // Eat the first object's START_OBJECT {
        Object__c objComponent;
        Boolean isNewApexClass = false;
        while((token = parser.nextToken()) != null) {
            // Parse the object
            if ((token = parser.getCurrentToken()) != JSONToken.END_OBJECT) {
                text = parser.getText();
                if (token == JSONToken.FIELD_Name && text == 'name') {           
                    token=parser.nextToken();
                    text = parser.getText();
                    if(mapObject.containsKey(text) == false){
                        isNewApexClass = true;
                        objComponent = new Object__c();
                        objComponent.Metadata_Type__c = mapMetadataType.get('Apex Class');  
                        objComponent.Name = text;
                        system.debug('########'+text);
                    }
                }
                if (token == JSONToken.FIELD_Name && text == 'createddate' && isNewApexClass == true) {           
                    token=parser.nextToken();
                    text = parser.getText();
                    objComponent.Created_Date__c = date.valueOf(text);
                    ObjectListUpsert.add(objComponent);
                    system.debug('########'+text);
                }
                //system.debug('########'+text);
            }
        }
        
        if(!ObjectListUpsert.isEmpty()){
            upsert ObjectListUpsert;
        }
    }
    
    global String sendToolingQueryRequest(String queryStr){
        system.debug('###########');
        HttpRequest req = new HttpRequest();
        //req.setEndpoint(TOOLINGAPI_ENDPOINT+'query/?q='+queryStr);
        req.setEndpoint('https://edysp123-dev-ed.my.salesforce.com/'+queryStr);
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
    global static String getInstance(){
        String instance;
        List<String> parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api','').split('\\.');
        if (parts.size() == 3 ) Instance = parts[0];
        else if (parts.size() == 5 || parts.size() == 4) Instance = parts[1];
        else Instance = null;
        return instance;
    }
    global void finish(Database.BatchableContext BC) {       
    }      
}