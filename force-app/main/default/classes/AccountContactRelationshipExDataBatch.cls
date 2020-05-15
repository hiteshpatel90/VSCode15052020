global class AccountContactRelationshipExDataBatch implements Database.Batchable<sObject>,Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT AccountId,ContactId,IsPrimary,Role, CreatedDate, lastmodifieddate FROM AccountContactRole';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<AccountContactRole> scope) {
        system.debug('AccountContactRole**'+scope);
        
        
        set<Id> sAccId = new set<Id>();
        set<Id> sConId = new set<Id>();
        for(AccountContactRole acr : scope){
            sAccId.add(acr.AccountId);
            sConId.add(acr.ContactId);
        }
    
        if(!sAccId.isEmpty() && !sConId.isEmpty()){
            List<AccountContactRelation> lstACR = [SELECT Id, AccountId, ContactId, Roles FROM AccountContactRelation WHERE AccountId IN: sAccId AND ContactId IN: sConId];
            Map<String, AccountContactRelation> mapACR = new Map<String, AccountContactRelation>();
            for(AccountContactRelation acr: lstACR){
                mapACR.Put(acr.AccountId + '---' + acr.ContactId, acr);
            }
            set<String> sAccCon = new set<String>();
            Map<Id, AccountContactRelation> mapACRUpdate = new Map<Id, AccountContactRelation>();
            Map<String, AccountContactRelation> mapACRInsert = new Map<String, AccountContactRelation>();
            for(AccountContactRole acr : scope){
                
                if(mapACR != null && mapACR.containsKey(acr.AccountId + '---' + acr.ContactId)){
                    if(mapACRUpdate.containsKey(mapACR.get(acr.AccountId + '---' + acr.ContactId).Id)){
                        mapACRUpdate.get(mapACR.get(acr.AccountId + '---' + acr.ContactId).Id).Roles += ';' + acr.Role;
                    }else{
                        AccountContactRelation objACR = new AccountContactRelation(id=mapACR.get(acr.AccountId + '---' + acr.ContactId).Id);
                        objACR.Roles = acr.Role;
                        mapACRUpdate.Put(mapACR.get(acr.AccountId + '---' + acr.ContactId).Id, objACR);
                    }
                }else{
                    if(mapACRInsert.containsKey(acr.AccountId + '---' + acr.ContactId)){
                        mapACRInsert.get(acr.AccountId + '---' + acr.ContactId).Roles += ';' + acr.Role;
                    }else{
                        AccountContactRelation objACR = new AccountContactRelation();
                        objACR.AccountId = acr.AccountId;
                        objACR.ContactId = acr.ContactId;
                        objACR.Roles = acr.Role;
                        mapACRInsert.Put(acr.AccountId + '---' + acr.ContactId, objACR);
                    }
                }
            }
            if(!mapACRInsert.isEmpty()){
               List <Database.SaveResult> saveResults = Database.insert(mapACRInsert.values(), false);
            }
            if(!mapACRUpdate.isEmpty()){
                List <Database.SaveResult> saveResults = Database.update(mapACRUpdate.values(), false);
            }
        }
    }   

    global void finish(Database.BatchableContext BC) {

    }
    global void execute(SchedulableContext sc){
        
    }
    /*
    AccountContactRelationshipExDataBatch b = new AccountContactRelationshipExDataBatch();
       
    //Parameters of ExecuteBatch(context,BatchSize)
    database.executebatch(b,200);
    */
}