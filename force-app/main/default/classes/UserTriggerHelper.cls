/**
* @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  
* @date Original: 04 Mar 2016, Last Modified: NA
* @description: This class is a helper class for User Trigger logic
*/

public with sharing class UserTriggerHelper {
  
  
     /**
    * @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  NA
    * @date Original: 04 Mar 2016, Last Modified: NA
    * @description: Given a list of users, this method populates the territory
    * using the account on the contact.
    */
  public void populateUserTerritoryAssignment(list<User> lstUsers){
    
    list<User> lstPortalUsers = new list<User>();
    map<Id, string> mapUserIdAccountName = new map<Id, string>();
    set<string> setAccountNames = new set<string>();
    map<string, Id> mapTerritoryNameTerritoryId;
    list<UserTerritory2Association> lstUserTerritory2Association;
    for(User objUser :[SELECT Id, Contact.Account.Name FROM User 
                      WHERE Profile.Name = 'AXIS Partner Community User'
                      AND Id IN:lstUsers]){
      
      lstPortalUsers.add(objUser);
      mapUserIdAccountName.put(objUser.Id, objUser.Contact.Account.Name);
      
    }
    system.debug('##--mapUserIdAccountName: '+ mapUserIdAccountName);
    if(mapUserIdAccountName.values().size() == 0){
      return;
    }
    setAccountNames.addAll(mapUserIdAccountName.values());
    system.debug('##--setAccountNames: '+ setAccountNames);
    setAccountNames.remove(null);
    if(setAccountNames.size() == 0){
      return;
    }
    mapTerritoryNameTerritoryId = createMapOfAccountNameAndTerritoryId(setAccountNames);
    system.debug('##--mapTerritoryNameTerritoryId: '+ mapTerritoryNameTerritoryId);
    if(mapTerritoryNameTerritoryId.KeySet().size() == 0){
      return;
    }
    lstUserTerritory2Association = createUserTerritoryAssignment(mapUserIdAccountName, mapTerritoryNameTerritoryId);
    system.debug('##--lstUserTerritory2Association: '+ lstUserTerritory2Association);

    if(lstUserTerritory2Association.size() > 0){
      insert lstUserTerritory2Association;
    }
    
  }// end of populateUserTerritoryAssignment
  
   /**
    * @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  NA
    * @date Original: 04 Mar 2016, Last Modified: NA
    * @description: Given a set of account names this method returns the 
    * map for account name and the corresponding territory id.
    */
  private map<string, Id> createMapOfAccountNameAndTerritoryId(set<string> setAccountNames){
    
    map<string, Id> mapTerritoryNameTerritoryId  = new map<string, Id>();
    setAccountNames.remove(null);
    if(setAccountNames.size() == 0){
      
      return mapTerritoryNameTerritoryId;
      
    }
    for(Territory2 objTerritory :[SELECT Id, Name FROM Territory2 WHERE Name =:setAccountNames]){
      mapTerritoryNameTerritoryId.put(objTerritory.Name, objTerritory.Id);
    }
    
    return mapTerritoryNameTerritoryId;
  }// end of createMapOfAccountNameAndTerritoryId
  
  /**
    * @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  NA
    * @date Original: 04 Mar 2016, Last Modified: NA
    * @description: Given a map of userID and account name and 
    * map of territory name and territory id this method populates
    * tset of account names this method returns the 
    * map for account name and the corresponding territory id.
    */
  private list<UserTerritory2Association> createUserTerritoryAssignment(map<Id, string> mapUserIdAccountName,  
                                      map<string, Id> mapTerritoryNameTerritoryId){
    
    list<UserTerritory2Association> lstUserTerritory2Association = new list<UserTerritory2Association>();
    for(Id userIdNeedingterritoryAssignment : mapUserIdAccountName.KeySet()){
      
      Id objterritory2Id = mapTerritoryNameTerritoryId.get(mapUserIdAccountName.get(userIdNeedingterritoryAssignment));
      if(objterritory2Id != null){
        
        UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(
                                        UserId = userIdNeedingterritoryAssignment,
                                        Territory2Id = objterritory2Id);
                                        
        lstUserTerritory2Association.add(objUserTerritory2Association);
      }
      
    }
    
    return lstUserTerritory2Association;
    
    
  }// end of createUserTerritoryAssignment
  
 
  public void populateContactOwnerasPortalUser(list<User> lstNewUsers, map<Id, User> mapOldUsers){
    
    set<Id> setPortalUserIds = new set<Id>();
    for(User objUser : lstNewUsers){
        
        if(objUser.ContactId != null
            && objUser.IsActive
            && !mapOldUsers.get(objUser.Id).IsActive){
            
            setPortalUserIds.add(objUser.Id);   
        }
    }// end of for-each
    
    if(setPortalUserIds.size() > 0){
        populateContactOwnerasPortalUser(setPortalUserIds);     
    }
    
  }// end of populateContactOwnerasPortalUser
  
   public void populateContactOwnerasPortalUser(list<User> lstNewUsers){
    
    set<Id> setPortalUserIds = new set<Id>();
    for(User objUser : lstNewUsers){
        
        if(objUser.ContactId != null
            && objUser.isActive){
            setPortalUserIds.add(objUser.Id);
        }
    }// end of for-each
    
    if(setPortalUserIds.size() > 0){
        populateContactOwnerasPortalUser(setPortalUserIds);     
    }
    
   }// end of populateContactOwnerasPortalUser
  
  @future
  public static void populateContactOwnerasPortalUser(set<Id> setUserIds){
    
    map<Id, Id> mapContactIdAndUserId = new map<Id, Id>();
    list<Contact> lstPortalContacts = new list<Contact>();
    
    for(User objUser : [SELECT Id, IsActive, ContactId FROM User WHERE Id IN: setUserIds]){
        
        if(objUser.ContactId != null
            && objUser.IsActive){
            mapContactIdAndUserId.put(objUser.ContactId, objUser.Id);
        }
    }// end of for-each
    
    if(mapContactIdAndUserId.keyset().size() == 0){
        return;
    }
    
    for(Contact objContact :[SELECT Id, OwnerId FROM Contact WHERE Id IN :mapContactIdAndUserId.KeySet()]){
        
        if(objContact.OwnerId !=mapContactIdAndUserId.get(objContact.Id) ){
            objContact.OwnerId = mapContactIdAndUserId.get(objContact.Id);
            lstPortalContacts.add(objContact);
        }
    }// end of for-each
    
    if(lstPortalContacts.size() > 0){
        update lstPortalContacts;
    }
    
  }// end of updateContactOwnerasPortalUser
  
    public void populateUserIdInContact(list<User> lstNewUsers){
        Map<Id, Id> mapContactUser = new Map<Id, Id>();
        for(User u: lstNewUsers){
            mapContactUser.Put(u.Contactid, u.id);
        }
        if(!mapContactUser.isEmpty()){
            // Call Future method to update Contact
            populateUserIdInContact(mapContactUser);        
        }
    }
    
    @future
    public static void populateUserIdInContact(Map<Id, Id> mapContactUser){
        List<Contact> contactList = [select id from contact where id in: mapContactUser.keyset()];
        if(!contactList.isEmpty()){
            for(Contact con: contactList){
                if(mapContactUser.containsKey(con.id)){
                    con.User_Id__c = mapContactUser.get(con.id);
                }
            }
            update contactList;
        }
    }

}