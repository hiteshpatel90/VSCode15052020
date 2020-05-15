Public class createAccountInOracle{
    public string strfirstName{get; set;}
    public string strResponseVal {get; set;}
    public string strLastName {get; set;}

    public createAccountInOracle(){
        
    }
    public void createAccount(){
        
        Http htp             = new Http();             
        HttpRequest htp_req  = new HttpRequest();
        HttpResponse htp_res = new HttpResponse();
        htp_req.setHeader('Content-Type','text/xml');
        htp_req.setMethod('GET');
        
        //string strRequestBody = '{"ACC_Name":' + strAccName + ',"ACCOUNT_NUMBER":' + intAccNumber + ',"LOV":' + strActiveLOV + '}';
        string strRequestBody = '{"Person":{"First_name":"' + strfirstName + '","Last_name":"' + strLastName + '"}}';
        strRequestBody = '{"Person":{"First_name":"TEST","Last_name":"TEST","Phone":"12345","Email":"test@test.com"}}';
        system.debug('##########strRequestBody'+ strRequestBody);
        //htp_req.setEndPoint('http://jossdev.jadeglobal.com:8081/ords/utimes/create_account?p1=' + strRequestBody);
        
        htp_req.setEndPoint('http://jgrac01.jadeglobal.com:8889/ords/levey/create_account?p1={"Person":{"First_name":"TEST","Last_name":"TEST","Phone":"12345","Email":"test@test.com"}}');
                             
        //htp_req.setBody(strRequestBody);        
        
        htp_req.setTimeout(120000);
        //htp_req.setEndPoint('http://jossdev.jadeglobal.com:8081/ords/utimes/create_account?p1='+ strAccName);  
        
        htp_res = htp.send(htp_req);
        system.debug('@@@@@@@@@@@'+ htp_res.getbody());
        strResponseVal = htp_res.getbody();
        if(htp_res.getStatus() == '200'){
            if(ApexPages.currentPage().getParameters().get('id') != null){
                Id AccountId = ApexPages.currentPage().getParameters().get('id');
                if(AccountId != null){
                    Account a = new Account();
                    a.Id = AccountId ;
                    if(htp_res.getbody() != null ){
                        a.Returned_Oracle_Id__c = htp_res.getbody();
                        
                    }
                }
            }
            
            
        }
        
        
    }
}