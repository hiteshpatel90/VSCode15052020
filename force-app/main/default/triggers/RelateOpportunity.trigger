trigger RelateOpportunity on Zendesk__Zendesk_Ticket__c (before insert, before update){
    
    set<String> strOppName = new set<String>();
    for(Zendesk__Zendesk_Ticket__c zt: trigger.new){
        if(zt.Opportunity_Name__c != null){
            strOppName.add(zt.Opportunity_Name__c);
        }
    }
    
    if(!strOppName.isEmpty()){
        // Fetch Existing Opportunity based on Name
        List<Opportunity> lstExistingOpp = [SELECT Id, Name FROM Opportunity WHERE Name IN: strOppName];
        if(!lstExistingOpp.isEmpty()){
            Map<String, Id> mapOpportunityWithId = new Map<String, Id>();
            for(Opportunity opp: lstExistingOpp){
                mapOpportunityWithId.Put(opp.Name, opp.Id);
            }
            for(Zendesk__Zendesk_Ticket__c zt: trigger.new){
                if(zt.Opportunity_Name__c != null && mapOpportunityWithId != null && mapOpportunityWithId.containsKey(zt.Opportunity_Name__c)){
                     zt.Zendesk__Opportunity__c = mapOpportunityWithId.get(zt.Opportunity_Name__c);
                }
            }
        }
    }
}