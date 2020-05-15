public class showSession{
    public string strSessionId {get; set;}
    public showSession(){
        strSessionId = 'https://edysp123-dev-ed.my.salesforce.com/secur/frontdoor.jsp?sid=' + system.userinfo.getsessionid();
        system.debug('########'+strSessionId);
        
        //00DP0000003oyjj!AR8AQEEcdHuIJsY.CGNkW.HeOQgJpUbBHejib_sRbAlJCv5gIKjASXEF4wnM2USpVuOIMlRBv5k7BsK0IGHSabwL_jIpzANW

    }
}