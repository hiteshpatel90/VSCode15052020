trigger StampOwner on Task (after insert) {
    // always use set<Id> instead of LIST.  because set is unique
    set<id> LeadIds = new set<id>();
    // Use MAP to make trigger as bulkify
    // DateTime tasktime; - previous code
    Map<Id, DateTime> tasktime = new Map<Id, DateTime>();
    // Id ownerid; - previous code
    Map<Id, Id> ownerid = new Map<Id, Id>();
    for(Task t1: Trigger.new){
        if(String.valueOf(t1.WhoId).startsWith('00Q')==true && t1.Status=='Completed' && (t1.Type=='Call' || t1.Type=='Email')){ //Check if Task is a Call or Email
            LeadIds.add(t1.whoid);
            // tasktime = t1.CreatedDate; - previous code
            tasktime.Put(t1.id, t1.CreatedDate);
            // ownerid = t1.OwnerId; - previous code
            ownerid.Put(t1.id, t1.OwnerId);
            System.debug(tasktime);
            System.debug(ownerid);  
        }    
    }
    List<Lead> leadQuery = [SELECT id,OwnerId, Owner_Assignment_Date__c,First_Touch__c FROM Lead WHERE id IN :LeadIds ];
    // Add the condition to check we are getting records of lead or not
    if(!leadQuery.isEmpty()){
        // Use try catch block to avoid runtime error
        try{
        // Never use hardcode id in code.
            List<User> lstUser = [SELECT id FROM user WHERE Name = 'HID Marketo' LIMIT 1];
            System.debug(leadQuery);
            for(integer i = 0; i < leadQuery.size(); i++){
                // if(leadQuery[i].OwnerId == ownerid && leadQuery[i].OwnerId !='00580000003aLLu' && leadQuery[i].Owner_Assignment_Date__c < tasktime){ - previous code
                if(leadQuery[i].OwnerId == ownerid.get(leadQuery[i].id) && leadQuery[i].OwnerId != lstUser[0].ID && leadQuery[i].Owner_Assignment_Date__c < tasktime.get(leadQuery[i].id)){
                    if(leadQuery[i].First_Touch__c == null){
                        leadQuery[i].First_Touch__c = tasktime.get(leadQuery[i].id);
                        System.debug(leadQuery[i].First_Touch__c);
                    }
                } 
            }
           
            update leadQuery;
        } catch (exception ex){
            system.debug('============ Exception ===========' + ex.getMessage());
        }
    }
}