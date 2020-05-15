public class CaseHelper { 

@future 
public static void updateOwnership(List<Id> caseIDs) { 
    Database.DMLOptions dmo = new Database.DMLOptions(); 
    dmo.EmailHeader.triggerUserEmail = false; 
    
    List<Case> casesToUpdate = [select ownerid, ChangeOwner__c from case where id in :caseIDs]; 
    
    for(Case c : casesToUpdate) { 
            c.OwnerId='005i0000002Q5rz'; 
            c.ChangeOwner__c = false; 
    } 
    
    Database.update(casesToUpdate, dmo); 
    } 
}