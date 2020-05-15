/******************************************************************************************
** Ameriprise Project

*******************************************************************************************
** Trigger Name: TriggerOnSubscriptionToCheckPsbox
** Description: This trigger is on Subscription__c object and is used to flag the "Subscribed to P&S Update" checkbox field on "Contact" when the Conact is subscribed to "Product and Services Updates" publication 

** Version: 1.0
** 
**-----------------------------------------------------------------------------------------
**Modification Log:
**----------------
**Developer                  Date          Version               Description

**-----------------------------------------------------------------------------------------
**Surya Pal               20-July-2014        1.0                 Created
**
**-----------------------------------------------------------------------------------------

**Review Log:
**----------------
**Reviewer                  Date           Version                Comments
**------------------------------------------------------------------------------------------
**              

********************************************************************************************/
trigger TriggerOnSubscriptionToCheckPsbox on Subscription__c(after insert, after update, after delete){
    List<Contact> lstContactUpdate = new List<Contact>();
    
    if(trigger.isInsert || trigger.isUpdate){
        List<Subscription__c> lstSubscription = [select id, Advisor__r.Name,Subscribed__c, Publication__r.Name from Subscription__c WHERE ID in :Trigger.newmap.keyset()];
        set<Id> sConId = new set<Id>();
        Contact objContact;
        for(Subscription__c sub: lstSubscription){
            if(sub.Publication__r.Name == 'Product and Services Updates'){
                //For checking not null value and check duplicate contacts
                if(sub.Advisor__c != null && sConId.contains(sub.Advisor__c) == false){
                    sConId.add(sub.Advisor__c);
                    objContact = new contact(id=sub.Advisor__c);
                    objContact.Subscribed_to_P_S_Update__c = sub.Subscribed__c;
                    lstContactUpdate.add(objContact);
                }
            }
        }
    }
    if(trigger.isDelete){
        set<Id> sConId = new set<Id>();
        Contact objContact;
        for(Subscription__c sub: trigger.old){            
            if(sub.Advisor__c != null){
                sConId.add(sub.Advisor__c);
                objContact = new contact(id=sub.Advisor__c);
                objContact.Subscribed_to_P_S_Update__c = false;
                lstContactUpdate.add(objContact);
            }
        }
    }
    if(lstContactUpdate.size() > 0){
        update lstContactUpdate;    
    }
}