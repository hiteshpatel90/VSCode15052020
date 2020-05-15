public with sharing class UserTriggerHandler {
    
    UserTriggerHelper helper = new UserTriggerHelper();
    
    public void onAfterInsert(list<User> lstUsers){
        
        helper.populateUserTerritoryAssignment(lstUsers);
        helper.populateContactOwnerasPortalUser(lstUsers);
        helper.populateUserIdInContact(lstUsers);
        
    }// end of onAfterInsert;
    
    public void onAfterInsert(list<User> lstUsers, map<Id, User> mapOldUsers){
        
        helper.populateContactOwnerasPortalUser(lstUsers, mapOldUsers);
        helper.populateUserIdInContact(lstUsers);
        
    }// end of onAfterInsert;

}