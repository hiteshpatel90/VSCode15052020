public with sharing class CS_AROpportunityCC {

    //Swetha Penmethsa -- Release 4.4 -- export list view   
    public boolean currentUserCanExportListview {get;set;}
    public CS_AROpportunityCC (){
        AxisUserInfo axisUserInfo = new AxisUserInfo();
        currentUserCanExportListview = false;
        if ( axisUserInfo.currentUserCanExportListview ) {
            currentUserCanExportListview = true;
        }
    }
    //Swetha Penmethsa -- Release 4.4 -- export list view   
    public List<SelectOption> getOpportunityTypeValues() {
        
        list<SelectOption> lstOptions = new list<SelectOption>();
        
        for(SelectOption options :  CS_ARContactsService.getPickValues(new Opportunity(), 'Type', null)){
            
            if(options.getValue() == 'SOS'){
                continue;
            }
            lstOptions.add(options);
        } 
        return lstOptions;
        
        //return CS_ARContactsService.getPickValues(new Opportunity(), 'Type', null);
    }   //  end of getOpportunityTypeValues
    
    
    public List<Territory2> getSubAgencyOrTeamDropDown(){
        List<Territory2> lstOptions = new List<Territory2>();
        
        map<Id, list<Territory2>> mapparentTerritoryAndListTerritories = CS_ARTerritoryService.parentTerritoryAndListTerritories();
        system.debug('##--getSubAgencyOrTeamDropDown.mapparentTerritoryAndListTerritories: '+ mapparentTerritoryAndListTerritories);
        
        for(ID territory : mapparentTerritoryAndListTerritories.keySet()){
            lstOptions.addAll(mapparentTerritoryAndListTerritories.get(territory));
        }
        
        return lstOptions;
    }   //  end of getFirstDropDown
    
    // Added by Srinivas Sattoor 4.15.2017 Release 3.1.3
    public Boolean getAssingedToMultipleTerritories(){
        
        list<Id> lstIds = CS_ARTerritoryService.retrieveMyTerritoryIds(false); 
        if(lstIds != null && lstIds.size() > 1){ 
            return true;
        }
        
        return false;
    }   //  end of getAssingedToMultipleTerritories
    
    // Added by Srinivas Sattoor 4.15.2017 Release 3.1.3
    //Modified by srinivas sattoor 6.20.2017 Release 4.1
    @RemoteAction
    public static ObjectTerritory2Association retrieveAccountTeamTerritory(string accountId){
        
        list<Id> lstAccountIds = new list<Id>{accountId};
        Map<Id,List<ObjectTerritory2Association>> mapAccTerritoryAssoc= CS_ARTerritoryService.mapObjectIdsToTerritories(lstAccountIds);
        
        //return mapAccTerritoryAssoc.get(accountId)[0];
        return null;
        
    }// end of retrieveAccountTeamTerritory
    
    @RemoteAction
     public static map<Id, list<Id>> retrieveMapParentTerritoryAndListTerritoryIds(){

        map<Id, list<Id>> mapparentTerritoryAndListTerritoryIds = new map<Id, list<Id>>();
        map<Id, list<Territory2>> mapparentTerritoryAndListTerritories = CS_ARTerritoryService.parentTerritoryAndListTerritories();
        
        for(ID territoryId : mapparentTerritoryAndListTerritories.keySet()){
            
            for(Territory2 childTerritories : retrieveChildTerritories(territoryId, mapparentTerritoryAndListTerritories)){
                
                if(mapparentTerritoryAndListTerritoryIds.get(territoryId) == null){
                    mapparentTerritoryAndListTerritoryIds.put(territoryId, new list<Id>());
                }
                mapparentTerritoryAndListTerritoryIds.get(territoryId).add(childTerritories.Id);
            }
            
        }// end of for-each 
        
        return mapparentTerritoryAndListTerritoryIds;
    }   //  end of retrieveMapParentTerritoryAndListTerritoryIds
    
    
    public static list<Territory2> retrieveChildTerritories(Id parentTerritoryId,  map<Id, list<Territory2>> mapparentTerritoryAndListTerritories){
        
        list<Territory2> lstAllChildTerritories = new list<Territory2>();
        list<Territory2> lstChildTerritories = mapparentTerritoryAndListTerritories.get(parentTerritoryId);
        
        if ( lstChildTerritories == null || lstChildTerritories.size() == 0 ) {
        
            return lstAllChildTerritories;
        
        } else {
            for(Territory2 childTerritory :mapparentTerritoryAndListTerritories.get(parentTerritoryId)){
                lstAllChildTerritories.add(childTerritory);
                lstAllChildTerritories.addALL(retrieveChildTerritories(childTerritory.Id, mapparentTerritoryAndListTerritories));
                
            }
        return lstAllChildTerritories;
        }
        return lstAllChildTerritories;
    }
    
    @RemoteAction
    public static string retrieveDefaultTerritory(){
        
        list<string> lstdefaultTerritoryIDs = CS_ARTerritoryService.retreiveMyTerritoryIDs();
        
        if(lstdefaultTerritoryIDs.size() > 0){
            return lstdefaultTerritoryIDs.get(0);
        } else{
            return '';
        }
    }   //  end of retrieveDefaultTerritory


    @RemoteAction
    public static list<CS_AROpportunityService.CS_AROpportunityWrapper> retrieveOpportunitiesInMyTeamTerritory() {
            return CS_AROpportunityService.retrieveOpportunitiesInMyTeamTerritory();
    }   //  end of retrieveOpportunityIdsInMyTeamTerritory
    
    @RemoteAction
    public static list<CS_AROpportunityService.CS_OpportunityCase> getCasesToBeLinked(list<string> surgeonIds, 
                                                                                     Id opportunityId){
        return CS_AROpportunityService.retrieveCasesToBeLinked(surgeonIds,
                                                               opportunityId); 
    }   //  end of getCasesToBeLinked
    
    @RemoteAction
    public static list<CS_AROpportunityService.CS_LinkOpportunity> getOpportunitiesToBeLinked(list<Id> surgeonId, Id opportunityId){
        return CS_AROpportunityService.retrieveOpportunitiesToBeLinked(surgeonId, opportunityId);
    }   //  end of getOpportunitiesToBeLinked
    
    
    @RemoteAction
    public static list<CS_AROpportunityService.OpportunityWrapper> retreiveActivities(string activityType,
                                                                                                string opportunityId){
        
        return CS_AROpportunityService.retrieveOpportunityActivity(activityType,
                                                                    opportunityId);
    }// end of retreiveActivities
    
    
    @RemoteAction
    public static List<SelectOption> retrieveOpportunityStages(string opportunityType) {
        return CS_AROpportunityService.retrieveOpportunityStages(opportunityType);
    }   //  end of retrieveOpportunityStages
    
    
    public list<Schema.RecordTypeInfo> getOpportunityTypes(){
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Opportunity').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        
        return recordTypeInfo;
    }   //  end of getOpportunityTypes
    
    @RemoteAction
    public static List<SelectOption> retrieveOpportunityTypeValues() {
        return CS_ARContactsService.getPickValues(new Opportunity(), 'Type', null);
    }
    
    @RemoteAction
    public static List<SelectOption> retrieveOpportunityContactRoleValues() {
        return CS_ARContactsService.getPickValues(new OpportunityContactRole(), 'Role', null);
    }
    
    @RemoteAction
    public static List<SelectOption> retrieveCompetitiveCompanyValues() {
        return CS_ARContactsService.getPickValues(new Opportunity(), 'Competitive_Company__c', null);
    }// end of retrieveCompetitiveCompanyValues
    
    @RemoteAction
    public static List<SelectOption> retrieveOpportunityTeamRoleValues() {
        return CS_ARContactsService.getPickValues(new OpportunityTeamMember(), 'TeamMemberRole', null);
    }
    
    @RemoteAction
    public static List<SelectOption> retrieveOpportunityCloseLostReasons(string opportunityType) {
        //return CS_ARContactsService.getPickValues(new Opportunity(), 'Close_Lost_Reasons__c', null);
        return CS_AROpportunityService.retrieveClosedLostReason(opportunityType);
    }
    
    @RemoteAction
    public static List<SelectOption> retrieveCompetitiveConversionValues() {
        return CS_ARContactsService.getPickValues(new Opportunity(), 'Competitve_Conversion__c', null);
    }
    
    @RemoteAction
    public static List<SelectOption> retrieveOpportunityStageValues(string opportunityType) {
        //return CS_ARContactsService.getPickValues(new Opportunity(), 'StageName', null);
        return retrieveOpportunityStages(opportunityType);
        
    }
    
    @RemoteAction
    public static List<SelectOption> retrieveOpportunityProductCategoryValues(string opportunityType) {
        //return CS_ARContactsService.getPickValues(new Opportunity(), 'Product_Category__c', null);
        return CS_AROpportunityService.retrieveOpportunityProductCategories(opportunityType);
    }
    
    @RemoteAction
    public static OpportunityContactRole saveOpportunityContactRole(string opportunityId,
                                                          string contactId,
                                                          string opportunityContactRole,
                                                          boolean primary){
    
        return CS_AROpportunityService.cSaveOpportunityContactRole(opportunityId,
                                                                   contactId,
                                                                   opportunityContactRole,
                                                                   primary);
    }
    
    @RemoteAction
    public static OpportunityTeamMember saveOpportunityTeamRole(string opportunityId,
                                                          string salesRepId,
                                                          string opportunityTeamRole){
    
        return CS_AROpportunityService.cSaveOpportunityTeamRole(opportunityId,
                                                                   salesRepId,
                                                                   opportunityTeamRole);
    }
    
    @RemoteAction
    public static void deleteOpportunityContactRole(string opportunityContactRoleId){
        
        CS_AROpportunityService.cDeleteOpportunityContactRole(opportunityContactRoleId);
    }
    
     @RemoteAction
    public static void deleteOpportunityTeamMember(string opportunityTeamMemberId){
        
        CS_AROpportunityService.cDeleteOpportunityTeamMember(opportunityTeamMemberId);
    }
    
     @RemoteAction
    public static void deleteOpportunitySurgeon(string opportunitySurgeonId){
        
        CS_AROpportunityService.cDeleteOpportunitySurgeon(opportunitySurgeonId);
    }
    
    @RemoteAction
    public static CS_AROpportunityService.CS_AROpportunityWrapper cancelOpportunity(string opportunityId,
                                         string cancelReason){
        
       return CS_AROpportunityService.cSaveCancelledOpportunity(opportunityId,
                                                         cancelReason);
    }
    
     @RemoteAction
    public static void createNote(string opportunityId,
                                         string noteBody,
                                         string noteId){
        
       CS_AROpportunityService.createNote(opportunityId,
                                           noteBody,
                                           noteId);
    }
    
    @RemoteAction
    public static CS_AROpportunityService.CS_AROpportunityWrapper saveOpportunityStage(string opportunityId,
                                                                                       string stageName,
                                                                                       string closeLostReason){
        
       return CS_AROpportunityService.cSaveOpportunityStage(opportunityId,
                                                            stageName,
                                                            closeLostReason);
    }
    
    @RemoteAction
    public static CS_AROpportunityService.CS_AROpportunityWrapper retrieveOpportunity(string opportunityId){
        
        return CS_AROpportunityService.buildCS_AROpportunityWrapper(opportunityId);
    }
    
     @RemoteAction
    public static list<Linked_Opportunity__c> saveLinkedOpportunities(string opportunityId, 
                                                                                         list<string> lstLinkedOpportunityIds){
        
       return CS_AROpportunityService.cSaveLinkedOpportunities(opportunityId,
                                                         lstLinkedOpportunityIds);
    }
    
     @RemoteAction
    public static void deleteLinkedOpportunity(string linkedOpportunityId){
        
        CS_AROpportunityService.cdeleteLinkedOpportunity(linkedOpportunityId);
    }
    
    @RemoteAction
    public static list<Opportunity_Case__c> saveLinkedCases(string opportunityId, 
                                                                list<string> lstLinkedCaseIds){
        
       return CS_AROpportunityService.cSaveLinkedCases(opportunityId,
                                                         lstLinkedCaseIds);
    }
    @RemoteAction
    public static CS_AROpportunityService.CS_AROpportunityWrapper saveOpportunitySurgeons(string opportunityId, 
                                                                    list<Id> lstsurgeonIds){
        
       return CS_AROpportunityService.cSaveOpportunitySurgeons(opportunityId,
                                                         lstsurgeonIds);
    }
    
     @RemoteAction
    public static void deleteLinkedCase(string linkedOpportunityId){
        
        CS_AROpportunityService.cdeleteLinkedCase(linkedOpportunityId);
    }
    
    @RemoteAction
    public static map<Id, list<Territory2>> retrieveUserTeams(){
        
        return CS_ARTerritoryService.parentTerritoryAndListTerritories();
    }
    
    @RemoteAction
    public static CS_AROpportunityService.CS_AROpportunityWrapper saveOpportunityN( map<String,Object> objOpportunity,
                                                            list<string> lstsurgeonIds,
                                                            list<string> lsSalesRep,
                                                            list<string> lstKeyContacts,
                                                            list<string> lstLinkOppIds,
                                                            list<OpportunityLineItem> lstLineItems){
                                                                
                                                                
        return CS_AROpportunityService.cSaveOpportunity(objOpportunity,
                                                        lstsurgeonIds,
                                                        lsSalesRep,
                                                        lstKeyContacts,
                                                        lstLinkOppIds,
                                                        lstLineItems);                                                      
    }
    
    @RemoteAction
    public static CS_AROpportunityService.CS_AROpportunityWrapper saveOpportunity(string opportunityId,
                                                            string opportunityOwner,
                                                            string opportunityName,
                                                            string accountId,
                                                            string opportunityCloseDate,
                                                            list<string> lstSurgeonIds,
                                                            list<string> lsSalesRep,
                                                            list<OpportunityLineItem> products,
                                                            string competitiveConversion,
                                                            string competitiveCompany,
                                                            string opportunityType,
                                                            string opportunityStage,
                                                            string procedureId,
                                                            decimal annualNumberOfProcedures,
                                                            decimal potentialRevenuePerCase,
                                                            decimal patientVolume,
                                                            decimal potentialUserNumber,
                                                            decimal totalNumOfTowers,
                                                            decimal potentialRevenuePerTower,
                                                            decimal totalNumOfORs,
                                                            decimal equipmentCost,
                                                            decimal laborAndMaterials,
                                                            decimal totalBudgetary,
                                                            decimal finalPOAmount,
                                                            string estimatedInstallDate,
                                                            string quoteNum,
                                                            string quoteDate,
                                                            decimal noChargeEquipmentValue,
                                                            decimal disposablePurchaseValue,
                                                            decimal totalAnnualPotential,
                                                            string quoteId,
                                                            string productCategory) {
        
        system.debug('##-- Products from UI: ' + products);
        system.debug('##-- potentialRevenuePerCase: ' + potentialRevenuePerCase);
        //Decimal decimalPotentialRevenuePerCase = decimal.valueOf(potentialRevenuePerCase);
        //system.debug('##-- decimalPotentialRevenuePerCase: ' + decimalPotentialRevenuePerCase);
        Date p_estimatedInstallDate;
        if(estimatedInstallDate != null){
            p_estimatedInstallDate = Date.parse(estimatedInstallDate);
        }
        
        Date p_quoteDate;
        if(quoteDate != null){
            p_quoteDate = Date.parse(quoteDate);
        }
        return CS_AROpportunityService.cSaveOpportunity(opportunityId,
                                                  opportunityOwner,
                                                  opportunityName,
                                                  accountId,
                                                  Date.parse(opportunityCloseDate),
                                                  lstSurgeonIds, 
                                                  lsSalesRep,
                                                  products,
                                                  competitiveConversion,
                                                  competitiveCompany,
                                                  opportunityType,
                                                  opportunityStage,
                                                  procedureId,
                                                  annualNumberOfProcedures,
                                                  potentialRevenuePerCase,
                                                  patientVolume,
                                                  potentialUserNumber,
                                                  totalNumOfTowers,
                                                  potentialRevenuePerTower,
                                                  totalNumOfORs,
                                                  equipmentCost,
                                                  laborAndMaterials,
                                                  totalBudgetary,
                                                  finalPOAmount,
                                                  p_estimatedInstallDate, //Date.parse(estimatedInstallDate),
                                                  quoteNum,
                                                  p_quoteDate,
                                                  noChargeEquipmentValue,
                                                  disposablePurchaseValue,
                                                  totalAnnualPotential,
                                                  quoteId,
                                                  productCategory);

    }  
   
    
    @RemoteAction
    public static void deleteOpportunity(string opportunityId){
    
        Opportunity objOppty = new Opportunity(Id = opportunityId);
        
        delete objOppty ;
    
    }// end of deleteOpportunity

    // added by chad for 4.1 - Task Support
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
    // end added by chad for 4.1 - Task Support    

    // added by chad for 4.4 Event support
    @RemoteAction   
    public static void linkEvents(String oppId, List<String> eventIds) {

        Set<String> uniqueEventIds = new Set<String>(eventIds);
        for ( String eventId : uniqueEventIds ) {
            CS_EventsService.linkOpportunity(eventId, oppId);
        }

    }    
    @RemoteAction
    public static void unlinkEvents(String oppId, List<String> eventIds) {
        
        Set<String> opIdHolder = new Set<String>();
        opIdHolder.add(oppId);

        Set<String> uniqueEventIds = new Set<String>(eventIds);
        for ( String eventId : uniqueEventIds ) {
            CS_EventsService.unlinkOpportunity(eventId, opIdHolder);
        }
        
    }
    // end added by chad for 4.4 Event support    
    
    //added by srinivas.sattoor on 8.21.2017 for release 4.4 CID-000440
    // this method adds an attachment to the opportunity
    @RemoteAction 
    public static void saveOpportunityAttachment(string opportunityId, string attachmentBody, string attachmentName){
        CS_AROpportunityService.saveOpportunityAttachment(opportunityId, attachmentBody, attachmentName); 
    }// end of saveOpportunityAttachment
    
    //added by srinivas.sattoor on 8.29.2017 for release 4.4 CID-000440
    // this method adds an attachment to the opportunity
    @RemoteAction 
    public static void updateOpportunityAttachment(string attachmentId, string attachmentName){ 
        CS_AROpportunityService.updateOpportunityAttachment(attachmentId, attachmentName); 
    }// end of saveOpportunityAttachment
    
    //added by srinivas.sattoor on 8.29.2017 for release 4.4 CID-000440
    // this method adds an attachment to the opportunity
    @RemoteAction 
    public static void deleteOpportunityAttachment(string attachmentId, string opportunityId){ 
        //CS_AROpportunityService.deleteOpportunityAttachment(attachmentId, opportunityId); 
    }// end of saveOpportunityAttachment
     
}   //  end of CS_AROpportunityCC