public with sharing class CS_ARCCExtension {
    // This class provides @RemoteAction methods common to all VF Pages, this prevents duplication of code and 
    // having to specify a different controller in each VF Remoting call 
    // - Chad chandler.armstrong@accenture.com
    
    // noop constructors for each custom controller, since the controllers only contain static methods there is no 
    // need to worry about member variable access in the extension
    public CS_ARCCExtension(CS_ARHomeCC cc) {}
    public CS_ARCCExtension(CS_ARContactsCC cc) {}
    public CS_ARCCExtension(CS_ARCasesCC cc) {}
    public CS_ARCCExtension(CS_ARTemplateCC cc) {}
    public CS_ARCCExtension(SalesReportCC cc){}
    public CS_ARCCExtension(CS_ARTasksCC cc){}
    
    // Added by Chad release 4.2 ( i think 4.2, this is for the new calendar )
    // public CS_ARCCExtension(CS_AREventsCC cc){}

    //Added by Ansu release 3.2 on 13 Feb for account redesign
    public CS_ARCCExtension(CS_ARAccountsCC cc){} 
    //Addition ends
     /*
    Below is Phase2
    */
    public CS_ARCCExtension(CS_AROpportunityCC cc) {}
    
    @RemoteAction
    public static List<CaseParticipant__c> retrieveCaseParticipants(String caseId ) {
        return CS_ARCasesService.retrieveCaseParticipants(caseId);
    }
    
    @RemoteAction
    public static List<Case_Products__c> retrieveCaseProducts(String caseId) {
        return CS_ARCasesService.retrieveCaseProducts(caseId);
    }

    @RemoteAction
    public static List<Case_Procedure__c> retrieveCaseProcedures(String caseId) {
        return CS_ARCasesService.retrieveCaseProcedures(caseId);
    }
    
    @RemoteAction
    public static List<Case_Procedure__c> retrieveCaseSurgicaProcedures(String caseId) {
        return CS_ARCasesService.retrieveCaseSurgicaProcedures(caseId);
    }
    
    @RemoteAction
    public static List<Case_Pref_Card__c> retrieveCasePrefCards(String caseId) {
        return CS_ARCasesService.retrieveCasePrefCards(caseId);
    }

    @RemoteAction
    public static List<Practitioner_Procedure__c> retrievePreferenceCards(String pract) {
       return CS_ARCasesService.retrievePreferenceCards(pract);
    }

    @RemoteAction
    public static List<User> searchUsers(String q) {
        
        return CS_ARCasesService.searchUsers(q);
        
    }
    
    @RemoteAction
    public static List<Product2> searchProducts(String q) {

        return CS_ARCasesService.searchProducts(q);
        
    }
    
    @RemoteAction
    public static CS_ARCalendarEventDTO retrieveCalendarEventDTOByCaseId(String caseId) {
        return CS_ARCasesService.retrieveCalendarEventDTOByCaseId(caseId);
    }
    /*
    Below is Phase2
    */
    @RemoteAction
    public static List<PriceBookEntry> searchPriceBookEntries(String q) {

        return CS_AROpportunityService.searchPriceBookEntries(q,false);
        
    }
    
   @RemoteAction
    public static List<Contact> searchOpportunityContacts(String accountId,
                                string opportunityId) {

        return CS_AROpportunityService.retrieveProvidersContacts(accountId, opportunityId);
        
    }
    
    @RemoteAction
    public static List<Procedure__c> searchProcedures(String q) {

        return CS_ARCasesService.searchProcedures(q);
        
    }
    
    @RemoteAction
    public static List<Procedure_Relationships__c> searchSurgicalTechniques(String q) {
        return CS_ARCasesService.searchSurgicalTechniques(q);
    }
    
    @RemoteAction
    public static List<ProcedureProduct__c> productsForSelectedProcedures(String q) {
        return CS_ARCasesService.productsForSelectedProcedures(q);   
    }   //  end of productsForSelectedProcedures

    @RemoteAction
    public static List<Practitioner_Procedure_Products__c> resolvePractitionerProcedureProducts(String practitionerId, String procedureId) {

        return CS_ARCasesService.resolvePractitionerProcedureProducts(practitionerId, procedureId);
        
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
    public static List<User> retrieveUsersInMyTerritory(){
        //return CS_ARTerritoryService.retrieveUsersInMyTerritory();
        list<Id> lstUserIds = new list<Id>();
        list<User>lstUsers = CS_ARTerritoryService.retrieveUsersInMyTerritory();
        list<User>lstActiveUsers= new list<User>();
        system.debug('##--lstUsers: '+ lstUsers);
        for(User objUser :lstUsers){
          
          if(objUser.IsActive){
            lstUserIds.add(objUser.Id);
            lstActiveUsers.add(objUser);
          }
        }
        
        return lstActiveUsers;
    }   //  end of retrieveUsersInMyTerritory
    
    //Added by Srinivas Sattoor on 6.21.2017 for 4.1 
    @RemoteAction
    public static List<User> retrieveUsersInMyTeamTerritory(string territoryId){ 
        list<Id> lstUserIds = new list<Id>();
        list<User>lstUsers;
        if(!string.isBlank(territoryId)){
            list<Id> lstTeamsInATeamHierarchy = CS_ARTerritoryService.retrieveParentTerritoriesForAGivenTerritory(territoryId);
            lstUsers = CS_ARTerritoryService.usersOfGivenTerritories(lstTeamsInATeamHierarchy);
        }else{
            lstUsers = CS_ARTerritoryService.retrieveUsersInMyTerritory();
        }
        list<User>lstActiveUsers= new list<User>();
        system.debug('##--lstUsers: '+ lstUsers);
        for(User objUser :lstUsers){
          
          if(objUser.IsActive){
            lstUserIds.add(objUser.Id);
            lstActiveUsers.add(objUser);
          }
        }
        
        return lstActiveUsers;
    }   //  end of retrieveUsersInMyTeamTerritory

    @RemoteAction
    public static List<Product2> retrievePreferenceCardProducts(String prefCardId) {

        return CS_ARCasesService.retrievePreferenceCardProducts(prefCardId);
        
    } 

    // Swetha -- display Surgeon with Team name - START
    @RemoteAction
    public static List<CS_ARSearch.accountWrapper> retrievePractitioners() {
        return CS_ARSearch.searchSurgeonsInMyTeamTerritory();
    }
    
    /* 
    Added by srinivas sattoor 05.25.2017 for 3.2 so that when managers
    assign an opp to an owner, surgeons are filtered for the territory 
    of the opp owner
    */
    
    @RemoteAction
    public static List<CS_ARSearch.accountWrapper> retrievePractitionersByOwner(string ownerId, string territoryId) {
        return CS_ARSearch.searchSurgeonsInSelectedOwnerTerritory(ownerId, territoryId);
    }
    
    // Swetha -- display Surgeon with Team name -- END
    
    @RemoteAction
    public static List<Account> retrieveProviders() {
        return CS_ARSearch.searchProvidersInMyTeamTerritory('');
    }
    
    /* 
    Added by srinivas sattoor 05.25.2017 for 3.2 so that when managers
    assign an opp to an owner, accounts are filtered for the territory 
    of the opp owner
    */
    
    @RemoteAction
    public static List<Account> retrieveProvidersByOwner(string ownerId, string territoryId) {
        system.debug('##--retrieveProvidersByOwner.ownerId: '+ ownerId);
        return CS_ARSearch.searchProvidersInSelectedOwnerTerritory(ownerId, territoryId);
    }
    
    @RemoteAction
    public static List<SelectOption> retrieveCase_CaseStatus_Picklist() {
        return CS_ARContactsService.getPickValues(new Case__c(), 'Status__c', null);
    }

    @RemoteAction
    public static void deleteCase(String id) {

        CS_ARCasesService.cdeleteCase(id);

    }

    @RemoteAction
    public static CS_ARCalendarEventDTO saveCase(String id, 
                                                String providerId, 
                                                String practitionerId, 
                                                List<String> prefCardIds, 
                                                String notes, 
                                                Long startDateMs, 
                                                Long endDateMs, 
                                                List<String> productIdList, 
                                                List<String> participantIdList, 
                                                String status,
                                                list<String> procedureIds, 
                                                List<String> surgicalIds, 
                                                String selectedOwnerId) {
        
        return CS_ARCasesService.csaveCase(id, 
                          providerId, 
                          practitionerId, 
                          prefCardIds, 
                          notes, 
                          startDateMs, 
                          endDateMs, 
                          productIdList, 
                          participantIdList, 
                          status, 
                          procedureIds, 
                          surgicalIds, 
                          selectedOwnerId);

    }   
    
    @RemoteAction
    public static CS_ARCalendarEventDTO updateCase(String caseId, Long startDateMs, Long endDateMs){
        return CS_ARCasesService.updateCase(caseId, startDateMs, endDateMs);
    }   //  end of updateCase

    @RemoteAction
    public static boolean updateTeamCalendarColor(Map<Id, string> teamColorMap){
        system.debug('*** length of team corlor map: ' + teamColorMap.keySet().size());
        return CS_ARCasesService.updateCalendarColor(teamColorMap);
    }
    
     @RemoteAction
    public static List<Procedure__c> searchTaxonomy(String q) {
      
        return CS_ARCasesService.searchTaxonomy(q);
    }
    
    
    @RemoteAction
    public static List<Procedure__c> getAllProductTeams() {
      
      //return [SELECT Id, Name, Product_Category__c FROM Procedure__c WHERE TaxonGroupId__c = 'team']; 
        //return CS_ARCasesService.searchTaxonomy(q);
        return CS_ARContactsService.c_getAllProductTeams();
        
    }  //  end of getAllProductTeams
    
    @RemoteAction
    public static List<Procedure__c> getAllRelatedProcedures(String productTeam) {
      
      return CS_ARContactsService.c_getAllRelatedProcedures(productTeam);
      //return [SELECT Id, Name, Product_Category__c FROM Procedure__c WHERE TaxonGroupId__c = 'procedure' and Product_Category__c = :productTeam]; 
        //return CS_ARCasesService.searchTaxonomy(q);
        
    }  //  end of getAllRelatedProcedures
    
     @RemoteAction
    public static List<Procedure__c> getAllRelatedSurgicalTechniques(String productTeam) {
      
      return CS_ARContactsService.c_getAllRelatedSurgicalTechniques(productTeam); 
      //return [SELECT Id, Name, Product_Category__c FROM Procedure__c WHERE TaxonGroupId__c = 'surgical_Technique' and Product_Category__c = :productTeam]; 
        //return CS_ARCasesService.searchTaxonomy(q);
        
    }  //  end of getAllRelatedSurgicalTechniques
    
    @RemoteAction
    public static List<Procedure__c> getRelatedSurgicalTechniques(String productTeam, List<Id> selectedProcedureIds) {
      
      
      if(selectedProcedureIds.size() == 0 ){
        
        return CS_ARContactsService.c_getAllRelatedSurgicalTechniques(productTeam);
      }
      
      set<Id> setSurgicalTechniqueIds = new set<Id>();
      for(Procedure_Relationships__c objProcRel : [SELECT Id, Child_Procedure__c FROM Procedure_Relationships__c WHERE Parent_Procedure__c IN :selectedProcedureIds]){
        setSurgicalTechniqueIds.add(objProcRel.Child_Procedure__c);
      }
      
      return [SELECT Id, Name, Product_Category__c FROM Procedure__c WHERE Id IN :setSurgicalTechniqueIds];  
      
    }  //  end of getRelatedSurgicalTechniques
    
    @RemoteAction
    public static Procedure__c checkIfProcedureAlreadyExists(string procedureName){
      
      return CS_ARContactsService.c_CheckIfProcedureAlreadyExists(procedureName);  
      
    }// end of checkIfProcedureAlreadyExists
    
    @RemoteAction               
    public static List<Campaign> allParentCampaigns() {

        return LeadManagementService.getAllParentCampaigns();
        
    }  //  end of allParentCampaigns

  @RemoteAction               
    public static List<Campaign> allDependentCampaigns(String campaignIds) {
      List<String> lstCampaignIds = new List<String>();
      lstCampaignIds = campaignIds.split('::');
      

        return LeadManagementService.getAllDependentCampaigns(lstCampaignIds);
        
    }  //  end of allDependentCampaigns
     
    
    @RemoteAction
    public static list<LeadManagementService.ConferenceMemberWrapper> returnAllConferenceMembers(){
      
      return LeadManagementService.getAllConferenceMemberWrappers(); 
    }//end of returnAllConferenceMembers
    
    @RemoteAction
    public static list<Conference_Member__c> retrieveArthrexCafeConferenceMember(Id conferenceId, Id contactId){
      
      return LeadManagementService.getArthrexCafeConferenceMember(conferenceId, contactId);
    }
    
   /* @RemoteAction
    public static list<LeadManagementVO.LeadsAppCaseWrapper> retrieveAllGeneralComments(Id conferenceId, Id contactId){
      
      return LeadManagementService.retrieveGeneralComments(conferenceId, contactId); 
    }//end of retrieveGeneralComments*/
    
    @RemoteAction
    public static map<string, list<Person_Conference_Interest__c>> retrievePersonCoferenceInterests(Id conferenceId, Id contactId){
      
      return LeadManagementService.retrievePersonCoferenceInterests(conferenceId, contactId); 
    }//end of retrieveGeneralComments
    
    @RemoteAction
    public static List<Conference_Team__c> getConferenceTeams(Id conferenceId){
      
      return LeadManagementService.getConferenceTeams(conferenceId); 
    }  //  end of getConferenceTeams
    
    //Release 3.2
    //Developer:- Mimansha Samal
    //Date:- 3/17/2017
    //Purpose:- Search Implants, Disposable and Equipment products from Price Book Entry
    @RemoteAction
    public static List<PriceBookEntry> searchPriceBookEntriesForIES(String q) {

        return CS_AROpportunityService.searchPriceBookEntries(q, true);
        
    }
    
    //Release 3.2, Added by Srinivas Sattoor 4.24.2017 Retrieve OppProdCategoryvalues
    @RemoteAction
    public static List<SelectOption> retrieveOpportunityProductCategoryValues(string opportunityType) { 
        return CS_AROpportunityService.retrieveOpportunityProductCategories(opportunityType);
    }
    
    //Release 3.2, Added by Srinivas Sattoor 4.24.2017 Retrieve oppStages
    @RemoteAction
    public static List<SelectOption> retrieveOpportunityStageValues(string opportunityType) { 
        return CS_AROpportunityService.retrieveOpportunityStages(opportunityType);
    }
    
    //Release 3.2, Added by Srinivas Sattoor 4.24.2017 Retrieve oppTypeValues
    @RemoteAction
    public static List<SelectOption> retrieveOpportunityTypeValues() { 
        return CS_ARContactsService.getPickValues(new Opportunity(), 'Type', null);
    }
    
    //Release 3.2, Added by Srinivas Sattoor 4.24.2017 Retrieve oppTypeValues
    @RemoteAction
    public static List<SelectOption> retrieveEnrollmentFormTypeValues() { 
        return CS_ARContactsService.getPickValues(new Opportunity(), 'Enrollment_Form_Type__c', null);
    }
    
    //Added by Ansu as part of Release 3.2 CDID-000175 FOR TIMEZONE on 02-05-2017
    public String getCurrentUserTimeZone(){
      return UserInfo.getTimeZone().getID();
    }  //  end of getCurrentUserTimeZone 
    
    //Release 3.2, Added by Srinivas Sattoor 4.24.2017 Retrieve closeLostReasons
    @RemoteAction
    public static List<SelectOption> retrieveOpportunityCloseLostReasons(string opportunityType) {
        //return CS_ARContactsService.getPickValues(new Opportunity(), 'Close_Lost_Reasons__c', null);
        return CS_AROpportunityService.retrieveClosedLostReason(opportunityType);
    }
    
    //Release 4.1, Added by Srinivas Sattoor 6.15.2017 Retrieve team options for logged in user
    @RemoteAction
    public static list<Territory2> retrieveUserTeams() { 
        return CS_ARTerritoryService.retrieveTerritoriesInMyTeamHierarchy();
    }// end of retrieveUserTeams
    
    //Release 4.1, Added by Srinivas Sattoor 6.20.2017 To populate the team as tree
    @RemoteAction
    public static Id retrieveMyterritoryId(){
        return CS_ARTerritoryService.retrieveMyTerritoryId();
    }   //  end of retrieveMyterritoryId
    
    //Release 4.1, Added by Srinivas Sattoor 6.20.2017 To populate the team as tree
    @RemoteAction
    public static map<Id, list<Territory2>> parentTerritoryAndListTerritories() {
        return CS_ARTerritoryService.parentTerritoryAndListTerritories();
    } // end of parentTerritoryAndListTerritories
    
    // Added by Srinivas Sattoor 4.15.2017 Release 3.1.3
    //Modified by srinivas sattoor 6.20.2017 Release 4.1
    @RemoteAction
    public static ObjectTerritory2Association retrieveAccountTeamTerritory(string accountId){
        
        list<Id> lstAccountIds = new list<Id>{accountId};
        Map<Id,List<ObjectTerritory2Association>> mapAccTerritoryAssoc= CS_ARTerritoryService.mapObjectIdsToTerritories(lstAccountIds);
        
        return mapAccTerritoryAssoc.get(accountId)[0];
        
    }// end of retrieveAccountTeamTerritory

    // Added by Chad for release 4.1 - Task Support
    @RemoteAction
    public static boolean isAccountAccesibleToUser(String accountId, String userId) {
        return CS_ARTasksService.c_CheckIfOwnerAndAccountTerritory(accountId, userId);
    }
    @RemoteAction
    public static Map<String,Object> getTaskPickListValues() {
        return CS_ARTasksService.retrieveTaskPicklists();
    }   

    @RemoteAction
    public static List<Filter_JSON__c> retrieveFiltersFor(String filterType) {
        return CS_FilterPersistenceService.getFilterJsonByUserAndType(UserInfo.getUserId(), filterType);
    }

    @RemoteAction
    public static void deleteFilterJson(String filterName, String filterType) {
        CS_FilterPersistenceService.deleteFilterJson(filterName, UserInfo.getUserId(), filterType);
    }

    @RemoteAction
    public static Filter_JSON__c saveFilterJson(String filterName, String filterJson, String filterType) {
        return CS_FilterPersistenceService.saveFilterJson(filterName, filterJson, UserInfo.getUserId(), filterType );
    }
    // End Added by Chad for release 4.1 - Task Support

    /*Start Release 4.4*/

    /*
        Vishnu: Added this method to get the eligible Opps that can be linked for the Surgeon
    */
    @RemoteAction
    public static List<CS_AROpportunityService.CS_LinkOpportunity> retrieveOpportunitiesToBeLinked(String accountId, Boolean forUnlink) {
        //return CS_AROpportunityService.retrieveOpportunitiesToBeLinkedToSurgeon(accountId, forUnlink);
        return null;
    }   //  end of retrieveOpportunitiesToBeLinked

    /*End of Release 4.4*/


}