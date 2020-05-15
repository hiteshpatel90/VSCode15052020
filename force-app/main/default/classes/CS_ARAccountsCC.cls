public with sharing class CS_ARAccountsCC {
 //Swetha Penmethsa -- Release 4.4 -- export list view   
    public boolean currentUserCanExportListview {get;set;}
    public CS_ARAccountsCC(){
        AxisUserInfo axisUserInfo = new AxisUserInfo();
        currentUserCanExportListview = false;
        if ( axisUserInfo.currentUserCanExportListview ) {
            currentUserCanExportListview = true;
        }
    }
     //Swetha Penmethsa -- Release 4.4 -- export list view
    @RemoteAction
    public static Account retrieveProvider(String providerId) {

        return CS_ARContactsService.retrieveProvider(providerId);

    }      
      
   
    @RemoteAction
    public static list<CS_ARAccountsService.CS_ARAccountWrapper> retrieveProviders(){
        return CS_ARAccountsService.retrieveProviders();
    }  // end of retrieveProviderDetails
    
    @RemoteAction
    public static List<Opportunity> retrieveOpportunitiesByAccountId(String accountId) {
        return CS_ARAccountsService.retrieveOpportunitiesByAccountId(accountId);
    }
    
    @RemoteAction
    public static List<Contact> retrieveProviderContacts(String providerId) {

        return CS_ARContactsService.retrieveProviderContacts(providerId);

    } 
     @RemoteAction
    public static List<CS_ARAccountsService.CS_SurgeonAffiliationWrapper> retrieveSurgeonAffiliationsByAccount(String accountId ) {
        return CS_ARAccountsService.retrieveSurgeonAffiliationsByAccount(accountId);
    } 
    
    @RemoteAction
    public static List<ObjectTerritory2Association> retrieveTerritoryForPractitioners(String accountId ) {
        //CS_ARAccountsService.cls_RetrieveTerritoryForPractitioners accService= new CS_ARAccountsService.cls_RetrieveTerritoryForPractitioners() ;
        //return accService.retrieveTerritoryForPractitioners(accountId);
        return null;
    }   
    
     @RemoteAction
    public static List<String> retrieveTerritoryForPractitioner(String accountId ) {
        return CS_ARContactsService.retrieveTerritoryForPractitioner(accountId);
    }
    
    @RemoteAction
    public static List<SelectOption> retrieveBusinessHourValues() {
        return CS_ARContactsService.getPickValues(new Account(), 'Business_Hours_Start__c', null);
    }
    @RemoteAction
    public static List<SelectOption> retrieveSterileProcessingHourValues() {
        return CS_ARContactsService.getPickValues(new Account(), 'Sterile_Processing_Hours_Start__c', null);
    }
    @RemoteAction
    public static List<SelectOption> retrieveFiscalYearMonthValues() {
        return CS_ARContactsService.getPickValues(new Account(), 'Account_Fiscal_Year_Start_Month__c', null);
    }
    @RemoteAction
    public static List<SelectOption> retrieveFiscalYearDayValues() {
        return CS_ARContactsService.getPickValues(new Account(), 'Account_Fiscal_Year_Start_Day__c', null);
    }
    @RemoteAction
    public static List<CS_ARAccountsService.AccountWrapper> retreiveActivities(string activityType,string accountId) {
        return CS_ARAccountsService.retrieveAccountActivity(activityType,
                                                                    accountId);
    }
    @RemoteAction
    public static void createNote(string accountId,
                                         string noteBody){
        
       CS_ARAccountsService.createNote(accountId,noteBody);
    } 
    @RemoteAction
    public static void updateNote(string noteId,string note){
        
       CS_ARAccountsService.updateNote(noteId,note);
    } 
    @RemoteAction
    public static void deleteNote(string noteId){
        
       CS_ARAccountsService.deleteNote(noteId);
    } 
       
    @RemoteAction
    public static void saveSurgeonAffiliations(string accountId, 
                                                                    list<Id> lstsurgeonIds){
        
       CS_ARContactsService.cSaveSurgeonsAffiliation(accountId,
                                                         lstsurgeonIds);
    }
    @RemoteAction
    public static void deleteSurgeonAffiliation(String affiliationId) {

        CS_ARContactsService.deleteSurgeonAffiliation(affiliationId);

    }
    @RemoteAction
    public static void deleteProviderContact(String contactId) {

        CS_ARContactsService.deleteProviderContact(contactId);

    } 
    @RemoteAction
    public static Contact saveContact(Map<String,Object> contactMap) {
        return CS_ARContactsService.saveContact(contactMap);
    } 
    @RemoteAction
    public static List<Account_Inventory__c> retrieveAccountInventory(String accountId) {
        return CS_ARAccountsService.retrieveAccountInventory(accountId);
    } 
    
    @RemoteAction
    public static List<PriceBookEntry> searchProducts(String q) {

        return CS_AROpportunityService.searchPriceBookEntries(q,true);
        
    }  
    
    @RemoteAction
    public static list<Account_Inventory__c> csaveAccountInventory(    String id,
                                                                       String disposables, 
                                                                       String equipment,
                                                                       String equipmentNotes, 
                                                                       String medications, 
                                                                       String sutures, 
                                                                       List<Account_Inventory__c> productList) {

        return CS_ARAccountsService.csaveAccountInventory(id,  
                                    disposables, equipment, equipmentNotes, medications, sutures,productList);
    } 
     @RemoteAction
    public static void updateProvider(Map<String,Object> providerFields) {

         CS_ARContactsService.updateProvider(providerFields);
    } 
    @RemoteAction
    public static List<PriceBookEntry> checkIfProductActive(String productId) {

        return CS_ARContactsService.checkIfProductActive(productId);
        
    } 
     @RemoteAction
    public static List<Account> retrievePractitioners() {
        return CS_ARAccountsService.searchSurgeonsInMyTeamTerritory('');
    } 

    // added by chad for 4.1 - Task Support
    @RemoteAction
    public static CS_ARTasksService.CS_ARTaskWrapper getTaskDetail(String taskId) {
        return CS_ARTasksService.getTaskDetail(taskId);        

    }

    @RemoteAction
    public static CS_ARTasksService.CS_ARTaskWrapper updateTaskStatus(String taskId, String status) {
        return CS_ARTasksService.updateTaskStatus(taskId, status);        
    }

    @RemoteAction
    public static CS_ARTasksService.CS_ARTaskWrapper saveTask(String taskType, List<String> relatedToWhatIds, List<String> relatedToWhoIds, Map<String,String> taskDetails) {

        return CS_ARTasksService.saveTask(taskType, relatedToWhatIds, relatedToWhoIds, taskDetails);

    } 
    // end added by chad for 4.1 - Task Support
         
}