/**
* @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  
* @date Original: 04 Mar 2016, Last Modified: NA
* @description: This class is a helper class for Account logic
*/
public with sharing class AccountTriggerHelper {
    
     /**
    * @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  NA
    * @date Original: 04 Mar 2016, Last Modified: NA
    * @description: Given a list of accounts, this method checks if there
    * is a practitioner with same email and adds an error if true.
    */
    public void duplicateEmailCheck(list<Account> lstAccounts){
        
        /*set<string> setEmails = new set<string> ();
        set<string> setExistingEmails = new set<string> ();
        
        for(Account objAccount :lstAccounts){
            
            if(objAccount.isPersonAccount && objAccount.PersonEmail != null){                
                setEmails.add(objAccount.PersonEmail);                
            }
            
        }
        
        if(setEmails.size() == 0){
            
            return;
            
        }
            
        for(Account existingAccount : [SELECT Id, PersonEmail FROM Account WHERE PersonEmail IN:setEmails]){
        
            setExistingEmails.add(existingAccount.PersonEmail);
        
        }// end of for-each existing Account
    
            
        if(setExistingEmails.size() == 0 ){
            
            return;
        
        }
            
        for(Account objAccount :lstAccounts){
        
            if(setExistingEmails.contains(objAccount.PersonEmail)){
                
                 objAccount.PersonEmail.addError('A practitioner with this email '
                               + 'address already exists.');
                
            }
        
        }// end of for-each objAccount*/
        
    }// end of duplicateEmailCheck
    
     /**
    * @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  NA
    * @date Original: 04 Mar 2016, Last Modified: NA
    * @description: Given a list of accounts being inserted,
    * this method populates account territory association when the assigned agency is populated.
    */
    public void populateTerritoryAssignmentOnInsert(list<Account> lstNewAccounts){
        /*list<Account> lstTerritoryAssignmentAccounts = new list<Account>();
        set<string> setAssignedAgencies = new set<string> ();
        set<string> setAssignedTeams = new set<string> ();
        
        for(Account objAccount :lstNewAccounts){
            

              if(objAccount.isPersonAccount
                && objAccount.AXIS_Assigned_Agency_Team__pc != ''
                && objAccount.AXIS_Assigned_Agency_Team__pc != null){  
                    
                    string[] lstAssignedAgencyAndTeams =  objAccount.AXIS_Assigned_Agency_Team__pc.split(';');
                    system.debug('##--populateTerritoryAssignmentOnInsert.lstAssignedAgencyAndTeams: '+ lstAssignedAgencyAndTeams);
                    for(string assignedAgencyAndTeamString :lstAssignedAgencyAndTeams){
                        
                        string[] assignedAgencyAndTeam = assignedAgencyAndTeamString.split('_');
                        system.debug('##--populateTerritoryAssignmentOnInsert.assignedAgencyAndTeam: '+ assignedAgencyAndTeam);
                        setAssignedAgencies.add(assignedAgencyAndTeam[0]);
                        setAssignedTeams.add(assignedAgencyAndTeam[1]);
                    }
                    
                    lstTerritoryAssignmentAccounts.add(objAccount);
                    //setAssignedAgencies.add(objAccount.Assigned_Agency__pc);
                    //setAssignedTeams.add(objAccount.Assigned_Team__pc);
                    
            }
            
        }// end of for-each 
        
        if(setAssignedAgencies.size() > 0){
            
            populateTerritoryAssignment(lstTerritoryAssignmentAccounts,
                                        setAssignedAgencies,
                                        setAssignedTeams);
            
        }*/
    }// end of populateTerritoryAssignmentOnInsert
    
     /**
    * @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  NA
    * @date Original: 04 Mar 2016, Last Modified: NA
    * @description: Given a list of accounts being updated and map of old accounts,
    * this method populates account territory association when the assigned agency is changed.
    */
    public void populateTerritoryAssignmentOnUpdate(list<Account> lstNewAccounts, map<Id, Account> mapOldAccounts){
        /*list<Account> lstTerritoryAssignmentAccounts = new list<Account>();
        set<string> setAssignedAgencies = new set<string> ();
        set<string> setAssignedTeams = new set<string>();
        list<Account> listShipToAccounts = new list<Account>();
        map<string, string> mapAssignedTeamAssignedAgency = new map<String, string>();
        
        for(Account objAccount :lstNewAccounts){
            
            if(objAccount.isPersonAccount
                && objAccount.AXIS_Assigned_Agency_Team__pc != ''
                && objAccount.AXIS_Assigned_Agency_Team__pc != null
                && (objAccount.AXIS_Assigned_Agency_Team__pc != mapOldAccounts.get(objAccount.Id).AXIS_Assigned_Agency_Team__pc)){   
                     
                    string[] lstAssignedAgencyAndTeams =  objAccount.AXIS_Assigned_Agency_Team__pc.split(';');
                    system.debug('##--populateTerritoryAssignmentOnInsert.lstAssignedAgencyAndTeams: '+ lstAssignedAgencyAndTeams);
                    for(string assignedAgencyAndTeamString :lstAssignedAgencyAndTeams){
                        
                        string[] assignedAgencyAndTeam = assignedAgencyAndTeamString.split('_');
                        system.debug('##--populateTerritoryAssignmentOnInsert.assignedAgencyAndTeam: '+ assignedAgencyAndTeam);
                        setAssignedAgencies.add(assignedAgencyAndTeam[0]);
                        if(assignedAgencyAndTeam[1] != null){
                            setAssignedTeams.add(assignedAgencyAndTeam[1]);
                        }
                    }
                    
                          
                    lstTerritoryAssignmentAccounts.add(objAccount);
                    //setAssignedAgencies.add(objAccount.Assigned_Agency__pc);
                    //setAssignedTeams.add(objAccount.Assigned_Team__pc);
            }else if(objAccount.isPersonAccount == false
                && objAccount.ParentId != null
                && objAccount.ParentId != mapOldAccounts.get(objAccount.Id).ParentId
                && objAccount.Account_Group__c == 'Z002'){
                    
                    listShipToAccounts.add(objAccount);
                
            }
            
        }// end of for-each 
        
        system.debug('##--populateTerritoryAssignmentOnUpdate.setAssignedAgencies:'+ setAssignedAgencies + 'Size: '+ setAssignedAgencies.size());
        if(setAssignedAgencies.size() > 0){
        system.debug('##--populateTerritoryAssignmentOnUpdate.setAssignedAgencies2:'+ setAssignedAgencies + 'Size: '+ setAssignedAgencies.size());
            populateTerritoryAssignment(lstTerritoryAssignmentAccounts,
                                        setAssignedAgencies,
                                        setAssignedTeams);
            
        }
        
        if(listShipToAccounts.size() > 0){
            
            populateTerritoryAssignmentsOnShipToUsingSoldTo(listShipToAccounts);
            
        }*/
    }// end of populateTerritoryAssignmentOnUpdate
    @Testvisible
    private void populateTerritoryAssignmentsOnShipToUsingSoldTo(list<Account> listShipToAccounts){
        
        map<Id, list<ObjectTerritory2Association>> mapAccountIdAndTerritoryAssociations = new map<Id, list<ObjectTerritory2Association>>();
        map<Id, list<ObjectTerritory2Association>> mapBillToAccountIdAndTerritoryAssociations = new map<Id, list<ObjectTerritory2Association>>();
        
        set<Id> setParentAccountIds = new set<Id>();
        list<Account> lstShipToAccountsNeedingTerritoryAssignment = new list<Account>();
        for(ObjectTerritory2Association territoryAssignment : [SELECT Id, ObjectId, Territory2Id 
                                                                            FROM ObjectTerritory2Association
                                                                           WHERE objectId IN :listShipToAccounts
                                                                           AND AssociationCause = :Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL]){
            
            if(mapAccountIdAndTerritoryAssociations.get(territoryAssignment.ObjectId) == null){
                mapAccountIdAndTerritoryAssociations.put(territoryAssignment.ObjectId, new list<ObjectTerritory2Association>());
            }   
            mapAccountIdAndTerritoryAssociations.get(territoryAssignment.ObjectId).add(territoryAssignment);                                                    
        }
        for(Account objShipToAccount :[SELECT Id, ParentId 
                                                FROM Account WHERE Id IN:listShipToAccounts]){
            
            if(!mapAccountIdAndTerritoryAssociations.keySet().contains(objShipToAccount.Id)){
                setParentAccountIds.add(objShipToAccount.ParentId);
                lstShipToAccountsNeedingTerritoryAssignment.add(objShipToAccount);
            }
        }// end of for-each
        
        if(setParentAccountIds.size() == 0 ){
            return;
        }
        mapBillToAccountIdAndTerritoryAssociations = returnBillToTerritoryAssignments(setParentAccountIds);
        
        if(mapBillToAccountIdAndTerritoryAssociations.keySet().size() == 0){
            return;
        }
        populateShipToTerritoryAssignments(lstShipToAccountsNeedingTerritoryAssignment, mapBillToAccountIdAndTerritoryAssociations);
        
    }// end of populateTerritoryAssignmentsOnShipToUsingSoldTo
    
    private map<Id, list<ObjectTerritory2Association>>  returnBillToTerritoryAssignments(set<Id>setParentAccountIds){
        
        map<Id, list<ObjectTerritory2Association>> mapBillToAccountIdAndTerritoryAssociations = new map<Id, list<ObjectTerritory2Association>>();
        for(ObjectTerritory2Association territoryAssignment : [SELECT Id, ObjectId, Territory2Id 
                                                                            FROM ObjectTerritory2Association 
                                                                            WHERE objectId IN :setParentAccountIds
                                                                            AND AssociationCause = :Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL]){
            
            if(mapBillToAccountIdAndTerritoryAssociations.get(territoryAssignment.ObjectId) == null){
                mapBillToAccountIdAndTerritoryAssociations.put(territoryAssignment.ObjectId, new list<ObjectTerritory2Association>());
            }   
            mapBillToAccountIdAndTerritoryAssociations.get(territoryAssignment.ObjectId).add(territoryAssignment);                                                  
        }
        
        return mapBillToAccountIdAndTerritoryAssociations;
    }// end of returnBillToTerritoryAssignments
    
    private void populateShipToTerritoryAssignments(list<Account>lstShipToAccountsNeedingTerritoryAssignment,
                                                    map<Id, list<ObjectTerritory2Association>>mapBillToAccountIdAndTerritoryAssociations){
        list<ObjectTerritory2Association> lstObjectTerritory2Associations = new list<ObjectTerritory2Association>();
        for(Account objAccount :lstShipToAccountsNeedingTerritoryAssignment){
            
            if(mapBillToAccountIdAndTerritoryAssociations.get(objAccount.ParentId) == null
                || mapBillToAccountIdAndTerritoryAssociations.get(objAccount.ParentId).size() == 0){
                continue;
            }
            for(ObjectTerritory2Association billToTerritoryAssociation : mapBillToAccountIdAndTerritoryAssociations.get(objAccount.ParentId)){
                
                ObjectTerritory2Association ObjTerritory2Association = new ObjectTerritory2Association(AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL,
                                                                                        ObjectId = objAccount.Id,
                                                                                        Territory2Id = billToTerritoryAssociation.territory2Id
                                                                                        );
                lstObjectTerritory2Associations.add(ObjTerritory2Association);
            }// end of inner for-each
        }// end of outer for-each
        
        if(lstObjectTerritory2Associations.size() > 0){
            insert lstObjectTerritory2Associations;
        }
        
    }// end of populateShipToTerritoryAssignments
    
     /**
    * @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  NA
    * @date Original: 04 Mar 2016, Last Modified: NA
    * @description: Given a set of agency strings, this method returns the
    * the map containing agency name and the corresponding territory2Id.
    */
    /*public void populateTerritoryAssignment(list<Account> lstTerritoryAssignmentAccounts, 
                                            set<string> setAssignedAgencies,
                                            set<string> setAssignedTeams){
        
        map<string, Id> mapAssignedAgencyTerritoryId = new map<string, Id>();
        list<ObjectTerritory2Association> lstAccountTerritory2Associations = new list<ObjectTerritory2Association>();
        system.debug('##--setAssignedAgencies: '+ setAssignedAgencies);
        //returns map of agency name and the corresponding territory id.
        mapAssignedAgencyTerritoryId =  returnMapAssignedAgencyTerritoryId(setAssignedAgencies,
                                                                           setAssignedTeams);
        system.debug('##--mapAssignedAgencyTerritoryId: '+ mapAssignedAgencyTerritoryId);
        if(mapAssignedAgencyTerritoryId.keyset().size() == 0){
            return;
        }
        lstAccountTerritory2Associations = returnAccountTerritory2Associations(lstTerritoryAssignmentAccounts,
                                                                                mapAssignedAgencyTerritoryId,
                                                                                existingAccountTerritory2Associations(lstTerritoryAssignmentAccounts));
        
        system.debug('##--lstAccountTerritory2Associations: '+ lstAccountTerritory2Associations);
        if(lstAccountTerritory2Associations.size() > 0){
            
            insert lstAccountTerritory2Associations;
        
        } 
        
    }// end of populateTerritoryAssignment*/
    
     /**
    * @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  NA
    * @date Original: 04 Mar 2016, Last Modified: NA
    * @description: Given a set of agency strings, this method returns the
    * the map containing agency name and the corresponding territory2Id.
    */
    private map<string, Id>  returnMapAssignedAgencyTerritoryId(set<string> setAssignedAgencies,
                                                                set<string> setAssignedTeams){
        
        system.debug('##--returnMapAssignedAgencyTerritoryId.setAssignedAgencies: '+ setAssignedAgencies);
        system.debug('##--returnMapAssignedAgencyTerritoryId.setAssignedTeams: '+ setAssignedTeams);
        map<string, Id> mapAssignedAgencyTerritoryId = new map<string, Id>();
        for(Territory2 objTerritory : [SELECT Id, Name, ParentTerritory2Id, ParentTerritory2.Name 
                                                    FROM Territory2 
                                                    WHERE ((Name IN: setAssignedTeams
                                                        AND ParentTerritory2.Name  IN: setAssignedAgencies)
                                                    OR NAME =:Constant.TERRITORY_ARTHREX_APAC)]){
            string uniqueName;
            if(objTerritory.Name == Constant.TERRITORY_ARTHREX_APAC){
                uniqueName = objTerritory.Name.toLowerCase();
            }else{
                uniqueName = (objTerritory.ParentTerritory2.Name + '_' + objTerritory.Name ).toLowerCase();
            }
            system.debug('##--returnMapAssignedAgencyTerritoryId.uniqueName: '+ uniqueName);
            mapAssignedAgencyTerritoryId.put(uniqueName, objTerritory.Id);
            
        }
        
        return mapAssignedAgencyTerritoryId;
    }//end of returnMapAssignedAgencyTerritoryId
    
      /**
    * @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  NA
    * @date Original: 04 Mar 2016, Last Modified: NA
    * @description: Given a list of accounts, map of agency name and corresponding
    * territory2Id and set of string containing concatenated accountids and territory2Ids,
    * this method returns a list of account to territory2 associations.
    */
    /*private list<ObjectTerritory2Association> returnAccountTerritory2Associations(list<Account> lstTerritoryAssignmentAccounts, 
                                                                                    map<string, Id> mapAssignedAgencyTerritoryId,
                                                                                    set<string> existingAccountTerritory2Associations){
                                                                                       
        list<ObjectTerritory2Association> lstAccountTerritory2Associations = new list<ObjectTerritory2Association>();
        list<ObjectTerritory2Association> lstAccountTerritory2AssociationsToBeDeleted = new list<ObjectTerritory2Association>();
        set<string> setExistingTerritoriesToNotDelete;
        string  accountTerritory2AssociationString = '';
        map<Id, list<ObjectTerritory2Association>> mapAccountIdAndlistExistingTerritoryAssociations = new map<Id, list<ObjectTerritory2Association>>();
        
        for(ObjectTerritory2Association territoryAssignment : [SELECT Id, ObjectId, Territory2Id 
                                                                            FROM ObjectTerritory2Association 
                                                                            WHERE objectId IN :lstTerritoryAssignmentAccounts
                                                                            AND AssociationCause = :Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL]){  
            
            if(mapAccountIdAndlistExistingTerritoryAssociations.get(territoryAssignment.ObjectId) == null){
                mapAccountIdAndlistExistingTerritoryAssociations.put(territoryAssignment.ObjectId, new list<ObjectTerritory2Association>());
            }   
            mapAccountIdAndlistExistingTerritoryAssociations.get(territoryAssignment.ObjectId).add(territoryAssignment);
                                                             
        }// end of for-each
        
        system.debug('##--returnAccountTerritory2Associations.lstTerritoryAssignmentAccounts: '+ lstTerritoryAssignmentAccounts);
        for(Account objAccount :lstTerritoryAssignmentAccounts){
            
            string[] lstAssignedAgencyAndTeams;
            setExistingTerritoriesToNotDelete = new set<string>();
            string uniqueString;
            if(objAccount.AXIS_Assigned_Agency_Team__pc == Constant.TERRITORY_ARTHREX){
                uniqueString = (objAccount.AXIS_Assigned_Agency_Team__pc).toLowerCase();
                lstAssignedAgencyAndTeams.add(uniqueString);
            }else{
               // uniqueString = (objAccount.Assigned_Team__pc +'_'+objAccount.Assigned_Agency__pc).tolowerCase();
                lstAssignedAgencyAndTeams =  objAccount.AXIS_Assigned_Agency_Team__pc.split(';');
                
            }
            system.debug('##--returnAccountTerritory2Associations.lstAssignedAgencyAndTeams: '+ lstAssignedAgencyAndTeams);
            
            for(string objUniqueString : lstAssignedAgencyAndTeams){
                uniqueString = objUniqueString.toLowerCase();
                system.debug('##--returnAccountTerritory2Associations.objUniqueString: '+ uniqueString);
                if( mapAssignedAgencyTerritoryId.get(uniqueString) == null){
                    continue;
                }
                system.debug('##--mapAssignedAgencyTerritoryId.get(uniqueString): '+ mapAssignedAgencyTerritoryId.get(uniqueString));
                accountTerritory2AssociationString = objAccount.Id+'_'+mapAssignedAgencyTerritoryId.get(uniqueString);
                if(existingAccountTerritory2Associations.contains(accountTerritory2AssociationString)){
                    setExistingTerritoriesToNotDelete.add(mapAssignedAgencyTerritoryId.get(uniqueString));
                    continue;
                }
                system.debug('##--mapAssignedAgencyTerritoryId.get(uniqueString): '+ mapAssignedAgencyTerritoryId.get(uniqueString));
                ObjectTerritory2Association accountTerritory2Association = new ObjectTerritory2Association(
                                                                                        ObjectId = objAccount.Id,
                                                                                        AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL,
                                                                                        Territory2Id = mapAssignedAgencyTerritoryId.get(uniqueString));
                lstAccountTerritory2Associations.add(accountTerritory2Association);
            
           }// end of inner for-each
           
           // delete existing association if not needed.
        
        }// end of for-each
        
        return lstAccountTerritory2Associations;
        
    }// end of returnAccountTerritory2Associations*/
    
     /**
    * @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  NA
    * @date Original: 04 Mar 2016, Last Modified: NA
    * @description: Given a list of accounts, this method queries the existing 
    * territory 2 and account associations, and returns the set of concatenated 
    * accountid and territory2ids
    */
    private set<string> existingAccountTerritory2Associations(list<Account> lstAccounts){
        
        set<string> setAccountTerritory2Associations = new set<string>();
        for(ObjectTerritory2Association acctTerriroty2Association :[SELECT Id,ObjectId, Territory2Id 
                                                                        FROM ObjectTerritory2Association 
                                                                        WHERE ObjectId IN :lstAccounts ]){
            setAccountTerritory2Associations.add(acctTerriroty2Association.ObjectId+'_'+acctTerriroty2Association.Territory2Id);
        }
        
        return setAccountTerritory2Associations;
        
    }// end of existingAccountTerritory2Associations
    
     /**
    * @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  NA
    * @date Original: 18 Nov 2016, Last Modified: NA
    * @description: Given a list of accounts, this method checks if the account
    * was inactivated and removes any territory assignments associated with it.
    */
    public void removeTerritoryAssignmentsOnInactive(list<Account> lstNewAccounts, map<Id, Account> mapOldAccounts){
        
        /*set<Account> setDeactivatedAccounts = new set<Account>();
        list<ObjectTerritory2Association> setTerritoryAssociationToBeRemoved = new list<ObjectTerritory2Association>();
        for(Account objAccount :lstNewAccounts){
            
            if(objAccount.Active__c == false
                && mapOldAccounts.get(objAccount.Id).Active__c == true
                && objAccount.isPersonAccount == false){
                
                setDeactivatedAccounts.add(objAccount);        
            }
            
        }// end of for-each
        
        if(setDeactivatedAccounts.size() == 0){
            
            return;
        }
        
        for(ObjectTerritory2Association objExAssociation :[SELECT Id, ObjectId, Territory2Id 
                                                            FROM ObjectTerritory2Association
                                                            WHERE ObjectId IN :setDeactivatedAccounts
                                                            AND AssociationCause = :Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL]){
                                                                
            setTerritoryAssociationToBeRemoved.add(objExAssociation);
        
        }// end of for-each
        
        if(setTerritoryAssociationToBeRemoved.size() > 0){
            delete setTerritoryAssociationToBeRemoved;
        }*/
        
        
    }// end of removeTerritoryAssignmentsOnInactive
    
    /*
    Will need it in a later release
    
    */
   /*   public void nameFormat(list<Account> lstAccounts){
        
        for(Account objAccount :lstAccounts){
            
            if(objAccount.isPersonAccount){
                
                system.debug('##--nameFormat:'+ nameFormat(objAccount.FirstName));
                objAccount.FirstName = nameFormat(objAccount.FirstName);
                objAccount.LastName = nameFormat(objAccount.LastName);
            }else{
                objAccount.Name =nameFormat(objAccount.Name);
            }
        }
    }
    
    public String nameFormat (String name) {
            String result = '';
            if (name != null && name != '') {
                for (String iter : name.split('[ ]+')) {
                     if (iter != null && iter != '') { 
                         if (iter.length() > 1) { 
                            result += iter.substring(0,1).toUpperCase() + iter.substring(1,iter.length()) + ' ';
                    } else { 
                         result += iter.substring(0,1).toUpperCase() + ' ';
                    } 
                } 
            }
        result = result.substring(0, result.length() - 1);
        } 
        return result;
    }// end of nameFormat
    
     <!--Release 2.2 /CID - 000063/Swetha P/Dec/9/2016/Validation on phone number field-->
    */
   
    /**
    * This method used to increment Global Customer Id
    */
    public void populateGlobalCustomerId(list<Account> lstAccounts){
        // Practitioner = GI # starts with 5 -- START
        List<Account> accList = [SELECT id, Global_Customer_ID__c from Account where Global_Customer_ID__c != null and Recordtype.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER order by Global_Customer_ID__c DESC LIMIT 1];
        Decimal intLatestPractitionerGlobalCustomerID = 500000000;
        if(!accList.isEmpty()){
            intLatestPractitionerGlobalCustomerID = decimal.valueOf(accList[0].Global_Customer_ID__c);            
        } 
        Id practitionerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_PRACTITIONER).getRecordTypeId(); 
        for(Account acc: lstAccounts){
            intLatestPractitionerGlobalCustomerID++;
            if(intLatestPractitionerGlobalCustomerID >= 500000000 && intLatestPractitionerGlobalCustomerID  < 700000000 && acc.RecordtypeId== practitionerRecordTypeId){
                acc.Global_Customer_ID__c = string.valueOf(intLatestPractitionerGlobalCustomerID);
            }
        }       
        // Practitioner = GI # starts with 5 -- END
        
        // Non-Practitioner = GI # starts with 7 -- START
        Decimal intLatestNonPractitionerGlobalCustomerID = 700000000;
        List<Account> accListNonPractitioner = [SELECT id, Global_Customer_ID__c from Account where Global_Customer_ID__c != null  and Recordtype.Name =: Constant.RECORDTYPE_NAME_SURGEON_CONTACT order by Global_Customer_ID__c DESC LIMIT 1];
        if(!accListNonPractitioner.isEmpty()){
             intLatestNonPractitionerGlobalCustomerID = decimal.valueOf(accListNonPractitioner[0].Global_Customer_ID__c);    
        }
        Id nonPractitionerRecordTypeId;// = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_NONE_PRACTITIONER).getRecordTypeId();
        for(Account acc: lstAccounts){
            intLatestNonPractitionerGlobalCustomerID++;            
            if(intLatestNonPractitionerGlobalCustomerID >= 700000000 && intLatestNonPractitionerGlobalCustomerID < 900000000 && acc.RecordtypeId == nonPractitionerRecordTypeId){
                acc.Global_Customer_ID__c = string.valueOf(intLatestNonPractitionerGlobalCustomerID);
            }
        }        
        // Non-Practitioner = GI # starts with 7 -- END
        
        
        // Undefined = GI # starts with 9 -- START
        List<Account> accListUndefined = [SELECT id, Global_Customer_ID__c from Account where Global_Customer_ID__c != null and Recordtype.Name =: Constant.RECORDTYPE_NAME_UNDEFINED order by Global_Customer_ID__c DESC LIMIT 1];
        Decimal intLatestUndefinedGlobalCustomerID = 900000000;
        if(!accListUndefined.isEmpty()){            
            intLatestUndefinedGlobalCustomerID = decimal.valueOf(accListUndefined[0].Global_Customer_ID__c);     
        }
        Id undefinedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_UNDEFINED).getRecordTypeId();       
        for(Account acc: lstAccounts){
            
            intLatestUndefinedGlobalCustomerID++;
            if(intLatestUndefinedGlobalCustomerID >= 900000000 && acc.RecordtypeId == undefinedRecordTypeId){
                acc.Global_Customer_ID__c = string.valueOf(intLatestUndefinedGlobalCustomerID);
            }
        }       
        // Undefined = GI # starts with 9 -- END
    }
    
    /**
    * This method used to increment Global Customer Id
    */
    public void populateGlobalCustomerIdOnRecTypeChange(list<Account> lstAccounts){    
        List<Account> accListPractitioner = [SELECT id, Global_Customer_ID__c from Account where Global_Customer_ID__c != null and Recordtype.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER order by Global_Customer_ID__c DESC LIMIT 1];
        List<Account> accListNonPractitioner = [SELECT id, Global_Customer_ID__c from Account where Global_Customer_ID__c != null  and Recordtype.Name =: Constant.RECORDTYPE_NAME_SURGEON_CONTACT order by Global_Customer_ID__c DESC LIMIT 1];
        List<Account> accListUndefined = [SELECT id, Global_Customer_ID__c from Account where Global_Customer_ID__c != null and Recordtype.Name =: Constant.RECORDTYPE_NAME_UNDEFINED order by Global_Customer_ID__c DESC LIMIT 1];
        
        Id practitionerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_PRACTITIONER).getRecordTypeId();        
        Id nonPractitionerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_SURGEON_CONTACT ).getRecordTypeId();
        Id undefinedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_UNDEFINED).getRecordTypeId();        
                
        Decimal intLatestPractitionerGlobalCustomerID = 500000000;
        if(!accListPractitioner.isEmpty()){
            intLatestPractitionerGlobalCustomerID = decimal.valueOf(accListPractitioner[0].Global_Customer_ID__c);            
        }
        
        Decimal intLatestNonPractitionerGlobalCustomerID = 700000000;
        if(!accListNonPractitioner.isEmpty()){
             intLatestNonPractitionerGlobalCustomerID = decimal.valueOf(accListNonPractitioner[0].Global_Customer_ID__c);    
        }
        
        Decimal intLatestUndefinedGlobalCustomerID = 900000000;
        if(!accListUndefined.isEmpty()){            
            intLatestUndefinedGlobalCustomerID = decimal.valueOf(accListUndefined[0].Global_Customer_ID__c);     
        }
        for(Account acc: lstAccounts){
            if(acc.RecordtypeId == practitionerRecordTypeId){
                intLatestPractitionerGlobalCustomerID++;
                acc.Global_Customer_ID__c = string.valueOf(intLatestPractitionerGlobalCustomerID);
            }else if(acc.RecordtypeId == nonPractitionerRecordTypeId){
                intLatestNonPractitionerGlobalCustomerID++;
                acc.Global_Customer_ID__c = string.valueOf(intLatestNonPractitionerGlobalCustomerID);
            }else if(acc.RecordtypeId == undefinedRecordTypeId){
                intLatestUndefinedGlobalCustomerID++;
                acc.Global_Customer_ID__c = string.valueOf(intLatestUndefinedGlobalCustomerID);
            }
        }
    }
    
    //Release 4.0/CID - CID-000315/Swetha P/Jun 22/2017/LeadsApp - Global ID/Constant Class
    
    /*
    Added by Srinivas Sattoor 03.20.2017
    populate geocode sync for person accounts as this is not available for person accounts yet 
    Release 3.2 make the map show on surgeon detail.
    */
    public void popultateGeoCodeonPersonAccounts(list<Account> lstNewAccounts, map<Id, Account> mapOldAccounts){
        
        /*for(Account objAccount :lstNewAccounts){
            // only interested in person account objects
            if ( objAccount.isPersonAccount ) {
                boolean geocode = false;
                Account oldAccount = mapOldAccounts.get(objAccount.Id);
                String newAddress = objAccount.PersonMailingStreet+' '+objAccount.PersonMailingCity+' '+objAccount.PersonMailingState+' '+objAccount.PersonMailingPostalCode+' '+objAccount.PersonMailingCountryCode;
                String oldAddress = oldAccount.PersonMailingStreet+' '+oldAccount.PersonMailingCity+' '+oldAccount.PersonMailingState+' '+oldAccount.PersonMailingPostalCode+' '+oldAccount.PersonMailingCountryCode;
                if ( !newAddress.equals(oldAddress) || objAccount.Geolocation__Latitude__s == null) {
                    // address has changed or lat lon doesn't exist, geocode
                    geocode = true;
                } 
                if ( geocode ) {
                    // perform the geocding async
                    CS_ARContactsService.geocodeAsync(objAccount.Id, objAccount.PersonMailingStreet, objAccount.PersonMailingCity, objAccount.PersonMailingState, objAccount.PersonMailingPostalCode, objAccount.PersonMailingCountryCode);           
                }
            }
            
        }// end of for-each*/
        
    }// end of popultateGeoCodeonPersonAccounts
    
    /*
    Added by Srinivas Sattoor 03.20.2017
    populate geocode sync for person accounts as this is not available for person accounts yet 
    Release 3.2 make the map show on surgeon detail.
    */
    public void popultateGeoCodeonPersonAccounts(list<Account> lstNewAccounts){
        
        /*for(Account objAccount :lstNewAccounts){
            // only interested in person account objects
            if ( objAccount.isPersonAccount ) { 
                    // perform the geocding async
                CS_ARContactsService.geocodeAsync(objAccount.Id, objAccount.PersonMailingStreet, objAccount.PersonMailingCity, objAccount.PersonMailingState, objAccount.PersonMailingPostalCode, objAccount.PersonMailingCountryCode);           
            }
            
        }// end of for-each*/
        
    }// end of popultateGeoCodeonPersonAccounts
    
    /**
    * @author Original: Ansu Routray, Last Modified:  
    * @date Original: 29 June 2017, Last Modified: NA
    * @release: 4.1
    * @component: CID-000297
    * @description: This method creates an email matrix record when new account with email is created
    */
    public void createPrimaryEmailMatrixRecord(list<Account> lstNewAccounts,map<Id, Account> mapOldAccounts){
        Map<string,Account_Record_Types_for_Email_matrix__c> recTypeMap=Account_Record_Types_for_Email_matrix__c.getAll();
        List<Email_Matrix__c> insertEmailMatrixList=new List<Email_Matrix__c>();
        
        for(Account objAccount :lstNewAccounts){
            if(recTypeMap.keyset().contains(objAccount.RecordTypeId))
            {
                //if(objAccount.PersonEmail!=mapOldAccounts.get(objAccount.Id).PersonEmail && mapOldAccounts.get(objAccount.Id).PersonEmail==null)
                //{
                    Email_Matrix__c EM =new Email_Matrix__c();
                    EM.Type__c='Work';
                    EM.Account__c=objAccount.Id;
                    EM.Active__c=true;
                    //EM.Email__c=objAccount.PersonEmail;
                    EM.Rep_Primary__c=True;
                    insertEmailMatrixList.add(EM);
                //}
            }
            
        }// end of for-each
        System.debug('insertEmailMatrixList=========>'+insertEmailMatrixList);
        
    }// end of createPrimaryEmailMatrixRecord
    
    /**
    * @author Original: Ansu Routray, Last Modified:  
    * @date Original: 29 June 2017, Last Modified: NA
    * @release: 4.1
    * @component: CID-000297
    * @description: This method creates an email matrix record when email field is updated on account
    */
    public void updatePrimaryEmailMatrixRecord(list<Account> lstNewAccounts,map<Id, Account> mapOldAccounts){
        Map<string,Account_Record_Types_for_Email_matrix__c> recTypeMap=Account_Record_Types_for_Email_matrix__c.getAll();
        List<Email_Matrix__c> updateEmailMatrixList=new List<Email_Matrix__c>();
        Map<Id,List<Email_Matrix__c>> accountToEmailMap=new Map<Id,List<Email_Matrix__c>>();
        List<Email_Matrix__c> lstEmailMatrix=new List<Email_Matrix__c>();
        lstEmailMatrix=[Select Rep_Primary__c,Email__c,Account__c,Active__c from Email_Matrix__c where  Account__c in:mapOldAccounts.keySet()];
        List<Email_Matrix__c> insertEmailMatrixList=new List<Email_Matrix__c>();
        for(Email_Matrix__c primaryEM :lstEmailMatrix)
        {
            if(accountToEmailMap.keyset().contains(primaryEM.Account__c)){
               List<Email_Matrix__c> EMlist=new  List<Email_Matrix__c>();
               EMlist=accountToEmailMap.get(primaryEM.Account__c);
               EMlist.add(primaryEM);
               accountToEmailMap.put(primaryEM.Account__c,EMlist);
            }
            else
            {
                List<Email_Matrix__c> EMlist=new  List<Email_Matrix__c>();
                EMlist.add(primaryEM);
                accountToEmailMap.put(primaryEM.Account__c,EMlist);
            }
                
        }
        
        for(Account objAccount :lstNewAccounts){
            System.debug('recTypeMap=========>'+recTypeMap+'objAccount.RecordTypeId=======>'+objAccount.RecordTypeId);
            if(recTypeMap.keyset().contains(String.valueOf(objAccount.RecordTypeId).substring(0,15)))
            {
                //if(objAccount.PersonEmail!=mapOldAccounts.get(objAccount.Id).PersonEmail && mapOldAccounts.get(objAccount.Id).PersonEmail!=null)
                //{
                    Boolean insEmailMatrxflag=true;
                    for(Email_Matrix__c emailMtrx:accountToEmailMap.get(objAccount.Id))
                    {
                        //if(objAccount.PersonEmail!=mapOldAccounts.get(objAccount.Id).PersonEmail && mapOldAccounts.get(objAccount.Id).PersonEmail!=null)
                        //{
                            //if(emailMtrx.Rep_Primary__c== false && emailMtrx.Email__c==objAccount.PersonEmail )
                            //{
                                emailMtrx.Rep_Primary__c=true;
                                emailMtrx.Active__c=true;
                                updateEmailMatrixList.add(emailMtrx);
                                insEmailMatrxflag=false;
                            //}
                            //else if(emailMtrx.Rep_Primary__c== true && emailMtrx.Email__c==objAccount.PersonEmail )
                            //{
                                insEmailMatrxflag=false;
                            //}
                            
                        //}
                    }
                    if(insEmailMatrxflag==true)
                    {
                        Email_Matrix__c EM =new Email_Matrix__c();
                        EM.Type__c='Work';
                        EM.Account__c=objAccount.Id;
                        EM.Active__c=true;
                        //EM.Email__c=objAccount.PersonEmail;
                        EM.Rep_Primary__c=True;
                        insertEmailMatrixList.add(EM);
                    }
                //}
                //else if(objAccount.PersonEmail!=mapOldAccounts.get(objAccount.Id).PersonEmail && mapOldAccounts.get(objAccount.Id).PersonEmail==null)
                //{
                    Email_Matrix__c EM =new Email_Matrix__c();
                    EM.Type__c='Work';
                    EM.Account__c=objAccount.Id;
                    EM.Active__c=true;
                    //EM.Email__c=objAccount.PersonEmail;
                    EM.Rep_Primary__c=True;
                    insertEmailMatrixList.add(EM);
                //}
            }
         }// end of for-each
        System.debug('insertEmailMatrixList=====>'+insertEmailMatrixList);
        System.debug('updateEmailMatrixList=====>'+updateEmailMatrixList);
        insert insertEmailMatrixList;
        update updateEmailMatrixList;            
        
    }// end of updatePrimaryEmailMatrixRecord
    

}