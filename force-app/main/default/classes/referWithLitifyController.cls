global class referWithLitifyController{
    
    webservice static string doRefer(Id referId){
        try{
        system.debug('#########');
            
            Http htp            = new Http();             
            HttpRequest htp_req  = new HttpRequest();
            HttpResponse htp_res = new HttpResponse();
            
            string body = getJSONRequest(); 
            htp_req.setHeader('Content-Type','application/json');
            htp_req.setHeader('Accept', 'application/json');

            htp_req.setMethod('POST');
            
            
            htp_req.setEndPoint('https://referral-api-dev.herokuapp.com/api/v1/authenticate/');
            htp_req.setbody(body);   
            htp_res = htp.send(htp_req);
            system.debug('@@@@@@@@@@@'+htp_res.getbody());
            
            system.debug('@@@@@@@@@@@'+htp_res.getHeaderkeys());
            system.debug('@@@@@@@@@@@'+htp_res.getHeader('X-User-Access-Token'));
            return htp_res.getbody();
        }catch (Exception ex){
            return 'false';
        }
        
    }
    
    public static string getJSONRequest(){
        string strJSONReq = '';
        strJSONReq = '{"email": "serge@etiproservices.com","password": "temp1234"}';
        return strJSONReq;
    }
}