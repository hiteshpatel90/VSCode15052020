public with sharing class CS_ARCasesService {

    public static void submitHelp(Map<String,Object> submission) {
        
        system.debug('##--submitHelp.submission: '+ submission);

        Case c = new Case();
        c.SuppliedEmail = (String)submission.get('email');
        c.SuppliedName = (String)submission.get('name');
        c.SuppliedPhone = (String)submission.get('phone');
        c.Subject = (String)submission.get('subject');
        c.Type = (String)submission.get('type');
        c.Description = (String)submission.get('description');
        c.Origin = 'Web';
        
        insert c;
    }

    public static List<User> searchUsers(String q) {
        
        return CS_ARSearch.searchUsers(q);
        
    }
    
    public static List<Product2> searchProducts(String q) {

        // quickly return if null or blank search query
        if ( q == null || q.length() == 0 ) { return new List<Product2>(); }

        // a product query can be qualified with a procedure by submitting
        // in the form <procedure ID>::<query string> however this feature
        // has been deprecated but I want to keep the format feature in case
        // it comes back in the future - Chad 
        String[] qElems = q.split('::');
        String query = null;
        String procedureId = null;
        if ( qElems.size() > 1 ) {
            procedureId = qElems[0];
            query = qElems[1];
        } else {
            query = qElems[0];
        }

        List<Product2> foundProducts = new List<Product2>();

        String objectName = 'Product2';
        List<String> fieldNames = new List<String> { 'Id','Name','Material_Number__c'};
        String filterClause = ' Available_in_User_Interface__c=true ';
        String orderBy = 'Name Desc';
        Integer recordLimit = 25;

        List<SObject> results = CS_ARSearch.searchRecords(query, objectName, fieldNames, filterClause, orderBy, recordLimit);
        if ( results == null ) { results = new List<SObject>(); }

        for ( SObject obj : results ) {
            foundProducts.add( (Product2) obj );
        }
        

        return foundProducts;
        
    }

    public static List<Practitioner_Procedure__c> retrievePreferenceCards(String practitionerId) {

        return CS_ARContactsService.retrievePractitionerPrefCards(practitionerId);

    }

    public static List<Procedure__c> searchProcedures(String q) {
        
        // quickly return if null search query
        if ( q == null ) { return new List<Procedure__c>(); }

        // q parameter is of the form <practitioner id>::<search string>
        String[] qElems = q.split('::');

        String practitionerId = null;
        String query = null;
        if ( qElems.size() > 1 ) {
            practitionerId = qElems[0];
            query = qElems[1];
        } else {
            query = qElems[0];
        }

        // weird object relationships here
        // 1. get procedures that can be searched for the given practitioner
        // 2. search procedures by name

        String filterClause = null;
        
        // Step 1. setup a filter clause consisting of procedure Ids for the given practitioner
        if ( practitionerId != null ) {
            // searching procedures tied to a practitioner is only performed if a practitioner Id is provided in the search query
            List<Practitioner_Procedure__c> procedures = Database.query('Select Id, Procedure__r.Id from Practitioner_Procedure__c where Practitioner__c =\''+String.escapeSingleQuotes(practitionerId)+'\'');
            if ( procedures == null ) { procedures = new List<Practitioner_Procedure__c>(); }
            
            filterClause = null;
            List<Id> procedureIds = new List<Id>();
            if ( procedures != null ) { 
                for ( Practitioner_Procedure__c procedure : procedures ) {
                    if ( filterClause == null ) { 
                        filterClause = '\''+procedure.Procedure__r.Id+'\'';
                    } else {
                        filterClause += ',\''+procedure.Procedure__r.Id+'\'';
                    }
                }
                filterClause = ' Id in ('+filterClause+') ';
            }
        }

        // Step 2. search procedures
        String objectName = 'Procedure__c';
        List<String> fieldNames = new List<String> { 'Id','Name','TaxonGroupId__c'};
        String orderBy = 'Name Desc';
        Integer recordLimit = 25;
        system.debug('********qElems: '+qElems);
        if(Test.isRunningTest()){
            qElems.add(qElems[0]);
        }


        if ( filterClause != null ) {
            // filter clause set above so add an AND
            filterClause += ' AND ';
        } else {
            // no filter clause init it to empty string 
            filterClause = '';
        }
        // TaxonGroupId__c must be procedure to exclude surgical techniques
        filterClause += ' TaxonGroupId__c = \'procedure\' ';


        List<SObject> results = CS_ARSearch.searchRecords(query, objectName, fieldNames, filterClause, orderBy, recordLimit);
        if ( results == null ) { results = new List<SObject>(); }

        List<Procedure__c> foundProcedures = new List<Procedure__c>();
        for ( SObject obj : results ) {
            foundProcedures.add( (Procedure__c) obj );
        }

        return foundProcedures;
        
    }
    
    public static List<Procedure__c> searchTaxonomy(string q){ 
        
        // quickly return if null search query
        if ( q == null ) { return new List<Procedure__c>(); } 
        
        string taxonGroupId = '';
        string productCategory = '';
        string typeOther = 'Other';
        String[] qElems = q.split('::');
        if (qElems.size() > 1){
            taxonGroupId = qElems[1];
        } if (qElems.size() > 2){
            productCategory = qElems[2];
        }
        
        system.debug('##--searchTaxonomy:q'+ q + 'taxonGroupId: ' + taxonGroupId); 
        String query = null; 
        query= qElems[0]; 
        // 1. search procedures by name 
        String filterClause = '';  
         
        String objectName = 'Procedure__c';
        
        List<String> fieldNames = new List<String> { 'Id','Name','TaxonGroupId__c'};
        String orderBy = 'Name Desc';
        Integer recordLimit = 25; 
       /* if(Test.isRunningTest()){
            qElems.add(qElems[0]);
        }*/   
         
        // TaxonGroupId__c must be procedure to exclude surgical techniques
        filterClause += ' TaxonGroupId__c = \'' + taxonGroupId + '\'';
        filterClause += ' AND Type__c != \'' + typeOther + '\'';
        
        if(productCategory != ''){
            filterClause += ' AND Product_Category__c = \'' + productCategory + '\'';
        }
        
        List<SObject> results = CS_ARSearch.searchRecords(query, objectName, fieldNames, filterClause, orderBy, recordLimit);
        if ( results == null ) { results = new List<SObject>(); }

        List<Procedure__c> foundProcedures = new List<Procedure__c>();
        for ( SObject obj : results ) {
            foundProcedures.add( (Procedure__c) obj );
        }
        return foundProcedures;
        
    }// end of searchTaxonomy
    
    public static List<Procedure_Relationships__c> searchSurgicalTechniques(String q){
        List<String> surgeIds;
        
        if(String.isBlank(q)){
            return new List<Procedure_Relationships__c>();
        } else if(! q.contains('::')){
            surgeIds = new List<String> {q};
        } else {
            surgeIds = q.split('::');
        }
        
        list< Procedure_Relationships__c > lstSurgicalTechniques = [SELECT Id, Child_Procedure__c, Child_Procedure__r.Name 
                                                                      FROM Procedure_Relationships__c 
                                                                     WHERE Parent_Procedure__c IN :surgeIds
                                                                       AND TaxonGroupId__c = 'surgical_technique'];
        
        return lstSurgicalTechniques;
    }   //  end of searchSurgicalTechniques
    
    public static List<ProcedureProduct__c> productsForSelectedProcedures(String q){
        list<ProcedureProduct__c> lstProducts = new list<ProcedureProduct__c>();
        list<String> procIds;
        
        if(String.isBlank(q)){
            return lstProducts;
        } else if(! q.contains('::')){
            procIds = new List<String> {q};
        } else {
            procIds = q.split('::');
        }
        
        lstProducts = [SELECT Id, Product__r.Name, Product__r.Material_Number__c, Product__c, Procedure__c  
                         FROM ProcedureProduct__c 
                        WHERE Procedure__c IN :procIds];
        
        return lstProducts;
    }   //  end of productsForSelectedProcedures

    public static List<Product2> retrievePreferenceCardProducts(String prefCardId) {

        List<Product2> products = new List<Product2>();
        set<Id> setProcedureProductIds = new set<Id>();

        List<Practitioner_Procedure_Products__c> productRefs = [select Product__r.Id from Practitioner_Procedure_Products__c where Practitioner_Procedure__c =:prefCardId];
        if ( productRefs != null && productRefs.size() > 0 ) {
            for ( Practitioner_Procedure_Products__c productRef : productRefs ) {
                //Id pid = productRef.Product__r.Id;
                //Product2 p = [select Id, Name from Product2 where  Available_in_User_Interface__c=true and id=:pid];
                //Product2 p = [select Id, Name from Product2 where id=:pid];
                if ( productRef.Product__r.Id != null ) { 
                    setProcedureProductIds.add(productRef.Product__r.Id); 
                }
            }
            
            if(setProcedureProductIds.size() > 0){
                for(Product2 objProduct :[select Id, Name from Product2 where Id IN :setProcedureProductIds]){
                    
                    products.add(objProduct);
                }
            }
        }

        return products;

    }

    public static List<Practitioner_Procedure_Products__c> resolvePractitionerProcedureProducts(String practitionerId, String procedureId) {

        List<Practitioner_Procedure_Products__c> products = null;

        List<Practitioner_Procedure__c> pps = [select Id from Practitioner_Procedure__c where Practitioner__c =:practitionerId AND Procedure__c =:procedureId ];
        if ( pps != null && pps.size() > 0 ) {
            Practitioner_Procedure__c pp = pps[0];
            products = [select Product__r.Name, Product__r.Id from Practitioner_Procedure_Products__c where Practitioner_Procedure__c =:pp.Id];
        }

        if ( products == null ) {
            products = new List<Practitioner_Procedure_Products__c>();
        }
        
        return products;
        
    }

    public static List<Case__c> retrieveCasesByPractitioner(String practitionerId) {
        List<Case__c> cases = [SELECT Id, Name, Description__c, Event_Start_Date__c, Event_End_Date__c,
                                                Health_Care_Provider__r.Name, Practitioner__r.Name, Procedure__r.Name, 
                                                Product__r.Name, OwnerId, Owner.Name, Procedure_Names_Placeholder__c
                                         FROM Case__c
                                         WHERE Practitioner__r.Id = :practitionerId
                                         ORDER BY Event_Start_Date__c desc ];
        if ( cases == null ) { cases = new List<Case__c>(); }
        
        return cases;
    }    

    public static CS_ARCalendarEventDTO retrieveCalendarEventDTOByCaseId(String caseId) {
        String caseListSoql = CS_ARCalendarEventDTO.getCaseBuildSoql();
        caseListSoql += ' WHERE Id=\''+String.escapeSingleQuotes(caseId)+'\'';

        CS_ARCalendarEventDTO caseDTO = null;

        List<Case__c> caseList = Database.query(caseListSoql);
        if ( caseList != null ) {

            // map acount territories to the case list
            List<Id> caseIds = new List<Id>();
            for ( Case__c c : caseList ) { caseIds.add(c.Health_Care_Provider__r.Id); }
            Map<Id,List<ObjectTerritory2Association>> territoryMap = CS_ARTerritoryService.mapObjectIdsToTerritories(caseIds);

            for ( Case__c c : caseList ) {

                caseDTO = CS_ARCalendarEventDTO.buildFromCase(c);

                // look up the territories
                List<ObjectTerritory2Association> territories = territoryMap.get(c.Health_Care_Provider__r.Id);
                if ( territories != null && territories.size() > 0 ){
                    // assuming only one territory
                    caseDTO.providerTerritory = territories[0].Territory2.Name;
                    caseDTO.providerTerritoryId = territories[0].Territory2Id;
                    caseDTO.providerParentTerritoryId = territories[0].Territory2.ParentTerritory2Id;

                }

            }
        }

        return caseDTO;
    
    }
    
    public static void updateCaseStage(String id, String nextStage){
        Case__c caseObj = [select Id, Status__c from Case__c where Id =:id];
        caseObj.Status__c = nextStage;
        update caseObj; 
    }   //  end  of updateCaseStage
    

    public static void cdeleteCase(String id) {

        Case__c caseObj = [select Id,OwnerId from Case__c where Id =:id];
        if ( caseObj != null ) {

            // if the current user is the owner than remove the entire case, otherwise just remove the participant entry
            String currentUserId = UserInfo.getUserId();
            if ( caseObj.OwnerId == currentUserId ) {
            
                // products mapped to this case
                Set<Case_Products__c> productList = new Set<Case_Products__c>([select Id,Product__c from Case_Products__c where Case__c =:caseObj.Id]);
                if ( productList == null ) { 
                    for ( Case_Products__c pr : productList ) {
                        delete pr;
                    }
                }

                // users mapped to this case
                Set<CaseParticipant__c> participantList = new Set<CaseParticipant__c>([select Id, Participant__c from CaseParticipant__c where Case__c =:caseObj.Id]);
                if ( participantList != null ) {
                    for ( CaseParticipant__c cp : participantList ) {
                        delete cp;
                    }
                }

                delete caseObj;

            } else {
                // take the current user off the participant list
                Set<CaseParticipant__c> participantList = new Set<CaseParticipant__c>([select Id, Participant__r.Id from CaseParticipant__c where Case__c =:caseObj.Id]);
                if ( participantList != null ) {
                    for ( CaseParticipant__c cp : participantList ) {
                        if ( cp.Participant__r.Id == currentUserId ) {
                            delete cp;                        
                        }
                    }
                }                

            }
            
        }
    }
    public static CS_ARCalendarEventDTO updateCaseDateTime(String id, Long startDateMs, Long endDateMs) {
        Case__c caseObj = Database.query(CS_ARCalendarEventDTO.getCaseBuildSoql()+' WHERE ID=\''+id+'\'');
        caseObj.Event_Start_Date__c = DateTime.newInstance(startDateMs);
        caseObj.Event_End_Date__c = DateTime.newInstance(endDateMs);

        update caseObj;

        return CS_ARCalendarEventDTO.buildFromCase( caseObj );
    }
    
   public static CaseParticipant__c cSaveCaseParticipant(string caseId,
                                                          string salesRepId){
        
        User participant = [SELECT Id, Title FROM User WHERE Id = :salesRepId];                                                 
        CaseParticipant__c objCaseParticipant = new CaseParticipant__c(Case__c= caseId,
                                                                       Participant__c =salesRepId,
                                                                       Participant__r =participant);
        insert objCaseParticipant;
        return objCaseParticipant;
    
    }// end of cSaveOpportunityContactRole
    
    public static CS_ARCalendarEventDTO updateCase(String caseId, Long startDateMs, Long endDateMs){
        
        Case__c caseObj = new Case__c();
        caseObj.Id = caseId;
        system.debug('##-- Updating the case: ' + caseId);
        // incoming date/time is UTC
        TimeZone tz = UserInfo.getTimeZone();
        DateTime startUTC = DateTime.newInstance(startDateMs);
        DateTime startDateTime = startUTC.AddSeconds(tz.getOffset(startUTC)/1000);

        DateTime endUTC = DateTime.newInstance(endDateMs);
        DateTime endDateTime = endUTC.AddSeconds(tz.getOffset(endUTC)/1000);

        caseObj.Event_Start_Date__c = startUTC;
        caseObj.Event_End_Date__c = endUTC;
        
        update caseObj;
        
        system.debug('##--Updated the Case: ' + caseObj);
        
        return CalendarDTOForCase(caseObj.Id);
        
    }   //  end of updateCase

    public static CS_ARCalendarEventDTO csaveCase(String id, 
                                                 String providerId, 
                                                 String practitionerId, 
                                                 List<String> prefCardIdList, 
                                                 String notes, 
                                                 Long startDateMs, 
                                                 Long endDateMs, 
                                                 List<String> productIdList, 
                                                 List<String> participantIdList, 
                                                 String status,
                                                 List<String> procedureIdList, 
                                                 List<String> surgicalIds, 
                                                 String selectedOwnerId) {

        Set<String> productIds = new Set<String>(productIdList);
        Set<String> participantIds = new Set<String>(participantIdList);
        Set<String> prefCardIds = new Set<String>(prefCardIdList);
        set<Id>setExistingProcedureIds = new set<Id>();
        set<Id>setExistingSurgicalTechniqueIds = new set<Id>();
        list<Case_Procedure__c> lstExistingProceduresToBeDeleted = new list<Case_Procedure__c>();
        list<Case_Procedure__c> lstProceduresToBeInserted = new list<Case_Procedure__c>();
        List<Case_Procedure__c> lstExistingProcedures = new List<Case_Procedure__c>();
        List<Case_Procedure__c> lstExistingSurgicalProcedures = new List<Case_Procedure__c>();
        
        
        Case__c caseObj = new Case__c();
        caseObj.Id = id;

        caseObj.Status__c = status;        
        caseObj.Health_Care_Provider__c = providerId; 
        caseObj.Practitioner__c = practitionerId;

        // incoming date/time is UTC
        TimeZone tz = UserInfo.getTimeZone();
        DateTime startUTC = DateTime.newInstance(startDateMs);
        DateTime startDateTime = startUTC.AddSeconds(tz.getOffset(startUTC)/1000);

        DateTime endUTC = DateTime.newInstance(endDateMs);
        DateTime endDateTime = endUTC.AddSeconds(tz.getOffset(endUTC)/1000);

        caseObj.Event_Start_Date__c = startUTC;
        caseObj.Event_End_Date__c = endUTC;


        caseObj.Description__c = notes;
        
        if(String.isNotBlank(selectedOwnerId)){
            caseObj.ownerId = selectedOwnerId;
        }
        // omitting product__c since we're attaching a list
        // caseObj.Product__c = ??
        upsert caseObj;

        // replace case procedures mapped to this case
        lstExistingProcedures = [select Id from Case_Procedure__c where Case__c=:caseObj.Id AND (Procedure__r.TaxonGroupId__c = 'Procedure' OR Procedure__r.TaxonGroupId__c = 'product_category')];
        
        if(lstExistingProcedures.size() > 0){
            for(Case_Procedure__c objCaseProcedure :lstExistingProcedures){
                setExistingProcedureIds.add(objCaseProcedure.Id);
            }
        }
        
        set<string> setProceduresNeeded = new set<string>();
        for ( String procId : procedureIdList ) {
            string[] lstTaxononmy = procId.split('::');
            // CID - CDID-000082/Swetha P/Dec/28/2016/Case Calendar Status -->
                      
            string procedureId;
            if(lstTaxononmy.size() > 1){
                procedureId = lstTaxononmy[1];
            }
            Id ProductTeamId = lstTaxononmy[0];
            string procedureName = '';
            if(lstTaxononmy.size() > 2){
             procedureName = lstTaxononmy[2];
            }
            //CID - CDID-000082/Swetha P/Dec/28/2016/Case Calendar Status -->
            if(procedureId.endsWithIgnoreCase('newId')){
                
                Procedure__c objProc = new Procedure__c(Procedure_Name__c = procedureName, 
                                                        Name = procedureName,  
                                                        TaxonGroupId__c = 'Procedure', 
                                                        Type__c = 'Other');
                
                insert objProc;
                
                procedureId = objProc.Id;
            }
            setProceduresNeeded.add(procedureId);
            if(!setExistingProcedureIds.contains(procedureId)){
                Case_Procedure__c caseProc = new Case_Procedure__c(Procedure__c = procedureId,
                                                                    Case__c = caseObj.Id,
                                                                    Product_Team__c = ProductTeamId);
                lstProceduresToBeInserted.add(caseProc);
            }
        }// end of for-each
        
        
        //delete existingProcedures;
        if(lstExistingProcedures.size() > 0){
            //set<string> setProceduresNeeded = new set<string>();
            //setProceduresNeeded.addALL(setProcedureIds);
            for(Case_Procedure__c objCaseProcedure :lstExistingProcedures){
                if(!setProceduresNeeded.contains(objCaseProcedure.Id)){
                    lstExistingProceduresToBeDeleted.add(objCaseProcedure); 
                }
                
            }
        }
        
        
        // replace case surgical procedures mapped to this case
        lstExistingSurgicalProcedures = [select Id from Case_Procedure__c where Case__c=:caseObj.Id AND (Procedure__r.TaxonGroupId__c = 'surgical_technique' OR Procedure__r.TaxonGroupId__c= 'product_family')];
        if(lstExistingSurgicalProcedures.size() > 0){
            for(Case_Procedure__c objCaseProcedure :lstExistingSurgicalProcedures){
                setExistingSurgicalTechniqueIds.add(objCaseProcedure.Id);
            }
        }
        
        set<string> setSurgicalProceduresNeeded = new set<string>();
        for ( String procId : surgicalIds ) {
            string[] lstTaxononmy = procId.split('::');
            string surgicalTechniqueId;
            if(lstTaxononmy.size() > 1){
             surgicalTechniqueId = lstTaxononmy[1];
            }
            Id ProductTeamId = lstTaxononmy[0];
            string procedureName = '';
            if(lstTaxononmy.size() > 2){
             procedureName = lstTaxononmy[2];
            }
            if(surgicalTechniqueId.endsWithIgnoreCase('newId')){
                
                Procedure__c objSurgicalProc = new Procedure__c(Procedure_Name__c = procedureName, 
                                                        Name = procedureName,  
                                                        TaxonGroupId__c = 'surgical_technique', 
                                                        Type__c = 'Other');
                
                insert objSurgicalProc;
                
                surgicalTechniqueId = objSurgicalProc.Id;
            }
            setSurgicalProceduresNeeded.add(surgicalTechniqueId);
            if(!setExistingSurgicalTechniqueIds.contains(surgicalTechniqueId)){
                Case_Procedure__c caseProc = new Case_Procedure__c(Procedure__c = surgicalTechniqueId,
                                                                    Case__c = caseObj.Id,
                                                                    Product_Team__c = ProductTeamId);
                lstProceduresToBeInserted.add(caseProc);
            }
        }// end of for-each
        
         //delete existingProcedures;
        if(lstExistingSurgicalProcedures.size() > 0){
            //setSurgicalProceduresNeeded.addALL(surgicalIds);
            for(Case_Procedure__c objCaseProcedure :lstExistingSurgicalProcedures){
                if(!setSurgicalProceduresNeeded.contains(objCaseProcedure.Id)){
                    lstExistingProceduresToBeDeleted.add(objCaseProcedure); 
                }
                
            }
        }
        
        if(lstExistingProceduresToBeDeleted.size() > 0){
            delete lstExistingProceduresToBeDeleted;
        }
        
        if(lstProceduresToBeInserted.size() > 0){
            insert lstProceduresToBeInserted;
        }
        

        // replace pref cards mapped to this case
        
        /*
        Below has been commented by Srinivas Sattoor 10/05/2016 as the below child records were being now added from detail page
        */
        /*List<Case_Pref_Card__c> prefCards = new List<Case_Pref_Card__c>([Select Id,Practitioner_Procedure__c from Case_Pref_Card__c where Case__c =:caseObj.Id]);
        delete prefCards;
        for ( String prefCardId : prefCardIds ) {
            Case_Pref_Card__c casePrefCard = new Case_Pref_Card__c();
            casePrefCard.Practitioner_Procedure__c = prefCardId;
            casePrefCard.Case__c = caseObj.Id;
            insert casePrefCard;
        }        
            
        // replace products mapped to this case
        List<Case_Products__c> productList = new List<Case_Products__c>([select Id,Product__c from Case_Products__c where Case__c =:caseObj.Id]);
        delete productList;
        for ( String productId : productIds ) {
            Case_Products__c caseProduct = new Case_Products__c();
            caseProduct.Product__c = productId;
            caseProduct.Case__c = caseObj.Id;
            insert caseProduct;
        }        

        // replace users mapped to this case
        List<CaseParticipant__c> participantList = new List<CaseParticipant__c>([select Id, Participant__c from CaseParticipant__c where Case__c =:caseObj.Id]);
        delete participantList;
        for ( String participantId : participantIds ) {
            CaseParticipant__c caseParticipant = new CaseParticipant__c();
            caseParticipant.Case__c = caseObj.Id;
            caseParticipant.Participant__c = participantId;
            insert caseParticipant;
        }      */  
     
        return CalendarDTOForCase(caseObj.Id);

    }
    @Testvisible
    private static CS_ARCalendarEventDTO CalendarDTOForCase(String caseId){
        
        // get the newly updated Case__c as a CS_ARCalendarEventDTO
        Case__c newlySavedCase = Database.query(CS_ARCalendarEventDTO.getCaseBuildSoql()+' WHERE ID=\''+ caseId +'\'');
        
        CS_ARCalendarEventDTO caseDTO = CS_ARCalendarEventDTO.buildFromCase( newlySavedCase );


        // resolve the territory for this case ( health care provider )
        Set<Id> userTerritoryIds = new Set<Id>(CS_ARTerritoryService.retrieveMyTerritoryIds());
        List<Id> providerIdAsList = new List<Id> { newlySavedCase.Health_Care_Provider__r.Id };
        Map<Id,List<ObjectTerritory2Association>> territoryMap = CS_ARTerritoryService.mapObjectIdsToTerritories(providerIdAsList);
        List<ObjectTerritory2Association> territories = territoryMap.get(newlySavedCase.Health_Care_Provider__r.Id );
        if ( territories != null && territories.size() > 0 ){
            
            // it's possible that a provider could be in multipl territories, one of which may not be in the user's 
            // territory. Only set the territory the user has access to
            for ( ObjectTerritory2Association territoryAssoc : territories ) {
                
                if ( userTerritoryIds.contains(territoryAssoc.Territory2Id) || userTerritoryIds.contains(territoryAssoc.Territory2.ParentTerritory2Id) ) {
                    
                    caseDTO.providerTerritory = territoryAssoc.Territory2.Name;
                    caseDTO.providerTerritoryId = territoryAssoc.Territory2Id;
                    caseDTO.providerParentTerritoryId = territoryAssoc.Territory2.ParentTerritory2Id;
                }

            }

        }   

        // all done
        return caseDTO;
        
    }   //  end of CalendarDTOForCase
    
    public static List<CaseParticipant__c> retrieveCaseParticipants(String caseId ) {
        List<CaseParticipant__c> caseParticipants = [select Participant__r.Id, Participant__r.Name from CaseParticipant__c where Case__c =:caseId];
        if ( caseParticipants == null ) { caseParticipants = new List<CaseParticipant__c>(); }
        return caseParticipants;
    }
    
    public static List<Case_Products__c> retrieveCaseProducts(String caseId) {
        List<Case_Products__c> caseProducts = [select Product__r.Id, Product__r.Name from Case_Products__c where Case__c =:caseId];
        if ( caseProducts == null ) { caseProducts = new List<Case_Products__c>(); }
        return caseProducts;                                     
    }
    
    public static List<Case_Procedure__c> retrieveCaseProcedures(String caseId) {
        List<Case_Procedure__c> caseProcedures = [SELECT Procedure__r.Id, Procedure__r.Name FROM Case_Procedure__c 
                                                                        WHERE Case__c =:caseId AND (Procedure__r.TaxonGroupId__c = 'Procedure' OR Procedure__r.TaxonGroupId__c = 'product_category')];
        if ( caseProcedures == null ) { caseProcedures = new List<Case_Procedure__c>(); }
        return caseProcedures;                                     
    }
    
    public static List<Case_Procedure__c> retrieveCaseSurgicaProcedures(String caseId) {
        List<Case_Procedure__c> caseProcedures = [SELECT Procedure__r.Id, Procedure__r.Name FROM Case_Procedure__c 
                                                                        WHERE Case__c =:caseId AND (Procedure__r.TaxonGroupId__c = 'surgical_technique' OR Procedure__r.TaxonGroupId__c = 'product_family')];
        if ( caseProcedures == null ) { caseProcedures = new List<Case_Procedure__c>(); }
        return caseProcedures;                                     
    }   //  end of retrieveCaseSurgicaProcedures
    
    public static List<Case_Pref_Card__c> retrieveCasePrefCards(String caseId) {
        List<Case_Pref_Card__c> casePrefCards = [select Practitioner_Procedure__r.Pref_Card_Name__c,Practitioner_Procedure__r.Id  from Case_Pref_Card__c where Case__c =:caseId];
        if ( casePrefCards == null ) { casePrefCards = new List<Case_Pref_Card__c>(); }
        return casePrefCards;                                     
    }    
    
    
    //Update Calendar Color attribute for the team
    public static boolean updateCalendarColor(Map<id, string> calendarColors){

        system.debug('Ready to  update user colors for: ' + calendarColors.keySet().size() + ';');

        List<string> userIds = new List<String>();
        List<User> usersToUpdate = new List<User>();
        for(Id userId : calendarColors.keySet()){
            userIds.add(userId);
            system.debug('Add user id to query: ' + userId);
        }

        system.debug('*** length of users to update: ' + userIds.size());
        for(User user : [select Id, Calendar_Color__c from User where Id IN :userIds]){
                user.Calendar_Color__c = calendarColors.get(user.Id);
                usersToUpdate.add(user);
                system.debug('DML: Updating calendar color: ' + user.Id+ ' with color: ' + user.Calendar_Color__c);
        }

        Database.SaveResult[] srList = Database.update(usersToUpdate, false);

        for(Database.SaveResult sr : srList){
            if(!sr.isSuccess()){
                system.debug('Color update failed for this user: ' + sr.getErrors());
                return false;
            }
        }

        return true;
    }
    
    public static Case_Pref_Card__c addCasePreferenceCard(String caseId, string prefcardId){
        
        Case_Pref_Card__c objCasePrefCard = new Case_Pref_Card__c();
        objCasePrefCard.Case__c = caseId;
        objCasePrefCard.Practitioner_Procedure__c = prefcardId;
         
        insert objCasePrefCard;
        objCasePrefCard= [SELECT Id,Practitioner_Procedure__c,Practitioner_Procedure__r.Procedure__r.Name,
                           Practitioner_Procedure__r.Pref_Card_Name__c, Case__c FROM  Case_Pref_Card__c WHERE Id = :objCasePrefCard.Id]; 
        
        return objCasePrefCard;
        
    }   //  end of addCasePreferenceCard
    
    public static list<CaseWrapper> retrieveCaseActivity(string activityType, 
                                                        Id caseId){
        
        list<CS_CaseActivityWrapper> lstCS_CaseActivityWrapper = new list<CS_CaseActivityWrapper>();
        list<CaseWrapper> lstSortedCaseWrapper= new list<CaseWrapper>();
        
        for(Case__c objCase :[SELECT Id, 
                                    (SELECT Id, IsDeleted, ParentId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue FROM Histories), // fetching history
                                    //(SELECT Id, Case__r.Health_Care_Provider__r.Name , Case__r.Event_Start_Date__c, Case__r.Health_Care_Provider__c, Case__r.Practitioner__c, Case__r.Practitioner__r.Name FROM Opportunity_Cases__r), //fetching surgical cases
                                    (SELECT Id, CreatedDate, Body, CreatedBy.Name FROM Notes), //fetching logs
                                    (SELECT Id, CreatedDate, CreatedBy.Name, Subject, Description FROM Tasks),// fetching tasks
                                    (SELECT Id, CreatedDate, CreatedBy.Name, Participant__r.Name FROM Case_Participants__r),
                                    (SELECT Id, CreatedDate, CreatedBy.Name, Practitioner_Procedure__r.Pref_Card_Name__c FROM Case_Pref_Cards__r),
                                    (SELECT Id, CreatedDate, CreatedBy.Name, Opportunity__r.Name FROM Opportunity_Cases__r)
                                    FROM Case__c WHERE Id = : caseId]){
            
            // adding opporutnity history   
            
            if(activityType == 'All Activities' || activityType == 'Log'){                  
                for(Case__History objCaseFieldHistory :objCase.Histories){
                    
                    string wrapperNotes ='';
                     
                    if(retrieveFieldName('Case__c', objCaseFieldHistory.Field) == 'Created'){
                        wrapperNotes = objCaseFieldHistory.CreatedBy.Name + ' ' + retrieveFieldName('Case__c', objCaseFieldHistory.Field) ;
                    }else{
                        
                        wrapperNotes = objCaseFieldHistory.CreatedBy.Name + ' changed ' + retrieveFieldName('Case__c', objCaseFieldHistory.Field);
                        if(objCaseFieldHistory.OldValue != null){
                            wrapperNotes += ' from ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objCaseFieldHistory.OldValue));
                            
                        }
                        wrapperNotes += ' to ' ;
                        wrapperNotes += CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objCaseFieldHistory.NewValue));
                    }
                    
                    CS_CaseActivityWrapper objWrapper = new CS_CaseActivityWrapper(objCaseFieldHistory.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG');        
                        lstCS_CaseActivityWrapper.add(objWrapper);   
                    
                }// end of for -each history
                
                
                if(objCase.Case_Participants__r.size() >0){
                    for(CaseParticipant__c objCaseParticipant :objCase.Case_Participants__r){
                        string wrapperNotes ='';
                        wrapperNotes = objCaseParticipant.CreatedBy.Name + ' added ' + objCaseParticipant.Participant__r.Name + ' as case participant' ;
                        CS_CaseActivityWrapper objWrapper = new CS_CaseActivityWrapper(objCaseParticipant.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG');        
                        lstCS_CaseActivityWrapper.add(objWrapper);
                    }
                }
                
                if(objCase.Case_Pref_Cards__r.size() >0){
                    for(Case_Pref_Card__c objCasePrefcard :objCase.Case_Pref_Cards__r){
                        string wrapperNotes ='';
                        wrapperNotes = objCasePrefcard.CreatedBy.Name + ' added ' + objCasePrefcard.Practitioner_Procedure__r.Pref_Card_Name__c + ' as case preference card' ;
                        CS_CaseActivityWrapper objWrapper = new CS_CaseActivityWrapper(objCasePrefcard.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG');        
                        lstCS_CaseActivityWrapper.add(objWrapper);
                    }
                }
                
                if(objCase.Opportunity_Cases__r.size() >0){
                    for(Opportunity_Case__c objOppCase :objCase.Opportunity_Cases__r){
                        string wrapperNotes ='';
                        wrapperNotes = objOppCase.CreatedBy.Name + ' added ' + objOppCase.Opportunity__r.Name + ' as linked opportunity' ;
                        CS_CaseActivityWrapper objWrapper = new CS_CaseActivityWrapper(objOppCase.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG');        
                        lstCS_CaseActivityWrapper.add(objWrapper);
                    }
                }
            
            }
            
            if(activityType == 'All Activities' || activityType == 'Note'){
                for(Note objNote : objCase.Notes){
                    
                    CS_CaseActivityWrapper objWrapper = new CS_CaseActivityWrapper(objNote.CreatedDate,
                                                                                             objNote.Body,
                                                                                             'NOTE');       
                        lstCS_CaseActivityWrapper.add(objWrapper);   
                    
                }
            }
            
            if(activityType == 'All Activities' || activityType == 'Task'){
                for(Task objTask : objCase.Tasks){
                    CS_CaseActivityWrapper objWrapper = new CS_CaseActivityWrapper(objTask.CreatedDate,
                                                                                             objTask.Description,
                                                                                             'TASK');       
                        lstCS_CaseActivityWrapper.add(objWrapper);
                    
                }
            }
            
        }
        
        for(CS_CaseActivityWrapper objWrapper : lstCS_CaseActivityWrapper){
            
            lstSortedCaseWrapper.add(new CaseWrapper(objWrapper));
        }
        lstSortedCaseWrapper.sort();
        
        return lstSortedCaseWrapper;
    
    }// end of retrieveOpportunityFieldHistory 
    
     public static list<CS_OpportunityCase> retrieveCasesToBeLinked(Id surgeonId ) {
        list<CS_OpportunityCase> lstCS_OpportunityCases = new list<CS_OpportunityCase>();
        
        for(Case__c objCase : [SELECT Id, Event_Start_Date__c, Practitioner__r.Name,
                                    Owner.Name, Health_Care_Provider__r.Name, Status__c,
                                    (SELECT Id, Procedure__c, Case__c, Procedure__r.Name FROM Case_Procedures__r)
                                        FROM Case__c 
                                        WHERE Practitioner__c = :surgeonId
                                        ]){
                                            
            lstCS_OpportunityCases.add(new CS_OpportunityCase(objCase));
        }
        
        return lstCS_OpportunityCases;
    }// end of retrieveOpportunitiesToBeLinked
    
    public static list<CS_LinkOpportunity> retrieveOpportunitiesToBeLinked(Id surgeonId,
                                                                            Id caseId) {
        list<CS_LinkOpportunity> lstCS_LinkOpportunities = new list<CS_LinkOpportunity>();
        
        list<CS_OpportunityCase> lstCS_OpportunityCases = new list<CS_OpportunityCase>();
        set<Id> setExistingLinkedOpportunityIds = new set<Id>();
        
        for(Opportunity_Case__c objOppCase : [SELECT Id, Case__c, Opportunity__c 
                                                    FROM Opportunity_Case__c 
                                                    WHERE Case__c = :caseId]){
            
            setExistingLinkedOpportunityIds.add(objOppCase.Opportunity__c);
        }
                                        
        for(Opportunity_Surgeons__c objOpptySurgeon : [SELECT Id, Opportunity__c, Opportunity__r.Name, Opportunity__r.Type,
                                                        Opportunity__r.StageName, Opportunity__r.Potential_Revenue_per_Case__c,
                                                        Opportunity__r.CloseDate, Surgeon__c
                                                            FROM Opportunity_Surgeons__c
                                                            WHERE Surgeon__c = :surgeonId]){
                                                                
            if(!setExistingLinkedOpportunityIds.contains(objOpptySurgeon.Opportunity__c)){
                                            
                lstCS_LinkOpportunities.add(new CS_LinkOpportunity(objOpptySurgeon));
            }
        }
        system.debug('##--lstCS_LinkOpportunities: '+ lstCS_LinkOpportunities);
        return lstCS_LinkOpportunities;
    }// end of retrieveOpportunitiesToBeLinked
    
    public static list<Opportunity_Case__c> cSaveLinkedOpportunities(string caseId, list<string> lstLinkedOpportunityIds){
        
        list<Opportunity_Case__c> lstOpportunityCases = new list<Opportunity_Case__c>();
        
        if(lstLinkedOpportunityIds.size() == 0){
            return lstOpportunityCases;
        }
        for(Opportunity linkedOpportunity : [SELECT Id, Name, Type FROM Opportunity WHERE Id IN :lstLinkedOpportunityIds]){
            
            Opportunity_Case__c objLinkOpportunityCase = new Opportunity_Case__c(Case__c = caseId,
                                                                      Opportunity__c = linkedOpportunity.Id,
                                                                      Opportunity__r = linkedOpportunity);
            
            lstOpportunityCases.add(objLinkOpportunityCase);
        }
        
        if(lstOpportunityCases.size() > 0){
            insert lstOpportunityCases;
        }
        
        return lstOpportunityCases;
        
    }// end of cSaveLinkedOpportunities
    
    public static list<Linked_Case__c> cSaveLinkedCases(string parentCaseId, list<string> lstCaseIds){
        
        list<Linked_Case__c> lstLinkedCases = new list<Linked_Case__c>();
        if(lstCaseIds.size() == 0){
            return lstLinkedCases;
        }
        for(Case__c objCase : [SELECT Id, Event_Start_Date__c, Event_End_Date__c, Health_Care_Provider__c, Practitioner__c, Procedure__c 
                                            FROM Case__c WHERE Id IN :lstCaseIds]){
            
            Linked_Case__c objLinkCase = new Linked_Case__c(Case__c = parentCaseId,
                                                            Linked_Case__r = objCase, 
                                                            Linked_Case__c = objCase.Id);
            
            lstLinkedCases.add(objLinkCase);
        }
        
        if(lstLinkedCases.size() > 0){
            insert lstLinkedCases;
        }
        
        return lstLinkedCases;
        
    }// end of cSaveLinkedCases
    
    
    public static void cDeleteCaseParticipant(string caseParticipantId){
        
        CaseParticipant__c objCaseParticipant = new CaseParticipant__c(Id = caseParticipantId);
        delete objCaseParticipant ;
    }// end of cDeleteCaseParticipant
    
    public static void createCaseNote(string caseId, string noteBody){
        
        Note caseNote = new Note(ParentId = caseId,
                                        Title = 'Opportunity Note',
                                        Body = noteBody);
        insert caseNote ;
    }// end of createNote
    
    public static void cDeletePreferenceCard(string casePreferenceCardId){
        
        Case_Pref_Card__c objCasePrefCard = new Case_Pref_Card__c(Id = casePreferenceCardId);
        delete objCasePrefCard ;
    }// end of cDeletePreferenceCard
    
    public static void cDeleteLinkedOpportunityCase(string linkedOpportunityCaseId){
        
        Opportunity_Case__c objOpptyCase = new Opportunity_Case__c(Id = linkedOpportunityCaseId);
        delete objOpptyCase ;
    }// end of cDeleteLinkedOpportunityCase
    
    
    
    public static string retrieveFieldName(string objectType, string fieldAPIName){
        
        system.debug('##--fieldAPIName: '+ fieldAPIName + ': ' + fieldAPIName);
        
        if(fieldAPIName == 'Created'){
            
            return 'Created';
        }
        
        map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectType);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        
        return fieldMap.get(fieldAPIName).getDescribe().getLabel();
        
    }
    
    public class CS_OpportunityCase{
        
        public boolean selected {get;set;}
        public Case__c objCase {get;set;} 
        public string procedureNames {get;set;}
        
        public CS_OpportunityCase(Case__c p_objCase){
            
            selected = false;
            objCase = p_objCase;
            procedureNames = '';
            if(p_objCase.Case_Procedures__r.size() > 0){
                
                for(Case_Procedure__c objCaseProc : p_objCase.Case_Procedures__r){
                    procedureNames += objCaseProc.Procedure__r.Name + ',';
                }
                procedureNames.removeEnd(',');
            }
        }
    }
    
    public class CS_LinkOpportunity{
        
        public boolean selected {get;set;}
        public Opportunity_Surgeons__c objOpportunitySurgeon {get;set;}
        
        public CS_LinkOpportunity(Opportunity_Surgeons__c p_objOpportunitySurgeon){
            
            selected = false;
            objOpportunitySurgeon = p_objOpportunitySurgeon;
        }
    }
    
    public class CS_CaseActivityWrapper{
        
        public datetime logDate {get;set;}
        public string notes {get;set;}
        public string activityType {get;set;}
        
        public CS_CaseActivityWrapper(datetime p_logDate,
                                        string p_notes,
                                         string p_activityType){
            
            logDate = p_logDate;
            notes = p_notes;
            activityType = p_activityType; 
        }
    }// end of CS_OpportunityLogWrapper
    
    public class CaseWrapper implements Comparable {

        public CS_CaseActivityWrapper caseActivity;
        
        // Constructor
        public CaseWrapper(CS_CaseActivityWrapper objCaseActivity) {
            caseActivity = objCaseActivity;
        }
        
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            CaseWrapper compareToOppy = (CaseWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (caseActivity.logDate < compareToOppy.caseActivity.logDate) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (caseActivity.logDate > compareToOppy.caseActivity.logDate) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }

}