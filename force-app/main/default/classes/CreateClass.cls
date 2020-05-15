public class CreateClass {
    final String endpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v28.0/tooling/sobjects';

    public CreateClass(){
        //createClassToolingMethod();
       
    }
    
    public void createClassToolingMethod(){
        String json = '{ "Name" : "TestClassTooling", "Body" : "public class TestClassTooling { public TestClassTooling(string s){}}" }'; 
        Httprequest req = new HttpRequest(); 
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v27.0/sobjects/ApexClass'); 
        req.setMethod('POST'); 
        req.setHeader('Content-Type', 'application/json'); 
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId()); 
        req.setBody(json); 
        Http httpReq = new Http(); 
        System.debug(req);
        HttpResponse res = httpReq.send(req); 
        System.debug(res.getBody());
    }
    
    public string createMetadataContainer(string changeMade){
        HttpRequest req = createHttpRequest(endpoint+'/MetadataContainer','POST');
    
        req.setBody('{"Name":"' + changeMade + '"}');
        String response = getResponse(req);
        Map<String,Object> rmp = (Map<String,Object>)JSON.deserializeuntyped(response);
        String cid = (String)rmp.get('id');// used to save containerId
        
        system.debug('@@@@@@@@@@@'+cid);
        return cid;
    }
    
    // mid: MetadaContainserId
    // axid: apexclass Id
    // classBody: Apex class body (updated)
    public void createApexClassMember(String mid, String axid, String classBody)
    {
        
        HttpRequest req = createHttpRequest(endpoint+'/ApexClassMember','POST');
        req.setBody('{"MetadataContainerId" : "'+mid+'", "ContentEntityId" : "'+axid+'", "Body": "'+classbody+'"}');
        String response = getResponse(req);
        Map<String,Object> rmp = (Map<String,Object>)JSON.deserializeuntyped(response);
        String apmid = (String)rmp.get('id');// Store ApexClassMember Id
    }
    
    
    public void createContainerAsyncRequest(String mid){
        HttpRequest req = createHttpRequest(endpoint+'/containerAsyncRequest','POST');
        req.setBody('{"MetadataContainerId" : "'+mid+'", "isCheckOnly": "false"}');
        String response = getResponse(req);
        Map<String,Object> rmp = (Map<String,Object>)JSON.deserializeuntyped(response);
        string carid = (String)rmp.get('id');
    }
    
    // create a http request with required endpoint and request method
    private HttpRequest createHttpRequest(String endpoint, String method)
    {
        HttpRequest req = new HttpRequest();
        endpoint += '';
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        return req;
    }
    
     // used receive response by sending a http request
    private String getResponse(HttpRequest req)
    {
        try
        {
            Http httpreq = new Http();
            HttpResponse  res = httpreq.send(req);
            String reqresponse = res.getBody();
            system.debug('@@@@@@@@@@@'+reqresponse );
            return reqresponse;
        }catch (Exception e){
            return 'Error:' +e.getMessage();
        }
    }

}