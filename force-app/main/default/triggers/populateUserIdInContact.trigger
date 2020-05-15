trigger populateUserIdInContact on User (after insert, after update) {
    Map<Id, Id> mapContactUser = new Map<Id, Id>();
    for(User u: trigger.new){
        mapContactUser.Put(u.Contactid, u.id);
    }
    if(!mapContactUser.isEmpty()){
        // Call Future method to update Contact
        populateUserIdInContact.updateContact(mapContactUser);        
    }
}