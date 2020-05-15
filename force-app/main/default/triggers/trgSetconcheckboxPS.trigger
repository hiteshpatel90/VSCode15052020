trigger trgSetconcheckboxPS on Subscription__c(after insert, after update){

   List<Contact> lstContactUpdate = new List<Contact>();  
   set<Id> sConId = new set<Id>();
   List<Subscription__c> lstSubscription = [select id, Advisor__r.Name,Subscribed__c, Publication__r.Name from Subscription__c WHERE ID in :Trigger.newmap.keyset()];

   for(Subscription__c sub: lstSubscription){  
       if(sub.Publication__r.Name == 'Product and Services Updates'){
           sConId.add(sub.Advisor__c);
           sub.Advisor__r.Subscribed_to_P_S_Update__c = sub.Subscribed__c;
           lstContactUpdate.add(sub.Advisor__r);
       }
   }  
   if(lstContactUpdate.size() > 0){
       update lstContactUpdate;
   }
}