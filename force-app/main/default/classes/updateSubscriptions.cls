public with sharing class updateSubscriptions {


     public void doUpdate(Map<Id, Lead> newMap, Map<Id, Lead> oldMap ) {
       List<Subscription__c>  subs;
       Map<id,id> convertedContactId = new Map<id,id>(); 
       Set<id> convertedLeads = new Set<id>();
            
       for(Lead l : newMap.values()) {
         if (l.IsConverted) {
           convertedContactId.put(l.id, l.ConvertedContactId);
           convertedLeads.add(l.id);      
         }           
       }
       
       subs = [SELECT Advisor__c, Lead__c, Id FROM Subscription__c where Lead__c in :convertedLeads];
       
       for(Subscription__c s : subs) {
         s.Advisor__c = convertedContactId.get(s.Lead__c);         
       }
       
       update subs;                       
     }
  
     public static void doAutoSubscribe(Set<Id> advisorIds) {
    List<Publication__c> pubs;
    List<Subscription__c> newSubs = new List<Subscription__c>();
    pubs = [ Select id from Publication__c where Subscribe_On_Advisor_Create__c = true ] ;
       
       for(Publication__c p : pubs) {
         for(Id id : advisorIds) {
             Subscription__c sub = new Subscription__c();
             sub.Advisor__c = id;
             sub.Publication__c = p.id;
             sub.Subscribed__c = true;
             newSubs.add(sub);
           }
         }
           
         try{
       if (!newSubs.isEmpty())  {
         insert newSubs; 
       }
         }
         Catch(Exception e){
         
         e.getmessage();
         }
 
     }   
     
     public void doAutoSubscribe(Map<Id, Contact> contactMap) {
        List<Subscription__c> existingSubs;
        Set<ID> advisorIDs = contactMap.keySet();
        Map<Id,Set<Id>> alreadySubscribed = new Map<Id,Set<Id>>();
        List<Subscription__c> newSubs = new List<Subscription__c>();
        
      existingSubs =  [SELECT Advisor__c, Publication__c, Id FROM Subscription__c where Advisor__c in :advisorIDs and Publication__r.Subscribe_On_Advisor_Create__c = true];

    for(Id id: advisorIds) {
      alreadySubscribed.put(id, new Set<id>());
    }
    
    for(Subscription__c sub : existingSubs) {
      Set<id> currentSubcriptions = new Set<id>();
      if (alreadySubscribed.containsKey(sub.Advisor__c)) {
        currentSubcriptions = alreadySubscribed.get(sub.Advisor__c);        
      }
      currentSubcriptions.add(sub.Publication__c);
      alreadySubscribed.put(sub.Advisor__c, currentSubcriptions);          
    }
    
    List<Publication__c> pubs;
    pubs = [ Select id from Publication__c where Subscribe_On_Advisor_Create__c = true ] ;
       
       for(Publication__c p : pubs) {
         for(Id id : advisorIds) {
           Set<id> currentSubscriptions = alreadySubscribed.get(id);
             
           if ( !currentSubscriptions.contains(p.id) ) {
             Subscription__c sub = new Subscription__c();
             sub.Advisor__c = id;
             sub.Publication__c = p.id;
             sub.Subscribed__c = true;
             newSubs.add(sub);
           }
         }
       }     
         
       if (!newSubs.isEmpty())  {
         insert newSubs; 
       }
       
     }
     
     
}