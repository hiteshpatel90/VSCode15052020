trigger MBW_DIR_Check on Attachment (before insert, before delete) {
    set<Id> OpportunityId = new set<Id>();
    String objectName = '';
    if(trigger.isinsert){
        for(Attachment atc: trigger.new){
            String myIdPrefix = string.valueOf(atc.ParentId).substring(0,3);
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                }
            }
            if(objectName == 'Opportunity'){
                if(atc.Name.containsIgnoreCase('DIR')){
                    OpportunityId.add(atc.ParentId);
                }
            }
        }
    }
    if(!OpportunityId.isEmpty()){
        List<Opportunity> lstOpportunity = [select id from Opportunity where id in: OpportunityId];
        for(Opportunity con: lstOpportunity){
            con.DIR_Attached__c = true;
        }
        if(!lstOpportunity.isEmpty()){
            update lstOpportunity;
        }
    }
    
    set<Id> OpportunityAtcDel = new set<Id>();
    if(trigger.isdelete){
        for(Attachment atc: trigger.old){
            String myIdPrefix = string.valueOf(atc.ParentId).substring(0,3);
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                }
            }
            if(objectName == 'Opportunity'){
                OpportunityAtcDel.add(atc.ParentId);
            }
        }
    }
    if(!OpportunityAtcDel.isEmpty()){
        List<Opportunity> lstOpportunity = [select id from Opportunity where id in: OpportunityAtcDel];
        for(Opportunity con: lstOpportunity){
            con.DIR_Attached__c = false;
        }
        if(!lstOpportunity.isEmpty()){
            update lstOpportunity;
        }
    }
}