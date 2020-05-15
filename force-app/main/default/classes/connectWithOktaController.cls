public class connectWithOktaController{
    public static void connectWithOkta(){
        system.debug('####### START -- connectWithOkta');
        
        String userName = 'anup.garg@gmail.com';
        String passcode = 'Goodhealth1$';
        String baseUrl = 'https://dev-382914-admin.okta.com';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        Blob headerValue = Blob.valueOf(userName+':'+passcode);
        String authorizationHeader = 'SSWS 00VWsNGJp2LA9CzkLzEaGwTUGuINo8jGwoRArzo0fO';
        system.debug('authorizationHeader' + authorizationHeader);
        
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        //String endpoint = baseUrl + '/api/v1/users?limit=25';
        String endpoint = baseUrl + '/api/v1/users/anup.garg@gmail.com';

        req.setMethod('GET');
        req.setEndpoint(endpoint);
        system.debug('Endpoint -'+endpoint);
        
        HttpResponse res = new HttpResponse();
        res = http.send(req);
        system.debug('body-'+res.getbody());
        
        system.debug('####### END -- connectWithOkta');
    }
    
    public static void loginToZendesk_BasicAuthentication(){
        String userName = 'hiteshpatel.aspl@gmail.com';
        String passcode = 'hello123';
        String baseUrl = 'https://oktatozendexk.zendesk.com';
        
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        system.debug('@@@@@@@@@'+userName+':'+passcode);
        Blob headerValue = Blob.valueOf(userName+':'+passcode);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        system.debug('authorizationHeader' + authorizationHeader);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        String endpoint = baseUrl + '/api/v2/search.json?query=';
        endpoint = endpoint + 'type:ticket';
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        system.debug('Endpoint -'+endpoint);
        res = http.send(req);
        system.debug('body-'+res.getbody());
    }
    
    public static void loginToZendesk_APIToken(){
        String userName = 'hiteshpatel.aspl@gmail.com';
        String apiToken = 'Xfq5HrJCwfRVi5vyiVycUg1zKQwttkvV5cD3XvLZ';
        String baseUrl = 'https://oktatozendexk.zendesk.com';
        
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        //{email_address}/token:{api_token}
        Blob headerValue = Blob.valueOf(userName+'/token'+':'+apiToken);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        String endpoint = baseUrl + '/api/v2/search.json?query=';
        endpoint = endpoint + 'type:ticket';
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        system.debug('Endpoint -'+endpoint);
        res = http.send(req);
        system.debug('body-'+res.getbody());
    }
    
    public static void loginToZendesk_APIToken_Anup(){
        String userName = 'anup.garg@gmail.com';
        String apiToken = 'Xfq5HrJCwfRVi5vyiVycUg1zKQwttkvV5cD3XvLZ';
        String baseUrl = 'https://oktatozendexk.zendesk.com';
        
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        //{email_address}/token:{api_token}
        Blob headerValue = Blob.valueOf(userName+'/token'+':'+apiToken);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        String endpoint = baseUrl + '/api/v2/search.json?query=';
        endpoint = endpoint + 'type:ticket';
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        system.debug('Endpoint -'+endpoint);
        res = http.send(req);
        system.debug('body-'+res.getbody());
    }
}