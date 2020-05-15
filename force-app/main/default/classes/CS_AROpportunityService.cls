public with sharing class CS_AROpportunityService {

     // returns a map of record type to list account id 
    public static list<CS_AROpportunityWrapper> retrieveOpportunitiesInMyTeamTerritory() {
        
        list<CS_AROpportunityWrapper> lstCS_AROpportunityWrapper = new list<CS_AROpportunityWrapper>();
        list<Id> lstMyTeamOpportunityIds = new list<Id>();
        list<User> lstMyTeamHierarchyUsers = CS_ARTerritoryService.retrieveUsersInMyTerritory();//new list<Id>();
        
        system.debug('##--retrieveOpportunitiesInMyTeamTerritory.lstMyTeamHierarchyUsers: '+ lstMyTeamHierarchyUsers);
        list<Id>lstOwnerIds = new list<Id>();
        list<Id> lstAccountIds = new list<Id>();
        
        // Added by srinivas sattoor on 9.28.2017 for 4.4 CID-000497 
        List<Id> lstHealthCareProviderIdsInMyTerritory = CS_ARTerritoryService.retrieveHealthCareProvidersInMyTeamTerritory();
        system.debug('##--lstHealthCareProviderIdsInMyTerritory: '+ lstHealthCareProviderIdsInMyTerritory);
        list<Opportunity> lstMyTeamOpportunities = new list<Opportunity>();

        for (Opportunity objOpportunity : [SELECT Id, Name, Account.Name, Procedure__c, Account.Preferred_Name__c, Procedure__r.Name, CreatedDate, LastModifiedDate,
                                                (SELECT Id, Product2.Material_Number__c, Product2.Description, Quantity, TotalPrice, UnitPrice, Product2Id, 
                                                                PriceBookEntryId, Product2.Name FROM OpportunityLineItems),// opportunity line items.
                                                Annual_Number_of_Procedures__c, Type, Potential_Revenue_per_Case__c, Product_Category__c,isClosed,
                                                (SELECT Id, ContactId, Contact.Name, Role, IsPrimary FROM OpportunityContactRoles),
                                                (SELECT Id, UserId, User.Name, User.Title ,OpportunityId, TeamMemberRole FROM OpportunityTeamMembers),//additional sales reps
                                                (SELECT Id, Surgeon__c, Surgeon__r.Name, Opportunity__c 
                                                              FROM Opportunity_Surgeons__r),// opportunity surgeons
                                                (SELECT Id, StageName, Name, Type, Potential_Revenue_per_Case__c, CloseDate  FROM  Opportunities__r),// linked Oppotunities
                                                (SELECT Id, Opportunity__c, Linked_Opportunity__c, Linked_Opportunity__r.Name, Linked_Opportunity__r.Type, 
                                                                        Linked_Opportunity__r.Potential_Revenue_per_Case__c, Linked_Opportunity__r.CloseDate  
                                                                        FROM  Linked_Opportunities__r),// linked Oppotunities
                                                    StageName, CloseDate, Owner.Name, Owner.Profile.Name, Owner.IsActive, probability, Competitve_Conversion__c, Competitive_Company__c, Close_Lost_Reasons__c,
                                                    Current_FY_Revenue__c, Total_Annual_Potential__c, Quote_Id__c, OwnerId, Patient_Volume__c, Potential_User_Number__c,
                                                    Total_of_Towers__c,Potential_Revenue_Per_Tower__c,Total_of_OR_s__c,Equipment_Cost__c,Labor_and_Materials__c, 
                                                    Total_Budgetary__c, Final_PO_Amount__c, Estimated_Install_Date__c, No_Charge_Equipment_Value__c, Disposable_Purchase_Value__c, 
                                                    Contract_Years__c, Quote__c, Quote_Date__c, Enrollment_Forms_Sent__c, Enrollment_Form_Type__c,
                                                    Integration_Type__c, Support_Plan__c,Billing_Method__c, Agreement_End_Date__c, Total_Agreement_Value__c, 
                                                    Agreement_Term_Years__c, Customer_PO_Number__c, Agreement_Start_Date__c, SAP_Agreement_Number__c
                                                    
                                                    FROM Opportunity
                                                    WHERE (OwnerId IN :lstMyTeamHierarchyUsers
                                                    // Added by srinivas sattoor on 9.28.2017 for 4.4 CID-000497
                                                    //Added logic to show Unassigned Opportunities of 3 types(SOS, Synergy Integration, Synergy Service) in AXIS.
                                                    OR (AccountId IN :lstHealthCareProviderIdsInMyTerritory 
                                                         AND (RecordType.Name  =:Constant.OPPORTUNITY_RECORDTYPE_NAME_SOS
                                                            OR RecordType.Name  =:Constant.OPPORTUNITY_RECORDTYPE_NAME_SYSNERGY_INTEGRATION
                                                            OR RecordType.Name  =:Constant.OPPORTUNITY_RECORDTYPE_NAME_SYNERGY_SERVICE) ) )
                                                    AND StageName !=  'Cancelled'
                                                    ORDER BY Type Asc, Probability Asc] ) {
            
            lstMyTeamOpportunityIds.add(objOpportunity.Id);
            lstMyTeamOpportunities.add(objOpportunity);
            lstOwnerIds.add(objOpportunity.OwnerId);
            //Added by Srinivas Sattoor 4.15.2017 to change the logic to use 
            //Account territory instead of user territory
            if(objOpportunity.AccountId != null){
                lstAccountIds.add(objOpportunity.AccountId); 
            } 
            
            
        }
        system.debug('##--retrieveOpportunitiesInMyTeamTerritory.lstMyTeamOpportunities: '+ lstMyTeamOpportunities);
        lstCS_AROpportunityWrapper = retrieveOpportunityIdsInMyTeamTerritory(lstMyTeamOpportunityIds,
                                                                            lstMyTeamOpportunities,
                                                                            lstOwnerIds,
                                                                            lstAccountIds);
        
        system.debug('##-- retrieveOpportunityIdsInMyTeamTerritory.lstCS_AROpportunityWrapper: '+ lstCS_AROpportunityWrapper);
        return lstCS_AROpportunityWrapper;

    }


    public static boolean canAccessOpportunity(String userId, String oppId) {
        List<Opportunity> opps = [select Id, OwnerId from Opportunity where Id=:oppId];
        if ( opps == null || opps.size() == 0) {
            return false;
        }

        String ownerId = opps[0].OwnerId;
        return false;
    }
    
    public static list<CS_AROpportunityWrapper> retrieveOpportunityIdsInMyTeamTerritory(list<Id>lstMyTeamOpportunityIds,
                                                                                        list<Opportunity> lstMyTeamOpportunities,
                                                                                        list<Id>lstOwnerIds,
                                                                                        list<Id>lstAccountIds) {
                                                                                            
        list<CS_AROpportunityWrapper> lstCS_AROpportunityWrapper = new list<CS_AROpportunityWrapper>();
        //commented by srinivas sattoor 4.15.2017 as this method is not used
        //Map<Id,List<ObjectTerritory2Association>> territoryMap = CS_ARTerritoryService.mapObjectIdsToTerritories(lstMyTeamOpportunityIds);
        //added below by srinivas sattoor 4.15.2017 for account territory
        Map<Id,List<ObjectTerritory2Association>> accoutnTerritoryMap = CS_ARTerritoryService.mapObjectIdsToTerritories(lstAccountIds); 
        
        //retrieve the owners territory association.
        Map<Id,List<UserTerritory2Association>> userTerritoryMap = CS_ARTerritoryService.mapUserIdsToTerritories(lstOwnerIds);
        
        // retrieve the current user's territory ids
        Set<Id> userTerritoryIds = new Set<Id>(CS_ARTerritoryService.retrieveMyTerritoryIds(true));
            
        for(Opportunity objOpportunity :lstMyTeamOpportunities){
            
            CS_AROpportunityWrapper objWrapper = new CS_AROpportunityWrapper(objOpportunity);
            if(userTerritoryMap.containsKey(objOpportunity.ownerId)){
                //look up user territories
                List<UserTerritory2Association> userTerritoryAssciations = userTerritoryMap.get(objOpportunity.ownerId);
                
                if(userTerritoryAssciations.size() > 0){
                    
                    objWrapper.ownerProviderTerritory = userTerritoryAssciations[0].Territory2.Name;
                    objWrapper.ownerProviderTerritoryId = userTerritoryAssciations[0].Territory2Id;
                    objWrapper.ownerProviderParentTerritoryId = userTerritoryAssciations[0].Territory2.ParentTerritory2Id;
                    
                } 
            }
            if(accoutnTerritoryMap.containsKey(objOpportunity.AccountId)){
                //look up account territories
                List<ObjectTerritory2Association> lstAccountTerritoryAssciations = accoutnTerritoryMap.get(objOpportunity.AccountId);
                
                if(lstAccountTerritoryAssciations.size() > 0){
                    
                    objWrapper.accountTerritory = lstAccountTerritoryAssciations[0].Territory2.Name;
                    objWrapper.accountTerritoryId = lstAccountTerritoryAssciations[0].Territory2Id;
                    objWrapper.accountParentTerritoryId = lstAccountTerritoryAssciations[0].Territory2.ParentTerritory2Id;
                    
                }
            }
            
            lstCS_AROpportunityWrapper.add( objWrapper ); 
            
        }// end of for-each
            
        return lstCS_AROpportunityWrapper;
    }
    
    public static list<CS_OpportunityTypeDashboardWrapper> retrieveOpportunityTypeDashboardWrapper(list<Opportunity> lstMyTeamOpportunities,
                                                                                                    list<Id>lstOwnerIds) {
                                                                                        
        
        map<string, CS_OpportunityTypeDashboardWrapper> mapOpportunityTypeAndCS_OpportunityTypeDashboardWrapper = new map<string, CS_OpportunityTypeDashboardWrapper>();
        
        for(Opportunity objOpportunity : lstMyTeamOpportunities){
            
            if(mapOpportunityTypeAndCS_OpportunityTypeDashboardWrapper.get(objOpportunity.Type) == null){
                mapOpportunityTypeAndCS_OpportunityTypeDashboardWrapper.put(objOpportunity.Type, new CS_OpportunityTypeDashboardWrapper(objOpportunity));
            }
            
            mapOpportunityTypeAndCS_OpportunityTypeDashboardWrapper.get(objOpportunity.Type).add(objOpportunity);
        }   //  end of for-each opportunity
        
        return mapOpportunityTypeAndCS_OpportunityTypeDashboardWrapper.values();
    }// end of retrieveOpportunityTypeDashboardWrapper
    
    public static list<CS_OpportunityCase> retrieveCasesToBeLinked( list<Id> surgeonIds, 
                                                                    Id oppId) {
        list<CS_OpportunityCase> lstCS_OpportunityCases = new list<CS_OpportunityCase>();
        set<Id> setExistingLinkedCaseIds = new set<Id>();
        
        for(Opportunity_Case__c objOppCase : [SELECT Id, Case__c FROM Opportunity_Case__c WHERE Opportunity__c = :oppId]){
            
            setExistingLinkedCaseIds.add(objOppCase.Case__c);
        }
        
        for(Case__c objCase : [SELECT Id, Event_Start_Date__c, Practitioner__r.Name,
                                    Owner.Name, Health_Care_Provider__r.Name, Status__c,
                                    (SELECT Id, Procedure__c, Case__c, Procedure__r.Name FROM Case_Procedures__r
                                     WHERE Procedure__r.TaxonGroupId__c = 'procedure')
                                   FROM Case__c 
                                   WHERE Practitioner__c IN :surgeonIds
                                        ]){
            if(!setExistingLinkedCaseIds.contains(objCase.Id)){
                lstCS_OpportunityCases.add(new CS_OpportunityCase(objCase));
            }             
        }
        
        return lstCS_OpportunityCases;
    }// end of retrieveCasesToBeLinked
    
    public static list<CS_LinkOpportunity> retrieveOpportunitiesToBeLinked(list<string> lstSurgeonIds, 
                                                                            Id opportunityId) {
        list<CS_LinkOpportunity> lstCS_LinkOpportunities = new list<CS_LinkOpportunity>();
        system.debug('##--lstsurgeonId: '+ lstSurgeonIds);
        
        set<Id> setExistingLinkedOpportunityIds = new set<Id>();
        
        /*
            Vishnu Release 4.4
                Adding a check on Opportunity Id so that we get all the Opps for Surgeon
        */
        if(opportunityId != null &&
            String.isNotBlank(opportunityId)){
            for(Linked_Opportunity__c objLinkedOpp : [SELECT Id, Linked_Opportunity__c FROM Linked_Opportunity__c WHERE Opportunity__c = :opportunityId]){
            
                setExistingLinkedOpportunityIds.add(objLinkedOpp.Linked_Opportunity__c);
            }
        }
        
                                        
        for(Opportunity_Surgeons__c objOpptySurgeon : [SELECT Id, Opportunity__c, Opportunity__r.Name, Opportunity__r.Type,
                                                        Opportunity__r.StageName, Opportunity__r.Potential_Revenue_per_Case__c,
                                                        Opportunity__r.CloseDate, Surgeon__c, Opportunity__r.CreatedBy.Name, 
                                                        Opportunity__r.Current_FY_Revenue__c,
                                                        Surgeon__r.Name, Opportunity__r.Account.Name         //  Vishnu Release 4.4 Added this to show the Surgeon name
                                                            FROM Opportunity_Surgeons__c
                                                            WHERE Surgeon__c IN :lstSurgeonIds]){
            if(!setExistingLinkedOpportunityIds.contains(objOpptySurgeon.Opportunity__c)){                           
                lstCS_LinkOpportunities.add(new CS_LinkOpportunity(objOpptySurgeon));
            }
        }
        system.debug('##--lstCS_LinkOpportunities: '+ lstCS_LinkOpportunities);
        return lstCS_LinkOpportunities;
    }// end of retrieveOpportunitiesToBeLinked

    /*
        Vishnu Release 4.4
            Retrieves Opportunities that are eligible to link/unlink to the Lead
    */
    public static List<CS_LinkOpportunity> retrieveOpportunitiesToBeLinkedToSurgeon(String surgeonId, String conferenceId, Boolean toUnlink) {
        List<CS_LinkOpportunity> lstLinkableOpps = new List<CS_LinkOpportunity>();
        Set<String> setLinkedOppIds = new Set<String>();
        
        lstLinkableOpps = retrieveOpportunitiesToBeLinked(new List<String>{surgeonId}, null);

        for(Opportunity_Leads__c objLeadOpp : [SELECT Id, Opportunity__c FROM Opportunity_Leads__c 
                                                WHERE Conference_Member__r.Contact__r.AccountId = :surgeonId
                                                  AND Conference_Member__r.Conference__c = :conferenceId]){
            setLinkedOppIds.add(objLeadOpp.Opportunity__c);
        }   //  end of for-each linked Opps

        if(toUnlink){
            for(Integer i=0; i < lstLinkableOpps.size() ; i++){
                if(! setLinkedOppIds.contains(lstLinkableOpps[i].objOpportunitySurgeon.Opportunity__c)){
                    lstLinkableOpps.remove(i);
                }
            }
        } else {
            for(Integer i=0; i < lstLinkableOpps.size() ; i++){
                if(setLinkedOppIds.contains(lstLinkableOpps[i].objOpportunitySurgeon.Opportunity__c)){
                    lstLinkableOpps.remove(i);
                }
            }
        }


        return lstLinkableOpps;
    }   //  end of retrieveOpportunitiesToBeLinkedToSurgeon
    
    public static OpportunityContactRole cSaveOpportunityContactRole(string opportunityId,
                                                          string contactId,
                                                          string opportunityContactRole,
                                                          boolean primary){
    
        OpportunityContactRole objOpptyContactRole = new OpportunityContactRole(OpportunityId= opportunityId,
                                                                                ContactId =contactId,
                                                                                IsPrimary = primary,
                                                                                Role = opportunityContactRole);
                                                                                
            
        insert objOpptyContactRole;
        
        Key_Contacts_Opportunity_log__c objKCOL = new Key_Contacts_Opportunity_log__c();
        objKCOL.opportunity__c = opportunityId;
        objKCOL.Contact__c = contactId;
        insert objKCOL;
            
        return objOpptyContactRole;
    
    }// end of cSaveOpportunityContactRole
    
    public static CS_AROpportunityService.CS_AROpportunityWrapper cSaveOpportunitySurgeons(string opportunityId,
                                                    list<Id> lstSurgeonIds){
        
        list<Opportunity_Surgeons__c> lstOpportunitySurgeons = new list<Opportunity_Surgeons__c>();
        for(Id surgeonId :lstSurgeonIds){
            Opportunity_Surgeons__c objOpptySurgeon = new Opportunity_Surgeons__c(Opportunity__c= opportunityId,
                                                                                Surgeon__c = surgeonId);
            lstOpportunitySurgeons.add(objOpptySurgeon);
        }
        insert lstOpportunitySurgeons;
        return buildCS_AROpportunityWrapper(opportunityId);
    
    }// end of cSaveOpportunitySurgeon
    
    public static OpportunityTeamMember cSaveOpportunityTeamRole(string opportunityId,
                                                          string salesRepId,
                                                          string opportunityTeamRole){
        system.debug('##--cSaveOpportunityTeamRole.salesRepId: '+ salesRepId); 
        list<OpportunityTeamMember> lstOpportunityTeamMembers = new list<OpportunityTeamMember>();
        OpportunityTeamMember objOpptyTeamMember = new OpportunityTeamMember(OpportunityId= opportunityId,
                                                                                UserId =salesRepId,
                                                                                TeamMemberRole = opportunityTeamRole,
                                                                                OpportunityAccessLevel = 'Edit');
        lstOpportunityTeamMembers.add(objOpptyTeamMember);
        //insert objOpptyTeamMember;
        createOpportunityTeamMember ct = new createOpportunityTeamMember();
        ct.c_createOpportunityTeamMember(lstOpportunityTeamMembers);
        return objOpptyTeamMember;
    
    }// end of cSaveOpportunityContactRole
    
    public static CS_AROpportunityService.CS_AROpportunityWrapper cSaveCancelledOpportunity(string OpportunityId,
                                                 string cancellationReason){
        
        Opportunity objOppty = new Opportunity(Id = OpportunityId,
                                               StageName = 'Cancelled',
                                               Cancelled_with_a_Reason__c = cancellationReason);
        
        update objOppty;
        return buildCS_AROpportunityWrapper(objOppty.Id);
    }// end of cSaveCancelledOpportunity
    
    public static CS_AROpportunityService.CS_AROpportunityWrapper cSaveOpportunityStage(string OpportunityId,
                                                                                        string stageName,
                                                                                        string closeLostReason){
        
        Opportunity objOppty = new Opportunity(Id = OpportunityId,
                                               StageName = stageName,
                                               Close_Lost_Reasons__c = closeLostReason);
        
        update objOppty;
        
        return buildCS_AROpportunityWrapper(objOppty.Id);
    }// end of cSaveCancelledOpportunity
    
    public static void cDeleteOpportunityContactRole(string opportunityContactRoleId){
               List<OpportunityContactRole> lstOppcontactrole = [select id, contactid, OpportunityId from OpportunityContactRole where id =: opportunityContactRoleId];
  if(!lstOppcontactrole.isEmpty()){
   Key_Contacts_Opportunity_log__c objKCOL = new Key_Contacts_Opportunity_log__c();
   objKCOL.deleted_by__c = system.userinfo.getUserid();
   objKCOL.opportunity__c = lstOppcontactrole[0].OpportunityId;
   objKCOL.Contact__c = lstOppcontactrole[0].Contactid;
   insert objKCOL;
  }
        OpportunityContactRole objOpptyContactRole = new OpportunityContactRole(Id = opportunityContactRoleId);
       delete objOpptyContactRole ;
    }// end of deleteOpportunityContactRole
    
    public static void cDeleteOpportunityTeamMember(string opportunityTeamMemberId){
        
        OpportunityTeamMember objOpptyTeamMember = new OpportunityTeamMember(Id = opportunityTeamMemberId);
        
        deleteOpportunityTeamMember dt =new deleteOpportunityTeamMember();
        dt.c_deleteOpportunityTeamMember(objOpptyTeamMember);
        //delete objOpptyTeamMember ;
    }// end of deleteOpportunityTeamMemberRole
    
    public static void cDeleteOpportunitySurgeon(string opportunitySurgeonId){
        
        Opportunity_Surgeons__c objOpptySurgeon = new Opportunity_Surgeons__c(Id = opportunitySurgeonId);
        delete objOpptySurgeon ;
    }// end of cDeleteOpportunitySurgeon
    
    public static void createNote(string OpportunityId, string noteBody, string noteId){
        
        Note opportunityNote = new Note(ParentId = OpportunityId,
                                        Title = 'Opportunity Note',
                                        Body = noteBody);
                                        
        if(!string.isBlank(noteId)){
            opportunityNote.Id = noteId;
        }
        upsert opportunityNote ;
    }// end of createNote
    
    // renamed by chad for v4.4
    public static void saveNote(string OpportunityId, string noteBody, string noteId){
        
        Note opportunityNote = new Note(ParentId = OpportunityId,
                                        Title = 'Opportunity Note',
                                        Body = noteBody);
                                        
        if(!string.isBlank(noteId)){
            opportunityNote.Id = noteId;
        }
        upsert opportunityNote ;
    }// end of createNote
    
    public static void cdeleteLinkedOpportunity(string linkedOpportunityId){
        
        Linked_Opportunity__c objLinkOpportunity = new Linked_Opportunity__c (Id = linkedOpportunityId);
        
        delete objLinkOpportunity;  
    }// end of cdeleteLinkedOpportunity
    
    public static void cdeleteLinkedCase(string linkedCaseId){
        
        Opportunity_Case__c objLinkCase = new Opportunity_Case__c (Id = linkedCaseId);
        
        delete objLinkCase; 
    }// end of cdeleteLinkedCase
    
    public static CS_AROpportunityWrapper cSaveOpportunity( map<String,Object> objOpportunity,
                                                            list<string> lstsurgeonIds,
                                                            list<string> lsSalesRep,
                                                            list<string> lstKeyContacts,
                                                            list<string> lstLinkOppIds,
                                                            list<OpportunityLineItem> lstLineItems){
        set<Id> setExistingTeamMembers = new set<Id>();
        set<Id> setExistingOpportunitySurgeons = new set<Id>();
        list<OpportunityTeamMember> lstOpportunityTeamMembers = new list<OpportunityTeamMember>();
        
        //commented by srinivas sattoor for 4.4 CID-000497
        //string oppOwner= (string)objOpportunity.get('opportunityOwner');
        string oppOwner;
        if((string)objOpportunity.get('opportunityOwner') == '0' ){
            Default_Owner__c cs = Default_Owner__c.getOrgDefaults();
            if ( cs != null && cs.Default_Owner__c != null ) { 
              oppOwner = cs.Default_Owner__c;
            }
            
        }else{
            oppOwner= (string)objOpportunity.get('opportunityOwner');
        }
        
        string oppType = (string)objOpportunity.get('opportunityType');
        string stageName = (string)objOpportunity.get('opportunityStage');
        Id oppId = (String.isBlank((string)objOpportunity.get('opportunityId')) ? null : (string)objOpportunity.get('opportunityId'));
        
        
        string p_OppCloseDate = (String)objOpportunity.get('opportunityCloseDate') ;
        Date oppCloseDate = null;
        if ( p_OppCloseDate != null ) {
            oppCloseDate = Date.parse(p_OppCloseDate);
        }
        
        string p_OppEstInstallDate = (String)objOpportunity.get('estimatedInstallDate') ;
        Date oppEstInstallDate = null;
        if (p_OppEstInstallDate != null ) {
            oppEstInstallDate = Date.parse(p_OppEstInstallDate);  
        }
        system.debug('##--cSaveOpportunity.oppEstInstallDate: '+ oppEstInstallDate);
        string p_OppQuoteDate = (String)objOpportunity.get('quoteDate') ;
        Date oppQuoteDate = null;
        if (p_OppQuoteDate!= null ) {
            oppQuoteDate = Date.parse(p_OppQuoteDate); 
        }
        
        string p_EnrollmentFormsSent = (String)objOpportunity.get('enrollmentFormsSent') ;
        Date oppEnrollmentFormsSent = null;
        if (p_EnrollmentFormsSent != null ) {
            oppEnrollmentFormsSent = Date.parse(p_EnrollmentFormsSent); 
        }
        
        string p_AnnualNumberOfProcedures = (string)objOpportunity.get('annualNumberOfProcedures');
        decimal annualNumberOfProcedures = null;
        
        // CDID-000056/Swetha Penmethsa/Jan/3/2017/Competitive Conversion/competitive company 
        
        if(p_AnnualNumberOfProcedures != null && p_AnnualNumberOfProcedures != '' && p_AnnualNumberOfProcedures != '-'){
            annualNumberOfProcedures = integer.valueof(p_AnnualNumberOfProcedures);
        }
        
        string p_AgreementStartDate = (String)objOpportunity.get('agreementStartDate') ;
        Date agreementStartDate = null;
        if (p_AgreementStartDate!= null ) {
            agreementStartDate = Date.parse(p_AgreementStartDate); 
        }
        
        string p_AgreementEndDate = (String)objOpportunity.get('agreementEndDate') ;
        Date agreementEndDate = null;
        if (p_AgreementEndDate!= null ) {
            agreementEndDate = Date.parse(p_AgreementEndDate); 
        }
      // CDID-000056/Swetha Penmethsa/Jan/3/2017/Competitive Conversion/competitive company 
      
        Opportunity objOppty = new Opportunity( ownerId = oppOwner,
                                               Name = (string)objOpportunity.get('opportunityName'),
                                               AccountId = (string)objOpportunity.get('accountId'),
                                               CloseDate = oppCloseDate,
                                               Competitve_Conversion__c = (string)objOpportunity.get('competitiveConversion'),
                                               Competitive_Company__c = (string)objOpportunity.get('competitiveCompany'),
                                               Type = oppType,
                                               StageName = stageName, //(string)objOpportunity.get('opportunityStage'),
                                               Procedure__c = (string)objOpportunity.get('procedureId'),
                                               Annual_Number_of_Procedures__c = annualNumberOfProcedures, //(integer)objOpportunity.get('annualNumberOfProcedures'),
                                               Potential_Revenue_per_Case__c = DecimalValueOf(objOpportunity.get('potentialRevenuePerCase')),
                                               Patient_Volume__c = DecimalValueOf(objOpportunity.get('patientVolume')),
                                               Potential_User_Number__c = DecimalValueOf(objOpportunity.get('potentialUserNumber')),
                                               Total_of_Towers__c = DecimalValueOf(objOpportunity.get('totalNumOfTowers')),
                                               Potential_Revenue_Per_Tower__c = DecimalValueOf(objOpportunity.get('potentialRevenuePerTower')),
                                               Total_of_OR_s__c = DecimalValueOf(objOpportunity.get('totalNumOfORs')),
                                               Equipment_Cost__c = DecimalValueOf(objOpportunity.get('equipmentCost')),
                                               Labor_and_Materials__c = DecimalValueOf(objOpportunity.get('laborAndMaterials')),
                                               Total_Budgetary__c = DecimalValueOf(objOpportunity.get('totalBudgetary')),
                                               Final_PO_Amount__c = DecimalValueOf(objOpportunity.get('finalPOAmount')),
                                               Estimated_Install_Date__c = oppEstInstallDate,
                                               Quote__c = (string)objOpportunity.get('quoteNum'),
                                               No_Charge_Equipment_Value__c = DecimalValueOf(objOpportunity.get('noChargeEquipmentValue')),
                                               Disposable_Purchase_Value__c = DecimalValueOf(objOpportunity.get('disposablePurchaseValue')),
                                               Total_Annual_Potential__c = DecimalValueOf(objOpportunity.get('totalAnnualPotential')),
                                               Quote_Id__c = (string)objOpportunity.get('quoteId'),
                                               Quote_Date__c = oppQuoteDate,
                                               Product_Category__c = (string)objOpportunity.get('productCategory'),
                                               RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppType).getRecordTypeId(),
                                               Close_Lost_Reasons__c = (string)objOpportunity.get('closedLostReason'),
                                               Enrollment_Forms_Sent__c = oppEnrollmentFormsSent, 
                                               Enrollment_Form_Type__c = (string)objOpportunity.get('enrollmentFormType'),
                                               //added by srinivas sattoor for 4.4 on 9.20.2017 for CID-000450
                                               Support_Plan__c = DecimalValueOf(objOpportunity.get('supportPlan')),
                                               Integration_Type__c = (string)objOpportunity.get('integrationType'),
                                               Billing_Method__c = (string)objOpportunity.get('billingMethod'),
                                               Agreement_End_Date__c = agreementEndDate,
                                               //Total_Agreement_Value__c = DecimalValueOf(objOpportunity.get('totalAgreementValue')), 
                                               Agreement_Term_Years__c = (string)objOpportunity.get('agreementTerm'), 
                                               Customer_PO_Number__c = (string)objOpportunity.get('customerPONumber'), 
                                               Agreement_Start_Date__c = agreementStartDate, 
                                               SAP_Agreement_Number__c = (string)objOpportunity.get('sapAgreementNumber')
                                               );
                                               
                                               
        system.debug('##--cSaveOpportunity.oppId: '+ oppId); 
          
        if(oppId != null){
            objOppty.Id = oppId;
            
            for(OpportunityTeamMember objTeamMember : [SELECT Id,UserId,OpportunityId FROM OpportunityTeamMember WHERE OpportunityId = :oppId]){
                setExistingTeamMembers.add(objTeamMember.UserId);
            }
            
            for(Opportunity_Surgeons__c objOpportunitySurgeon : [SELECT Id,Surgeon__c ,Opportunity__c  FROM Opportunity_Surgeons__c WHERE Opportunity__c = :oppId]){
                setExistingOpportunitySurgeons.add(objOpportunitySurgeon.Surgeon__c);
            }
            
        }
        
        if(stageName == null){
            objOppty.StageName = retrieveDefaultStage(oppType);
        }
        if(objOppty.Competitve_Conversion__c == 'No'){
            objOppty.Competitive_Company__c = '';
        }
        upsert objOppty;
      
        if(lsSalesRep != null && lsSalesRep.size() > 0){
            
            for(string salesRepId : lsSalesRep){
                
                system.debug('##--cSaveOpportunity.salesRepId: '+ salesRepId);
                if(salesRepId == 'undefined'){
                    continue;
                }
                if(setExistingTeamMembers.contains(salesRepId)){
                    continue;
                }
                OpportunityTeamMember objOpptyTeamMember = new OpportunityTeamMember( OpportunityId = objOppty.Id,
                                                                                      UserId = salesRepId,
                                                                                      OpportunityAccessLevel = 'Edit');
                lstOpportunityTeamMembers.add(objOpptyTeamMember);
            }// end of for-each
            
        }
        system.debug('##--lstOpportunityTeamMembers: '+ lstOpportunityTeamMembers.size());
        if(lstOpportunityTeamMembers.size() > 0){
                
            //insert lstOpportunityTeamMembers;
            createOpportunityTeamMember ct = new createOpportunityTeamMember();
            ct.c_createOpportunityTeamMember(lstOpportunityTeamMembers);
        }
        system.debug('##--lstLineItems: '+ lstLineItems.size());
        if(lstLineItems!=null && lstLineItems.size() > 0){
            
            list<OpportunityLineItem> lstExistinglineItems = new list<OpportunityLineItem>();
            lstExistinglineItems = retrieveExistingOpportunityLineItems(objOppty.Id);
            
            delete lstExistinglineItems;
            
            for(OpportunityLineItem objLineItem :lstLineItems){
                objLineItem.OpportunityId = objOppty.Id;
            }
            
            insert lstLineItems;
        }
        else{
   list<OpportunityLineItem> lstExistinglineItems = new list<OpportunityLineItem>();
            lstExistinglineItems = retrieveExistingOpportunityLineItems(objOppty.Id);
            
            delete lstExistinglineItems;
  }
       
        if(lstsurgeonIds != null && lstsurgeonIds.size() > 0){
            
            list<Opportunity_Surgeons__c> lstOpportunitySurgeons = new list<Opportunity_Surgeons__c>();
            
            for(string surgeonId : lstsurgeonIds){
                
                if(setExistingOpportunitySurgeons.contains(surgeonId)){
                    continue;
                }
                
                Opportunity_Surgeons__c objOpptySurgeon = new Opportunity_Surgeons__c( Opportunity__c = objOppty.Id,
                                                                                       Surgeon__c = surgeonId);
                lstOpportunitySurgeons.add(objOpptySurgeon);
            }// end of for-each
            
            if(lstOpportunitySurgeons.size() > 0){
                insert lstOpportunitySurgeons;
            }
            
        }
        
        system.debug('##--buildCS_AROpportunityWrapper: '+ buildCS_AROpportunityWrapper(objOppty.Id));
          
        return buildCS_AROpportunityWrapper(objOppty.Id);
        
    }// end of cSaveOpportunity
    
    
    private static Decimal DecimalValueOf(Object obj){
        
        system.debug('##--obj: '+ obj);
        String objStr = (String)obj;
        
        system.debug('##--objStr: '+ objStr);
        if(String.isNotBlank(objStr)){
            
            return Decimal.valueOf(objStr);
        }
        return 0;
    }   //  end of DecimalValueOf
    
    public static CS_AROpportunityWrapper cSaveOpportunity(string Id,
                                                            string opportunityOwner,
                                                            string opportunityName,
                                                            string accountId,
                                                            date opportunityCloseDate,
                                                            list<string> lstsurgeonIds,
                                                            list<string> lsSalesRep,
                                                            list<OpportunityLineItem> lstLineItems,
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
                                                            date estimatedInstallDate,
                                                            string quoteNum,
                                                            date quoteDate,
                                                            decimal noChargeEquipmentValue,
                                                            decimal disposablePurchaseValue,
                                                            decimal totalAnnualPotential,
                                                            string quoteId,
                                                            string productCategory){
        
        
        set<Id> setExistingTeamMembers = new set<Id>();
        set<Id> setExistingOpportunitySurgeons = new set<Id>();
        list<OpportunityTeamMember> lstOpportunityTeamMembers = new list<OpportunityTeamMember>();
            
        Opportunity objOppty = new Opportunity(ownerId = opportunityOwner,
                                               Name = opportunityName,
                                               AccountId = accountId,
                                               CloseDate = opportunityCloseDate,
                                               Competitve_Conversion__c = competitiveConversion,
                                               Competitive_Company__c = competitiveCompany,
                                               Type = opportunityType,
                                               StageName = opportunityStage,
                                               Procedure__c = procedureId,
                                               Annual_Number_of_Procedures__c = annualNumberOfProcedures,
                                               Potential_Revenue_per_Case__c = potentialRevenuePerCase,
                                               Patient_Volume__c = patientVolume,
                                               Potential_User_Number__c = potentialUserNumber,
                                               Total_of_Towers__c = totalNumOfTowers,
                                               Potential_Revenue_Per_Tower__c = potentialRevenuePerTower,
                                               Total_of_OR_s__c = totalNumOfORs,
                                               Equipment_Cost__c = equipmentCost,
                                               Labor_and_Materials__c = laborAndMaterials,
                                               Total_Budgetary__c = totalBudgetary,
                                               Final_PO_Amount__c = finalPOAmount,
                                               Estimated_Install_Date__c = estimatedInstallDate,
                                               Quote__c = quoteNum,
                                               No_Charge_Equipment_Value__c = noChargeEquipmentValue,
                                               Disposable_Purchase_Value__c = disposablePurchaseValue,
                                               Total_Annual_Potential__c = totalAnnualPotential,
                                               Quote_Id__c = quoteId,
                                               Quote_Date__c = quoteDate,
                                               Product_Category__c = productCategory,
                                               RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(opportunityType).getRecordTypeId());
        
        if(Id != null){
            objOppty.Id = Id;
            
            for(OpportunityTeamMember objTeamMember : [SELECT Id,UserId,OpportunityId FROM OpportunityTeamMember WHERE OpportunityId = :Id]){
                setExistingTeamMembers.add(objTeamMember.UserId);
            }
            
            for(Opportunity_Surgeons__c objOpportunitySurgeon : [SELECT Id,Surgeon__c ,Opportunity__c  FROM Opportunity_Surgeons__c WHERE Opportunity__c = :Id]){
                setExistingOpportunitySurgeons.add(objOpportunitySurgeon.Surgeon__c);
            }
            
        }
        
        if(opportunityStage == null){
            objOppty.StageName = retrieveDefaultStage(opportunityType);
        }
        
        upsert objOppty;
        
        if(!setExistingTeamMembers.contains(opportunityOwner)){
            system.debug('##--cSaveOpportunity.opportunityOwner: '+ opportunityOwner);
            OpportunityTeamMember objOpptyTeamMember = new OpportunityTeamMember( OpportunityId = objOppty.Id,
                                                                                      UserId = opportunityOwner,
                                                                                   TeamMemberRole = 'Owner');
            lstOpportunityTeamMembers.add(objOpptyTeamMember);
            
        }
        
        if(lsSalesRep != null && lsSalesRep.size() > 0){
            
            for(string salesRepId : lsSalesRep){
                
                if(setExistingTeamMembers.contains(salesRepId)){
                    continue;
                }
                OpportunityTeamMember objOpptyTeamMember = new OpportunityTeamMember( OpportunityId = objOppty.Id,
                                                                                      UserId = salesRepId);
                lstOpportunityTeamMembers.add(objOpptyTeamMember);
            }// end of for-each
            
        }
        
        if(lstOpportunityTeamMembers.size() > 0){
                
            //insert lstOpportunityTeamMembers;
            createOpportunityTeamMember ct = new createOpportunityTeamMember();
            ct.c_createOpportunityTeamMember(lstOpportunityTeamMembers);
        }
        
        if(lstLineItems!=null && lstLineItems.size() > 0){
            
            list<OpportunityLineItem> lstExistinglineItems = new list<OpportunityLineItem>();
            lstExistinglineItems = retrieveExistingOpportunityLineItems(objOppty.Id);
            
            delete lstExistinglineItems;
            
            for(OpportunityLineItem objLineItem :lstLineItems){
                objLineItem.OpportunityId = objOppty.Id;
            }
            
            insert lstLineItems;
        }
        
        if(lstsurgeonIds != null && lstsurgeonIds.size() > 0){
            
            list<Opportunity_Surgeons__c> lstOpportunitySurgeons = new list<Opportunity_Surgeons__c>();
            
            for(string surgeonId : lstsurgeonIds){
                
                if(setExistingOpportunitySurgeons.contains(surgeonId)){
                    continue;
                }
                
                Opportunity_Surgeons__c objOpptySurgeon = new Opportunity_Surgeons__c( Opportunity__c = objOppty.Id,
                                                                                       Surgeon__c = surgeonId);
                lstOpportunitySurgeons.add(objOpptySurgeon);
            }// end of for-each
            
            if(lstOpportunitySurgeons.size() > 0){
                insert lstOpportunitySurgeons;
            }
            
        }
          
        return buildCS_AROpportunityWrapper(objOppty.Id);
        
    }// end of cSaveOpportunity
    
    
    public static CS_AROpportunityWrapper buildCS_AROpportunityWrapper(Id opportunityId) {
        
        Opportunity wrapperOppty = [SELECT Id, Name,  Account.Name, Account.Preferred_Name__c, Procedure__c, Procedure__r.Name, CreatedDate, LastModifiedDate,
                                                (SELECT Id, Product2.Material_Number__c, Product2.Description, Quantity, TotalPrice, UnitPrice, Product2Id, 
                                                                PriceBookEntryId, Product2.Name FROM OpportunityLineItems),// opportunity line items.
                                                Annual_Number_of_Procedures__c, Type, Potential_Revenue_per_Case__c, Product_Category__c,isClosed,
                                                (SELECT Id, ContactId, Contact.Name, Role, IsPrimary FROM OpportunityContactRoles),
                                                (SELECT Id, UserId, User.Title, User.Name, OpportunityId, TeamMemberRole FROM OpportunityTeamMembers),//additional sales reps
                                                (SELECT Id, Surgeon__c, Surgeon__r.Name, Opportunity__c, CreatedBy.Name 
                                                        FROM Opportunity_Surgeons__r),// opportunity surgeons
                                                (SELECT Id, Case__r.Event_Start_Date__c, Case__r.Practitioner__r.Name, Case__r.Owner.Name 
                                                        FROM  Opportunity_Cases__r WHERE Case__c != null),// linked cases
                                                (SELECT Id, Opportunity__c, Linked_Opportunity__c, Linked_Opportunity__r.Name, Linked_Opportunity__r.Type, 
                                                                        Linked_Opportunity__r.Potential_Revenue_per_Case__c, Linked_Opportunity__r.CloseDate  FROM  Linked_Opportunities__r),// linked Oppotunities
                                                    StageName, CloseDate, Owner.Name, Owner.Profile.Name, Owner.IsActive, Probability, Competitve_Conversion__c, Competitive_Company__c,  Close_Lost_Reasons__c,
                                                    Enrollment_Forms_Sent__c, Enrollment_Form_Type__c,
                                                    Current_FY_Revenue__c, Total_Annual_Potential__c, Quote_Id__c, OwnerId, Patient_Volume__c, Potential_User_Number__c,
                                                    Total_of_Towers__c,Potential_Revenue_Per_Tower__c,Total_of_OR_s__c,Equipment_Cost__c,Labor_and_Materials__c, 
                                                    Total_Budgetary__c, Final_PO_Amount__c, Estimated_Install_Date__c, No_Charge_Equipment_Value__c, Disposable_Purchase_Value__c, 
                                                    Contract_Years__c, Quote__c, Quote_Date__c, Integration_Type__c, Support_Plan__c,Billing_Method__c, 
                                                    Agreement_End_Date__c, Total_Agreement_Value__c, Agreement_Term_Years__c, Customer_PO_Number__c, 
                                                    Agreement_Start_Date__c, SAP_Agreement_Number__c
                                                    FROM Opportunity
                                                    WHERE Id = :opportunityId];
        CS_AROpportunityWrapper objWrapper = new CS_AROpportunityWrapper(wrapperOppty);
        
        return objWrapper;
    
    }
    
    
    public static list<Linked_Opportunity__c> cSaveLinkedOpportunities(string opportunityId, list<string> lstLinkedOpportunityIds){
        
        list<Linked_Opportunity__c> lstLinkedOpportunities = new list<Linked_Opportunity__c>();
        if(lstLinkedOpportunityIds.size() == 0){
            return lstLinkedOpportunities;
        }
        for(Opportunity linkedOpportunity : [SELECT Id, Name, Type FROM Opportunity WHERE Id IN :lstLinkedOpportunityIds]){
            
            Linked_Opportunity__c objLinkOpportunity = new Linked_Opportunity__c(Opportunity__c = opportunityId,
                                                                                Linked_Opportunity__c = linkedOpportunity.Id,
                                                                                 Linked_Opportunity__r = linkedOpportunity);
            
            lstLinkedOpportunities.add(objLinkOpportunity);
        }
        
        if(lstLinkedOpportunities.size() > 0){
            insert lstLinkedOpportunities;
        }
        
        return lstLinkedOpportunities;
        
    }// end of cSaveLinkedOpportunities
    
    public static list<Opportunity_Case__c> cSaveLinkedCases(string opportunityId, list<string> lstCaseIds){
        
        list<Opportunity_Case__c> lstOpportunityCases = new list<Opportunity_Case__c>();
        if(lstCaseIds.size() == 0){
            return lstOpportunityCases;
        }
        for(Case__c objCase : [SELECT Id, Event_Start_Date__c, Event_End_Date__c, Health_Care_Provider__c, Practitioner__c, Procedure__c 
                                            FROM Case__c WHERE Id IN :lstCaseIds]){
            
            Opportunity_Case__c objOpportunityCase = new Opportunity_Case__c(Case__c = objCase.Id,
                                                                             Case__r = objCase,
                                                                             Opportunity__c = opportunityId);
            
            lstOpportunityCases.add(objOpportunityCase);
        }
        
        if(lstOpportunityCases.size() > 0){
            insert lstOpportunityCases;
        }
        
        return lstOpportunityCases;
        
    }// end of cSaveLinkedCases
    
    public without sharing class createOpportunityTeamMember{
        
        public void c_createOpportunityTeamMember(list<OpportunityTeamMember> lstOpptyTeamMembers){
            
            insert lstOpptyTeamMembers;
            
        }// end of c_createOpportunityTeamMember
        
    }// end of createOpportunityTeamMember
    
    public without sharing class deleteOpportunityTeamMember{
        
        public void c_deleteOpportunityTeamMember(OpportunityTeamMember objOpptyTeamMember){
            
            delete objOpptyTeamMember;
            
        }// end of deleteOpportunityTeamMember
        
    }// end of createOpportunityTeamMember
        
     //Release 3.2
    //Developer:- Mimansha Samal
    //Date:- 4/10/2017
    //Purpose:- Updated the method to search only Implants, Dsiposable and Equipments and products which are active.
     public static List<PriceBookEntry> searchPriceBookEntries(String q, boolean searchImp_Equip_DispOnly) {
        
        system.debug('##--Search String: '+ q);
        final String specialChars = '& | ! ( ) { } [ ] ^ " ~ * ? : \' + ';
        String cleansedTerm = q.replaceAll('\\\\', '');
        string otherString = 'Other';
        for (String sc: specialChars.split(' ')) {
            cleansedTerm = cleansedTerm.replaceAll('\\' + sc, '\\\\\\\\' + sc);
        }
        
        //string searchString = CS_ARSearch.escapeSearchTerm(q);
        string searchInput = '%' + cleansedTerm + '%';
        system.debug('##--searchInput : '+ searchInput);
        
        string priceBookQuery = 'SELECT Id, IsActive, Product2.Name, Product2Id, Product2.Material_Number__c, Product2.Description, UnitPrice, Product2.Material_Group_Type__c ' +
                                  ' FROM PriceBookEntry WHERE (Product2.Material_Number__c LIKE :searchInput OR Product2.Name LIKE :searchInput) AND IsActive = TRUE ';
            
        if(searchImp_Equip_DispOnly){
            priceBookQuery += 'AND Product2.Material_Group_Type__c != :otherString ';
        }                         
        priceBookQuery += ' ORDER BY Product2.Name DESC, Product2.Material_Number__c DESC LIMIT 25 ';
        
        list<PriceBookEntry> foundPriceBookEntries =Database.Query(priceBookQuery);
       /* list<PriceBookEntry> foundPriceBookEntries = new list<PriceBookEntry>();
        for ( PriceBookEntry objPriceBookEntry : [SELECT Id, Product2.Name, Product2.Material_Number__c, 
                                                            Product2.Description, UnitPrice
                                                    FROM PriceBookEntry 
                                                    WHERE Product2.Material_Number__c LIKE :searchInput 
                                                    OR Product2.Name LIKE :searchInput
                                                    ORDER BY Product2.Name DESC, Product2.Material_Number__c DESC
                                                    LIMIT 25] ) {
            foundPriceBookEntries.add(objPriceBookEntry);
        }*/
        system.debug('##--foundPriceBookEntries: '+ foundPriceBookEntries);
        return foundPriceBookEntries;
        
    }// end of searchPriceBookEntries
    
    public static list<Contact> retrieveProvidersContacts(Id accountId,
                                                          Id opportunityId){
        
        list<Contact> lstContacts = new list<Contact>();
        
        set<Id> setExistingOppContactIds = new set<Id>();
        
        for(OpportunityContactRole objOppContactRole : [SELECT Id, ContactId 
                                                        FROM OpportunityContactRole 
                                                        WHERE OpportunityId = :opportunityId]){
            
            setExistingOppContactIds.add(objOppContactRole.ContactId);
        }
        system.debug('##--retrieveProvidersContacts.setExistingOppContactIds: '+ setExistingOppContactIds);
        for(Contact objContact :[SELECT Id, Name, FirstName, LastName 
                                        FROM Contact 
                                        WHERE AccountId = :accountId]){
            
            if(!setExistingOppContactIds.contains(objContact.Id)){
                
                lstContacts.add(objContact);
            }
        }
        system.debug('##--retrieveProvidersContacts.lstContacts: '+ lstContacts);
        return lstContacts;
    }// end of retrieveProvidersContacts
    
    public static list<OpportunityLineItem> retrieveExistingOpportunityLineItems(Id opportunityId){
        
        list<OpportunityLineItem> lstOpportunityLineItems = new list<OpportunityLineItem>();
        for(OpportunityLineItem objLineItem :[SELECT Id, OpportunityId, PriceBookEntryId
                                                            FROM OpportunityLineItem 
                                                            WHERE OpportunityId = :opportunityId]){
            lstOpportunityLineItems.add(objLineItem);
        }
        
        return lstOpportunityLineItems;
    }// end of retrieveExistingOpportunityLineItems
    
    public class CS_AROpportunityWrapper{
        
        public string opportunityId {get;set;}
        public string opportunityName {get;set;}
        public string opportunityOwner {get;set;}
        public string account {get;set;}
        public string accountId {get;set;} 
        public string accountTerritory {get;set;}
        public string accountTerritoryId {get;set;}
        public string accountParentTerritoryId {get;set;}
        public string productCategory {get;set;}
        public string procedure {get;set;}
        public string procedureId {get;set;}
        public decimal probability {get;set;}
        public string product {get;set;}
        public string productNames {get; set;}
        public string totalAnnualRevenue {get;set;}
        public string potentialFYRevenue {get;set;}
        public string currentFYRevenue {get;set;}
        public string opportunityType {get;set;}
        public string currentStage {get;set;}
        public string closeDate {get;set;}
        public string ownerProviderTerritory {get;set;}
        public string ownerProviderTerritoryId {get;set;}
        public string ownerProviderParentTerritoryId {get;set;}
        public string competitiveConversion {get;set;}
        public string competitiveCompany {get;set;}
        public decimal patientVolume {get;set;}
        public decimal potentialUserNumber {get;set;}
        public boolean isClosed {get;set;}
        public boolean isClosedWon {get;set;}
        public boolean isClosedLost {get;set;}
        public string owner {get;set;}
        public list<OpportunityTeamMember> opportunityTeamMembers {get;set;}
        public list<Opportunity_Surgeons__c> opportunitySurgeons {get;set;}
        public list<OpportunityContactRole> opportunityContactRoles {get;set;}
        public list<OpportunityLineItem> products {get; set;}
        public list<Linked_Opportunity__c> lstLinkedOpportunities {get; set;}
        public string opportunitySurgeonNames {get;set;}
        public string opportunitySurgeonIds {get;set;}
        public string teamMemberNames {get; set;}
        public string closeLostReasons {get;set;}
        public decimal annualNumberOfProcedures {get;set;}
        public string quoteId {get;set;}
        public string ownerId {get;set;}
        public decimal totalNumOfTowers {get;set;}
        public decimal potentialRevenuePerTower {get;set;}
        public decimal totalNumOfORs {get;set;}
        public string equipmentCost {get;set;}
        public string laborAndMaterials {get;set;}
        public string totalBudgetary {get;set;}
        public string finalPOAmount {get;set;}
        public string estimatedInstallDate {get;set;}
        public decimal noChargeEquipmentValue {get;set;}
        public string disposablePurchaseValue {get;set;}
        public decimal contractYears {get;set;}
        public string quoteNum {get;set;}
        public string quoteDate {get;set;}
        public string enrollmentFormsSent {get;set;}
        public string enrollmentFormType {get;set;}
        public string lastModifiedDate {get;set;}
        public string opportunityAge {get;set;}
        public string createdDate {get;set;}
        public string integrationType {get;set;}
        public string supportPlan {get;set;}
        public string billingMethod {get;set;}
        public string agreementEndDate {get;set;}
        public string totalAgreementValue {get;set;}
        public string agreementTerm {get;set;}
        public string customerPONumber {get;set;}
        public string agreementStartDate {get;set;}
        public string sapAgreementNumber {get;set;}
        
        
        public CS_AROpportunityWrapper(Opportunity objOpportunity){
            
            opportunityId = objOpportunity.Id;
            opportunityName = objOpportunity.Name;
            //account = objOpportunity.Account.Name;
            // Added by Swetha - Display Nick name instead of Account name
            account = string.isBlank(objOpportunity.Account.Preferred_Name__c)?objOpportunity.Account.Name : objOpportunity.Account.Preferred_Name__c;
            accountId = objOpportunity.AccountId;
            productCategory = objOpportunity.Product_Category__c;
            procedure = objOpportunity.Procedure__r.Name;
            procedureId = objOpportunity.Procedure__c;
            product = 'Will Populate Later';
            annualNumberOfProcedures = objOpportunity.Annual_Number_of_Procedures__c;
            totalAnnualRevenue = multiplyAndFormat(1, objOpportunity.Total_Annual_Potential__c); 
            potentialFYRevenue = multiplyAndFormat(1, objOpportunity.Potential_Revenue_per_Case__c); 
            opportunityType = objOpportunity.Type;
            currentStage = objOpportunity.StageName;
            closeDate = String.valueOf(objOpportunity.CloseDate);
            isClosed = objOpportunity.IsClosed;
            isClosedWon = objOpportunity.StageName == 'Closed - Won'? true: false;
            isClosedLost = objOpportunity.StageName == 'Closed - Lost'? true: false;
            // Added by srinivas sattoor on 9.28.2017 for 4.4 CID-000497
            if(!objOpportunity.Owner.Profile.Name.contains('Community') 
                || !objOpportunity.Owner.IsActive){
                owner = 'Unassigned';
                ownerId = objOpportunity.OwnerId;
            }else{
                owner = objOpportunity.Owner.Name; 
                ownerId = objOpportunity.OwnerId;
            }
            quoteId = objOpportunity.Quote_Id__c;
            probability = objOpportunity.Probability;
            competitiveConversion = objOpportunity.Competitve_Conversion__c;
            competitiveCompany = objOpportunity.Competitive_Company__c;
            closeLostReasons = objOpportunity.Close_Lost_Reasons__c;
            currentFYRevenue = objOpportunity.StageName == 'Closed - Won'? multiplyAndFormat(1, objOpportunity.Total_Annual_Potential__c) : multiplyAndFormat(1,objOpportunity.Current_FY_Revenue__c);
            // Added by srinivas sattoor on 9.28.2017 for 4.4 CID-000497
            if(!objOpportunity.Owner.Profile.Name.contains('Community')
              || !objOpportunity.Owner.IsActive){
                opportunityOwner = 'Unassigned';    
            }else{
                opportunityOwner = objOpportunity.Owner.Name;   
            }
            
            patientVolume = objOpportunity.Patient_Volume__c;
            potentialUserNumber = objOpportunity.Potential_User_Number__c;
            totalNumOfTowers = objOpportunity.Total_of_Towers__c;
            potentialRevenuePerTower = objOpportunity.Potential_Revenue_Per_Tower__c;
            totalNumOfORs = objOpportunity.Total_of_OR_s__c;
            equipmentCost = multiplyAndFormat(1, objOpportunity.Equipment_Cost__c); 
            laborAndMaterials = multiplyAndFormat(1, objOpportunity.Labor_and_Materials__c); 
            totalBudgetary = multiplyAndFormat(1, objOpportunity.Total_Budgetary__c);
            finalPOAmount = multiplyAndFormat(1, objOpportunity.Final_PO_Amount__c);
            estimatedInstallDate = String.valueOf(objOpportunity.Estimated_Install_Date__c);//objOpportunity.Estimated_Install_Date__c;
            noChargeEquipmentValue = objOpportunity.No_Charge_Equipment_Value__c;
            disposablePurchaseValue = multiplyAndFormat(1, objOpportunity.Disposable_Purchase_Value__c);
            contractYears = objOpportunity.Contract_Years__c;
            quoteNum = objOpportunity.Quote__c;
            quoteDate = String.valueOf(objOpportunity.Quote_Date__c);
            enrollmentFormsSent = String.valueOf(objOpportunity.Enrollment_Forms_Sent__c);
            enrollmentFormType = objOpportunity.Enrollment_Form_Type__c;
            lastModifiedDate = string.valueof(objOpportunity.LastModifiedDate); 
            createdDate = string.valueof(objOpportunity.CreatedDate); 
            opportunityAge = string.valueof((DateTime.now().getTime() - objOpportunity.CreatedDate.getTime())/1000*60*60*24);
            integrationType  = objOpportunity.Integration_Type__c;
            supportPlan  = multiplyAndFormat(1, objOpportunity.Support_Plan__c);
            
            billingMethod = objOpportunity.Billing_Method__c;
            agreementEndDate = string.valueof(objOpportunity.Agreement_End_Date__c);
            totalAgreementValue = multiplyAndFormat(1, objOpportunity.Total_Agreement_Value__c);
            agreementTerm = objOpportunity.Agreement_Term_Years__c;
            customerPONumber = objOpportunity.Customer_PO_Number__c;
            agreementStartDate = string.valueof(objOpportunity.Agreement_Start_Date__c);
            sapAgreementNumber = objOpportunity.SAP_Agreement_Number__c;
            
            products = new list<OpportunityLineItem>();
            productNames = '';
            for(OpportunityLineItem objLineItem : objOpportunity.OpportunityLineItems){
                
                products.add(objLineItem);
                productNames += objLineItem.Product2.Name + ', ' ;
            }
            productNames = productNames.removeEnd(', ');
            if(String.isBlank(productNames)){
                productNames=null;
            }
            
            // adding opportunity team members
            teamMemberNames = '';
            opportunityTeamMembers = new list<OpportunityTeamMember>();
            for(OpportunityTeamMember opptyTeamMember :objOpportunity.OpportunityTeamMembers){
                opportunityTeamMembers.add(opptyTeamMember);
                teamMemberNames += opptyTeamMember.user.Name + ', ' ;
            }
            teamMemberNames = teamMemberNames.removeEnd(', ');
            if(String.isBlank(teamMemberNames)){
                teamMemberNames=null;
            }
            opportunityContactRoles = new list<OpportunityContactRole>();
            for(OpportunityContactRole objOpptyContactRole :objOpportunity.OpportunityContactRoles){
                opportunityContactRoles.add(objOpptyContactRole);
            }
            
            // adding opportunity surgeons
            opportunitySurgeonNames = '';
            opportunitySurgeons = new list<Opportunity_Surgeons__c>();
            for(Opportunity_Surgeons__c objOpptySurgeon :objOpportunity.Opportunity_Surgeons__r){
                opportunitySurgeons.add(objOpptySurgeon);
                opportunitySurgeonNames += objOpptySurgeon.Surgeon__r.Name + ', ' ;
            }
            opportunitySurgeonNames = opportunitySurgeonNames.removeEnd(', ');
            if(String.isBlank(opportunitySurgeonNames)){
                opportunitySurgeonNames=null;
            }
            
            // adding linked opportunities
            lstLinkedOpportunities = new list<Linked_Opportunity__c>();
            for(Linked_Opportunity__c objOpptyLinked :objOpportunity.Linked_Opportunities__r){
                lstLinkedOpportunities.add(objOpptyLinked);
            }
            
            
            
        }   //  end of constructor
        
        private string multiplyAndFormat(decimal c_annualNumOfProcs, decimal c_potentialRevPerCase){
            
            list<String> args = new String[]{'0','number','###,###,##0.00'};
            
            if(c_annualNumOfProcs == null || c_potentialRevPerCase == null){
                return null;
            }
            
            return '$' + String.format((c_annualNumOfProcs * c_potentialRevPerCase).format(), args);
        }   //  end of multiplyAndFormat
        
    }// end of CS_AROpportunityWrapper
    
    public static list<OpportunityWrapper> retrieveOpportunityActivity(string activityType, 
                                                                       Id opportunityId){
        
        list<CS_OpportunityActivityWrapper> lstCS_OpportunityActivityWrapper = new list<CS_OpportunityActivityWrapper>();
        list<OpportunityWrapper> lstSortedOpportunityWrapper= new list<OpportunityWrapper>();
        
        for(Opportunity objOppty :[SELECT Id, 
                                    (SELECT Id, IsDeleted, OpportunityId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue 
                                                                    FROM Histories order by CreatedDate), // fetching history
                                    (SELECT Id, CreatedDate, Body, CreatedBy.Name FROM Notes order by CreatedDate), //fetching logs
                                    (SELECT Id, User.Name, CreatedDate,CreatedBy.Name FROM OpportunityTeamMembers order by CreatedDate), //fetching oppteammembers
                                    (SELECT Id, CreatedDate, Contact.Name, CreatedBy.Name, IsPrimary FROM OpportunityContactRoles order by CreatedDate), // fetching opportunityContactRoles
                                    (SELECT Id, CreatedDate, Name, CreatedBy.Name FROM Attachments), //fetching attachments 
                                    (SELECT ContentDocumentId, ContentDocument.Title, LinkedEntityId, ContentDocument.CreatedDate,ContentDocument.CreatedBy.Name FROM ContentDocumentLinks), //Fetching files
                                    (SELECT Id, CreatedDate, CreatedBy.Name, deleted_by__c, deleted_by__r.Name, Lastmodifieddate, Contact__r.Name 
                                                    FROM Key_Contacts_Opportunity_logs__r order by CreatedDate asc), // fetching deleted opportunityContactRoles
                                    (SELECT Id, CreatedDate, CreatedBy.Name, Conference_Member__c, Opportunity__r.Name, Opportunity__r.StageName FROM Opportunity_Leads__r ORDER BY CreatedDate) //  Vishnu Release 4.4: Added this to show leads in Opportunity screen
                                          FROM Opportunity WHERE Id = : opportunityId]){
            
            // adding opporutnity history   
            
            if(activityType == 'All Activities' || activityType == 'Log'){                  
                for(OpportunityFieldHistory objOpptyFieldHistory :objOppty.Histories){
                    string wrapperNotes ='';
                    
                    if(checkIfFieldValueIsId(string.valueof(objOpptyFieldHistory.NewValue))){
                        continue;
                    }
                    if(retrieveFieldName('Opportunity', objOpptyFieldHistory.Field) == 'Created'){
                        //wrapperNotes = objOpptyFieldHistory.CreatedBy.Name + ' ' + retrieveFieldName('Opportunity', objOpptyFieldHistory.Field) ;
                        wrapperNotes =  retrieveFieldName('Opportunity', objOpptyFieldHistory.Field) ;
                    }else if(objOpptyFieldHistory.NewValue != null){
                        //wrapperNotes = objOpptyFieldHistory.CreatedBy.Name + ' changed ' + retrieveFieldName('Opportunity', objOpptyFieldHistory.Field);
                        wrapperNotes = 'Changed ' + retrieveFieldName('Opportunity', objOpptyFieldHistory.Field);
                        if(objOpptyFieldHistory.OldValue != null){ 
                            
                            wrapperNotes += ' from ' +  retriveRecordNameForLookUps(string.valueof(objOpptyFieldHistory.OldValue));
                            
                        }
                        system.debug('##--wrapperNotes1: '+ wrapperNotes);
                        wrapperNotes += ' to ';
                        wrapperNotes += objOpptyFieldHistory.NewValue == null?'':retriveRecordNameForLookUps(string.valueof(objOpptyFieldHistory.NewValue));
                        system.debug('##--wrapperNotes2: '+ wrapperNotes);
                    
                    }else if(objOpptyFieldHistory.NewValue == null){
                        
                        wrapperNotes = 'Deleted ' + retriveRecordNameForLookUps(string.valueof(objOpptyFieldHistory.OldValue)) + ' in ' + retrieveFieldName('Opportunity', objOpptyFieldHistory.Field);
                        
                    }
                    CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(objOpptyFieldHistory.Id, objOpptyFieldHistory.CreatedBy.Name, objOpptyFieldHistory.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG');        
                       lstCS_OpportunityActivityWrapper.add(objWrapper);   
                    
                }// end of for -each history
                
                
                for(Opportunity_Surgeons__c objOppSurgeon : [SELECT Id, Opportunity__c , Surgeon__r.Name,isDeleted, Lastmodifieddate, LastModifiedBy.Name, CreatedDate, CreatedBy.Name,
                                                                (SELECT Id, ParentId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue FROM Histories order by CreatedDate)
                                                        FROM Opportunity_Surgeons__c WHERE Opportunity__c = :opportunityId ALL ROWS]){
                    if(objOppSurgeon.Histories.size() > 0){                                 
                        for(Opportunity_Surgeons__History objOpptySurgFieldHistory :objOppSurgeon.Histories){
                            lstCS_OpportunityActivityWrapper.add(createOpptySurgeonHistoryWrapper(objOpptySurgFieldHistory, objOppSurgeon));  
                          
       
                        }
                    }
                    if(objOppSurgeon.isDeleted){
                        String strNote = objOppSurgeon.LastModifiedBy.Name + ' deleted ' + objOppSurgeon.Surgeon__r.Name;
                        CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(objOppSurgeon.Id, objOppSurgeon.CreatedBy.Name, objOppSurgeon.Lastmodifieddate, strNote, 'LOG');
                        lstCS_OpportunityActivityWrapper.add(objWrapper);
                    }
                    
                }// end of for-each Opportunity_Surgeons__c
                
                for(Opportunity_Case__c objOppCase : [SELECT Id, Opportunity__c , Case__r.Name,   
                                                                (SELECT Id, ParentId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue FROM Histories order by CreatedDate)
                                                        FROM Opportunity_Case__c WHERE Opportunity__c = :opportunityId ALL ROWS]){
                    if(objOppCase.Histories.size() > 0){                                    
                        for(Opportunity_Case__History objOpptyCaseHistory :objOppCase.Histories){ 
                            lstCS_OpportunityActivityWrapper.add(createOpptyCaseHistoryWrapper(objOpptyCaseHistory, objOppCase));  
                        }
                    }
                    
                }// end of for-each Opportunity_Case__c
                
                for(Linked_Opportunity__c objLinkedOpp : [SELECT Id, Opportunity__c, Lastmodifieddate, isDeleted, LastModifiedBy.Name,  Linked_Opportunity__r.Name,CreatedBy.Name, CreatedDate FROM Linked_Opportunity__c WHERE Opportunity__c = :opportunityId ALL ROWS]){
                    string objLinkedOppWrapperNotes = objLinkedOpp.CreatedBy.Name + ' added ' + objLinkedOpp.Linked_Opportunity__r.Name + ' in linked opportunities';
                    CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(objLinkedOpp.Id, objLinkedOpp.CreatedBy.Name, objLinkedOpp.CreatedDate,
                                                                                                 objLinkedOppWrapperNotes,
                                                                                                 'LOG');  
                   lstCS_OpportunityActivityWrapper.add(objWrapper);
                   
                   if(objLinkedOpp.isDeleted){
                        String strNote = objLinkedOpp.LastModifiedBy.Name + ' deleted ' + objLinkedOpp.Linked_Opportunity__r.Name;
                        objWrapper = new CS_OpportunityActivityWrapper(objLinkedOpp.Id, objLinkedOpp.LastModifiedBy.Name, objLinkedOpp.Lastmodifieddate, strNote, 'LOG');
                        lstCS_OpportunityActivityWrapper.add(objWrapper);
                    }
                    
                }// end of for-each Linked_Opportunity__c
                
                for(OpportunityTeamMember objOppTeamMember : objOppty.OpportunityTeamMembers){
                    
                    string objOppTeamMemberWrapperNotes = objOppTeamMember.CreatedBy.Name + ' added ' + objOppTeamMember.User.Name + ' in Opportunity Team';
                    CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(objOppTeamMember.Id, objOppTeamMember.CreatedBy.Name, objOppTeamMember.CreatedDate,
                                                                                                 objOppTeamMemberWrapperNotes,
                                                                                                 'LOG');  
                   // lstCS_OpportunityActivityWrapper.add(objWrapper);
                }
              
                for(Key_Contacts_Opportunity_log__c objOppContactRoleDel : objOppty.Key_Contacts_Opportunity_logs__r){
                    
                     
                   //CDID-000056/Swetha Penmethsa/Jan /11/2017/Key Contacts Log 
                    if(objOppContactRoleDel.deleted_by__c != null){
                        String strNote = objOppContactRoleDel.deleted_by__r.Name + ' deleted ' + objOppContactRoleDel.Contact__r.Name;
                        CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(objOppContactRoleDel.Id, objOppContactRoleDel.CreatedBy.Name, objOppContactRoleDel.Lastmodifieddate, strNote, 'LOG');
                        lstCS_OpportunityActivityWrapper.add(objWrapper);
                    }else{
                        string objOppContactRoleWrapperNotes = objOppContactRoleDel.CreatedBy.Name + ' added ' + objOppContactRoleDel.Contact__r.Name + ' in Key Contacts';
                        CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(objOppContactRoleDel.Id, 
                                                                                                    objOppContactRoleDel.CreatedBy.Name, 
                                                                                                    objOppContactRoleDel.CreatedDate,
                                                                                                    objOppContactRoleWrapperNotes,
                                                                                                  'LOG'); 
                        lstCS_OpportunityActivityWrapper.add(objWrapper);
                    }
                }
            }
            //CDID-000056/Swetha Penmethsa/Jan /11/2017/Key Contacts Log 
            
            
            //adding surgical cases
            if(activityType == 'All Activities' || activityType == 'Event') {

                /*for (Event e : CS_EventsService.getEventActivityForOpportunity(opportunityId) ) {

                    String note = e.Type;
                    if ( e.Location != null ) {
                        note+=' - '+e.Location;
                    }

                    CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(e.Id,e.CreatedBy.Name,e.StartDateTime,
                                                                                             note,
                                                                                             'EVENT');      
                    lstCS_OpportunityActivityWrapper.add(objWrapper); 
                }*/

            }
            
            if(activityType == 'All Activities' || activityType == 'Note'){
                for(Note objNote : objOppty.Notes){
                    
                    CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(objNote.Id, objNote.CreatedBy.Name, objNote.CreatedDate,
                                                                                             objNote.Body,
                                                                                             'NOTE');       
                        lstCS_OpportunityActivityWrapper.add(objWrapper);   
                    
                }
            }
            
            if(activityType == 'All Activities' || activityType == 'Task'){
                
                List<Task> tasks = CS_ARTasksService.retrieveSFTasksByAssociatedId(opportunityId);
                for(Task objTask : tasks){
                    CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(objTask.Id, objTask.CreatedBy.Name, objTask.CreatedDate,
                                                                                             objTask.Subject,
                                                                                             'TASK', objTask.Status);       
                        lstCS_OpportunityActivityWrapper.add(objWrapper);
                    
                }
                
            }


            /*
                Vishnu Release 4.4
                    Added this to show the Associated Leads in the Opportunity Activities
            */
            if(activityType == 'All Activities' || activityType == 'Lead'){
                
                for(Opportunity_Leads__c objOppLead : objOppty.Opportunity_Leads__r){
                    CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(objOppLead.Id, objOppLead.CreatedBy.Name, objOppLead.CreatedDate,
                                                                                             objOppLead.Opportunity__r.Name,
                                                                                             'LEAD', objOppLead.Opportunity__r.StageName);       
                        lstCS_OpportunityActivityWrapper.add(objWrapper);
                    
                }
                
            }
            
            //Added by srinivas.sattoor on 8.21.2017 for Release 4.4, CID-000440 
            if(activityType == 'All Activities' || activityType == 'Attachment'){
                // for(Attachment objAttachment : objOppty.Attachments){
                map<Id, ContentVersion> mapContentDocumentIdAndContentVersion = retieveMapContentDocumentIdAndContentVersion(objOppty.ContentDocumentLinks);
                
                
                for(ContentDocumentLink objContentDocumentLink : objOppty.ContentDocumentLinks){    
                    CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(mapContentDocumentIdAndContentVersion.get(objContentDocumentLink.ContentDocumentId).Id,//objContentDocumentLink.ContentDocumentId, 
                                                                                                 objContentDocumentLink.ContentDocument.CreatedBy.Name, 
                                                                                                 objContentDocumentLink.ContentDocument.CreatedDate,
                                                                                                 objContentDocumentLink.ContentDocument.Title,
                                                                                                 'ATTACHMENT'); 
                                                                                                  
                    lstCS_OpportunityActivityWrapper.add(objWrapper);
                }// end of for-each attachment
            }
            
        }
        
        for(CS_OpportunityActivityWrapper objWrapper : lstCS_OpportunityActivityWrapper){
            
            lstSortedOpportunityWrapper.add(new OpportunityWrapper(objWrapper));
        }
        lstSortedOpportunityWrapper.sort();
        return lstSortedOpportunityWrapper;
    
    }// end of retrieveOpportunityFieldHistory
    
    public static map<Id, ContentVersion> retieveMapContentDocumentIdAndContentVersion(list<ContentDocumentLink> listContentDocumentLinks){
        map<Id, ContentVersion> mapContentDocumentIdAndContentVersion = new map<Id, ContentVersion>();
        set<Id> setContentDocumentIds = new set<Id>();
        for(ContentDocumentLink objContentDocumentLink : listContentDocumentLinks){
            setContentDocumentIds.add(objContentDocumentLink.ContentDocumentId);  
        }// end of for-each
        for(ContentVersion objContentVersion : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN:setContentDocumentIds]){
            mapContentDocumentIdAndContentVersion.put(objContentVersion.ContentDocumentId, objContentVersion);
            
        }
        return mapContentDocumentIdAndContentVersion;
    }// end of retieveMapContentDocumentIdAndContentVersion
    
    public class CS_OpportunityTypeDashboardWrapper{
        
        public string opportunityType {get;set;}
        public integer openOpportunities {get;set;}
        public integer closedOpportunities {get;set;}
        public integer closedWonOpportunities {get;set;}
        public integer totalOpportunities {get;set;}
        public decimal rateOfWonOpportunities {get;set;}
        public string ownerProviderTerritory {get;set;}
        public string ownerProviderTerritoryId {get;set;}
        public string ownerProviderParentTerritoryId {get;set;}
        
        public CS_OpportunityTypeDashboardWrapper(string p_opportunityType,
                                                integer p_openOpportunities,
                                                integer p_closedOpportunities,
                                                integer p_totalOpportunities,
                                                decimal p_rateOfWonOpportunities){
                                                    
            opportunityType= p_opportunityType;
            openOpportunities = p_openOpportunities;
            closedOpportunities = p_closedOpportunities;
            totalOpportunities = p_totalOpportunities;
            rateOfWonOpportunities = p_rateOfWonOpportunities;
            
        }
        
        public CS_OpportunityTypeDashboardWrapper(Opportunity objOpportunity){
            opportunityType = objOpportunity.Type;
            totalOpportunities = 1;
            closedWonOpportunities = 0;
            rateOfWonOpportunities = 0;
            
            if(objOpportunity.IsClosed){
                closedOpportunities = 1;
                openOpportunities = 0;
            } else {
                openOpportunities = 1;
                closedOpportunities = 0;
            }
            
            if(objOpportunity.StageName == 'Closed - Won'){
                closedWonOpportunities++;
            }
            
            rateOfWonOpportunities = closedWonOpportunities / totalOpportunities;
        }
        
        public void add(Opportunity objOpportunity){
            totalOpportunities++;
            if(objOpportunity.IsClosed){
                closedOpportunities++;
            } else {
                openOpportunities++;
            }
            if(objOpportunity.StageName == 'Closed - Won'){
                closedWonOpportunities++;
            }
            
            rateOfWonOpportunities = closedWonOpportunities / totalOpportunities;
            
        }   //  end of add
    }// end of CS_OpportunityTypeDashboardWrapper
    
    public class CS_OpportunityCase{
        
        public boolean selected {get;set;}
        public Case__c objCase {get;set;}
        public string procedureNames {get;set;} 
        
        public CS_OpportunityCase(Case__c p_objCase){
            
            selected = false;
            objCase = p_objCase;
            procedureNames = '';
            
            if( p_objCase.Case_Procedures__r.size() > 0){
                for(Case_Procedure__c objCaseProc : p_objCase.Case_Procedures__r){
                    procedureNames += objCaseProc.Procedure__r.Name + ', ';
                    
                }
                system.debug('##--CS_OpportunityCase.procedureNames'+ procedureNames);
                procedureNames = procedureNames.removeEnd(', ');
                system.debug('##--CS_OpportunityCase.procedureNames'+ procedureNames);
            }
        }
    }
    
    public class CS_LinkOpportunity{
        
        public boolean selected {get;set;}
        public Opportunity_Surgeons__c objOpportunitySurgeon {get;set;}
        public string closeDate {get;set;}
        
        public CS_LinkOpportunity(Opportunity_Surgeons__c p_objOpportunitySurgeon){
            
            selected = false;
            objOpportunitySurgeon = p_objOpportunitySurgeon;
            closeDate = String.valueOf(p_objOpportunitySurgeon.Opportunity__r.CloseDate);
        }
    }
    
    public static string retrieveFieldName(string objectType, string fieldAPIName){
        
        system.debug('##--fieldAPIName: '+ fieldAPIName + ': ' + fieldAPIName);
        
        if(fieldAPIName == 'Created'){
            return 'Created';
        }else if(fieldAPIName == 'Owner'){
            return 'Owner';
        }else if(fieldAPIName == 'Account'){
            return 'Account';
        }else if(fieldAPIName == 'RecordType'){
            return 'RecordType';
        }
        
        map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectType);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        
        return fieldMap.get(fieldAPIName).getDescribe().getLabel();
        
    }
    
    public static string retrieveFieldType(string objectType, string fieldAPIName){
        
        system.debug('##--fieldAPIName: '+ fieldAPIName + ': ' + fieldAPIName);
        
        if(fieldAPIName == 'Created'){
            return 'Created';
        }else if(fieldAPIName == 'Owner'){
            return 'Owner';
        }else if(fieldAPIName == 'Account'){
            return 'Account';
        }else if(fieldAPIName == 'RecordType'){
            return 'RecordType';
        }
        
        map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectType);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        
        return string.valueof(fieldMap.get(fieldAPIName).getDescribe().getType());
        
    }
    
    public static List<SelectOption> retrieveOpportunityStages(string opportunityType){
        List<selectOption> options = new List<selectOption>(); 
        
        Axis_Opportunity_Stages__c oppStages = Axis_Opportunity_Stages__c.getValues(opportunityType);
        
        for(string objOppStage : oppStages.Opportunity_Stages__c.split(',')){
            options.add(new selectOption(objOppStage.trim() , objOppStage.trim()));
        }
        return options;
    }
    
    public static List<SelectOption> retrieveOpportunityProductCategories(string opportunityType){
        List<selectOption> options = new List<selectOption>();
        
        if(opportunityType == 'SOS'){
            
            options.add(new selectOption('Other' , 'Other'));
            
        }else if (opportunityType == 'Synergy Video' ||
                    opportunityType == 'Synergy Integration' || 
                    opportunityType == 'Synergy Service'){
            
            options.add(new selectOption('Synergy' , 'Synergy'));
            
        }else if(opportunityType == 'Agreements'){
            options.add(new selectOption('Capital Consumables' , 'Capital Consumables'));
            options.add(new selectOption('Biologics' , 'Biologics'));
        }else{
            options.add(new selectOption('Shoulder' , 'Shoulder'));
            options.add(new selectOption('Knee/Hip' , 'Knee/Hip'));
            options.add(new selectOption('Distal Extremities' , 'Distal Extremities'));
            options.add(new selectOption('Biologics' , 'Biologics'));
            options.add(new selectOption('Capital Consumables' , 'Capital Consumables'));
            options.add(new selectOption('Arthroplasty' , 'Arthroplasty'));
        }
        
        return options;
    }
    
    
    public static List<SelectOption> retrieveClosedLostReason(string opportunityType){
        List<selectOption> options = new List<selectOption>();
        
        if(opportunityType == 'SOS'){
            
            options.add(new selectOption('Choose Another Vendor' , 'Choose Another Vendor'));
            options.add(new selectOption('Pricing' , 'Pricing'));
            options.add(new selectOption('Deferred' , 'Deferred'));
            
        }else{
            options.add(new selectOption('Pricing Issue' , 'Pricing Issue'));
            options.add(new selectOption('Surgeon Chose Competitive Product' , 'Surgeon Chose Competitive Product'));
            options.add(new selectOption('Surgical Technique Issue' , 'Surgical Technique Issue'));
            options.add(new selectOption('Never Incorporated into Practice' , 'Never Incorporated into Practice'));
        }
        
        return options;
    }
    
    private static string retrieveDefaultStage(string opportunityType){
        
        /*if(opportunityType == 'Agreement\'s' ||
            opportunityType == 'Instrument Purchase' ||
            opportunityType == 'Product Conversion' ||
            opportunityType == 'Stocking Order' ||
            opportunityType == 'Synergy Video'){
                
            return 'Qualified';
            
        }else{
            
            return 'Qualified';
            
        }*/
        
        return 'Qualified';
    }// end of retrieveDefaultStage
    
    public class CS_OpportunityActivityWrapper{
        
        public datetime logDate {get;set;}
        public string notes {get;set;}
        public string activityType {get;set;}
        public string logOwner{get;set;}
        public string recId{get;set;}
        public string stage{get;set;}
        
        public CS_OpportunityActivityWrapper(string p_Id,string p_owner,datetime p_logDate,
                                        string p_notes,
                                         string p_activityType){
            
            recId=p_Id;
            logOwner = p_owner;
            logDate = p_logDate;
            notes = p_notes;
            activityType = p_activityType; 
        }
        public CS_OpportunityActivityWrapper(string p_Id,string p_owner,datetime p_logDate,
                                        string p_notes,
                                         string p_activityType,
                                         string p_stage){
            
            recId=p_Id;
            logOwner = p_owner;
            logDate = p_logDate;
            notes = p_notes;
            activityType = p_activityType;
            stage = p_stage;
             
        }
       
    }// end of CS_OpportunityActivityWrapper
    
    public class OpportunityWrapper implements Comparable {

        public CS_OpportunityActivityWrapper oppy;
        
        // Constructor
        public OpportunityWrapper(CS_OpportunityActivityWrapper op) {
            oppy = op;
        }
        
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            OpportunityWrapper compareToOppy = (OpportunityWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (oppy.logDate < compareToOppy.oppy.logDate) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (oppy.logDate > compareToOppy.oppy.logDate) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
    
    public static string retriveRecordNameForLookUps(string fieldValue){
        system.debug('##--fieldValue: '+ fieldValue);
        if(fieldValue == null){
            return '';
        }
        String p_fieldValue = String.escapeSingleQuotes(fieldValue);
        if((p_fieldValue.length() == 15 || p_fieldValue.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', p_fieldValue)) {
            
            Id recordId = Id.valueOf(p_fieldValue);
            DescribeSObjectResult describeResult = recordId.getSObjectType().getDescribe();
            string query = 'SELECT Id, Name FROM ' + describeResult.getName() + ' WHERE Id =:recordId';
            system.debug('##--retriveRecordNameForLookUps.query: '+ query);
            sObject sobj = Database.query(query);
            
            return (string)sobj.get('Name');
        }else if(p_fieldValue.length() ==  19 && p_fieldValue.contains('00:00:00')){
             return p_fieldValue.substringBefore(' ');
        }
        return p_fieldValue;
        
        
    }
    
    public static CS_OpportunityActivityWrapper createOpptySurgeonHistoryWrapper(Opportunity_Surgeons__History objOpptySurgFieldHistory, 
                                                                          Opportunity_Surgeons__c objOppSurgeon){
        
        string wrapperNotes ='';
        if(retrieveFieldName('Opportunity_Surgeons__c', objOpptySurgFieldHistory.Field) == 'Created'){
            //wrapperNotes = objOpptySurgFieldHistory.CreatedBy.Name + ' added ' + objOppSurgeon.Surgeon__r.Name;
            wrapperNotes = 'Added ' + objOppSurgeon.Surgeon__r.Name;
        }else{
            //wrapperNotes = objOpptySurgFieldHistory.CreatedBy.Name + ' changed ' + retrieveFieldName('Opportunity_Surgeons__c', objOpptySurgFieldHistory.Field);
            wrapperNotes = 'Changed ' + retrieveFieldName('Opportunity_Surgeons__c', objOpptySurgFieldHistory.Field);
            if(objOpptySurgFieldHistory.OldValue != null){
                wrapperNotes += ' from ' + retriveRecordNameForLookUps(string.valueof(objOpptySurgFieldHistory.OldValue));
                
            }
            system.debug('##--wrapperNotes1: '+ wrapperNotes);
            wrapperNotes += ' to ';
            wrapperNotes += objOpptySurgFieldHistory.NewValue == null?'':retriveRecordNameForLookUps(string.valueof(objOpptySurgFieldHistory.NewValue));
            system.debug('##--wrapperNotes2: '+ wrapperNotes);
        
        }
        CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(objOpptySurgFieldHistory.Id, objOpptySurgFieldHistory.CreatedBy.Name, objOpptySurgFieldHistory.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG'); 
       return objWrapper;
        
    }// end of createOpptySurgeonHistoryWrapper
    
    public static CS_OpportunityActivityWrapper createOpptyCaseHistoryWrapper(Opportunity_Case__History objOpptyCaseFieldHistory, 
                                                                          Opportunity_Case__c objOppCase){
        
        string wrapperNotes ='';
        if(retrieveFieldName('Opportunity_Case__c', objOpptyCaseFieldHistory.Field) == 'Created'){
            //wrapperNotes = objOpptyCaseFieldHistory.CreatedBy.Name + ' added case'; //objOppCase.Case__r.Name;
            wrapperNotes = 'Added case';  
        }else{
            //wrapperNotes = objOpptyCaseFieldHistory.CreatedBy.Name + ' changed ' + retrieveFieldName('Opportunity_Case__c', objOpptyCaseFieldHistory.Field);
            wrapperNotes = 'Changed ' + retrieveFieldName('Opportunity_Case__c', objOpptyCaseFieldHistory.Field);
            if(objOpptyCaseFieldHistory.OldValue != null){
                wrapperNotes += ' from ' + retriveRecordNameForLookUps(string.valueof(objOpptyCaseFieldHistory.OldValue));
                
            }
            system.debug('##--wrapperNotes1: '+ wrapperNotes);
            wrapperNotes += ' to ';
            wrapperNotes += objOpptyCaseFieldHistory.NewValue == null?'':retriveRecordNameForLookUps(string.valueof(objOpptyCaseFieldHistory.NewValue));
            system.debug('##--wrapperNotes2: '+ wrapperNotes);
        
        }
        CS_OpportunityActivityWrapper objWrapper = new CS_OpportunityActivityWrapper(objOpptyCaseFieldHistory.Id, 
                                                                                            objOpptyCaseFieldHistory.CreatedBy.Name, 
                                                                                            objOpptyCaseFieldHistory.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG'); 
       return objWrapper;
        
    }// end of createOpptyCaseHistoryWrapper
    
    public static boolean checkIfFieldValueIsId(string fieldValue){
        
        if(fieldValue == null){
            return false;
        }
        String p_fieldValue = String.escapeSingleQuotes(fieldValue);
        if((p_fieldValue.length() == 15 || p_fieldValue.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', p_fieldValue)) {
            return true;
        }else{
            return false;
        }
        
    }  
    
    //added by srinivas.sattoor on 8.21.2017 for release 4.4 CID-000440
    // this method adds a file to the opportunity
    public static void saveOpportunityAttachment(string opportunityId, string attachmentBody, string attachmentName){
         
        ContentVersion objContentVersion = new ContentVersion();
        objContentVersion.versionData = EncodingUtil.base64Decode(attachmentBody);
        objContentVersion.title = attachmentName;
        objContentVersion.pathOnClient = '/'+attachmentName;
        insert objContentVersion;
        
        Id contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :objContentVersion.Id].ContentDocumentId;
        
        ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
        
        objContentDocumentLink.ContentDocumentId = contentDocumentId;
        objContentDocumentLink.LinkedEntityId = opportunityId;
        objContentDocumentLink.ShareType = 'V';
        insert objContentDocumentLink; 
        
    }// end of saveOpportunityAttachment
    
    //added by srinivas.sattoor on 8.21.2017 for release 4.4 CID-000440
    // this method updates the file of the opportunity 
    public static void updateOpportunityAttachment(string attachmentId, string attachmentName){
        
        ContentVersion objContentVersion = new ContentVersion(Id =attachmentId, title = attachmentName);
        update objContentVersion;
    }// end of updateOpportunityAttachment
    
     //added by srinivas.sattoor on 8.21.2017 for release 4.4 CID-000440
    // this method updates the file of the opportunity 
    public static void deleteOpportunityAttachment(string attachmentId, string opportunityId){
        
        
        ContentVersion objContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:attachmentId];
        //ContentDocument objContentDocument = [SELECT Id FROM ContentDocument WHERE Id =:objContentVersion.ContentDocumentId];
        //delete objContentDocument;
        list<ContentDocumentLink> lstContentDocumentLink  = [SELECT Id, ContentDocumentId, LinkedEntityId 
                                                            FROM ContentDocumentLink
                                                            WHERE ContentDocumentId = :objContentVersion.ContentDocumentId
                                                            AND LinkedEntityId = :opportunityId LIMIT 1];
        if(lstContentDocumentLink.size() > 0){
            
            delete lstContentDocumentLink;
        }
    }// end of updateOpportunityAttachment
    
     /*
        Vishnu Release 4.4
            Retrieve all the linked Opps to the given Lead
    */
    public static List<Opportunity_Leads__c> retrieveOpportunitiesLinkedToLead(String conferenceMemberId){
        List<Opportunity_Leads__c> lstLinkedOpportunities = new List<Opportunity_Leads__c>();
        
        for(Opportunity_Leads__c objLeadOpp : [SELECT Id, Conference_Member__c, Opportunity__c, 
                                                        Opportunity__r.Name, Opportunity__r.CloseDate, Opportunity__r.StageName
                                                 FROM Opportunity_Leads__c 
                                                WHERE Conference_Member__c = :conferenceMemberId]){
            lstLinkedOpportunities.add(objLeadOpp);
        }   //  end of for-each Existing linked Opp

        return lstLinkedOpportunities;
    }   //  end of retrieveOpportunitiesLinkedToLead

    /*
        Vishnu Release 4.4
            Creates a link between Lead and Opportunities
    */ 
    public static void cSaveOpportunityLead(String conferenceMemberId, List<String> lstOpportunityIds, String operationType){
        List<Opportunity_Leads__c> lstNewLeadOpps = new List<Opportunity_Leads__c>();
        List<Opportunity_Leads__c> lstUnLinkLeadOpps = new List<Opportunity_Leads__c>();
        Set<String> setExistingLeadOpps = new Set<String>();
        Set<String> setGivenOppIds = new Set<String>();
        Integer totalLinkedOppCount=0;
        Integer deletionCOunt=0;

        LeadOpportunityAccessor serviceNoSharing = new LeadOpportunityAccessor();

        for(String oppId : lstOpportunityIds){
            setGivenOppIds.add(oppId);
        }   //  end of for-each given Oppids

        for(Opportunity_Leads__c objLeadOpp : [SELECT Id, Conference_Member__c, Opportunity__c 
                                                 FROM Opportunity_Leads__c 
                                                WHERE Conference_Member__c = :conferenceMemberId]){
            totalLinkedOppCount++;
            setExistingLeadOpps.add(objLeadOpp.Opportunity__c);
            if('unlink'.equalsIgnoreCase(operationType) && setGivenOppIds.contains(objLeadOpp.Opportunity__c)){
                lstUnLinkLeadOpps.add(objLeadOpp);
            }
        }   //  end of for-each Existing linked Opp

        if('unlink'.equalsIgnoreCase(operationType)){
                //  Unlink operation was called so deleting the selected opps
            deletionCOunt = lstUnLinkLeadOpps.size();

            if(! lstUnLinkLeadOpps.isEmpty()){
                System.debug('##-- Deleting the linked Opportunities: ' + lstUnLinkLeadOpps);
                serviceNoSharing.deleteLeadOpportunity(lstUnLinkLeadOpps);
                //delete lstUnLinkLeadOpps;
            }

            if(deletionCOunt == totalLinkedOppCount){
                //  Since we deleted all the linked Opportunities we need to reset the Conf Member status
                updateConfMemberStatus(conferenceMemberId, 'Lead', '');
            }
        } else{
                //  Link operation is called so adding the Opps
            for(String oppId : lstOpportunityIds){
                if(! setExistingLeadOpps.contains(oppId)){
                    lstNewLeadOpps.add(new Opportunity_Leads__c(Conference_Member__c = conferenceMemberId,
                                                                Opportunity__c = oppId));
                }
            }   //  end of for-each new opp ids to be linked

            if(! lstNewLeadOpps.isEmpty()){
                System.debug('##-- Adding new Linked Opp for Lead: ' + lstNewLeadOpps);
                insert lstNewLeadOpps;
            }

                //  need to set the Conf Member status to Converted
            updateConfMemberStatus(conferenceMemberId, 'Converted', '');
        }   //   end of if-else

    }   //  end of cSaveOpportunityLead


    public static Boolean updateConfMemberStatus(String conferenceMemberId, String status, String message){
        List<Conference_Member__c> lstConfMembers = [SELECT Id, Status__c, Disqualify_Reason__c FROM Conference_Member__c WHERE Id = :conferenceMemberId];

        /*if(Utils.isListEmpty(lstConfMembers)){
            return true;
        }*/

        Conference_Member__c objConfMember = lstConfMembers[0];
        objConfMember.Status__c = status;
        objConfMember.Disqualify_Reason__c = message;

        System.debug('##-- Updating the Status of COnf Memebr: ' + objConfMember);
        update objConfMember;
        return true;
    }   //  end of updateConfMemberStatus


    /*
        Vishnu Release 4.4
            Creates a link between Opportunity and Leads
    */ 
    public static void cSaveLeadsForOpportunity(String opportunityId, List<String> lstConfMemIds, String operationType){
        List<Opportunity_Leads__c> lstNewLeadOpps = new List<Opportunity_Leads__c>();
        List<Opportunity_Leads__c> lstUnLinkLeadOpps = new List<Opportunity_Leads__c>();
        Set<String> setExistingLeadOpps = new Set<String>();
        Set<String> setGivenLeadIds = new Set<String>();
        Integer totalLinkedOppCount=0;
        Integer deletionCOunt=0;

        LeadOpportunityAccessor serviceNoSharing = new LeadOpportunityAccessor();

        for(String leadId : lstConfMemIds){
            setGivenLeadIds.add(leadId);
        }   //  end of for-each given Oppids

        for(Opportunity_Leads__c objLeadOpp : [SELECT Id, Conference_Member__c, Opportunity__c 
                                                 FROM Opportunity_Leads__c 
                                                WHERE Opportunity__c = :opportunityId]){
            totalLinkedOppCount++;
            setExistingLeadOpps.add(objLeadOpp.Conference_Member__c);
            if('unlink'.equalsIgnoreCase(operationType) && setGivenLeadIds.contains(objLeadOpp.Conference_Member__c)){
                lstUnLinkLeadOpps.add(objLeadOpp);
            }
        }   //  end of for-each Existing linked Opp

        if('unlink'.equalsIgnoreCase(operationType)){
                //  Unlink operation was called so deleting the selected opps
            deletionCOunt = lstUnLinkLeadOpps.size();

            if(! lstUnLinkLeadOpps.isEmpty()){
                System.debug('##-- Deleting the linked Opportunities: ' + lstUnLinkLeadOpps);
                serviceNoSharing.deleteLeadOpportunity(lstUnLinkLeadOpps);
                //delete lstUnLinkLeadOpps;
            }
            //  TODO: Set the Status for the Conf Members
        } else{
                //  Link operation is called so adding the Opps
            for(String leadId : lstConfMemIds){
                if(! setExistingLeadOpps.contains(leadId)){
                    lstNewLeadOpps.add(new Opportunity_Leads__c(Conference_Member__c = leadId,
                                                                Opportunity__c = opportunityId));
                }
            }   //  end of for-each new opp ids to be linked

            if(! lstNewLeadOpps.isEmpty()){
                System.debug('##-- Adding new Linked Opp for Lead: ' + lstNewLeadOpps);
                insert lstNewLeadOpps;
            }
            /*
                //  need to set the Conf Member status to Converted
            updateConfMemberStatus(conferenceMemberId, 'Converted', '');
            */
        }   //   end of if-else

    }   //  end of cSaveLeadsForOpportunity
    
    public without sharing class LeadOpportunityAccessor{
        
        public void deleteLeadOpportunity(List<Opportunity_Leads__c> lstUnLinkLeadOpps){
            
            delete lstUnLinkLeadOpps;
            
        }   // end of deleteLeadOpportunity
        
    }
    
}