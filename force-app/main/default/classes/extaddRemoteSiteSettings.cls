public with sharing class extaddRemoteSiteSettings {
    public Remote_Site_Setting_Config__c objRSSetting {get; set;}
    public string strSelSandbox {get; set;}
    public string strSelApplicationList {get; set;}
    public extaddRemoteSiteSettings(ApexPages.StandardController controller) {
        objRSSetting = new Remote_Site_Setting_Config__c();
    }
    public void saveRemoteSiteSettings(){
        try{
            objRSSetting.Sandbox_Name__c = strSelSandbox;
            objRSSetting.Application_List__c = strSelApplicationList;
            insert objRSSetting;
            
            objRSSetting = new Remote_Site_Setting_Config__c();
        }catch (Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public List<SelectOption> getSandboxes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None --'));
        options.add(new SelectOption('Sandbox1','Sandbox 1'));
        options.add(new SelectOption('Sandbox2','Sandbox 2'));
        options.add(new SelectOption('Sandbox3','Sandbox 3'));
        return options;
    }
    public List<SelectOption> getApplicationLists() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None --'));
        options.add(new SelectOption('Marketing_API','Marketing API'));
        options.add(new SelectOption('Merchant_API','Merchant API'));
        return options;
   }
}