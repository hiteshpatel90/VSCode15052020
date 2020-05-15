//
// (c) 2015 Appirio, Inc. 
//
// Trigger Handler Manager: AccountRelationshipTriggerHandlerManager
// For Trigger Handler: AccountRelationshipTriggerHandler
// For Trigger: AccountRelationshipTrigger
// On SObject: Account Relationship (Account_Relationship__c)
// Description: For "Account Relationship" record type, the unique key for checking duplicate records should be "Parent Account" + "Child Account".
// For "Contact Relationship" record type, the unique key for checking duplicate records should be "Parent Account" + "Contact To" +
// "Contact Role(Primary Contact/Billing Contact)". Also, auto-populates 'Account.Parent_Broker__c' and validate primary parent account.
// The billing contact cannot be marked inactive if there is no other billing contact associated with that account.
//
// User Story Acceptance Criteria Updated on 29th April 2015 For Issue # I-157451 - A duplicate contact relationship should not be allowed
// irrespective of contact role. The new unique key for contact relationship records is "Parent Account" + "Contact To".
//
// 23rd March 2015    Hemendra Singh Bhati    Original (Task # T-372661)
// 26th March 2015    Hemendra Singh Bhati    Modified (Task # T-373693)  - Complete code re-factored.
// 01st April 2015    Hemendra Singh Bhati    Modified (Task # T-374701)  - Removed active flag from all unique combinations for both
//                                                                          "Account Relationship" and "Contact Relationship" record types.
// 09th April 2015    Hemendra Singh Bhati    Modified (Task # T-377199)  - Added Method: populateAccountParentBroker(). Added logic to
//                                                                          auto-populate 'Account.Parent_Broker__c'.
// 10th April 2015    Hemendra Singh Bhati    Modified (Task # T-377199)  - Added Method: validatePrimaryParentAccount(). Added logic to
//                                                                          validate primary parent account.
// 24th April 2015    Hemendra Singh Bhati    Modified (Issue # I-155139) - The billing contact cannot be marked inactive if there is no other
//                                                                        - billing contact associated with that account.
//                                                                        - Added Method: validateBillingContactDeactivation().
// 29th April 2015    Hemendra Singh Bhati    Modified (Issue # I-157451) - A duplicate contact relationship should not be allowed irrespective
//                                                                        - of contact role.
//                                                                        - Updated Methods: validateAccountRelationshipRecords(), 
//                                                                        - validateExistingContactRelationshipTypeRecords().
// 06th May 2015      Hemendra Singh Bhati    Modified (Task # T-392803)  - Set the boolean field "Is_Sent_To_CDH__c" value to "False" whenever a
//                                                                        - new record on 'Account_Relationship__c' object is created and whenever
//                                                                        - the "Active" field is updated to "False".
//                                                                        - Added Method: updateIsSentToCDH().
// 27th May 2015      Ravindra Shekhawat      Modified (Task # T-)        - Added code for rolling up Agent/Office on brokers and agents on office and
//                                                                        - brokers
//                                                                                                                                              - Added Methods: processOldAccounts(), processAgentRelationship()
//                                                                        - processOfficeRelationship(), filterChildOfficeAgents(),
//                                                                        - filterAccountRelationships(), rollUpAccounts().
// 05th June 2015     Hemendra Singh Bhati    Modified (Issue # I-166269) - Deleted Methods: processOldAccounts(), processAgentRelationship(),
//                                                                        - processOfficeRelationship(), filterChildOfficeAgents(), rollUpAccounts().
// 05th June 2015     Hemendra Singh Bhati    Modified (Issue # I-166282) - Added Method: computeTotalAgentsAndTotalOffices().
//
public with sharing class AccountRelationshipTriggerHandlerManager {
  private final String ACCOUNT_RELATIONSHIP_RECORD_TYPE = 'Account Relationship';
  private final String CONTACT_RELATIONSHIP_RECORD_TYPE = 'Contact Relationship';
  private Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
  private Id AccRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;  
  private final String ACCOUNT_TYPE_BROKER = 'Broker';
  private final String ACCOUNT_TYPE_REALTOR_OFFICE = 'Realtor Office';
  private final String ACCOUNT_TYPE_REALTOR_AGENT = 'Realtor Agent';

  // Error Messages.
  private String accountTypeErrorMessage = ''; 
  private String contactTypeErrorMessage = '';

  /*
  @method      : validateBillingContactDeactivation
  @description : Validating billing contact for contact relationship records.
  @params      : List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void validateBillingContactDeactivation(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap,
                                                 Boolean isInsert) {
    // Contact relationship record type Id.
    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(CONTACT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;

    // Processing newly created/updated contact relationship records.
    Set<Id> toBeIgnored = new Set<Id>();
    Map<Id, List<Account_Relationship__c>> parentAccountMapping = new Map<Id, List<Account_Relationship__c>>();
    for(Account_Relationship__c theAccountRelationship : newValues) {
        if(theAccountRelationship.RecordTypeId != contactRelationshipRecordTypeId || theAccountRelationship.Parent_Account__c == null) {
            continue;
        }

      if(isInsert && String.isBlank(theAccountRelationship.Contact_Role__c)) {
        if(!parentAccountMapping.containsKey(theAccountRelationship.Parent_Account__c)) {
            parentAccountMapping.put(theAccountRelationship.Parent_Account__c, new List<Account_Relationship__c>());
        }
        parentAccountMapping.get(theAccountRelationship.Parent_Account__c).add(theAccountRelationship);
      }
      else if(
        !isInsert &&
        (
          (
            theAccountRelationship.Billing_Contact__c == true &&
            oldMap.get(theAccountRelationship.Id).Active__c == true &&
            theAccountRelationship.Active__c == false
          ) ||
          (
            oldMap.get(theAccountRelationship.Id).Billing_Contact__c == true &&
            theAccountRelationship.Billing_Contact__c == false &&
            String.isBlank(theAccountRelationship.Contact_Role__c)
          ) ||
          (String.isNotBlank(oldMap.get(theAccountRelationship.Id).Contact_Role__c) && String.isBlank(theAccountRelationship.Contact_Role__c))
        )
      ) {
        if(!parentAccountMapping.containsKey(theAccountRelationship.Parent_Account__c)) {
          parentAccountMapping.put(theAccountRelationship.Parent_Account__c, new List<Account_Relationship__c>());
        }
        parentAccountMapping.get(theAccountRelationship.Parent_Account__c).add(theAccountRelationship);
        toBeIgnored.add(theAccountRelationship.Id);
      }
    }
    system.debug('TRACE: parentAccountMapping - ' + parentAccountMapping);
    system.debug('TRACE: toBeIgnored - ' + toBeIgnored);

    // Processing parent account mapping with contact relationship records.
    // Here, we are finding out whether the data set to process has an active billing contact for a parent account.
    // If it has, then we will ignore that parent account.
    // And if there is no active billing contact found, we will compare the data set with existing contact relationship records.
    // Here, the data set means the newly inserted/updated contact relationship records.
    Boolean hasBillingContact;
    Set<Id> parentAccountIds = new Set<Id>();
    for(Id parentAccountId : parentAccountMapping.keySet()) {
        hasBillingContact = false;
        for(Account_Relationship__c theAccountRelationship : parentAccountMapping.get(parentAccountId)) {
            if(theAccountRelationship.Billing_Contact__c == true && theAccountRelationship.Active__c == true) {
                hasBillingContact = true;
                break;
            }
        }

      if(!hasBillingContact) {
        parentAccountIds.add(parentAccountId);
      }
    }

    // Extracting existing contact relationship records.
    if(parentAccountIds.size() > 0) {
        Set<Id> parentAccountsWithActiveBillingContact = new Set<Id>();
        for(Account_Relationship__c theAccountRelationship : [SELECT Parent_Account__c FROM Account_Relationship__c
                                                              WHERE RecordTypeId = :contactRelationshipRecordTypeId AND
                                                              Parent_Account__c IN :parentAccountIds AND Billing_Contact__c = true AND
                                                              Active__c = true AND Id NOT IN :toBeIgnored]) {
            parentAccountsWithActiveBillingContact.add(theAccountRelationship.Parent_Account__c);
        }
        system.debug('TRACE: parentAccountsWithActiveBillingContact - ' + parentAccountsWithActiveBillingContact);

      Account_Relationship__c theAccountRelationship = null;
      String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
      for(Id parentAccountId : parentAccountIds) {
        if(!parentAccountsWithActiveBillingContact.contains(parentAccountId)) {
            theAccountRelationship = parentAccountMapping.get(parentAccountId).get(0);
           // theAccountRelationship.addError(
          //  'Billing contact must be enabled and active since there is no other active billing contact associated with the parent account. ' + 
        //    '[Parent Account URL: ' + baseURL + theAccountRelationship.Parent_Account__c + ']\r\n'
         // );
        }
      }
    }
  }

  /*
  @method      : validatePrimaryParentAccount
  @description : Validating primary parent account.
  @params      : List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void validatePrimaryParentAccount(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
    // Account relationship record type Id.
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;

    // Error Message.
      String errorMessage = 'The selected child account already has a parent marked as primary in the following records:\r\n';

    // Filtering new values.
      Set<Id> primaryParentAccountIds = new Set<Id>();
      Set<Id> childAccountIds = new Set<Id>();

      Map<Id, String> childAccountIdAndItsType = new Map<Id, String>();
      Map<Id, String> primaryParentAccountIdAndItsType = new Map<Id, String>();

    List<Account_Relationship__c> filteredNewValues = new List<Account_Relationship__c>();
    for(Account_Relationship__c theAccountRelationship : newValues) {
      if(theAccountRelationship.RecordTypeId != accountRelationshipRecordTypeId) {
        continue;
        }

      if(isInsert) {
        if(
          theAccountRelationship.Parent_Account__c != null &&
          theAccountRelationship.Child_Account__c != null &&
          theAccountRelationship.Is_Parent_Primary__c == true
        ) {
          filteredNewValues.add(theAccountRelationship);
          primaryParentAccountIds.add(theAccountRelationship.Parent_Account__c);
          childAccountIds.add(theAccountRelationship.Child_Account__c);
            }
        }
        else {
            if(
              theAccountRelationship.Parent_Account__c != null &&
              theAccountRelationship.Child_Account__c != null &&
              theAccountRelationship.Is_Parent_Primary__c == true &&
              (
                oldMap.get(theAccountRelationship.Id).Parent_Account__c != theAccountRelationship.Parent_Account__c ||
                oldMap.get(theAccountRelationship.Id).Child_Account__c != theAccountRelationship.Child_Account__c ||
            oldMap.get(theAccountRelationship.Id).Is_Parent_Primary__c != theAccountRelationship.Is_Parent_Primary__c
              )
            ) {
                filteredNewValues.add(theAccountRelationship);
                primaryParentAccountIds.add(theAccountRelationship.Parent_Account__c);
                childAccountIds.add(theAccountRelationship.Child_Account__c);
            }
        }
    }
    system.debug('TRACE: filteredNewValues - ' + filteredNewValues);
    system.debug('TRACE: primaryParentAccountIds - ' + primaryParentAccountIds);
    system.debug('TRACE: childAccountIds - ' + childAccountIds);

    // Determining primary parent account and child account types.
    Set<Id> accountIds = new Set<Id>();
    accountIds.addAll(primaryParentAccountIds);
    accountIds.addAll(childAccountIds);
    for(Account theAccount : [SELECT Id, Type FROM Account WHERE (Type = :ACCOUNT_TYPE_REALTOR_OFFICE OR Type = :ACCOUNT_TYPE_BROKER
                              OR Type = :ACCOUNT_TYPE_REALTOR_AGENT) AND Id IN :accountIds]) {
      if(primaryParentAccountIds.contains(theAccount.Id)) {
        primaryParentAccountIdAndItsType.put(theAccount.Id, theAccount.Type);
      }
      else if(childAccountIds.contains(theAccount.Id)) {
        childAccountIdAndItsType.put(theAccount.Id, theAccount.Type);
      }
    }
    system.debug('TRACE: primaryParentAccountIdAndItsType - ' + primaryParentAccountIdAndItsType);
    system.debug('TRACE: childAccountIdAndItsType - ' + childAccountIdAndItsType);

    // Processing filtered new values.
    primaryParentAccountIds = new Set<Id>();
    childAccountIds = new Set<Id>();
    if(filteredNewValues.size() > 0) {
      if(filteredNewValues.size() > 1) {
        Boolean hasError = false;
        for(Integer i = 0;i < filteredNewValues.size() - 1; i++) {
            for(Integer j = i + 1;j < filteredNewValues.size(); j++) {
                hasError = false;
                if(
             filteredNewValues.get(i).Parent_Account__c != filteredNewValues.get(j).Parent_Account__c &&
             filteredNewValues.get(i).Child_Account__c == filteredNewValues.get(j).Child_Account__c
                ) {
              if(
                childAccountIdAndItsType.containsKey(filteredNewValues.get(i).Child_Account__c) &&
                childAccountIdAndItsType.get(filteredNewValues.get(i).Child_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_AGENT) &&
                primaryParentAccountIdAndItsType.containsKey(filteredNewValues.get(i).Parent_Account__c) &&
                primaryParentAccountIdAndItsType.get(filteredNewValues.get(i).Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE) &&
                primaryParentAccountIdAndItsType.containsKey(filteredNewValues.get(j).Parent_Account__c) &&
                primaryParentAccountIdAndItsType.get(filteredNewValues.get(j).Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE)
              ) {
                hasError = true;
                filteredNewValues.get(i).addError(errorMessage + 'Parent Account: ' + filteredNewValues.get(j).Parent_Account__c + ', ' +
                + 'Child Account: ' + filteredNewValues.get(j).Child_Account__c + '\r\n');
              }
              else if(
                childAccountIdAndItsType.containsKey(filteredNewValues.get(i).Child_Account__c) &&
                childAccountIdAndItsType.get(filteredNewValues.get(i).Child_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE) &&
                primaryParentAccountIdAndItsType.containsKey(filteredNewValues.get(i).Parent_Account__c) &&
                primaryParentAccountIdAndItsType.get(filteredNewValues.get(i).Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_BROKER) &&
                primaryParentAccountIdAndItsType.containsKey(filteredNewValues.get(j).Parent_Account__c) &&
                primaryParentAccountIdAndItsType.get(filteredNewValues.get(j).Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_BROKER)
              ) {
                hasError = true;
                filteredNewValues.get(i).addError(errorMessage + 'Parent Account: ' + filteredNewValues.get(j).Parent_Account__c + ', ' +
                + 'Child Account: ' + filteredNewValues.get(j).Child_Account__c + '\r\n');
              }
                }
            if(hasError == false) {
              primaryParentAccountIds.add(filteredNewValues.get(i).Parent_Account__c);
              primaryParentAccountIds.add(filteredNewValues.get(j).Parent_Account__c);

              childAccountIds.add(filteredNewValues.get(i).Child_Account__c);
              childAccountIds.add(filteredNewValues.get(j).Child_Account__c);
                }
            }
          }
      }
      else if(filteredNewValues.size() == 1) {
        primaryParentAccountIds.add(filteredNewValues.get(0).Parent_Account__c);
        childAccountIds.add(filteredNewValues.get(0).Child_Account__c);
      }
      system.debug('TRACE: primaryParentAccountIds - ' + primaryParentAccountIds);
      system.debug('TRACE: childAccountIds - ' + childAccountIds);

      // Extracting existing primary parent account Ids and child account Ids.
      Set<Id> existingPrimaryParentAccountIds = new Set<Id>();
      Set<Id> existingchildAccountIds = new Set<Id>();
      List<Account_Relationship__c> theExistingRecords = [SELECT Id, Name, Parent_Account__c, Child_Account__c FROM Account_Relationship__c
                                                          WHERE Child_Account__c IN :childAccountIds AND Is_Parent_Primary__c = true];
      for(Account_Relationship__c theAccountRelationship : theExistingRecords) {
        existingPrimaryParentAccountIds.add(theAccountRelationship.Parent_Account__c);
        existingchildAccountIds.add(theAccountRelationship.Child_Account__c);
      }

        // Determining primary parent account and child account types.
        accountIds = new Set<Id>();
        accountIds.addAll(existingPrimaryParentAccountIds);
        accountIds.addAll(existingchildAccountIds);
        for(Account theAccount : [SELECT Id, Type FROM Account WHERE (Type = :ACCOUNT_TYPE_REALTOR_OFFICE OR Type = :ACCOUNT_TYPE_BROKER
                                  OR Type = :ACCOUNT_TYPE_REALTOR_AGENT) AND Id IN :accountIds]) {
          if(existingPrimaryParentAccountIds.contains(theAccount.Id)) {
            primaryParentAccountIdAndItsType.put(theAccount.Id, theAccount.Type);
          }
          else if(existingchildAccountIds.contains(theAccount.Id)) {
            childAccountIdAndItsType.put(theAccount.Id, theAccount.Type);
          }
        }
      system.debug('TRACE: primaryParentAccountIdAndItsType - ' + primaryParentAccountIdAndItsType);
      system.debug('TRACE: childAccountIdAndItsType - ' + childAccountIdAndItsType);

      // Determining the usage of above primary parent account Ids in existing records.
      String childAccountType = '';
      String primaryParentAccountType = '';
      Map<Id, List<Account_Relationship__c>> childAccountIdAndItsInstancesMapping = new Map<Id, List<Account_Relationship__c>>();
      for(Account_Relationship__c theAccountRelationship : theExistingRecords) {
        childAccountType = childAccountIdAndItsType.get(theAccountRelationship.Child_Account__c);
        primaryParentAccountType = primaryParentAccountIdAndItsType.get(theAccountRelationship.Parent_Account__c);

        system.debug('TRACE: childAccountType - ' + childAccountType);
        system.debug('TRACE: primaryParentAccountType - ' + primaryParentAccountType);

        if(
         String.isNotBlank(childAccountType) &&
         String.isNotBlank(primaryParentAccountType) &&
         (
          (childAccountType.equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_AGENT) && primaryParentAccountType.equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE)) ||
          (childAccountType.equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE) && primaryParentAccountType.equalsIgnoreCase(ACCOUNT_TYPE_BROKER))
         )
        ) {
            if(!childAccountIdAndItsInstancesMapping.containsKey(theAccountRelationship.Child_Account__c)) {
              childAccountIdAndItsInstancesMapping.put(theAccountRelationship.Child_Account__c, new List<Account_Relationship__c>());
            }
            childAccountIdAndItsInstancesMapping.get(theAccountRelationship.Child_Account__c).add(theAccountRelationship);
        }
      }
      system.debug('TRACE: childAccountIdAndItsInstancesMapping - ' + childAccountIdAndItsInstancesMapping);

      // Processing re-filtered new values.
      String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
      for(Account_Relationship__c theAccountRelationship : filteredNewValues) {
          if(childAccountIdAndItsInstancesMapping.containsKey(theAccountRelationship.Child_Account__c)) {
            primaryParentAccountType = primaryParentAccountIdAndItsType.get(theAccountRelationship.Parent_Account__c);
            system.debug('TRACE: primaryParentAccountType - ' + primaryParentAccountType);

            for(Account_Relationship__c theExistingRecord : childAccountIdAndItsInstancesMapping.get(theAccountRelationship.Child_Account__c)) {
                if(isInsert || (theAccountRelationship.Id != theExistingRecord.Id)) {
                    system.debug('TRACE: primaryParentAccountType - ' + primaryParentAccountIdAndItsType.get(theExistingRecord.Parent_Account__c));
                    if(primaryParentAccountType == primaryParentAccountIdAndItsType.get(theExistingRecord.Parent_Account__c)) {
                theAccountRelationship.addError(errorMessage + theExistingRecord.Name + ' [Record URL - ' + baseURL + theExistingRecord.Id + ']\r\n');
                    }
                }
            }
          }
      }
      }
  }

  /*
  @method      : validateAccountRelationshipRecords
  @description : Validating Account Relationship Records Uniqueness.
  @params      : List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void validateAccountRelationshipRecords(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap,
                                                 Boolean isInsert) {
    // Categorizing new values on the basis of record type.
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;
    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(CONTACT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;

    List<Account_Relationship__c> newAccountTypeValues = new List<Account_Relationship__c>();
    List<Account_Relationship__c> newContactTypeValues = new List<Account_Relationship__c>();
    for(Account_Relationship__c theNewRecord : newValues) {
        if(theNewRecord.RecordTypeId == accountRelationshipRecordTypeId) {
            newAccountTypeValues.add(theNewRecord);
        }
        else if(theNewRecord.RecordTypeId == contactRelationshipRecordTypeId) {
            newContactTypeValues.add(theNewRecord);
        }
    }
    system.debug('TRACE: newAccountTypeValues - ' + newAccountTypeValues);
    system.debug('TRACE: newContactTypeValues - ' + newContactTypeValues);

    // Account Type Error Message.
    accountTypeErrorMessage = 'The account relationship with the given combination of parent account and child account';
    accountTypeErrorMessage += ' is already in use. Please select a different combinaton or activate the existing account relationship.';
    accountTypeErrorMessage += ' The account relationship record(s) using this combination is(are) as follows:\r\n';

    // Validating new account relationship type values for unique key: "Parent Account" + "Child Account".
    Set<Id> parentAccountIds = new Set<Id>();
    Set<Id> childAccountIds = new Set<Id>();
    if(newAccountTypeValues.size() > 1) {
      for(Integer i = 0;i < newAccountTypeValues.size() - 1; i++) {
        for(Integer j = i + 1;j < newAccountTypeValues.size(); j++) {
          if(
            newAccountTypeValues.get(j).Parent_Account__c == newAccountTypeValues.get(i).Parent_Account__c &&
            newAccountTypeValues.get(j).Child_Account__c == newAccountTypeValues.get(i).Child_Account__c
          ) {
              newAccountTypeValues.get(i).addError(
               accountTypeErrorMessage + 'Parent Account: ' + newAccountTypeValues.get(j).Parent_Account__c
               + ', Child Account: ' + newAccountTypeValues.get(j).Child_Account__c + '\r\n'
              );
          }
          else {
            parentAccountIds.add(newAccountTypeValues.get(i).Parent_Account__c);
            childAccountIds.add(newAccountTypeValues.get(i).Child_Account__c);

            parentAccountIds.add(newAccountTypeValues.get(j).Parent_Account__c);
            childAccountIds.add(newAccountTypeValues.get(j).Child_Account__c);
          }
        }
      }
    }
    else if(newAccountTypeValues.size() == 1) {
      parentAccountIds.add(newAccountTypeValues.get(0).Parent_Account__c);
      childAccountIds.add(newAccountTypeValues.get(0).Child_Account__c);
    }
    system.debug('TRACE: parentAccountIds - ' + parentAccountIds);
    system.debug('TRACE: childAccountIds - ' + childAccountIds);

    // Contact Type Error Message.
    contactTypeErrorMessage = 'The contact relationship with the given combination of parent account and contact';
    contactTypeErrorMessage += ' is already in use. Please select a different combinaton';
    contactTypeErrorMessage += ' or activate the existing contact relationship.';
    contactTypeErrorMessage += ' The contact relationship record(s) using this combination is(are) as follows:\r\n';

    // Validating new contact relationship type values for the unique key: "Parent Account" + "Contact To".
    Boolean hasError = false;
    Set<Id> contactToIds = new Set<Id>();
    if(newContactTypeValues.size() > 1) {
      for(Integer i = 0;i < newContactTypeValues.size() - 1; i++) {
        for(Integer j = i + 1;j < newContactTypeValues.size(); j++) {
          hasError = false;
          if(
            newContactTypeValues.get(j).Parent_Account__c == newContactTypeValues.get(i).Parent_Account__c &&
            newContactTypeValues.get(j).Contact_To__c == newContactTypeValues.get(i).Contact_To__c
          ) {
            hasError = true;
              newContactTypeValues.get(i).addError(
               contactTypeErrorMessage + 'Parent Account: ' + newContactTypeValues.get(j).Parent_Account__c
               + ', Contact To: ' + newContactTypeValues.get(j).Contact_To__c + '\r\n'
              );
          }
          if(!hasError) {
            parentAccountIds.add(newContactTypeValues.get(i).Parent_Account__c);
            contactToIds.add(newContactTypeValues.get(i).Contact_To__c);

            parentAccountIds.add(newContactTypeValues.get(j).Parent_Account__c);
            contactToIds.add(newContactTypeValues.get(j).Contact_To__c);
          }
        }
      }
    }
    else if(newContactTypeValues.size() == 1) {
      parentAccountIds.add(newContactTypeValues.get(0).Parent_Account__c);
      contactToIds.add(newContactTypeValues.get(0).Contact_To__c);
    }
    system.debug('TRACE: parentAccountIds - ' + parentAccountIds);
    system.debug('TRACE: contactToIds - ' + contactToIds);

    // Extracting existing records and categorizing them on the basis of record type.
    String theUniqueKey = '';
    Map<String, List<Account_Relationship__c>> uniqueKeyAndExistingAccountTypeRecordsMapping = new Map<String, List<Account_Relationship__c>>();
    Map<String, List<Account_Relationship__c>> uniqueKeyAndExistingContactTypeRecordsMapping = new Map<String, List<Account_Relationship__c>>();
    if(!parentAccountIds.isEmpty() || !childAccountIds.isEmpty())
    for(Account_Relationship__c theExistingRecord : [SELECT Id, Name, Parent_Account__c, Child_Account__c, Contact_To__c, RecordTypeId
                                                     FROM Account_Relationship__c WHERE Parent_Account__c != null AND Child_Account__c != null AND Contact_To__c != null AND ((Parent_Account__c IN :parentAccountIds AND
                                                     Child_Account__c IN :childAccountIds) OR (Parent_Account__c IN
                                                     :parentAccountIds AND Contact_To__c IN :contactToIds))]) {
      if(theExistingRecord.RecordTypeId == accountRelationshipRecordTypeId) {
        theUniqueKey = String.valueOf(theExistingRecord.Parent_Account__c) + '__' + String.valueOf(theExistingRecord.Child_Account__c);
        theUniqueKey = theUniqueKey.toLowerCase();
        if(!uniqueKeyAndExistingAccountTypeRecordsMapping.containsKey(theUniqueKey)) {
            uniqueKeyAndExistingAccountTypeRecordsMapping.put(theUniqueKey, new List<Account_Relationship__c>());
        }
        uniqueKeyAndExistingAccountTypeRecordsMapping.get(theUniqueKey).add(theExistingRecord);
      }
      else if(theExistingRecord.RecordTypeId == contactRelationshipRecordTypeId) {
        theUniqueKey = String.valueOf(theExistingRecord.Parent_Account__c) + '__' + String.valueOf(theExistingRecord.Contact_To__c);
        theUniqueKey = theUniqueKey.toLowerCase();
        if(!uniqueKeyAndExistingContactTypeRecordsMapping.containsKey(theUniqueKey)) {
          uniqueKeyAndExistingContactTypeRecordsMapping.put(theUniqueKey, new List<Account_Relationship__c>());
        }
        uniqueKeyAndExistingContactTypeRecordsMapping.get(theUniqueKey).add(theExistingRecord);
      }
    }
    system.debug('TRACE: uniqueKeyAndExistingAccountTypeRecordsMapping - ' + uniqueKeyAndExistingAccountTypeRecordsMapping);
    system.debug('TRACE: uniqueKeyAndExistingContactTypeRecordsMapping - ' + uniqueKeyAndExistingContactTypeRecordsMapping);

    if(uniqueKeyAndExistingAccountTypeRecordsMapping.size() > 0) {
        validateExistingAccountRelationshipTypeRecords(newAccountTypeValues, uniqueKeyAndExistingAccountTypeRecordsMapping, oldMap, isInsert);
    }
    if(uniqueKeyAndExistingContactTypeRecordsMapping.size() > 0) {
        validateExistingContactRelationshipTypeRecords(newContactTypeValues, uniqueKeyAndExistingContactTypeRecordsMapping, oldMap, isInsert);
    }
  }

  /*
  @method      : validateExistingAccountRelationshipTypeRecords
  @description : Validating existing account relationship type records.
  @params      : List<Account_Relationship__c> newAccountTypeValues, Map<String, List<Account_Relationship__c>>
               : uniqueKeyAndExistingAccountTypeRecordsMapping, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void validateExistingAccountRelationshipTypeRecords(List<Account_Relationship__c> newAccountTypeValues, Map<String, List<Account_Relationship__c>>
                                                             uniqueKeyAndExistingAccountTypeRecordsMapping, Map<Id, Account_Relationship__c> oldMap,
                                                             Boolean isInsert) {
    // Validating new account type records with existing account relationship records for
    // unique key: "Parent Account" + "Child Account".
    String theUniqueKey = '';
    Boolean hasError = false;
    String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
      for(Account_Relationship__c theNewRecord : newAccountTypeValues) {
        hasError = false;
        theUniqueKey = String.valueOf(theNewRecord.Parent_Account__c) + '__' + String.valueOf(theNewRecord.Child_Account__c);
        theUniqueKey = theUniqueKey.toLowerCase();
        if(isInsert) {
        if(uniqueKeyAndExistingAccountTypeRecordsMapping.containsKey(theUniqueKey)) {
            for(Account_Relationship__c theExistingRecord : uniqueKeyAndExistingAccountTypeRecordsMapping.get(theUniqueKey)) {
            accountTypeErrorMessage += theExistingRecord.Name + ' [Record URL - ' + baseURL + theExistingRecord.Id + ']\r\n';
            }
          theNewRecord.addError(accountTypeErrorMessage);
        }
        }
        else {
          if(
          (oldMap.get(theNewRecord.Id).Parent_Account__c != theNewRecord.Parent_Account__c ||
          oldMap.get(theNewRecord.Id).Child_Account__c != theNewRecord.Child_Account__c)
        ) {
            if(uniqueKeyAndExistingAccountTypeRecordsMapping.containsKey(theUniqueKey)) {
              for(Account_Relationship__c theExistingRecord : uniqueKeyAndExistingAccountTypeRecordsMapping.get(theUniqueKey)) {
                if(theExistingRecord.Id != theNewRecord.Id) {
                    hasError = true;
                accountTypeErrorMessage += theExistingRecord.Name + ' [Record URL - ' + baseURL + theExistingRecord.Id + ']\r\n';
                }
              }
              if(hasError) {
              theNewRecord.addError(accountTypeErrorMessage);
              }
            }
          }
        }
    }
  }

  /*
  @method      : validateExistingContactRelationshipTypeRecords
  @description : Validating existing contact relationship type records.
  @params      : List<Account_Relationship__c> newContactTypeValues, Map<String, List<Account_Relationship__c>>
               : uniqueKeyAndExistingContactTypeRecordsMapping, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void validateExistingContactRelationshipTypeRecords(List<Account_Relationship__c> newContactTypeValues, Map<String, List<Account_Relationship__c>>
                                                             uniqueKeyAndExistingContactTypeRecordsMapping, Map<Id, Account_Relationship__c> oldMap,
                                                             Boolean isInsert) {
    // Validating new contact type records with existing contact relationship records for unique key: "Parent Account" + "Contact To".
    String theUniqueKey = '';
    String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
      for(Account_Relationship__c theNewRecord : newContactTypeValues) {
        theUniqueKey = String.valueOf(theNewRecord.Parent_Account__c) + '__' + String.valueOf(theNewRecord.Contact_To__c);
        theUniqueKey = theUniqueKey.toLowerCase();
        if(isInsert) {
        if(uniqueKeyAndExistingContactTypeRecordsMapping.containsKey(theUniqueKey)) {
            for(Account_Relationship__c theExistingRecord : uniqueKeyAndExistingContactTypeRecordsMapping.get(theUniqueKey)) {
            contactTypeErrorMessage += theExistingRecord.Name + ' [Record URL - ' + baseURL + theExistingRecord.Id + ']\r\n';
                }
                theNewRecord.addError(contactTypeErrorMessage);
        }
        }
        else {
          if(
           oldMap.get(theNewRecord.Id).Parent_Account__c != theNewRecord.Parent_Account__c ||
           oldMap.get(theNewRecord.Id).Contact_To__c != theNewRecord.Contact_To__c
          ) {
            if(uniqueKeyAndExistingContactTypeRecordsMapping.containsKey(theUniqueKey)) {
              for(Account_Relationship__c theExistingRecord : uniqueKeyAndExistingContactTypeRecordsMapping.get(theUniqueKey)) {
                if(theExistingRecord.Id != theNewRecord.Id) {
                contactTypeErrorMessage += theExistingRecord.Name + ' [Record URL - ' + baseURL + theExistingRecord.Id + ']\r\n';
                }
              }
              theNewRecord.addError(contactTypeErrorMessage);
            }
          }
        }
    }
  }

  /*
  @method      : populateAccountParentBroker
  @description : Populating Custom Field 'Account.Parent_Broker__c'.
  @params      : List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void populateAccountParentBroker(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap,
                                          Boolean isInsert) {
    // Account relationship record type Id.
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;
    List<Account> Acctupdate = New List<Account>();
    boolean emladrsupdated = false;                                          
    // Extracting new child account Ids.
    Set<Id> replacedChildAccountIds = new Set<Id>();
    Set<Id> newChildAccountIds = new Set<Id>();
    List<Account_Relationship__c> filteredNewValues = new List<Account_Relationship__c>();
    for(Account_Relationship__c theAccountRelationship : newValues) {
        if(isInsert) {
          if(
           (theAccountRelationship.RecordTypeId == accountRelationshipRecordTypeId) &&
           (theAccountRelationship.Child_Account__c != null)
          ) {
            newChildAccountIds.add(theAccountRelationship.Child_Account__c);
            filteredNewValues.add(theAccountRelationship);
          }
        }
        else {            
            If(theAccountRelationship.Contact_Role__c == 'Primary Contact'){
                Acctupdate.add(New Account(Id = theAccountRelationship.Parent_Account__c,
                                           Primary_Email__c  = theAccountRelationship.Email_Address__c));
            }
            
        if(
         (theAccountRelationship.RecordTypeId == accountRelationshipRecordTypeId) &&
         (
          (oldMap.get(theAccountRelationship.Id).Parent_Account__c != theAccountRelationship.Parent_Account__c) ||
          (oldMap.get(theAccountRelationship.Id).Child_Account__c != theAccountRelationship.Child_Account__c) ||
          (oldMap.get(theAccountRelationship.Id).Is_Parent_Primary__c != theAccountRelationship.Is_Parent_Primary__c)
         )
        ) {
          newChildAccountIds.add(theAccountRelationship.Child_Account__c);
          filteredNewValues.add(theAccountRelationship);

          // Taking care of replaced child accounts.
          if(oldMap.get(theAccountRelationship.Id).Child_Account__c != theAccountRelationship.Child_Account__c) {
            newChildAccountIds.add(oldMap.get(theAccountRelationship.Id).Child_Account__c);
            if(oldMap.get(theAccountRelationship.Id).Child_Account__c!=null)
            replacedChildAccountIds.add(oldMap.get(theAccountRelationship.Id).Child_Account__c);
          }
        }
        }
    }

    // Resetting parent broker for replaced child accounts.
    if(replacedChildAccountIds.size() > 0) {
        List<Account> childAccountsToBeUpdated = new List<Account>();
        for(Id replacedChildAccountId : replacedChildAccountIds) {
            childAccountsToBeUpdated.add(new Account(
              Id = replacedChildAccountId,
              Parent_Broker__c = null
            ));
        }
        childAccountsToBeUpdated.addall(Acctupdate);
        update childAccountsToBeUpdated;
        emladrsupdated = true;
    }

    if(newChildAccountIds.size() > 0) {
        // Filtering child account Ids of type "Realtor Agent" and "Realtor Office" from new child account Ids extracted above.
        Set<Id> filteredChildAccountIds = new Set<Id>();
      Map<Id, String> childAccountIdAndItsType = new Map<Id, String>();
        for(Account theAccount : [SELECT Id,Type FROM Account WHERE (Type = :ACCOUNT_TYPE_REALTOR_AGENT OR Type = :ACCOUNT_TYPE_REALTOR_OFFICE)
                                  AND Id IN :newChildAccountIds]) {
          filteredChildAccountIds.add(theAccount.Id);
          childAccountIdAndItsType.put(theAccount.Id, theAccount.Type);
        }

        // Determining primary parent account of child accounts filtered above.
        Set<Id> primaryParentAccountIds = new Set<Id>();
        Map<Id, Id> childAccountAndItsPrimaryParentAccount = new Map<Id, Id>();
        for(Account_Relationship__c theAccountRelationship : [SELECT Parent_Account__c, Child_Account__c FROM Account_Relationship__c
                                                              WHERE RecordTypeId = :accountRelationshipRecordTypeId AND Parent_Account__c != null
                                                            AND Is_Parent_Primary__c = true AND Child_Account__c IN :filteredChildAccountIds]) {
        childAccountAndItsPrimaryParentAccount.put(theAccountRelationship.Child_Account__c, theAccountRelationship.Parent_Account__c);
        primaryParentAccountIds.add(theAccountRelationship.Parent_Account__c);
        }

      // Processing filtered new values.
      for(Account_Relationship__c theAccountRelationship : filteredNewValues) {
        if(
          !childAccountAndItsPrimaryParentAccount.containsKey(theAccountRelationship.Child_Account__c) &&
          theAccountRelationship.Is_Parent_Primary__c == true
        ) {
            childAccountAndItsPrimaryParentAccount.put(theAccountRelationship.Child_Account__c, theAccountRelationship.Parent_Account__c);
            primaryParentAccountIds.add(theAccountRelationship.Parent_Account__c);
        }
      }

      // Determining primary parent account type.
      Map<Id, String> primaryParentAccountIdAndItsType = new Map<Id, String>();
      for(Account theAccount : [SELECT Id,Type FROM Account WHERE (Type = :ACCOUNT_TYPE_REALTOR_OFFICE OR Type = :ACCOUNT_TYPE_BROKER)
                                AND Id IN :primaryParentAccountIds]) {
        primaryParentAccountIdAndItsType.put(theAccount.Id, theAccount.Type);
      }

      // Updating child account field 'Account.Parent_Broker__c'.
      if(childAccountAndItsPrimaryParentAccount.size() > 0) {
        Id parentBrokerId = null;
        String childAccountType = '';
        String primaryParentAccountType = '';
        List<Account> childAccountsToBeUpdated = new List<Account>();
        Set<Id> findParentBroker = new Set<Id>();
          for(Id childAccountId : childAccountAndItsPrimaryParentAccount.keySet()) {
            parentBrokerId = null;
            childAccountType = childAccountIdAndItsType.get(childAccountId);
            primaryParentAccountType = primaryParentAccountIdAndItsType.get(childAccountAndItsPrimaryParentAccount.get(childAccountId));

          if(childAccountType == ACCOUNT_TYPE_REALTOR_AGENT && primaryParentAccountType == ACCOUNT_TYPE_REALTOR_OFFICE) {
            parentBrokerId = null;
            findParentBroker.add(childAccountAndItsPrimaryParentAccount.get(childAccountId));
          }
          else if(childAccountType == ACCOUNT_TYPE_REALTOR_OFFICE && primaryParentAccountType == ACCOUNT_TYPE_BROKER) {
            parentBrokerId = childAccountAndItsPrimaryParentAccount.get(childAccountId);
          }

          if(parentBrokerId != null) {
              childAccountsToBeUpdated.add(new Account(
                Id = childAccountId,
                Parent_Broker__c = parentBrokerId
              ));
          }
          }

        if(findParentBroker.size() > 0) {
          // Extracting parent parent broker when child account is "Agent" and parent account is "Office".
          Map<Id, Id> parentParentBrokerMapping = new Map<Id, Id>();
            for(Account_Relationship__c theAccountRelationship : [SELECT Parent_Account__c, Child_Account__c FROM Account_Relationship__c
                                                                  WHERE RecordTypeId = :accountRelationshipRecordTypeId AND Parent_Account__c != null
                                                                  AND Is_Parent_Primary__c = true AND Child_Account__c IN :findParentBroker]) {
              parentParentBrokerMapping.put(theAccountRelationship.Child_Account__c, theAccountRelationship.Parent_Account__c);
            }

          // Updating "Agent" child account with parent parent broker account. 
          for(Id childAccountId : childAccountAndItsPrimaryParentAccount.keySet()) {
              parentBrokerId = null;
              childAccountType = childAccountIdAndItsType.get(childAccountId);
              primaryParentAccountType = primaryParentAccountIdAndItsType.get(childAccountAndItsPrimaryParentAccount.get(childAccountId));

              if(childAccountType == ACCOUNT_TYPE_REALTOR_AGENT && primaryParentAccountType == ACCOUNT_TYPE_REALTOR_OFFICE) {
              if(parentParentBrokerMapping.containsKey(childAccountAndItsPrimaryParentAccount.get(childAccountId))) {
                parentBrokerId = parentParentBrokerMapping.get(childAccountAndItsPrimaryParentAccount.get(childAccountId));
              }
              }

              if(parentBrokerId != null) {
                childAccountsToBeUpdated.add(new Account(
                  Id = childAccountId,
                  Parent_Broker__c = parentBrokerId
                ));
              }
          }
        }

          if(childAccountsToBeUpdated.size() > 0) {
              If(!emladrsupdated){
                  childAccountsToBeUpdated.addall(Acctupdate);
                  emladrsupdated = true;
              }
              update childAccountsToBeUpdated;
          }
      }
    }
                                              
              If(!emladrsupdated){
                  Update Acctupdate;
                  emladrsupdated = true;
              }
                                              
  }

  /*
  @method      : updateIsSentToCDH
  @description : Updating boolean field "Is_Sent_To_CDH__c" for both account and contact relationship records.
               : Set the boolean field "Is_Sent_To_CDH__c" value to "False" whenever a new record on 'Account_Relationship__c' object
               : is created and whenever the "Active" field is updated to "False".
  @params      : List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void updateIsSentToCDH(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
    // Processing new values.
    for(Account_Relationship__c theAccountRelationship : newValues) {
        if(isInsert) {
            theAccountRelationship.Is_Sent_to_CDH__c = false;
        }
        else if(
         !isInsert &&
         oldMap.get(theAccountRelationship.Id).Active__c == true &&
         theAccountRelationship.Active__c == false
        ) {
            theAccountRelationship.Is_Sent_to_CDH__c = false;
        }
    }
  }

  /*
  @method      : computeTotalAgentsAndTotalOffices
  @description : Compute total agents on office account and total offices/agents on broker account.
  @params      : Map<Id, Account_Relationship__c> newMap, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void computeTotalAgentsAndTotalOffices(Map<Id, Account_Relationship__c> newMap, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
    // Extracting account relatioship record type Id.
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;

    // Extracting parent and child account Ids.
    // Processing newly inserted/updated account relatioship records.
    Set<Id> theAccountIds = new Set<Id>();
    List<Account_Relationship__c> filteredNewValues = new List<Account_Relationship__c>();
    for(Account_Relationship__c theAccountRelationship : newMap.values()) {
      if(theAccountRelationship.RecordTypeId == accountRelationshipRecordTypeId) {
        // Account Relatioships Inserted.
        if(
          (
            isInsert &&
            theAccountRelationship.Parent_Account__c != null &&
            theAccountRelationship.Child_Account__c != null &&
            theAccountRelationship.Is_Parent_Primary__c == true &&
            theAccountRelationship.Active__c == true
          )
        ) {
          theAccountIds.add(theAccountRelationship.Parent_Account__c);
          theAccountIds.add(theAccountRelationship.Child_Account__c);
          filteredNewValues.add(theAccountRelationship);
        }
        // Account Relatioships Updated.
        else if(
          !isInsert &&
          (
            oldMap.get(theAccountRelationship.Id).Parent_Account__c != theAccountRelationship.Parent_Account__c ||
            oldMap.get(theAccountRelationship.Id).Child_Account__c != theAccountRelationship.Child_Account__c ||
            oldMap.get(theAccountRelationship.Id).Is_Parent_Primary__c != theAccountRelationship.Is_Parent_Primary__c ||
            oldMap.get(theAccountRelationship.Id).Active__c != theAccountRelationship.Active__c
          )
        ) {
          filteredNewValues.add(theAccountRelationship);
  
          // Processing newly updated parent and child accounts.
          if(theAccountRelationship.Parent_Account__c != null) {
            theAccountIds.add(theAccountRelationship.Parent_Account__c);
          }
          if(theAccountRelationship.Child_Account__c != null) {
            theAccountIds.add(theAccountRelationship.Child_Account__c);
          }
  
          // Taking care of replaced old parent and child accounts.
          if(oldMap.get(theAccountRelationship.Id).Parent_Account__c != null) {
            theAccountIds.add(oldMap.get(theAccountRelationship.Id).Parent_Account__c);
          }
          if(oldMap.get(theAccountRelationship.Id).Child_Account__c != null) {
            theAccountIds.add(oldMap.get(theAccountRelationship.Id).Child_Account__c);
          }
        }
      }
    }
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - theAccountIds - ' + theAccountIds);
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - filteredNewValues - ' + filteredNewValues);

    // Extracting parent and child account types.
    Map<Id, String> theAccountAndTypeMapping = new Map<Id, String>();
    if(theAccountIds.size() > 0) {
      for(Account theAccount : [SELECT Id, Type FROM Account WHERE Id IN :theAccountIds AND Type != '']) {
        theAccountAndTypeMapping.put(theAccount.Id, theAccount.Type);
      }
    }
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - theAccountAndTypeMapping - ' + theAccountAndTypeMapping);

    // Processing filtered inserted/updated account relatioship records.
    // Extracting broker and office accounts to update.
    Set<Id> theBrokerAccountIds = new Set<Id>();
    Set<Id> theOfficeAccountIds = new Set<Id>();
    for(Account_Relationship__c theAccountRelationship : filteredNewValues) {
      if(
        isInsert &&
        theAccountAndTypeMapping.containsKey(theAccountRelationship.Parent_Account__c) &&
        theAccountAndTypeMapping.containsKey(theAccountRelationship.Child_Account__c)
      ) {
        if(
          theAccountAndTypeMapping.get(theAccountRelationship.Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_BROKER) &&
          theAccountAndTypeMapping.get(theAccountRelationship.Child_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE)
        ) {
          theBrokerAccountIds.add(theAccountRelationship.Parent_Account__c);
        }
        else if(
          theAccountAndTypeMapping.get(theAccountRelationship.Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE) &&
          theAccountAndTypeMapping.get(theAccountRelationship.Child_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_AGENT)
        ) {
          theOfficeAccountIds.add(theAccountRelationship.Parent_Account__c);
        }
      }
      else if(!isInsert) {
        // Processing newly updated parent accounts.
        if(
          theAccountRelationship.Parent_Account__c != null &&
          theAccountAndTypeMapping.containsKey(theAccountRelationship.Parent_Account__c)
        ) {
          if(theAccountAndTypeMapping.get(theAccountRelationship.Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_BROKER)) {
            theBrokerAccountIds.add(theAccountRelationship.Parent_Account__c);
          }
          else if(theAccountAndTypeMapping.get(theAccountRelationship.Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE)) {
            theOfficeAccountIds.add(theAccountRelationship.Parent_Account__c);
          }
        }

        // Taking care of replaced old parent accounts.
        if(
          oldMap.get(theAccountRelationship.Id).Parent_Account__c != null &&
          theAccountAndTypeMapping.containsKey(oldMap.get(theAccountRelationship.Id).Parent_Account__c)
        ) {
          if(theAccountAndTypeMapping.get(oldMap.get(theAccountRelationship.Id).Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_BROKER)) {
            theBrokerAccountIds.add(oldMap.get(theAccountRelationship.Id).Parent_Account__c);
          }
          else if(theAccountAndTypeMapping.get(oldMap.get(theAccountRelationship.Id).Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE)) {
            theOfficeAccountIds.add(oldMap.get(theAccountRelationship.Id).Parent_Account__c);
          }
        }
      }
    }
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - theBrokerAccountIds - ' + theBrokerAccountIds);
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - theOfficeAccountIds - ' + theOfficeAccountIds);

    // Extracting broker accounts for office accounts filtered above.
    if(theOfficeAccountIds.size() > 0) {
      for(Account_Relationship__c theAccountRelationship : [SELECT Id, Parent_Account__c FROM Account_Relationship__c WHERE
                                                            Child_Account__c IN :theOfficeAccountIds AND Parent_Account__c != null AND
                                                            Parent_Account__r.Type = 'Broker' AND Is_Parent_Primary__c = true AND
                                                            Active__c = true]) {
        theBrokerAccountIds.add(theAccountRelationship.Parent_Account__c);
      }
    }
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - Update theBrokerAccountIds - ' + theBrokerAccountIds);

    // Processing broker accounts extracted above.
    Account theAccount = null;
    Map<Id, Account> theAccountsToBeUpdated = new Map<Id, Account>();
    if(theBrokerAccountIds.size() > 0) {
      Map<Id, Id> theOfficeAccountAndItsBrokerAccountMapping = new Map<Id, Id>();
      Map<Id, Integer> totalBrokerOffices = new Map<Id, Integer>();
      Map<Id, Integer> totalBrokerAgents = new Map<Id, Integer>();

      // Computing total offices for broker accounts.
      for(Account_Relationship__c theAccountRelationship : [SELECT Id, Parent_Account__c, Child_Account__c FROM Account_Relationship__c WHERE
                                                            Parent_Account__c IN :theBrokerAccountIds AND Is_Parent_Primary__c = true
                                                            AND Active__c = true AND Child_Account__c != null
                                                            AND Child_Account__r.Type = 'Realtor Office']) {
        theOfficeAccountAndItsBrokerAccountMapping.put(theAccountRelationship.Child_Account__c, theAccountRelationship.Parent_Account__c);
        if(!totalBrokerOffices.containsKey(theAccountRelationship.Parent_Account__c)) {
          totalBrokerOffices.put(theAccountRelationship.Parent_Account__c, 0);
        }
        totalBrokerOffices.put(
          theAccountRelationship.Parent_Account__c,
          totalBrokerOffices.get(theAccountRelationship.Parent_Account__c) + 1
        );
      }

      // Computing total offices for broker accounts.
      Integer totalOffices = 0;
      for(Id theAccountId : totalBrokerOffices.size() > 0 ? totalBrokerOffices.keySet() : theBrokerAccountIds) {
        if(theAccountsToBeUpdated.containsKey(theAccountId)) {
          theAccount = theAccountsToBeUpdated.get(theAccountId);
          theAccount.Total_Offices__c = totalBrokerOffices.containsKey(theAccountId) ? totalBrokerOffices.get(theAccountId) + totalOffices : 0;
        }
        else {
          theAccountsToBeUpdated.put(
            theAccountId,
            new Account(
              Id = theAccountId,
              Total_Offices__c = totalBrokerOffices.containsKey(theAccountId) ? totalBrokerOffices.get(theAccountId) + totalOffices : 0
            )
          );
        }
        totalOffices = totalOffices + (totalBrokerOffices.containsKey(theAccountId) ? totalBrokerOffices.get(theAccountId) : 0);
      }

      // Computing total agents for broker accounts.
      for(Account_Relationship__c theAccountRelationship : [SELECT Id, Parent_Account__c FROM Account_Relationship__c WHERE
                                                            Parent_Account__c IN :theOfficeAccountAndItsBrokerAccountMapping.keySet()
                                                            AND Is_Parent_Primary__c = true AND Active__c = true
                                                            AND Child_Account__c != null AND Child_Account__r.Type = 'Realtor Agent']) {
        if(!totalBrokerAgents.containsKey(theAccountRelationship.Parent_Account__c)) {
          totalBrokerAgents.put(theAccountRelationship.Parent_Account__c, 0);
        }
        totalBrokerAgents.put(
          theAccountRelationship.Parent_Account__c,
          totalBrokerAgents.get(theAccountRelationship.Parent_Account__c) + 1
        );
      }

      // Computing total agents for broker accounts.
      Integer totalAgents = 0;
      for(Id theAccountId : totalBrokerAgents.size() > 0 ? totalBrokerAgents.keySet() : theOfficeAccountAndItsBrokerAccountMapping.keySet()) {
        if(theOfficeAccountAndItsBrokerAccountMapping.containsKey(theAccountId)) {
          if(theAccountsToBeUpdated.containsKey(theOfficeAccountAndItsBrokerAccountMapping.get(theAccountId))) {
            theAccount = theAccountsToBeUpdated.get(theOfficeAccountAndItsBrokerAccountMapping.get(theAccountId));
            theAccount.Total_Agents__c = totalBrokerAgents.containsKey(theAccountId) ? totalBrokerAgents.get(theAccountId) + totalAgents : 0;
          }
          else {
            theAccountsToBeUpdated.put(
              theOfficeAccountAndItsBrokerAccountMapping.get(theAccountId),
              new Account(
                Id = theOfficeAccountAndItsBrokerAccountMapping.get(theAccountId),
                Total_Agents__c = totalBrokerAgents.containsKey(theAccountId) ? totalBrokerAgents.get(theAccountId) + totalAgents : 0
              )
            );
          }
          totalAgents = totalAgents + (totalBrokerAgents.containsKey(theAccountId) ? totalBrokerAgents.get(theAccountId) : 0);
        }
      }

      system.debug('TRACE: computeTotalAgentsAndTotalOffices - theOfficeAccountAndItsBrokerAccountMapping - ' + theOfficeAccountAndItsBrokerAccountMapping);
      system.debug('TRACE: computeTotalAgentsAndTotalOffices - totalBrokerOffices - ' + totalBrokerOffices);
      system.debug('TRACE: computeTotalAgentsAndTotalOffices - totalBrokerAgents - ' + totalBrokerAgents);
      system.debug('TRACE: computeTotalAgentsAndTotalOffices - totalAgents - ' + totalAgents);
      system.debug('TRACE: computeTotalAgentsAndTotalOffices - totalOffices - ' + totalOffices);
    }

    // Processing office accounts extracted above.
    if(theOfficeAccountIds.size() > 0) {
      Map<Id, Integer> totalOfficeAgents = new Map<Id, Integer>();

      // Computing total agents for office accounts.
      for(Account_Relationship__c theAccountRelationship : [SELECT Id, Parent_Account__c FROM Account_Relationship__c WHERE
                                                            Parent_Account__c IN :theOfficeAccountIds AND Is_Parent_Primary__c = true
                                                            AND Active__c = true AND Child_Account__c != null
                                                            AND Child_Account__r.Type = 'Realtor Agent']) {
        if(!totalOfficeAgents.containsKey(theAccountRelationship.Parent_Account__c)) {
          totalOfficeAgents.put(theAccountRelationship.Parent_Account__c, 0);
        }
        totalOfficeAgents.put(
          theAccountRelationship.Parent_Account__c,
          totalOfficeAgents.get(theAccountRelationship.Parent_Account__c) + 1
        );
      }

      // Computing total agents for office accounts.
      Integer totalAgents = 0;
      for(Id theAccountId : totalOfficeAgents.size() > 0 ? totalOfficeAgents.keySet() : theOfficeAccountIds) {
        if(theAccountsToBeUpdated.containsKey(theAccountId)) {
          theAccount = theAccountsToBeUpdated.get(theAccountId);
          theAccount.Total_Agents__c = totalOfficeAgents.containsKey(theAccountId) ? totalOfficeAgents.get(theAccountId) + totalAgents : 0;
        }
        else {
          theAccountsToBeUpdated.put(
            theAccountId,
            new Account(
              Id = theAccountId,
              Total_Agents__c = totalOfficeAgents.containsKey(theAccountId) ? totalOfficeAgents.get(theAccountId) + totalAgents : 0
            )
          );
        }
        totalAgents = totalAgents + (totalOfficeAgents.containsKey(theAccountId) ? totalOfficeAgents.get(theAccountId) : 0);
      }

      system.debug('TRACE: computeTotalAgentsAndTotalOffices - totalOfficeAgents - ' + totalOfficeAgents);
      system.debug('TRACE: computeTotalAgentsAndTotalOffices - totalAgents - ' + totalAgents);
    }

    // Updating broker and office accounts with values computed above.
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - theAccountsToBeUpdated - ' + theAccountsToBeUpdated);
    if(theAccountsToBeUpdated.size() > 0) {
      update theAccountsToBeUpdated.values();
    }
  }
  
  public void checkcontactUniquenes(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert){
    
      set<ID> parentIds = new set<ID>();
      list<Account> accList = new list<Account>();
      
      if(isInsert){
          for(Account_Relationship__c accRelation: newValues){
          if(accRelation.Active__c && accRelation.RecordTypeID == contRelationShipRTID ){
              if(accRelation.Contact_Role__c == 'Primary Contact')
                      accRelation.Primary_Contact_Unique__c = ''+accRelation.RecordTypeID + accRelation.Parent_Account__c + accRelation.Contact_Role__c+ accRelation.Active__c;
              if(accRelation.Billing_Contact__c)
                      accRelation.Billing_Contact_Unique__c = ''+accRelation.RecordTypeID + accRelation.Parent_Account__c + ''+ accRelation.Billing_Contact__c + accRelation.Active__c;              
           }
          if(accRelation.Active__c && accRelation.RecordTypeID == AccRelationShipRTID){
              system.debug('test==>'+accRelation.Parent_Account__c);
             parentIds.add(accRelation.Parent_Account__c);  
           }
          }
      }
      else{
          for(Account_Relationship__c accRelUpdate: newvalues){
         if(accRelUpdate.RecordTypeID == contRelationShipRTID){
              if(oldMap.get(accRelUpdate.ID).Active__c && (accRelUpdate.Active__c != oldMap.get(accRelUpdate.ID).Active__c || accRelUpdate.Contact_Role__c != oldMap.get(accRelUpdate.ID).Contact_Role__c )){                                
                        accRelUpdate.Primary_Contact_Unique__c = ''+accRelUpdate.RecordTypeID + accRelUpdate.Parent_Account__c + accRelUpdate.Contact_Role__c + accRelUpdate.Active__c;                                                              
                        }
              if(oldMap.get(accRelUpdate.ID).Active__c && (accRelUpdate.Active__c != oldMap.get(accRelUpdate.ID).Active__c  || accRelUpdate.Billing_Contact__c != oldMap.get(accRelUpdate.ID).Billing_Contact__c)){
                        accRelUpdate.Billing_Contact_Unique__c = ''+accRelUpdate.RecordTypeID + accRelUpdate.Parent_Account__c + ''+accRelUpdate.Billing_Contact__c  + accRelUpdate.Active__c;                        
                        if(!accRelUpdate.Billing_Contact__c)                        
                            accRelUpdate.Billing_Contact_Unique__c = ''+accRelUpdate.RecordTypeID + accRelUpdate.Parent_Account__c + ''+accRelUpdate.Billing_Contact__c  + accRelUpdate.Active__c + datetime.now();                                                                            
              }
              
              if(accRelUpdate.Active__c != oldMap.get(accRelUpdate.ID).Active__c || accRelUpdate.Contact_Role__c != oldMap.get(accRelUpdate.ID).Contact_Role__c || accRelUpdate.Billing_Contact__c != oldMap.get(accRelUpdate.ID).Billing_Contact__c ){                  
                        accRelUpdate.Primary_Contact_Unique__c = ''+accRelUpdate.RecordTypeID + accRelUpdate.Parent_Account__c + accRelUpdate.Contact_Role__c + accRelUpdate.Active__c;          
                        }
              if(accRelUpdate.Active__c != oldMap.get(accRelUpdate.ID).Active__c  || accRelUpdate.Billing_Contact__c != oldMap.get(accRelUpdate.ID).Billing_Contact__c || accRelUpdate.Billing_Contact__c != oldMap.get(accRelUpdate.ID).Billing_Contact__c){              
                        accRelUpdate.Billing_Contact_Unique__c = ''+accRelUpdate.RecordTypeID + accRelUpdate.Parent_Account__c + ''+accRelUpdate.Billing_Contact__c  + accRelUpdate.Active__c;                        
                        if(!accRelUpdate.Billing_Contact__c)                        
                            accRelUpdate.Billing_Contact_Unique__c = ''+accRelUpdate.RecordTypeID + accRelUpdate.Parent_Account__c + ''+accRelUpdate.Billing_Contact__c  + accRelUpdate.Active__c + datetime.now();                                                                                                    
              }
                            
            }                            
          }      
      }
  }
   /*
  @method      : updateAccountforParentChild
  @description : Update Child accounts when a new account relatoin recor dis created/updated
  @params      : List<Account_Relationship__c> newValues
  @returns     : void
  @author      : Ravinder Reddy
  */
    
  public void CheckChildAccountAssetValidation(map<ID,Account_Relationship__c> newValues,map<ID,Account_Relationship__c> oldmap,boolean isInsert)
  {
      set<ID> childAccountIds = new set<ID>();
      set<ID> parentAccountIds = new set<ID>();
      map<ID,ID> accMap = new map<ID,ID>();
      map<ID,ID> accMap2 = new map<ID,ID>();
      if(newValues != Null && newValues.size()>0){      
      for(Account_Relationship__c accRelation: newValues.values()){
      system.debug('we are here');
           accMap.put(accRelation.Child_Account__c,accRelation.ID); 
           accMap2.put(accRelation.Parent_Account__c,accRelation.ID);            
           // if update and Active marked true
          if(!isInsert && oldmap.containsKey(accRelation.ID) && oldmap.get(accRelation.ID).Active__c == true && !accRelation.Active__c  &&  accRelation.RecordTypeID == AccRelationShipRTID && accRelation.Child_Account__c != null){             
             childAccountIds.add(accRelation.Child_Account__c);  
           }
          if(!isInsert && oldmap.containsKey(accRelation.ID) && oldmap.get(accRelation.ID).Active__c == true && !accRelation.Active__c  &&  accRelation.RecordTypeID == AccRelationShipRTID && accRelation.Parent_Account__c != null){             
             parentAccountIds.add(accRelation.Parent_Account__c);  
           }
                      
           // if insert and Active marked true           
//           if(isInsert && !accRelation.Active__c  &&  accRelation.RecordTypeID == AccRelationShipRTID && accRelation.Child_Account__c != null){
//               parentAccountIds.add(accRelation.Parent_Account__c);
//           }
        }
        }
// AND Status =: 'Active' AND Account.Type =: 'Realtor Office'    
       if(parentAccountIds .size() > 0)
           for(Asset oassetParent: [SELECT ID,AccountID,Account.Type FROM Asset  WHERE AccountID IN:parentAccountIds AND Asset_Type__c =: 'Parent' AND Status =: 'Active' AND Product_Account__c != null AND Product_Account__r.Type =: 'Realtor Office']){
               if(accMap2.containsKey(oassetParent.AccountID) && newValues.containsKey(accMap2.get(oassetParent.AccountID))){
                  newValues.get(accMap2.get(oassetParent.AccountID)).addError('You cannot In-Active an Active Asset');
               }
           }
               
       if(childAccountIds.size() > 0){
           for(Asset oasset: [SELECT ID,AccountID,Account.Type FROM Asset  WHERE AccountID IN:childAccountIds AND Status =: 'Active' AND Account.Type =: 'Realtor Office']){
               if(accMap.containsKey(oasset.AccountID) && newValues.containsKey(accMap.get(oasset.AccountID))){
                  newValues.get(accMap.get(oasset.AccountID)).addError('You cannot in Active an Active Asset');
               }
           }

                      
           if(childAccountIds.size() >0){
           list<Account> accList = new list<Account>();
               for(Account oacc : [SELECT ID,Parent_Broker__c FROM Account WHERE ID IN: childAccountIds]){
                   Account accTemp = new Account(ID=oacc.ID);
                   accTemp.Parent_Broker__c = null;
                   accList.add(accTemp);
               }
               if(!accList.isEmpty())
                   update accList;
           }   
       }
        
  }
  

   /*
  @method      : updateAccountforParentChild
  @description : Update Child accounts when a new account relatoin recor dis created/updated
  @params      : List<Account_Relationship__c> newValues
  @returns     : void
  @author      : Ravinder Reddy
  */
    
  public void updateAccountforParentChild(list<Account_Relationship__c> newValues)
  {
      set<ID> parentIds = new set<ID>();
      list<Account> accList = new list<Account>();
      
       for(Account_Relationship__c accRelation: newValues){
       
          if(accRelation.Active__c && accRelation.RecordTypeID == AccRelationShipRTID){
              system.debug('test==>'+accRelation.Parent_Account__c);
             parentIds.add(accRelation.Parent_Account__c);  
           }
        }
          
       for(Account_Relationship__c  oaccRelation : [SELECT ID,Child_Account__c,Parent_Account__c,Relationship_Type__c,Parent_Account__r.OwnerID  FROM Account_Relationship__c WHERE Parent_Account__r.Type = 'Broker' AND  Child_Account__r.Type = 'Realtor Office' AND Parent_Account__c IN: parentIds AND RecordType.DeveloperName = 'Account_Relationship' order by Name asc limit 49998]){
                  system.debug('****type****'+oaccRelation.Relationship_Type__c);
                      
              if(oaccRelation.Relationship_Type__c == 'Parent/Child')
          accList.add(new Account(ID=oaccRelation.Child_Account__c,OwnerId = oaccRelation.Parent_Account__r.OwnerID ));
            
       }
      system.debug('accList======'+accList);
       if(!accList.isEmpty()){
           system.debug('accList======'+accList[0]);
            //AccountTriggerHandlerManager.onTerritorychagneFlag = true;
            update accList ;
        }   
      
  }
  
 
   /*
  @method      : populateIsParentPrimary
  @description : Populating Contact Account if isPArent Primary is marked true
  @params      : List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  @author      : Ravinder Reddy
  */
  public static boolean updateAccrealtion = false;
  public void populateIsParentPrimary(map<ID,Account_Relationship__c> newmap, Map<Id, Account_Relationship__c> oldMap,
                                          Boolean isInsert) {
    //Is_Parent_Primary__c
    map<ID,ID> contactmap = new map<ID,ID>();
    list<Contact> contactList = new list<Contact>();
    map<ID,ID> parentAccountIDs = new map<ID,ID>();
    list<Account_Relationship__c> accRelationUpdate = new list<Account_Relationship__c>();
    for(Account_Relationship__c accRelation : newmap.values()){
        if(accRelation.RecordtypeID == contRelationShipRTID  ){
            if((isInsert && accRelation.Is_Parent_Primary__c) || ( !isInsert && oldmap != null && oldmap.containskey(accRelation.ID) && accRelation.Is_Parent_Primary__c && oldmap.get(accRelation.ID).Is_Parent_Primary__c != accRelation.Is_Parent_Primary__c )){
                if(accRelation.Contact_To__c != null && accRelation.Parent_Account__c != null)        
                    contactmap.put(accRelation.Contact_To__c,accRelation.Parent_Account__c);
                    parentAccountIDs.put(accRelation.Parent_Account__c,accRelation.ID);
        }
            if(!isInsert && !accRelation.Is_Parent_Primary__c &&  oldmap != null && oldmap.containskey(accRelation.ID) && oldmap.get(accRelation.ID).Is_Parent_Primary__c != accRelation.Is_Parent_Primary__c )
            {
             if(accRelation.Contact_To__c != null)        
                    contactmap.put(accRelation.Contact_To__c,null);   
            }
        }
    } 
    
    
     
        
    for(contact con : [SELECT Id,AccountId FROM contact WHERE ID IN: contactmap.keyset()]){
        if(contactmap.containsKey(con.ID)){
            contactList .add(new Contact(ID=con.ID,AccountId = contactmap.get(con.ID)));  
        }
        
    }

            for(Account_Relationship__c accRelation : newmap.values()){
                      parentAccountIDs.put(accRelation.Parent_Account__c,accRelation.ID);
            }
    
    map<ID,Integer> ContactsCount = new map<ID,Integer>();
     AggregateResult[] groupedResults = [SELECT Parent_Account__c,Count(ID) contactCount FROM Account_Relationship__c  WHERE Parent_Account__c IN: parentAccountIDs.keyset() AND RecordType.DeveloperName = 'Contact_Relationship' AND Active__c = true   GROUP BY Parent_Account__c limit 49995 ]; 
        
    for (AggregateResult ar : groupedResults)  {
            ContactsCount.put(''+ar.get('Parent_Account__c'),Integer.valueOf(ar.get('contactCount')));                                         
    }
    for(Account_Relationship__c oaccountRelation :newmap.values())
    {
     if(oaccountRelation.RecordtypeID == contRelationShipRTID && parentAccountIDs.containsKey(oaccountRelation.Parent_Account__c)&&ContactsCount.containsKey(oaccountRelation.Parent_Account__c) && ContactsCount.get(oaccountRelation.Parent_Account__c) == 1){
        if(Isinsert){
        accRelationUpdate.add(new Account_Relationship__c (ID=parentAccountIDs.get(oaccountRelation.Parent_Account__c),Billing_Contact__c = true,Contact_Role__c = 'Primary Contact')); 
        }
        else{
            accRelationUpdate.add(new Account_Relationship__c (ID=parentAccountIDs.get(oaccountRelation.Parent_Account__c))); 
        }
              
              }
    }
    
    
    if(!contactlist.isEmpty()){
      set<contact> contactset = new set<Contact>();
      contactset.addAll(contactlist);
      contactlist.clear();
      for(contact ocon: contactset){

        contactlist.add(ocon);
      }
      update contactlist;
    }
      
    if(!accRelationUpdate.isEmpty()){                                                 
    updateAccrealtion = true;
     set<Account_Relationship__c> accRealtionset = new set<Account_Relationship__c>();
      accRealtionset.addAll(accRelationUpdate);
      accRelationUpdate.clear();
      for(Account_Relationship__c oaccr: accRealtionset){
        accRelationUpdate.add(oaccr);
      }
        update accRelationUpdate;
        }
  } 
    //during insert if account has already billing contact to true then set old billing contact to false
    public void setbillngcntctfalseinsert(Map<Id,Account_Relationship__c> NewMap){
        set<id> prntactids = new set<id>();
        List<Account> Acctupdate = New List<Account>();
        list<Account_Relationship__c> acctreltndata = new list<Account_Relationship__c>();
        for(Account_Relationship__c acctrelloop : NewMap.values()){
            prntactids.add(acctrelloop.Parent_account__c);
            If(acctrelloop.Contact_Role__c == 'Primary Contact'){
                Acctupdate.add(New Account(Id = acctrelloop.Parent_Account__c,
                                           Primary_Email__c  = acctrelloop.Email_Address__c));
            }
        }
        system.debug('Acctupdate:'+Acctupdate);
        acctreltndata = [select parent_Account__c,Billing_Contact__c,Active__c 
                         from Account_Relationship__c where parent_Account__c in :prntactids
                         and Billing_Contact__c = true and Active__c = true order by createddate desc];
        for(Account_Relationship__c newvlloop : NewMap.values()){
            if(newvlloop.Billing_Contact__c == true &&
               newvlloop.Active__c == true){
                   system.debug('subbu is here');
                   for(Account_Relationship__c acctrltnloop : acctreltndata){
                       system.debug('Naresh is here');
                       if(acctrltnloop.parent_Account__c == newvlloop.parent_Account__c
                          && acctrltnloop.Billing_Contact__c == true   
                          && acctrltnloop.Active__c == true
                          //excluding the just created one
                          && acctrltnloop.id != acctreltndata[0].id){
                              system.debug('Sanjay is here');
                              acctrltnloop.Billing_Contact__c = false;
                          }
                   }
               }       
        }
        system.debug('acctreltndata:'+acctreltndata);
        if(acctreltndata.size() > 0){
            update acctreltndata;
        }
        
        If(Acctupdate != Null && Acctupdate.size() > 0){
           Update Acctupdate;
        }
    }
     //during update if account has already billing contact to true then set old billing contact to false
    public void setbillngcntctfalseupdate(Map<Id,Account_Relationship__c> NewMap,Map<Id,Account_Relationship__c> OldMap){
        set<id> prntactids = new set<id>();
        set<id> acctrltnids = new set<id>();
        list<Account_Relationship__c> acctreltndata = new list<Account_Relationship__c>();
        
        for(Account_Relationship__c acctrelloop : NewMap.values()){
            if(acctrelloop.Billing_Contact__c != oldmap.get(acctrelloop.id).Billing_Contact__c &&
               acctrelloop.Billing_Contact__c == true){
               prntactids.add(acctrelloop.Parent_account__c);
               acctrltnids.add(acctrelloop.id);    
            }
        }
        
        acctreltndata = [select parent_Account__c,Billing_Contact__c,Active__c 
                         from Account_Relationship__c where parent_Account__c in :prntactids
                         and Billing_Contact__c = true and Active__c = true and id not in :acctrltnids];
        
        for(Account_Relationship__c acctreltnloop : acctreltndata){
            acctreltnloop.Billing_Contact__c = false;
        }
        system.debug('acctreltndata:'+acctreltndata);
        if(acctreltndata.size() > 0){
            update acctreltndata;
        }
    }   
}