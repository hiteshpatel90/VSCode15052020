public with sharing class SalesforceTool
{
    final String endpoint = 'https://ap1.salesforce.com/services/data/v28.0/tooling/sobjects';

    // SomeValues to be store
    public String oid ;
    public String cid ;
    public String apmid ;
    public String carid ;

    public SalesforceTool()
    {
    }

    // used receive response by sending a http request
    private String getResponse(HttpRequest req)
    {
        try
        {
            Http
            httpreq = new Http();
            HttpResponse
            res = httpreq.send(req);
            String reqresponse = res.getBody();
            return
            reqresponse;
        }
        catch (Exception e){return
        'Error:' +e.getMessage();}
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
}