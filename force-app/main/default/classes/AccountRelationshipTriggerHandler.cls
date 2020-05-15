//
// (c) 2015 Appirio, Inc.
//
// Trigger Handler Name: AccountRelationshipTriggerHandler
// For Trigger: AccountRelationshipTrigger
// On SObject: Account Relationship (Account_Relationship__c)
// Description: For "Account Relationship" record type, the unique key for checking duplicate records should be "Parent Account" + "Child Account" +
// "Active Flag". For "Contact Relationship" record type, the unique key for checking duplicate records should be "Parent Account" + "Contact To" +
// "Contact Role(Primary Contact/Billing Contact)" + "Active Flag". Also, auto-populate 'Account.Parent_Broker__c' and validate primary parent
// account. The billing contact cannot be marked inactive if there is no other billing contact associated with that account.
//
// User Story Acceptance Criteria Updated on 29th April 2015 For Issue # I-157451 - A duplicate contact relationship should not be allowed
// irrespective of contact role.
//
// 17th March 2015    Hemendra Singh Bhati    Original (Task # T-371098)
// 23rd March 2015    Hemendra Singh Bhati    Modified (Task # T-372661)  - Complete Code Re-factored.
// 26th March 2015    Hemendra Singh Bhati    Modified (Task # T-373693)  - Complete Code Re-factored.
// 09th April 2015    Hemendra Singh Bhati    Modified (Task # T-377199)  - Added logic to auto-populate 'Account.Parent_Broker__c'.
// 10th April 2015    Hemendra Singh Bhati    Modified (Task # T-377199)  - Added logic to validate primary parent account.
// 23rd April 2015    Hemendra Singh Bhati    Modified (Issue # I-155139) - The billing contact cannot be marked inactive if there is no other
//                                                                        - billing contact associated with that account.
//                                                                        - Updated Method: onBeforeInsertUpdate().
// 29th April 2015    Hemendra Singh Bhati    Modified (Issue # I-157451) - A duplicate contact relationship should not be allowed irrespective
//                                                                        - of contact role.
// 06th May 2015      Hemendra Singh Bhati    Modified (Task # T-392803)  - Set the boolean field "Is_Sent_To_CDH__c" value to "False" whenever a
//                                                                        - new record on 'Account_Relationship__c' object is created and whenever
//                                                                        - the "Active" field is updated to "False".
//                                                                        - Updated Method: onBeforeInsertUpdate().
// 05th June 2015     Hemendra Singh Bhati    Modified (Issue # I-166282) - Updated Method: onAfterInsertUpdate().
//
public with sharing class AccountRelationshipTriggerHandler {
    private integer batchSize = 0;
    private boolean isExecuting = false;
    private AccountRelationshipTriggerHandlerManager theManager = null;
    
    public AccountRelationshipTriggerHandler(Boolean isExecuting, Integer size) {
        batchSize = size;
        isExecuting = isExecuting;
        theManager = new AccountRelationshipTriggerHandlerManager();
    }
    
    // Validating account relationship records on before insert/update trigger event.
    public void onBeforeInsertUpdate(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
        // Turn off account relationship records unique combination if the value of custom setting field is true.
        
        //system.debug('@@@@@@@@@@@@@@@@@@@@@');
        if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Unique_Relationship_Validation__c == false) {
            //system.debug('###########');
            system.debug('TRACE: Validating account relationship records.');
            theManager.validateAccountRelationshipRecords(newValues, oldMap, isInsert);
        }
        
        // Turn off primary parent account validation if the value of custom setting field is true.
        if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Primary_Parent_Account_Validation__c == false) {
            system.debug('TRACE: Validating primary parent account.');
            theManager.validatePrimaryParentAccount(newValues, oldMap, isInsert);
        }
        
        // Turn off billing contact validation for contact relationship records if the value of custom setting field is true.
        if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Billing_Contact_Validation__c == false) {
            system.debug('TRACE: Validating billing contact for contact relationship records.');
            theManager.validateBillingContactDeactivation(newValues, oldMap, isInsert);
        }
        
        // Turn off updation of boolean field "Is_Sent_To_CDH__c" if the value of custom setting field is true.
        if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Is_Sent_To_CDH_Updation_Off__c == false) {
            system.debug('TRACE: Updating boolean field "Is_Sent_To_CDH__c" for both account and contact relationship records.');
            theManager.updateIsSentToCDH(newValues, oldMap, isInsert);
        }
        theManager.checkcontactUniquenes(newValues,oldMap,isInsert);
    }
    
    // Populating account parent broker field on after insert/update trigger event.
    public void onAfterInsertUpdate(Map<Id,Account_Relationship__c> newMap, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
        // Turn off auto population of account custom field named 'Account.Parent_Broker__c' if the value of custom setting field is true.
        if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Account_Parent_Broker__c == false) {
            system.debug('TRACE: Populating account parent broker field.');
            theManager.populateAccountParentBroker(newMap.values(), oldMap, isInsert);
        }
        if(AccountRelationshipTriggerHandlerManager.updateAccrealtion == false)
            theManager.populateIsParentPrimary(newMap, oldMap, isInsert);
        // Turn off agent/office account roll-ups on broker account.
        if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Agent_Office_Rollup_Off__c == false) {
            system.debug('TRACE: Computing total agents and total offices.');
            //theManager.computeTotalAgentsAndTotalOffices(newMap, oldMap, isInsert);
            // modified by Ravinder Reddy
            if(isInsert){
                theManager.setbillngcntctfalseinsert(newMap); 
            }  
            if(!isInsert){
                theManager.updateAccountforParentChild(newmap.values());
            }
        }
    }
}