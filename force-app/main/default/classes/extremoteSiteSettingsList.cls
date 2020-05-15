public class extremoteSiteSettingsList{
    public List<Remote_Site_Setting_Config__c> lstRemoteSiteSettings {get; set;}
    public extremoteSiteSettingsList(apexpages.standardController stdCon){
        lstRemoteSiteSettings = [select id, Name, AccessTokenRefreshed__c, APIClient_AccessToken__c, Application_List__c, AuthnzEndPoint__c, ClientId__c, ClientSecret__c, ContentType__c, Endpoint_Urls__c, ExpirationOffset__c, ExpiredDateTimeGMT__c, GrantType__c, Sandbox_Name__c, Scope__c from Remote_Site_Setting_Config__c];
    }
    
    public pagereference createNewRemoteSiteSetting(){
        pagereference pr = new pagereference('/apex/addRemoteSiteSettings');
        pr.setRedirect(true);
        return pr;
    }
}