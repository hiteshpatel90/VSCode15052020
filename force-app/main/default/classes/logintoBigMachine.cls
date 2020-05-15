public class logintoBigMachine{

    public static String login(){
        
        string username = 'jackermann';
        string password = 'Cr33p1ngd347h';
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');   
        req.setTimeout(60000);
        req.setEndpoint('https://actividentity.bigmachines.com/v1_0/receiver');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');        
        req.setHeader('SOAPAction', '""');
        req.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"> <soapenv:Header> <bm:category xmlns:bm="urn:soap.bigmachines.com">Security</bm:category> <bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com"> <bm:schemaLocation>https://actividentity.bigmachines.com/bmfsweb/actividentity/schema/v1_0/security/Security.xsd</bm:schemaLocation> </bm:xsdInfo> </soapenv:Header> <soapenv:Body> <bm:login xmlns:bm="urn:soap.bigmachines.com"> <bm:userInfo> <bm:username>' + username + '</bm:username> <bm:password>' + password + '</bm:password> <bm:sessionCurrency>USD</bm:sessionCurrency> </bm:userInfo> </bm:login> </soapenv:Body> </soapenv:Envelope>');
        HttpResponse res =  new Http().send(req);

        String strSessionId = '';
        string[] arrSessionId = res.getBody().split('<bm:sessionId>');
        strSessionId = arrSessionId[1].split('</bm:sessionId>')[0];
        system.debug('@@@@@@22'+strSessionId);
        return strSessionId;
    }
}