public class fatchAccountRecords{
    public static String fetchAccounts()
    {
        string strSessionid = loginsalesforce.login();
        string[] arrSessionid = strSessionid.split('<sessionId>');
        string[] arrSessionid1 = arrSessionid[0].split('</sessionId>');
        strSessionid = arrSessionid1[0];
        //system.debug('############strSessionid '+strSessionid );
        HttpRequest req = new HttpRequest();
        
        //string strSessionid = '00D90000000YfMQ!AQ0AQIt.dQQWR04Gg2Hj6pPpkctP.BaArwFeEWE2I2fyjXYYHB9Wnhyrd8QDyrbpO46F7BZ2rrpKAr2.2HAt07bxm7rnGdY0';
        //req.setHeader('Authorization', 'Bearer '+strSessionid );
        //req.setHeader('Authorization', 'OAuth '+SESSION_ID);
        
        req.setEndpoint('https://hiteshpatel-dev-ed.my.salesforce.com/services/apexrest/BoxRecords');
        req.setMethod('GET');  
        //req.setBody(''); 
        req.setTimeout(60000);
        req.setHeader('Authorization','Bearer '+strSessionid );
        //req.setHeader('Authorization','Bearer '+UserInfo.getSessionId());
        system.debug('############'+UserInfo.getSessionId());
        
         
        //req.setHeader('Authorization','Bearer ' + strSessionid );
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');        

        HttpResponse res =  new Http().send(req);
        //system.debug('############'+UserInfo.getSessionId());
        system.debug('response'+ res);
        system.debug('response'+ res.getBody());
        return res.getBody();
    }
    
}