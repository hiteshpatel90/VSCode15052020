//
// (c) 2015 Appirio, Inc.
//
// Trigger Name: AccountRelationshipTrigger
// On SObject: Account Relationship (Account_Relationship__c)
// Description: For "Account Relationship" record type, the unique key for checking duplicate records should be "Parent Account" + "Child Account" +
// "Active Flag". For "Contact Relationship" record type, the unique key for checking duplicate records should be "Parent Account" + "Contact To" +
// "Contact Role(Primary Contact/Billing Contact)" + "Active Flag". Also, auto-populate 'Account.Parent_Broker__c'. The billing contact cannot be
// marked inactive if there is no other billing contact associated with that account.
//
// User Story Acceptance Criteria Updated on 29th April 2015 For Issue # I-157451 - A duplicate contact relationship should not be allowed
// irrespective of contact role.
//
// 17th March 2015    Hemendra Singh Bhati    Original (Task # T-371098)
// 23rd March 2015    Hemendra Singh Bhati    Modified (Task # T-372661)  - Complete Code Re-factored.
// 26th March 2015    Hemendra Singh Bhati    Modified (Task # T-373693)  - Complete Code Re-factored.
// 09th April 2015    Hemendra Singh Bhati    Modified (Task # T-377199)  - Added logic to auto-populate 'Account.Parent_Broker__c'.
// 23rd April 2015    Hemendra Singh Bhati    Modified (Issue # I-155139) - The billing contact cannot be marked inactive if there is no other
//                                                                        - billing contact associated with that account.
// 29th April 2015    Hemendra Singh Bhati    Modified (Issue # I-157451) - A duplicate contact relationship should not be allowed irrespective
//                                                                        - of contact role.
// 06th May 2015      Hemendra Singh Bhati    Modified (Task # T-392803)  - Set the boolean field "Is_Sent_To_CDH__c" value to "False" whenever a
//                                                                        - new record on 'Account_Relationship__c' object is created and whenever
//                                                                        - the "Active" field is updated to "False".
//
trigger AccountRelationshipTrigger on Account_Relationship__c(before insert, before update, after insert, after update) {
    //if(OrderDecompController.testClassTriggerFlag == True){
    
    //}else{
        DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
        // Turn off trigger if the value of custom setting field is true. 
        if(Dtrg.TaskTrigger__c!=UserInfo.getUserName()){
            AccountRelationshipTriggerHandler theHandler = new AccountRelationshipTriggerHandler(Trigger.isExecuting, Trigger.size);
            
            // Turn off the trigger if the value of custom setting field is true.
            if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Overall_Trigger_Off__c == false) {
                system.debug('TRACE: AccountRelationshipTrigger is active.');
                
                // Trigger Event - Before Insert/Update.
                if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
                    theHandler.onBeforeInsertUpdate(trigger.new, trigger.oldMap, trigger.isInsert);
                    //     theHandler.onBeforeUpdate(trigger.newmap, trigger.oldMap, trigger.isInsert);      
                }
                
                // Trigger Event - After Insert/Update.
                if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
                    theHandler.onAfterInsertUpdate(trigger.newMap, trigger.oldMap, trigger.isInsert);
                }
            }
        }
    //}
}