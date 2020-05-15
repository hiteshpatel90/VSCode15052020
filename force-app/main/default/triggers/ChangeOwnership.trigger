trigger ChangeOwnership on Case (before update) { 
        List<ID> caseIDs = new List<ID>(); 
        
        for (Case c : Trigger.New){ 
                if (c.ChangeOwner__c == true){ 
                        caseIDs.add(c.Id); 
                } 
        } 
        
        if(caseIDs.size() > 0) { 
                CaseHelper.updateOwnership(caseIDs); 
        } 
}