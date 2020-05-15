/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}
    public String language {get; set;} 
    private String sfdcBaseURL;

    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, startUrl);
    }
    
     global SiteLoginController () {
       sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
       
        username = null;
        password = null;
        
       if(ApexPages.currentPage().getParameters().get('lang') == null || ApexPages.currentPage().getParameters().get('lang') == ''){
         language = 'en';
       }else{
         language = ApexPages.currentPage().getParameters().get('lang');
       }

     }

    public PageReference loginButton(){
        String userId = username;
        String passId = password;

        if(userId != null || userId.length() > 0){
            if(passId != null || passId.length() > 0){

                String startUrl = System.currentPageReference().getParameters().get('startURL');
                return Site.login(username, password, startUrl);
            }
        }
        return null;
    }

    public PageReference logoutButton(){
        PageReference newPage = new PageReference(sfdcBaseURL +'/apex/ARLogin');
        newPage.setRedirect(true);
        return newPage;
    }
    
    public List<SelectOption> getHelpTypeOptions() {
        //return CS_ARContactsService.getPickValues(new Case(), 'Type', null);
        return null;
    }
}