public class GoogleMapsController{
    
    public static string getGoogleMapsAPIKey(){
        //string strKey = 'AIzaSyChFem1z5U6WZnECKAfgfVkvdmCVzPfnPs';
        //string strKey = 'AIzaSyC8ALdyDBjNeN2Lm3RYh1u6CyTSVqAPUVg';
        string strKey = 'AIzaSyAD8XTK0-Oo7Kwk5SbO2U8oQszMEIlcH0I';
        return strKey;
    }
    @AuraEnabled
    public static string getAddressAutoComplete(String input, String types) {
        String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='
                + EncodingUtil.urlEncode(input, 'UTF-8')
                + '&types=' + types
                + '&key=' + GoogleMapsController.getGoogleMapsAPIKey();
        return GoogleMapsController.getHttp(url);
    }
    
    public static string getHttp(string strURL){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strURL);
        //req.setHeader(CONTENT_TYPE,TEXT_XML);
        //req.setHeader(AUTHORIZATION,BEARER+' '+sessionId);
        req.setTimeout(120000);
        res = h.send(req);        
        String responseBody = res.getBody(); 
        system.debug('##################'+responseBody);       
        return responseBody;
    }
}