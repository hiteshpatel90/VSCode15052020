trigger OpportunityLineItemTrigger on OpportunityLineItem (after Insert) {
    
    if(Trigger.isInsert){
        List<Opportunity> lstOppUpdate = new List<Opportunity>();
        Opportunity objOpp;
        set<Id> sOppIdAdded = new set<Id>();
        List<OpportunityLineItem> lstOLINew = [SELECT Id, OpportunityId FROM OpportunityLineItem WHERE Id IN: trigger.newMap.keyset() AND Product2.Family = 'Sponsorship' AND Opportunity.Type != 'Existing Customer - Upgrade'];
        for(OpportunityLineItem oli: lstOLINew){
            if(!sOppIdAdded.contains(oli.OpportunityId)){
                sOppIdAdded.add(oli.OpportunityId);
                objOpp = new Opportunity(id=oli.OpportunityId);
                objOpp.Type = 'Existing Customer - Upgrade';
                lstOppUpdate.add(objOpp);
            }
        }
        if(!lstOppUpdate.isEmpty()){
            update lstOppUpdate;
        }
    }
}