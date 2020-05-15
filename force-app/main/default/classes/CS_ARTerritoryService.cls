public without sharing class CS_ARTerritoryService {

    // see https://execloud.wordpress.com/2015/05/06/tm2/

    // returns a map of record type to list account id 
    public static Map<String,List<Id>> retrieveAccountIdsInMyTeamTerritory() {
        
        Map<String,List<Id>> territoryMap = new Map<String,List<Id>>();

        List<Account> accts = [SELECT RecordType.Name, Id FROM Account USING SCOPE My_Team_Territory];
        for ( Account acct : accts ) {
            String recordTypeName = acct.RecordType.Name;

            List<Id> ids = territoryMap.get(recordTypeName);
            if ( ids == null ) { ids = new List<Id>(); }
            
            ids.add(acct.Id);
            territoryMap.put(recordTypeName, ids);

        }
        
        return territoryMap;

    } 
    
    public static List<Id> retrieveAccountIdsInMyTeamTerritoryByRecordType(String rt) { 

        Map<String,List<Id>> territoryMap = CS_ARTerritoryService.retrieveAccountIdsInMyTeamTerritory();
        if ( territoryMap.containsKey(rt) ) {
            return territoryMap.get(rt);
        } else {
            return new List<Id>();
        }
    }


    public static List<Id> retrieveHealthCareProvidersInMyTeamTerritory() {

        List<Id> hcpIds = CS_ARTerritoryService.retrieveAccountIdsInMyTeamTerritoryByRecordType(Constant.RECORDTYPE_NAME_HEALTH_CARE_PROVIDER);

        List<Id> shipTos = new List<Id>();
        for ( Account acct : [select Id from Account where id in :hcpIds AND Account_group__c = 'Z002'] ) {
            shipTos.add(acct.Id);
        }

        return shipTos;

    }

    public static List<Id> retrieveSurgeonsInMyTeamTerritory() {

        return CS_ARTerritoryService.retrieveAccountIdsInMyTeamTerritoryByRecordType('Practitioner');

    }   

    public static Map<Id,List<ObjectTerritory2Association>> mapObjectIdsToTerritories(List<Id> objectIds) {
        
        Map<Id,List<ObjectTerritory2Association>> assocMap = new Map<Id,List<ObjectTerritory2Association>>();

        Set<Id> dedupIds = new Set<Id>(objectIds);
        List<ObjectTerritory2Association> assocs = [SELECT ObjectId, Territory2Id, Territory2.Name, Territory2.ParentTerritory2Id FROM ObjectTerritory2Association where ObjectId in :dedupIds];
        for ( ObjectTerritory2Association assoc : assocs ) {

            List<ObjectTerritory2Association> objectAssocs = assocMap.get(assoc.ObjectId);
            
            if ( objectAssocs == null ) { objectAssocs = new List<ObjectTerritory2Association>(); }
            objectAssocs.add(assoc);
            assocMap.put(assoc.ObjectId, objectAssocs);

        }

        // it's possible some of the original objectIds did not result in a map entry
        for ( Id id : dedupIds ) {
            if ( !assocMap.containsKey(id) ) {
                system.debug('##--HCP with not territory: '+ id);
                assocMap.put(id, new List<ObjectTerritory2Association>());
            }
        }

        return assocMap;
    }


   // recursively traverses the territory children
    public static List<Id> retrieveChildTerritories(Id parentId) {

        List<Id> childIds = new List<Id>();
        
        if(parentId == null){
            return childIds;
        }

        List<Territory2> children = [select Id, Name from Territory2 where ParentTerritory2Id=:parentId];
        system.debug('##--retrieveChildTerritories.children: '+ children);
        if ( children == null || children.size() == 0 ) {
        
            return childIds;
        
        } else {
            list<Id> lstChildIds = new list<Id>();
            for ( Territory2 child : children ) {
                childIds.add(child.Id);  
                lstChildIds.add(child.Id);                
                //childIds.addAll( CS_ARTerritoryService.retrieveChildTerritories(child.Id) );
                
            }
            system.debug('##--retrieveChildTerritories.lstChildIds: '+ lstChildIds);
            if(lstChildIds.size() > 0){
                childIds.addAll( CS_ARTerritoryService.retrieveChildTerritories(lstChildIds) );
            }
            return childIds;
        }

        return childIds;
    }
    
    // Given a list of parentIds this method recursively traverses the territory children 
    // and returns all the chid territory ids.
    
    public static List<Id> retrieveChildTerritories(list<Id> lstParentIds) {

        List<Id> childIds = new List<Id>();
        
        if(lstParentIds == null || lstParentIds.size() == 0){
            return childIds;
        }
        List<Territory2> children = [select Id from Territory2 where ParentTerritory2Id IN :lstParentIds];
        system.debug('##--retrieveChildTerritories2.children: '+ children);
        if ( children == null || children.size() == 0 ) {
        
            return childIds;
        
        } else {
            
            list<Id> lstChildIds = new list<Id>();
            for ( Territory2 child : children ) {
                childIds.add(child.Id);
                lstChildIds.add(child.Id);             
                //childIds.addAll( CS_ARTerritoryService.retrieveChildTerritories(child.Id) );
                
            }
            system.debug('##--retrieveChildTerritories2.lstChildIds: '+ lstChildIds);
            if(lstChildIds.size() > 0){
                childIds.addAll( CS_ARTerritoryService.retrieveChildTerritories(lstChildIds) );
            }
            return childIds;
        }

        return childIds;
    }// end of retrieveChildTerritories

    public static List<String> retreiveMyTerritoryNames() {
        List<String> names = new List<String>();

        List<Id> myIds = CS_ARTerritoryService.retrieveMyTerritoryIds();
        List<Territory2> territories = [Select Id, Name from Territory2 where Id in :myIds];
        for ( Territory2 t : territories ) {
            names.add(t.Name);
        }

        return names;
    }  //  end of retreiveMyTerritoryNames
    
    
    public static List<String> retreiveMyTerritoryIDs() {
        List<String> ids = new List<String>();

        List<Id> myIds = CS_ARTerritoryService.retrieveMyTerritoryIds();
        List<Territory2> territories = [Select Id, Name from Territory2 where Id in :myIds];
        for ( Territory2 t : territories ) {
            ids.add(t.Id);
        }

        return ids;
    }  //  end of retreiveMyTerritoryIDs
    
    public static List<Territory2> retrieveMyTerritories() {
        
        List<Id> myIds = CS_ARTerritoryService.retrieveMyTerritoryIds();
        List<Territory2> territories = [Select Id, Name from Territory2 where Id in :myIds];
        if ( territories == null ) { territories = new List<Territory2>(); }

        return territories;
    }

    public static String myTerritoryType(){
        
        List<Id> myIds = CS_ARTerritoryService.retrieveMyTerritoryIds();
        
        for ( Territory2 t : [Select Id, Name, Territory_Type__c from Territory2 where Id in :myIds] ) {
            return t.Territory_Type__c;
        }
        
        return '';
    }   //  end of myTerritoryType
    
    public static map<Id, list<Territory2>> parentTerritoryAndListTerritories(){
        List<Id> myIds = CS_ARTerritoryService.retrieveMyTerritoryIds(true);
        
        system.debug('##--parentTerritoryAndListTerritories.myIds: '+ myIds.size());
        map<Id, list<Territory2>> mapParentTerritoryAndListTerritories = new map<Id, list<Territory2>>();
        for(Territory2 objTerr : [SELECT Id, ParentTerritory2Id, ParentTerritory2.Name, Name, Territory_Type__c
                                                FROM Territory2 WHERE Id IN :myIds]){
                                                    
            if(mapParentTerritoryAndListTerritories.get(objTerr.ParentTerritory2Id) == null){
              mapParentTerritoryAndListTerritories.put(objTerr.ParentTerritory2Id, new list<Territory2>());
            }
            
            mapParentTerritoryAndListTerritories.get(objTerr.ParentTerritory2Id).add(objTerr);
        }
        return mapParentTerritoryAndListTerritories;
    }   //  end of parentTerritoryAndListTerritories
    
    public static list<Id> retrieveMyParentTerritories(){
      
      list<Id> lstParentTerritoryIds =new list<Id>();
      for(UserTerritory2Association objUserTerritory2 : [SELECT Id, Territory2Id,Territory2.ParentTerritory2Id FROM UserTerritory2Association 
                                  WHERE UserId =:UserInfo.getUserId()]){
                                    
        lstParentTerritoryIds.add(objUserTerritory2.Territory2.ParentTerritory2Id);                          
      }// end of for-each
      
      return lstParentTerritoryIds;
      
    }// end of retrieveMyParentTerritories
    
    public static map<id, Territory2> territoryMapOfGivenIds(Set<ID> Ids){
        
        Map<ID, Territory2> mapTerritories = new Map<ID, Territory2>([SELECT Id, Territory2.ParentTerritory2Id, Name FROM Territory2 WHERE ID IN :Ids]);
        
        return mapTerritories;
    }   //  end of territoryMapOfGivenIds
   
    
    public static List<String> retreiveMyTerritories(Id territoryId) {
        List<String> names = new List<String>();

        List<Id> myIds = CS_ARTerritoryService.retrieveMyTerritoryIds();
        List<Territory2> territories = [Select Id, Name from Territory2 where Id in :myIds];
        for ( Territory2 t : territories ) {
            names.add(t.Name);
        }

        return names;
    }

    public static List<String> retrieveTerritoryNamesByUserId(String userId) {
        List<String> names = new List<String>();
        List<Territory2> territories = [Select Id, Name from Territory2 where Id =:userId];
        for ( Territory2 t : territories ) {
            names.add(t.Name);
        }

        return names;
    }

    public static List<User> retrieveUsersInMyTerritory() {
        List<Id> territoryIds = CS_ARTerritoryService.retrieveMyTerritoryIds(true);
        return usersOfGivenTerritories(territoryIds);
    }   //  end of retrieveUsersInMyTerritory
    
    //Added by Srinivas Sattoor on 6.21.2017 for 4.1 
    //Given a territory Id this method returns users in the territory
    public static List<User> retrieveUsersInMyTeamTerritory(string territoryId) {
        
        if(string.isBlank(territoryId)){
            return retrieveUsersInMyTerritory();
        }else{
            
            return usersOfGivenTerritories(new list<Id>{territoryId});
        }
         
    }   //  end of retrieveUsersInMyTeamTerritory
    
    public static List<Id> retrieveUserIdsInMyTerritory(Id territoryId) {
            
        List<Id> territoryIds = new List<Id>();
        
        if(territoryId == null){
            territoryIds.addAll(CS_ARTerritoryService.retrieveMyTerritoryIds(false));
        }else{
            territoryIds.add(territoryId);
        }
    
        territoryIds.addAll( CS_ARTerritoryService.retrieveChildTerritories(territoryId));
        
        List<Id> userIds = new List<Id>();
        for ( User objUser : usersOfGivenTerritories(territoryIds)) {
            userIds.add(objUser.Id);
        }

        return userIds;
    }
    
    public static List<User> usersOfGivenTerritories(List<Id> territoryIds){
        
        List<UserTerritory2Association> userTerritories = [SELECT Id, UserId, User.ID, User.Name,  User.contact.Account.Name,
                                                                        User.Title, User.IsActive, User.FullPhotoUrl, User.Calendar_Color__c
                                                                    FROM UserTerritory2Association 
                                                                    WHERE Territory2Id in :territoryIds
                                                                    //AND User.IsActive = :true
                                                                    ];

        List<User> lstTerritoryUsers = new List<User>();
        
        set<User> setTerritoryUsers = new set<User>();
        for ( UserTerritory2Association tAssoc : userTerritories) {
            
            setTerritoryUsers.add(tAssoc.User);
        }
        
        lstTerritoryUsers.addALL(setTerritoryUsers);
        return lstTerritoryUsers;
    }   //  end of usersOfGivenTerritories
    

    public static List<Id> retrieveMyTerritoryIds() { 
        return CS_ARTerritoryService.retrieveMyTerritoryIds(false);
    }

    public static List<Id> retrieveMyTerritoryIds(boolean recurse) {
        
        List<Id> territoryIds = new List<Id>();

        String userId = UserInfo.getUserId();
        List<UserTerritory2Association> userTerritories = [SELECT Id, Territory2Id FROM UserTerritory2Association WHERE UserId=:userId];
        for ( UserTerritory2Association ut : userTerritories ) {

            territoryIds.add( ut.Territory2Id );
            if ( recurse ) {
                territoryIds.addAll( CS_ARTerritoryService.retrieveChildTerritories(ut.Territory2Id ));
            }   
        }

        // system.debug('*********** '+String.join(territoryIds,' '));

        return territoryIds;
    } 
    
    public static Map<Id,List<UserTerritory2Association>> mapUserIdsToTerritories(List<Id> objectUserIds) {
        
        Map<Id,List<UserTerritory2Association>> userAssocMap = new Map<Id,List<UserTerritory2Association>>();

        Set<Id> dedupUserIds = new Set<Id>(objectUserIds);
        List<UserTerritory2Association> userAssocs = [SELECT Id, UserId, User.ID, User.Name, Territory2Id, Territory2.Name, User.Title,
                                                        Territory2.ParentTerritory2Id FROM UserTerritory2Association WHERE UserId in :dedupUserIds];
        for ( UserTerritory2Association userAssoc : userAssocs ) {

            List<UserTerritory2Association> objectAssocs = userAssocMap.get(userAssoc.UserId);
            
            if ( objectAssocs == null ) { 
                objectAssocs = new List<UserTerritory2Association>(); 
            }
            objectAssocs.add(userAssoc);
            userAssocMap.put(userAssoc.UserId, objectAssocs);

        }

        // it's possible some of the user ids did not result in a map entry
        for ( Id id : dedupUserIds ) {
            if ( !userAssocMap.containsKey(id) ) {
                system.debug('##--HCP with not territory: '+ id);
                userAssocMap.put(id, new List<UserTerritory2Association>());
            }
        }

        return userAssocMap;
    }
    
    public static Id retrieveMyTerritoryId(){
        
        String userId = UserInfo.getUserId();
        List<UserTerritory2Association> territories = [Select Id, Territory2Id from UserTerritory2Association where UserId =:userId];
        return territories[0].Territory2Id;
        
    }// end of retrieveMyTerritoryId
    
    public static Territory2 retrieveMyTerritory(){
        
        String userId = UserInfo.getUserId();
        list<UserTerritory2Association> territories = [Select Id, Territory2Id from UserTerritory2Association where UserId =:userId]; 
        list<Territory2> lstMyTerritories = [Select Id, Name from Territory2 where Id = :territories[0].Territory2Id];
        return lstMyTerritories[0];
        
    }// end of retrieveMyTerritoryId
    
    //Release 2.2
    //Component ID:- CID000062
    //Developer:- Mimansha Samal
    //Date:- 1/12/2017
    //Purpose:- Retrieving Assigned Territories that the user is assigned to.
    public static List<String> retrieveTerritoryForUser(String userId) {
        
         List<String> territoryNames = new List<String>();
         List<UserTerritory2Association> lstAssociation= [SELECT UserId, Territory2Id, Territory2.Name, Territory2.ParentTerritory2Id FROM UserTerritory2Association where UserId=:userId];
         
         for ( UserTerritory2Association t : lstAssociation) {
            territoryNames.add(t.Territory2.Name);
         }            
         
         return territoryNames;
    }
    
    /* 
    Added by srinivas sattoor 05.25.2017 for 3.2 so that when managers
    assign an opp to an owner, accounts are filtered for the territory 
    of the opp owner
    */
    public static set<Id> retrieveTerritoryIdsForUser(String userId) {
        
         set<Id> setUserTerritoryIds = new set<Id>();  
         for ( UserTerritory2Association objTerritory2Association : [SELECT UserId, Territory2Id, Territory2.Name, 
                                                                Territory2.ParentTerritory2Id 
                                                          FROM UserTerritory2Association 
                                                          WHERE UserId=:userId]) {
            setUserTerritoryIds.add(objTerritory2Association.Territory2Id); 
            setUserTerritoryIds.addAll( CS_ARTerritoryService.retrieveChildTerritories(objTerritory2Association.Territory2Id)); 
         }            
         
         return setUserTerritoryIds;
    }// end of retrieveTerritoryIdsForUser 
    
    /* 
    Added by srinivas sattoor 05.25.2017 for 3.2 so that when managers
    assign an opp to an owner, accounts are filtered for the territory 
    of the opp owner
    */
    public static set<Id> retrieveAccountIdsForGivenTerritories(set<Id> setTerritoryIds) {
        
        system.debug('##--retrieveAccountIdsForGivenTerritories.setTerritoryIds: '+ setTerritoryIds);
        set<Id> setAccountIdsInGivenTerritories = new set<Id>();
        for(ObjectTerritory2Association objAssociation : [SELECT Id, Territory2Id, ObjectId
                                                                FROM ObjectTerritory2Association
                                                                WHERE Territory2Id IN :setTerritoryIds
                                                                And Object.type = 'Account'
                                                                //AND AssociationCause = 'Territory2Manual'
                                                                ]){
            setAccountIdsInGivenTerritories.add(objAssociation.ObjectId);
        } 
        /*List<Id> shipTos = new List<Id>();
        for ( Account acct : [select Id from Account where id in :setAccountIdsInGivenTerritories AND Account_group__c = 'Z002'] ) {
            shipTos.add(acct.Id);
        }*/

        return setAccountIdsInGivenTerritories;

    }
    
    /* Added by srinivas sattoor 06.15.2017 for 4.1  CID-000287
     * This method returns the users territories in the team hierarchy
     * This method will be used for driving opportunity and case creation 
    */ 
    public static List<Territory2> retrieveTerritoriesInMyTeamHierarchy() {
        
        List<Id> myIds = CS_ARTerritoryService.retrieveMyTerritoryIds(true);
        List<Territory2> territories = [Select Id, Name from Territory2 where Id in :myIds];
        if ( territories == null ) { territories = new List<Territory2>(); }

        return territories;
    }
     
    /* Added by srinivas sattoor on 06.15.2017 for 4.1 CID-000287
     * Given a territory id this method does a recursiove check for all the parents
     * and returns all the parent territories 
    */ 
    public static list<string> retrieveParentTerritoriesForAGivenTerritory(string territoryId){
        list<string> lstTerritories = new List<string>();
        set<Id> setLoggedInUserAssignedTerritoryIds =new set<Id>();
        
        List<Id> lstLoggedInUserAssignedTerritoryIds = CS_ARTerritoryService.retrieveMyTerritoryIds(false);
        
        setLoggedInUserAssignedTerritoryIds.addAll(lstLoggedInUserAssignedTerritoryIds);
        String territoryName; 
        Territory2 objTerritory = CS_ARTerritoryService.territoryMapOfGivenIds(new set<Id>{Id.valueOf(territoryId)}).get(Id.valueOf(territoryId));
        
        system.debug('##--objTerritory: '+ objTerritory);
        while(objTerritory != null 
                && objTerritory.ParentTerritory2Id != null 
                && !setLoggedInUserAssignedTerritoryIds.contains(objTerritory.Id)){
            lstTerritories.add(objTerritory.Id);
            objTerritory = CS_ARTerritoryService.territoryMapOfGivenIds(new set<Id>{objTerritory.ParentTerritory2Id}).get(objTerritory.ParentTerritory2Id);
        }
        if( (objTerritory != null 
                && objTerritory.ParentTerritory2Id == null) 
            || setLoggedInUserAssignedTerritoryIds.contains(objTerritory.Id) ){
            //  Getting the FIrst Territory
            lstTerritories.add(objTerritory.Id);
        }
        return lstTerritories;
    }   //  end of getTerritoriesForTerritory
    
    
}