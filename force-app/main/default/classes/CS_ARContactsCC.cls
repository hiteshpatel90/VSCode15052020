public with sharing class CS_ARContactsCC {
    
    public string currentUserOIAccess {get; set;}
    
    @RemoteAction
    public static boolean isUniquePractitionerProcedureName(String practId, String name) {
        return CS_ARContactsService.isUniquePractitionerProcedureName(practId, name);
    }
    
    @RemoteAction
    public static List<Account> retrievePractitioners(Integer pageNum, Integer rowsPerPage) {
        // pageNum and rowsPerPage are not used right now

        List<Account> practitioners = CS_ARContactsService.retrievePractitioners();
        return practitioners;

    }

    //Retrieve pardot prospect activities
    @RemoteAction
    public static JSON2ApexVisitorActivity retrievePractitionerPardotActivities(string practitionerEmail, boolean loadMore) {
        //JSON2ApexVisitorActivity j2a;
        //return j2a;
        //return PardotAPIIntegrationServices.retrieveVisitorActivity(practitionerEmail, false);
        return null;
    }
    
    @RemoteAction
    public static List<CS_ARContactsService.AccountWrapper> retreiveActivities(string activityType,string accountId) {
        return CS_ARContactsService.retrieveAccountActivity(activityType,
                                                                    accountId);
    }
    
    @RemoteAction
    public static void createNote(string accountId,
                                         string noteBody){
        
       CS_ARContactsService.createNote(accountId,noteBody);
    }
    
    //Retrieve pardot visit details
    @RemoteAction
    public static JSON2ApexVisit retrievePractitionerPardotVisit(string practitionerVisitId){
        //return PardotAPIIntegrationServices.retrieveVisitDetails(practitionerVisitId);
        return null;
    }

    //Retrieve pardot email details
    @RemoteAction
    public static JSON2ApexPardotEmail retrievePractitionerPardotEmail(string practitionerEmailId) {
        //return PardotAPIConnector.RetrievePardotEmail(practitionerEmailId);
        return null;
    }    

    @RemoteAction
    public static List<Institution__c> searchInstitutions(String q) {
        return CS_ARSearch.searchInstitutions(q);
    }    
    @RemoteAction
    public static List<SelectOption> retrieveAreaOfInterestValues() {
        return CS_ARContactsService.getPickValues(new Account(), 'Arthrex_com_Surgeon_Specialty__pc', null);
    }      
    @RemoteAction
    public static List<SelectOption> retrieveDesignationValues() {
        return CS_ARContactsService.getPickValues(new Account(), 'Designation__pc', null);
    }    
    @RemoteAction
    public static List<SelectOption> retrievePracticeFocusValues() {
        return CS_ARContactsService.getPickValues(new Account(), 'Focus_of_my_practice__pc', null);
    }     
    @RemoteAction
    public static List<SelectOption> retrieveUserTypeValues() {
        return CS_ARContactsService.getPickValues(new Account(), 'User_Type__pc', null);
    }
    @RemoteAction
    public static List<SelectOption> retrieveSalutationValues() {
        return CS_ARContactsService.getPickValues(new Account(), 'Salutation', null);
    }    
    @RemoteAction
    public static List<SelectOption> retrieveGenderValues() {
        return CS_ARContactsService.getPickValues(new Account(), 'Gender__c', null);
    }  
    @RemoteAction
    public static List<SelectOption> retrieveStateValues() {
        return CS_ARContactsService.getPickValues(new Account(), 'BillingState', null);
    }
    
    //Code added by Ansu for 2.2 release to get account details edit modal picklist values
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
    
    //Code added by Ansu ends
    
    @RemoteAction
    public static Contact saveContact(Map<String,Object> contactMap) {
        return CS_ARContactsService.saveContact(contactMap);
    }    
       
    
    @RemoteAction
    public static Account retrievePractitioner(String accountId) {
        Account p = CS_ARContactsService.retrievePractitioner(accountId);
        /*
        if ( p.Profile_Picture__c == null ) { 
            p.Profile_Picture__c = '/profilephoto/005/T';
        }
        */
        return p;
    }

    @RemoteAction
    public static List<Case__c> retrieveCasesByPractitioner(String practitionerId) {
        
        return CS_ARCasesService.retrieveCasesByPractitioner(practitionerId);

    } 

    @RemoteAction
    public static List<Account> retrieveProviders(Integer pageNum, Integer rowsPerPage) {

        return CS_ARContactsService.retrieveProviders(pageNum, rowsPerPage);

    }

    @RemoteAction
    public static Account retrieveProvider(String providerId) {

        return CS_ARContactsService.retrieveProvider(providerId);

    }    
    @RemoteAction
    public static List<Contact> retrieveProviderContacts(String providerId) {

        return CS_ARContactsService.retrieveProviderContacts(providerId);

    } 

    @RemoteAction
    public static void deleteProviderContact(String contactId) {

        CS_ARContactsService.deleteProviderContact(contactId);

    } 
      @RemoteAction
    public static void deleteRelatedContact(String contactId) {

        CS_ARContactsService.deleteRelatedContact(contactId);

    }   
    
    @RemoteAction
    public static List<Product2> searchProducts(String q) {

        return CS_ARCasesService.searchProducts(q);
        
    }


    @RemoteAction
    public static CS_ARCalendarEventDTO retrieveCalendarEventDTOByCaseId(String caseId) {
        return CS_ARCasesService.retrieveCalendarEventDTOByCaseId(caseId);
    }    

    @RemoteAction
    public static void updatePractitionerDemographics(Map<String,Object> surgeon) {


        CS_ARContactsService.updatePractitionerDemographics(surgeon);
    }

    @RemoteAction
    public static void updateProvider(Map<String,Object> providerDetail) {


        CS_ARContactsService.updateProvider(providerDetail);
    }    


    @RemoteAction
    public static void updatePractitionerBio(Map<String,Object> practitionerBio) {


        CS_ARContactsService.updatePractitionerBio(practitionerBio);
    
    } 
  
    @RemoteAction
    public Static List<String> retrievePractitionerTasks(String practitionerId) {
        return CS_ArContactsService.retrievePractitionerTasks(practitionerId);
    }


    @RemoteAction
    public static List<Practitioner_Procedure__c> retrievePractitionerPrefCards(String practitionerId) {

        return CS_ARContactsService.retrievePractitionerPrefCards(practitionerId);

    }
    
    
    @RemoteAction
    public static CS_ARContactsService.CS_PreferenceCardWrapper retrievePractitionerPrefCard(String cardId) {
        return CS_ARContactsService.retrievePractitionerPrefCard(cardId);
    }    

    @RemoteAction
    public static List<Practitioner_Procedure_Products__c> retrievePractitionerPrefCardProducts(String cardId) {
        return CS_ARContactsService.retrievePractitionerPrefCardProducts(cardId);
    }    

    // saves or updates a Practioner_Procedure__c object and syncs associated Practioner_Procedure_Products__c records
    @RemoteAction
    public static CS_ARContactsService.CS_PreferenceCardWrapper csavePractitionerProcedure(String id,
                                                                       String name,
                                                                       String practitionerId,
                                                                       list<string> lstProcedureIds, 
                                                                       //String procedureId,
                                                                       list<string> lstSurgicalTechniqueIds, 
                                                                       //string surgicalTechniqueId, 
                                                                       String disposables, 
                                                                       String equipment,
                                                                       String equipmentNotes, 
                                                                       String medications, 
                                                                       String sutures, 
                                                                       String position, 
                                                                       List<String> productIdList) {

        return CS_ARContactsService.csavePractitionerProcedure(id, name, practitionerId, lstProcedureIds, //procedureId, 
                                    lstSurgicalTechniqueIds, //surgicalTechniqueId, 
                                    disposables, equipment, equipmentNotes, medications, sutures, position, productIdList);
    }
    @RemoteAction               
    public static List<Account> searchPractitioners(String q) {

        return CS_ARSearch.searchSurgeonsInMyTeamTerritory(q);
        
    }
    @RemoteAction
    public static List<Account> searchProviders(String q) {

        return CS_ARSearch.searchProvidersInMyTeamTerritory(q);
        
    }
    @RemoteAction
    public static List<Procedure__c> searchProcedures(String q) {
        return CS_ARCasesService.searchProcedures(q);
    }
    
    @RemoteAction
    public static List<Procedure__c> searchTaxonomy(String q) {
      
        return CS_ARCasesService.searchTaxonomy(q);
    }
    
    
    @RemoteAction
    public static List<Procedure__c> getAllProductTeams() {
      
      return CS_ARContactsService.c_getAllProductTeams();
        
    }  //  end of getAllProductTeams
    
    @RemoteAction
    public static List<Procedure__c> getAllRelatedProcedures(String productTeam) { 
      
        return CS_ARContactsService.c_getAllRelatedProcedures(productTeam);
    }  //  end of getAllRelatedProcedures
    
     @RemoteAction
    public static List<Procedure__c> getAllRelatedSurgicalTechniques(String productTeam) {
      return CS_ARContactsService.c_getAllRelatedSurgicalTechniques(productTeam); 
    }  //  end of getAllRelatedSurgicalTechniques
    
    
    @RemoteAction
    public static List<Procedure_Relationships__c> searchSurgicalTechniques(String q) {
        return CS_ARCasesService.searchSurgicalTechniques(q);
    }
    
    
    @RemoteAction
    public static void deletePractitionerProcedure(String id) {
        CS_ARContactsService.deletePractitionerProcedure(id);
    }

    @RemoteAction
    public static List<Product2> retrievePreferenceCardProducts(String prefCardId) {
        return CS_ARCasesService.retrievePreferenceCardProducts(prefCardId);
    }   
    
    @RemoteAction
    public static List<Account> retrievePractitionersInTerritory() {
        return CS_ARSearch.searchSurgeonsInMyTeamTerritory('');
    }
    
    @RemoteAction
    public static List<Account> retrieveProvidersInTerritory() {
        return CS_ARSearch.searchProvidersInMyTeamTerritory('');
    }    
    
    @RemoteAction
    public static List<Practitioner_Procedure__c> retrievePreferenceCards(String pract) {
        return CS_ARCasesService.retrievePreferenceCards(pract);
    }
    
    @RemoteAction
    public static List<CaseParticipant__c> retrieveCaseParticipants(String caseId ) {
        return CS_ARCasesService.retrieveCaseParticipants(caseId);
    }
    
    @RemoteAction
    public static List<Case_Products__c> retrieveCaseProducts(String caseId) {
        return CS_ARCasesService.retrieveCaseProducts(caseId);
    }
    
    @RemoteAction
    public static List<Case_Pref_Card__c> retrieveCasePrefCards(String caseId) {
        return CS_ARCasesService.retrieveCasePrefCards(caseId);
    }    

    @RemoteAction
    public static void saveNewSurgeonRequest(String npi, String firstName, String lastName) {
        CS_ArContactsService.saveNewSurgeonRequest(npi, firstName, lastName);
    }
    
    //Code added by AR for surgeon profile picture update
     @RemoteAction
    public static void updateProfilePicture(Map<String,Object> profile,Id practitionerId ) {
        CS_ArContactsService.updateProfilePicture(profile,practitionerId );
    }
    //end of code -AR
    
    public String getCurrentUserTimeZone(){
        return UserInfo.getTimeZone().getID();
    }   //  end of getCurrentUserTimeZone
    
    //Release 2.2
    //Component ID:- CID000064
    //Developer:- Mimansha Samal
    //Date:- 12/6/2016
    //Purpose:- Retrieving Assigned Territories that the practitioner is assigned to.
    @RemoteAction
    public static List<String> retrieveTerritoryForPractitioner(String accountId ) {
        return CS_ARContactsService.retrieveTerritoryForPractitioner(accountId);
    }
    
    //Release 2.2
    //Component ID:- CID000064
    //Developer:- Mimansha Samal
    //Date:- 12/6/2016
    //Purpose:- Retrieving Account Affiliations that the practitioner is associated to.
    @RemoteAction
    public static List<CS_ARContactsService.CS_AccountAffiliationWrapper> retrieveAccountAffiliationsByPractitioner(String practitionerId ) {
        return CS_ARContactsService.retrieveAccountAffiliationsByPractitioner(practitionerId);
    }
    
    //Release 2.2
    //Component ID:- CID000064
    //Developer:- Mimansha Samal
    //Date:- 12/9/2016
    //Purpose:- Delete Account Affiliation for the practitioner
    @RemoteAction
    public static void deleteAccountAffiliation(String affiliationId) {

        CS_ARContactsService.deleteAccountAffiliation(affiliationId);

    }
    
    //Release 2.2
    //Component ID:- CID000064
    //Developer:- Mimansha Samal
    //Date:- 12/19/2016
    //Purpose:- Save Account Affiliations for the practitioner
    @RemoteAction
    public static void saveAccountAffiliations(String practitionerId, list<Id> lstAccountIds){
        
       CS_ARContactsService.cSaveAccountAffiliation(practitionerId, lstAccountIds);
    } 
    
    @RemoteAction
    public static void saveSurgeonAffiliations(string accountId, 
                                                                    list<Id> lstsurgeonIds){
        
       CS_ARContactsService.cSaveSurgeonsAffiliation(accountId,
                                                         lstsurgeonIds);
    }
    //Code added by Ansu for Surgeon Affiliations- Account Requirement//Code commented by Ansu,as code is moved to CS_Araccountcc
    /*@RemoteAction
    public static List<Affiliation__c> retrieveSurgeonAffiliationsByAccount(String accountId ) {
        return CS_ARContactsService.retrieveSurgeonAffiliationsByAccount(accountId);
    }*/ 
    
    @RemoteAction
    public static void deleteSurgeonAffiliation(String affiliationId) {

        CS_ARContactsService.deleteSurgeonAffiliation(affiliationId);

    } 
    @RemoteAction
    public static List<ObjectTerritory2Association> retrieveTerritoryForPractitioners(String accountId ) {
        return CS_ARContactsService.retrieveTerritoryForPractitioners(accountId);
    }  

    @RemoteAction
    public static List<Opportunity> retrieveOpportunitiesByAccountId(String accountId) {
        return CS_ARContactsService.retrieveOpportunitiesByAccountId(accountId);
    }
    @RemoteAction
    public static void updateNote(string noteId,string note){
        
       CS_ARContactsService.updateNote(noteId,note);
   }
     @RemoteAction
    public static void deleteNote(string noteId){
        
       CS_ARContactsService.deleteNote(noteId);
    }
  
    
    @RemoteAction
    public static void deleteSurgeonProfilePic(String accountId) {
        CS_ARContactsService.deleteSurgeonProfilePicWrapper objDSPW = new CS_ARContactsService.deleteSurgeonProfilePicWrapper();
        objDSPW.c_deleteSurgeonProfilePic(accountId);
    }
    
    @RemoteAction
    public static String saveSurgeonProfilePic(String accountId, String attachmentBody) {        
        CS_ARContactsService.saveSurgeonProfilePicWrapper objSpW = new CS_ARContactsService.saveSurgeonProfilePicWrapper();
        return objSpW.c_saveSurgeonProfilePicWrapper(accountId, attachmentBody);        
    }
    
    @RemoteAction
    public static List<Account> retrieveSurgeonRelatedContacts(String providerId) {
        return CS_ARContactsService.retrieveSurgeonRelatedContacts(providerId);
    }
    
    @RemoteAction
    public static Account saveRelatedContact(Map<String,Object> accountMap) {
         
        return CS_ARContactsService.saveRelatedContact(accountMap);
    }   
    
    // saves or updates a Practioner_Procedure__c object and syncs associated Practioner_Procedure_Products__c records
    @RemoteAction
    public static CS_ARContactsService.CS_PreferenceCardWrapper csavePractitionerPreferenceCards(String id,
                                                                       String name,
                                                                       String practitionerId,
                                                                       list<string> lstProcedureIds, 
                                                                       //String procedureId,
                                                                       list<string> lstSurgicalTechniqueIds, 
                                                                       //string surgicalTechniqueId, 
                                                                       String disposables, 
                                                                       String equipment,
                                                                       String equipmentNotes, 
                                                                       String medications, 
                                                                       String sutures, 
                                                                       String position, 
                                                                       List<Practitioner_Procedure_Products__c> prefCardProdList) {

        return CS_ARContactsService.csavePractitionerPreferenceCards(id, name, practitionerId, lstProcedureIds, //procedureId, 
                                                                lstSurgicalTechniqueIds, //surgicalTechniqueId, 
                                                                disposables, equipment, equipmentNotes, medications, sutures, position, prefCardProdList);
    }
    
     //Release 3.2
    //Developer:- Mimansha Samal
    //Date:- 3/17/2017
    //Purpose:- Check if products are active from Price Book Entry
    
    @RemoteAction
    public static List<PriceBookEntry> checkIfProductActive(String productId) {

        return CS_ARContactsService.checkIfProductActive(productId);
        
    }
    
    @RemoteAction
    public static List<PriceBookEntry> retrievePersonAccountIdForContactId(String suregeonId) {

        return CS_ARContactsService.checkIfProductActive(suregeonId);
        
    }
    
    // added by chad for release 4.1
    @RemoteAction
    public static CS_ARTasksService.CS_ARTaskWrapper updateTaskStatus(String taskId, String status) {
        return CS_ARTasksService.updateTaskStatus(taskId, status);
    }

    @RemoteAction
    public static CS_ARTasksService.CS_ARTaskWrapper saveSFTask(List<String> relatedToWhatIds, List<String> relatedToWhoIds, Map<String,String> taskDetails) {

        return CS_ARTasksService.saveTask('axisactivity', relatedToWhatIds, relatedToWhoIds, taskDetails);

    }
    
    @RemoteAction
    public static CS_ARTasksService.CS_ARTaskWrapper retrieveMyTaskDetail(String taskId) {
        return CS_ARTasksService.getTaskDetail(taskId);
    }
    // end added by chad
    
    public boolean currentUserCanExportListview {get;set;}
    public CS_ARContactsCC(){
        AxisUserInfo axisUserInfo = new AxisUserInfo();
        currentUserCanExportListview = false;
        if ( axisUserInfo.currentUserCanExportListview ) {
            currentUserCanExportListview = true;
        }
    }
    
    @RemoteAction
    public static void searchPrograms() {

    }
    @RemoteAction
    public static void retrieveOrthoSpecialtiesValues() {

    }
    @RemoteAction
    public static void retrieveOrthoCourseTypeValues() {

    }
    @RemoteAction
    public static void retrieveOrthoProgramTypeValues() {

    }
    @RemoteAction
    public static void retrieveOrthoEmailValues(string suregeonId) {

    }
    @RemoteAction
    public static void retrieveOrthoSuffixValues(string suregeonId) {

    }
    @RemoteAction
    public static void retrieveOrthoPrefixValues(string suregeonId) {

    }
    @RemoteAction
    public static void retrieveOrthoStateValues(string suregeonId) {

    }
    @RemoteAction
    public static void retrieveOrthoCountryValues(string suregeonId) {

    }
    @RemoteAction
    public static void retrieveEducationTypeValues() {

    }
    @RemoteAction
    public static void retrieveProgramTypeValues() {

    }
    @RemoteAction
    public static void retrieveSurgeonOrthoillustrated(string suregeonId) {

    }
    @RemoteAction
    public static void deactivateOrthoSurgeon(string suregeonId) {

    }
    @RemoteAction
    public static void retrievePractitionerPrograms(string suregeonId) {

    }
    @RemoteAction
    public static void saveOIData(string suregeonId, string OIWebsite, string OIState, string OICity, string OICountry, string OIStreet, string OIPostalcode, string OIFirstname, string OILastname, string OIMiddlename, string OISuffix, string OIDesignation, string OIEmail, string OIPhone, string OIPrefix, string OISpecialties, string OIStatelicense, string OIPraciticename, string courseIds, string courses) {

    }
}