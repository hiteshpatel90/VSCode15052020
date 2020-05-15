public with sharing class CS_ARSearch {


    public static List<Account> searchProvidersInMyTeamTerritory(String q) {
        List<Account> foundProviders = new List<Account>();
        
        // qualify the search so it only covers providers in the caller's territory
        List<Id> hcpsInTerritoryIds = CS_ARTerritoryService.retrieveHealthCareProvidersInMyTeamTerritory();
        
        if ( q == null || q.length() == 0 ) { 

            // if there's an empty search just return all the providers in the user's territory
            foundProviders = [SELECT Id,Name,Preferred_Name__c, BillingStreet, BillingPostalCode, BillingState, BillingCity, BillingCountry, BillingCountryCode,
                              ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, ShippingCountry, ShippingCountryCode, Phone, Fax,
                              Website, Customer_Number__c  
                          FROM Account 
                          WHERE Active__c =: TRUE
                          AND Id in :hcpsInTerritoryIds order BY Name Asc];

        } else {
            
            // sosl

            String objectName = 'Account';
            
            List<String> fieldNames = new List<String> { 'Id','Name','Phone','Fax','Preferred_Name__c','BillingStreet','BillingPostalCode','BillingState',
                                  'BillingCity','BillingCountry','BillingCountryCode', 'ShippingStreet', 'ShippingPostalCode', 
                                  'ShippingState', 'ShippingCity', 'ShippingCountry', 'ShippingCountryCode','Website','Customer_Number__c'};
            String filterClause = ' Id in (\''+String.join(hcpsInTerritoryIds,'\',\'')+'\') ';
            String orderBy = 'Name Asc';
            Integer recordLimit = 25;
            List<SObject> results = CS_ARSearch.searchRecords(q, objectName, fieldNames, filterClause, orderBy, recordLimit);
            for ( SObject obj : results ) {
                Account c = (Account)obj;
                foundProviders.add( c );
            }


        }

        for ( Account c : foundProviders ) {
           if ( c.Preferred_Name__c == null ) {
                // if preferred name isn't available use Name
                c.Preferred_name__c = c.Name;
            }

        }

        return foundProviders;
        
    }
    
    
    /* 
    Added by srinivas sattoor 05.25.2017 for 3.2 so that when managers
    assign an opp to an owner, accounts are filtered for the territory 
    of the opp owner
    */
    public static List<Account> searchProvidersInSelectedOwnerTerritory(string OwnerId, string territoryId) {
        
        system.debug('##--searchProvidersInSelectedOwnerTerritory.OwnerId: '+OwnerId);
        system.debug('##--searchProvidersInSelectedOwnerTerritory.territoryId: '+territoryId);
        if(string.isBlank(ownerId) && string.isBlank(territoryId)){
            
            return searchProvidersInMyTeamTerritory('');
        }
        
        set<Id> setUserTerritoryIds = CS_ARTerritoryService.retrieveTerritoryIdsForUser(OwnerId);
        system.debug('##--searchProvidersInSelectedOwnerTerritory.setUserTerritoryIds: '+setUserTerritoryIds);
        List<Account> foundProviders = new List<Account>();
        
        // qualify the search so it only covers providers in the caller's territory
        set<Id> hcpsInTerritoryIds = new set<Id>();
        if(string.isBlank(territoryId)){
            hcpsInTerritoryIds = CS_ARTerritoryService.retrieveAccountIdsForGivenTerritories(setUserTerritoryIds); 
        }else{
            // Added by Srinivas Sattoor for 4.1 CID-000287.This will retrieve accounts for a given territory
            hcpsInTerritoryIds = CS_ARTerritoryService.retrieveAccountIdsForGivenTerritories(new set<Id>{territoryId});
        }
        system.debug('##--searchProvidersInSelectedOwnerTerritory.hcpsInTerritoryIds: '+hcpsInTerritoryIds);
        
        // if there's an empty search just return all the providers in the user's territory 
        foundProviders = [SELECT Id,Name,Preferred_Name__c, BillingStreet, BillingPostalCode, BillingState, BillingCity, BillingCountry, 
                                BillingCountryCode, ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, ShippingCountry, 
                                ShippingCountryCode, Phone, Fax, Website, Customer_Number__c  
                          FROM Account 
                          WHERE Active__c =: TRUE
                          AND  Account_group__c = 'Z002'
                          AND Id IN :hcpsInTerritoryIds ORDER BY Name Asc];  
        for ( Account c : foundProviders ) {
           if ( c.Preferred_Name__c == null ) {
                // if preferred name isn't available use Name
                c.Preferred_name__c = c.Name;
            } 
        }
        system.debug('##--searchProvidersInSelectedOwnerTerritory.foundProviders: '+ foundProviders);
        return foundProviders;
        
    }// end of searchProvidersInSelectedOwnerTerritory
    
    // Swetha -- display Surgeon with Team name - START
    public static map<Id, List<string>> retriveMapAccountIdAndTerrirtoryName(set<Id>setAccountIds){
        
        map<Id, List<string>> mapAccountIdAndTerrirtoryName = new map<Id, List<string>>();
        for(ObjectTerritory2Association objTerritory2Association : [SELECT Id, Territory2.Name, objectId FROM ObjectTerritory2Association 
                                                                            WHERE objectId IN :setAccountIds]){
                                                                                
            if(mapAccountIdAndTerrirtoryName.containsKey(objTerritory2Association.objectId)){
                mapAccountIdAndTerrirtoryName.get(objTerritory2Association.objectId).add(objTerritory2Association.Territory2.Name);
            }else{
                List<string> strTerritory = new List<string>();
                strTerritory.add(objTerritory2Association.Territory2.Name);
                mapAccountIdAndTerrirtoryName.put(objTerritory2Association.objectId, strTerritory);
            }                                                                    
            
        }
        
        return mapAccountIdAndTerrirtoryName;
    }// end of retriveMapAccountIdAndTerrirtoryName
    
    // wrapper class to display Surgeon list
    public class accountWrapper{
        public Account objAccount {get; set;}
        public List<string> teamname {get; set;}
        public string strAccFullName {get; set;}
        public string scheduleCase {get; set;}
    }
    
    public static List<accountWrapper> searchSurgeonsInMyTeamTerritory() {
        List<accountWrapper> lstAccWrappter = new List<accountWrapper>();
        
        // if there's an empty search just return all the surgeons in the user's territory
        // foundSurgeons = [select Id,Name,Profile_Picture__c, Email__c, PersonEmail, Provider__r.Id, Provider__r.Name,Phone from Account where Id in :surgInTerritoryIds order by Name Asc];
        List<Account> foundSurgeons = [select Id,Name,designation__c,
            Internship__c, Certifications__c, Awards__c, Profile_Picture__c, Professional_Societies__c,Sport_Interests__c,
            Residencies__c,Fellowships__c  
            from Account  where RecordType.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER order by name Asc];
                
        set<Id> sAccId = new set<Id>();
        for(Account acc: foundSurgeons){
            sAccId.add(acc.id);
        }
        Map<Id, List<string>> mapAccountIdAndTerrirtoryName = new Map<Id, List<string>>();
        if(sAccId.size() > 0){
            
            mapAccountIdAndTerrirtoryName = retriveMapAccountIdAndTerrirtoryName(sAccId);
        }
        
        accountWrapper objaccountWrapper;
        for(Account acc: foundSurgeons){
            objaccountWrapper = new accountWrapper();
            objaccountWrapper.objAccount = acc;
            objaccountWrapper.teamname = mapAccountIdAndTerrirtoryName.get(acc.id);
            //objaccountWrapper.strAccFullName = acc.LastName + ', ' + acc.FirstName;
            objaccountWrapper.scheduleCase = 'Schedule Case';
            lstAccWrappter.add(objaccountWrapper);
        }
        return lstAccWrappter;
    }
    
    /* 
    Added by srinivas sattoor 05.25.2017 for 3.2 so that when managers
    assign an opp to an owner, surgeons are filtered for the territory 
    of the opp owner
    */
    public static List<accountWrapper> searchSurgeonsInSelectedOwnerTerritory(string ownerId, string territoryId) {
        
        if(string.isBlank(ownerId) && string.isBlank(territoryId)){
            
            return searchSurgeonsInMyTeamTerritory();
        }
        set<Id> setUserTerritoryIds = new set<Id>();
        set<Id> accountsInTerritoryIds = new set<Id>();
        List<accountWrapper> lstAccWrappter = new List<accountWrapper>();
        
        if(string.isBlank(territoryId)){
            setUserTerritoryIds = CS_ARTerritoryService.retrieveTerritoryIdsForUser(OwnerId);  
            
        }else{
            setUserTerritoryIds.add(territoryId);
        }
        system.debug('##--searchSurgeonsInSelectedOwnerTerritory.setUserTerritoryIds: '+setUserTerritoryIds);
        // this returns all the accounts in the territory including HCO's and Surgeons
        accountsInTerritoryIds = CS_ARTerritoryService.retrieveAccountIdsForGivenTerritories(setUserTerritoryIds); 
        
        // if there's an empty search just return all the surgeons in the user's territory
         list<Account> foundSurgeons = [SELECT Id,Name,
                                                Internship__c, Certifications__c, Awards__c,Professional_Societies__c,Sport_Interests__c,
                                                Residencies__c,Fellowships__c  
                                                FROM Account  
                                                WHERE RecordType.Name = :Constant.RECORDTYPE_NAME_PRACTITIONER
                                                AND Id IN :accountsInTerritoryIds
                                                ORDER BY Name Asc];
                
        set<Id> sAccId = new set<Id>();
        for(Account acc: foundSurgeons){
            sAccId.add(acc.id);
        }
        Map<Id, List<string>> mapAccountIdAndTerrirtoryName = new Map<Id, List<string>>();
        if(sAccId.size() > 0){
            
            mapAccountIdAndTerrirtoryName = retriveMapAccountIdAndTerrirtoryName(sAccId);
        }
        
        accountWrapper objaccountWrapper;
        for(Account acc: foundSurgeons){
            objaccountWrapper = new accountWrapper();
            objaccountWrapper.objAccount = acc;
            objaccountWrapper.teamname = mapAccountIdAndTerrirtoryName.get(acc.id);
            //objaccountWrapper.strAccFullName = acc.LastName + ', ' + acc.FirstName;
            objaccountWrapper.scheduleCase = 'Schedule Case';
            lstAccWrappter.add(objaccountWrapper);
        }
        return lstAccWrappter;
    }
    
    // Swetha -- display Surgeon with Team name -- END
    
    public static List<Account> searchSurgeonsInMyTeamTerritory(String q) {
        List<Account> foundSurgeons = new List<Account>();
        
        // qualify the search so it only covers surgeons in the caller's territory
        // List<Id> surgInTerritoryIds = CS_ARTerritoryService.retrieveSurgeonsInMyTeamTerritory();
        
        if ( q == null || q.length() == 0 ) {
            
            // if there's an empty search just return all the surgeons in the user's territory
            // foundSurgeons = [select Id,Name,Profile_Picture__c, Email__c, PersonEmail, Provider__r.Id, Provider__r.Name,Phone from Account where Id in :surgInTerritoryIds order by Name Asc];
            foundSurgeons = [select Id,Name,
                Internship__c, Certifications__c, Awards__c,Professional_Societies__c,Sport_Interests__c,
                Residencies__c,Fellowships__c  
                from Account  where RecordType.Name = :Constant.RECORDTYPE_NAME_PRACTITIONER order by Name Asc];

        } else {
            
            // sosl


            String objectName = 'Account';
            List<String> fieldNames = new List<String> { 'Id','Name','Internship__c', 'Certifications__c', 
                'Awards__c','Professional_Societies__c','Sport_Interests__c', 'Residencies__c','Fellowships__c'   };
            // String filterClause = ' Id in (\''+String.join(surgInTerritoryIds,'\',\'')+'\') ';
            String filterClause = ' RecordType.Name =\'Practitioner\' ';
            String orderBy = 'Name Asc';
            Integer recordLimit = 25;
            List<SObject> results = CS_ARSearch.searchRecords(q, objectName, fieldNames, filterClause, orderBy, recordLimit);
            for ( SObject obj : results ) {
                foundSurgeons.add( (Account) obj );
            }


        }
        return foundSurgeons;
        
    }    

    public static List<User> searchUsers(String q) {

        List<User> foundUsers = new List<User>();
        if ( q != null && q.length() > 3 ) {
            // sosl

            // retrieve the parent account id for this user ( it may not exist, if so the parentAccountId will be null)
            String curUserId = UserInfo.getUserId();
            User user = [select Contact.AccountId from User where Id=:curUserId];
            String parentAccountId = user.Contact.AccountId;


            String objectName = 'User';
            List<String> fieldNames = new List<String> { 'Id','Name','Email'};
            String orderBy = 'Name Desc';
            Integer recordLimit = 25;

            // scope the user search to partner users within the same account as the current user if possible
            String filterClause = '';
            filterClause = 'IsActive=true '; 
            if ( parentAccountId != null ) {
                filterClause += 'AND Contact.AccountId=\''+parentAccountId+'\' ';   
            }
            

            List<SObject> results = CS_ARSearch.searchRecords(q, objectName, fieldNames, filterClause, orderBy, recordLimit);
            for ( SObject obj : results ) {
                foundUsers.add( (User) obj );
            }

        }
        return foundUsers;
    }

    public static List<Institution__c> searchInstitutions(String q) {

        List<Institution__c> found = new List<Institution__c>();
        if ( q != null && q.length() > 3 && !q.equals('*all*') ) {
            // sosl

            String objectName = 'Institution__c';
            List<String> fieldNames = new List<String> { 'Id','Name'};
            String orderBy = 'Name Asc';
            Integer recordLimit = 25;
            String filterClause = '';   

            List<SObject> results = CS_ARSearch.searchRecords(q, objectName, fieldNames, filterClause, orderBy, recordLimit);
            for ( SObject obj : results ) {
                found.add( (Institution__c) obj );
            }

        }
        
        return found;
    }    


  public static list<sObject> searchRecords( String queryString, String objectName, 
    list<String> fieldNames, String filterClause, String orderBy, Integer recordLimit ) {
  if (queryString == null || queryString.length() == 0 ) { 
        return null;
    } 

    String sQuery = CS_ARSearch.escapeSearchTerm(queryString);

    String sObjectName = (objectName == null) ? 'Contact' : String.escapeSingleQuotes( objectName );

    String sInFields = ' IN ALL FIELDS ';
    
    String sFields = (fieldNames == null || fieldNames.isEmpty()) ? 'Id, Name' : 
    String.escapeSingleQuotes( String.join( fieldNames, ', ' ) );  
    
    String sOrder = ' ORDER BY ' + ( (orderBy == null || orderBy == '') ? 'Name' : String.escapeSingleQuotes(orderBy) ); 
    
    String sLimit = (recordLimit == null || recordLimit == 0 || recordLimit >= 2000) ? '' : 
      ( ' LIMIT ' + String.valueOf(recordLimit));
    
    // can't escape the filter clause
    String sWhere = (filterClause == null || filterClause == '') ? '' : 
      ( ' WHERE ' + filterClause );

    sQuery = CS_ARSearch.escapeSearchTerm(sQuery);
    //String queryStr = 'FIND { \"*'+ sQuery + '*\"}' + sInFields + ' RETURNING ' + sObjectName + '( ' + sFields + sWhere + sOrder + sLimit + ' )';
    String queryStr = 'FIND \''+ sQuery + '\'' + sInFields + ' RETURNING ' + sObjectName + '( ' + sFields + sWhere + sOrder + sLimit + ' )';


    System.debug(queryStr);

    list<list<sObject>> results = Search.query(queryStr);
    
    return results[0];
  }  

    public static String escapeSearchTerm(String term) {

        // just return null if input is null;
        if ( term == null ) { return null; }

        // exclude * and ? if you want your users to use wild cards
        final String specialChars = '& | ! ( ) { } [ ] ^ " ~ * ? : \' + -';
        //final String specialChars = '& | ! ( ) { } [ ] ^ " ~ * ? : \' + ';

        // get rid of all backslashes from the input term
        String cleansedTerm = term.replaceAll('\\\\', '');
        for (String sc: specialChars.split(' ')) {
            cleansedTerm = cleansedTerm.replaceAll('\\' + sc, '\\\\\\\\' + sc);
        }
        return cleansedTerm;
    }
    
    public static set<Id> searchHCOInMyTeamTerritory() {
        set<Id> foundHCO = new set<Id>();
        List<UserTerritory2Association> lstUserTerritory = [SELECT Id, Territory2Id,UserId from UserTerritory2Association where IsActive = true and UserId =: userinfo.getUserId()];
        set<Id> sUserTerritoties = new set<Id>();
        for(UserTerritory2Association uta: lstUserTerritory){
            sUserTerritoties.add(uta.Territory2Id);
        }
        //system.assertEquals(sUserTerritoties, null);
        // 1 Level
        Map<Id, Territory2> childTerritories1 = new  Map<Id, Territory2>([Select Id from Territory2 where ParentTerritory2Id in :sUserTerritoties]);
        //system.assertEquals(childTerritories1, null);
        // 2 Level
        if(!childTerritories1.keyset().isEmpty()){
            sUserTerritoties.addall(childTerritories1.keyset());
            Map<Id, Territory2> childTerritories2 = new  Map<Id, Territory2>([Select Id from Territory2 where ParentTerritory2Id in :childTerritories1.keyset()]);
            // 3 Level
            if(!childTerritories2.keyset().isEmpty()){
                sUserTerritoties.addall(childTerritories2.keyset());
                Map<Id, Territory2> childTerritories3 = new  Map<Id, Territory2>([Select Id from Territory2 where ParentTerritory2Id in :childTerritories2.keyset()]);
                // 4 Level
                if(!childTerritories3.keyset().isEmpty()){
                    sUserTerritoties.addall(childTerritories3.keyset());
                    Map<Id, Territory2> childTerritories4 = new  Map<Id, Territory2>([Select Id from Territory2 where ParentTerritory2Id in :childTerritories3.keyset()]);
                    // 5 Level
                    if(!childTerritories4.keyset().isEmpty()){
                        sUserTerritoties.addall(childTerritories4.keyset());
                        Map<Id, Territory2> childTerritories5 = new  Map<Id, Territory2>([Select Id from Territory2 where ParentTerritory2Id in :childTerritories4.keyset()]);
                        // 6 Level
                        if(!childTerritories5.keyset().isEmpty()){
                            sUserTerritoties.addall(childTerritories5.keyset());
                            Map<Id, Territory2> childTerritories6 = new  Map<Id, Territory2>([Select Id from Territory2 where ParentTerritory2Id in :childTerritories5.keyset()]);
                            // 7 Level
                            if(!childTerritories6.keyset().isEmpty()){
                                sUserTerritoties.addall(childTerritories6.keyset());
                                Map<Id, Territory2> childTerritories7 = new  Map<Id, Territory2>([Select Id from Territory2 where ParentTerritory2Id in :childTerritories6.keyset()]);
                                // 8 Level
                                if(!childTerritories7.keyset().isEmpty()){
                                    sUserTerritoties.addall(childTerritories7.keyset());
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        List<ObjectTerritory2Association> lstOTA = [SELECT Id, Territory2.Name, objectId, SobjectType FROM ObjectTerritory2Association where Territory2Id IN: sUserTerritoties];
        for(ObjectTerritory2Association ota: lstOTA){
            foundHCO.add(ota.objectId);
        }
        return foundHCO;
    
    }
}