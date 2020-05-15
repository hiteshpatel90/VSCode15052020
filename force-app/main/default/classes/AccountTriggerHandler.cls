/**
* @author Original: Srinivas Sattoor Cloud Sherpas, Last Modified:  
* @date Original: 04 Mar 2016, Last Modified:
* @description: This class is a handler class for Account logic
*/

public with sharing class AccountTriggerHandler {
    
    AccountTriggerHelper helper = new AccountTriggerHelper();
    
    
    public void onBeforeInsert(list<Account> lstNewAccounts){
        
        // setting default owner when creating any new accounts
        
        if(userInfo.getUserName() != Pardot_Integration_User__c.getOrgDefaults().User_Name__c){
            
            DefaultModelFacade.setDefaultOwner(lstNewAccounts);
            
        }
        
          
       
        
        // formating names, as the names are coming as all caps from SAP
        // Might need in a later release
        //helper.nameFormat(lstNewAccounts);
        
   //Release 2.2 /CID - 000063/Swetha P/Dec/9/2016/Global Customer ID 
        
         //Release 4.0/CID - CID-000319/Swetha P/Jun 16/2017/LeadsApp - Renaming Account Record Types   
        list<Account> lstNewAccount = new list<Account>();
        Id practitionerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_PRACTITIONER).getRecordTypeId();
        Id undefinedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_UNDEFINED).getRecordTypeId();        
        Id nonPractitionerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_SURGEON_CONTACT).getRecordTypeId();
         //Release 4.0/CID - CID-000319/Swetha P/Jun 16/2017/LeadsApp - Renaming Account Record Types  
        list<Account> lstNewPersonAccount = new list<Account>();
        for(Account objAccount :lstNewAccounts){
            
            //if(objAccount.isPersonAccount){
                lstNewPersonAccount.add(objAccount);
            //}
              //Release 4.0/CID - CID-000315/Swetha P/Jun 23/2017/LeadsApp - Global ID/Constant Class
            if(objAccount.RecordtypeId == practitionerRecordTypeId || objAccount.RecordtypeId == undefinedRecordTypeId || objAccount.RecordtypeId == nonPractitionerRecordTypeId){
                lstNewAccount.add(objAccount);
            }
        }
         //Release 4.0/CID - CID-000315/Swetha P/Jun 23/2017/LeadsApp - Global ID/Constant Class
        
        if(lstNewPersonAccount.size() > 0){
            
            helper.duplicateEmailCheck(lstNewAccounts);
            
        }
         //Release 4.0/CID - CID-000315/Swetha P/Jun 22/2017/LeadsApp - Global ID/Constant Class
        if(lstNewAccount.size() > 0){            
            helper.populateGlobalCustomerId(lstNewAccount);
        }
         //Release 4.0/CID - CID-000315/Swetha P/Jun 22/2017/LeadsApp - Global ID/Constant Class
        
    }// end of onBeforeInsert
    
    //Release 2.2 /CID - 000063/Swetha P/Dec/9/2016/Global Customer ID
    
        //Release 4.0/CID - CID-000319/Swetha P/Jun 15/2017/LeadsApp - Renaming Account Record Types  
    public void onBeforeUpdate(list<Account> lstNewAccounts, map<Id, Account> mapOldAccounts){
        list<Account> lstNewAccount = new list<Account>();
        Id practitionerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_PRACTITIONER).getRecordTypeId();        
        Id undefinedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_UNDEFINED).getRecordTypeId();        
        Id nonPractitionerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_SURGEON_CONTACT).getRecordTypeId();
        //Release 4.0/CID - CID-000319/Swetha P/Jun 15/2017/LeadsApp - Renaming Account Record Types  
        list<Account> listDuplicateEmailCheckAccounts = new list<Account>();
        // formating names, as the names are coming as all caps from SAP
        // Might need in a later release
        //helper.nameFormat(lstNewAccounts);
        
        for(Account objAccount : lstNewAccounts){
            //if(objAccount.isPersonAccount && objAccount.PersonEmail != mapOldAccounts.get(objAccount.Id).PersonEmail){
                    
                listDuplicateEmailCheckAccounts.add(objAccount);
                
            //}
              //Release 4.0/CID - CID-000315/Swetha P/Jun 22/2017/LeadsApp - Global ID/Constant Class

            if(objAccount.RecordTypeId != null && objAccount.RecordTypeId != mapOldAccounts.get(objAccount.Id).RecordTypeId && (objAccount.RecordtypeId == practitionerRecordTypeId || objAccount.RecordtypeId == undefinedRecordTypeId || objAccount.RecordtypeId == nonPractitionerRecordTypeId)){   
                lstNewAccount.add(objAccount);
                //Release 4.0/CID - CID-000315/Swetha P/Jun 22/2017/LeadsApp - Global ID/Constant Class

            }
            //Release 2.2 /CID - 000063/Swetha P/Dec/9/2016/Global Customer ID
            
        }//end of for-each
        
        if(listDuplicateEmailCheckAccounts.size() > 0){            
            helper.duplicateEmailCheck(listDuplicateEmailCheckAccounts);            
        }
          //Release 4.0/CID - CID-000315/Swetha P/Jun 22/2017/LeadsApp - Global ID/Constant Class

        if(lstNewAccount.size() > 0){            
            helper.populateGlobalCustomerIdOnRecTypeChange(lstNewAccount);
        }
          //Release 4.0/CID - CID-000315/Swetha P/Jun 22/2017/LeadsApp - Global ID/Constant Class

        
    }// end of onBeforeUpdate
    
    public void onAfterInsert(list<Account> lstNewAccounts){
        
        //helper.logPersonAccountChange(lstNewAccounts);
        helper.populateTerritoryAssignmentOnInsert(lstNewAccounts);
        if(ClsStaticVariables.DoNotProcessPractitionerGeoCodeCalculation == false){
            helper.popultateGeoCodeonPersonAccounts(lstNewAccounts);
        }
            
        
        // END of code from CS_Geocode.trigger
        
    }// end of onafterInsert
    
    public void onAfterUpdate(list<Account> lstNewAccounts, map<Id, Account> mapOldAccounts){
        
        //helper.logPersonAccountChangeonEmailChange(lstNewAccounts, mapOldAccounts);
        helper.populateTerritoryAssignmentOnUpdate(lstNewAccounts, mapOldAccounts);
        helper.removeTerritoryAssignmentsOnInactive(lstNewAccounts, mapOldAccounts);
        if(ClsStaticVariables.DoNotProcessPractitionerGeoCodeCalculation == false){
            helper.popultateGeoCodeonPersonAccounts(lstNewAccounts, mapOldAccounts);
        } 
        
        /**     
        * @author Original: Ansu Routray, Last Modified:        
        * @date Original: 29 June 2017, Last Modified: NA       
        * @release: 4.1     
        * @component: CID-000297        
        * @description: Below line creates/updates an email matrix record when email field is updated on account        
        */      
        helper.updatePrimaryEmailMatrixRecord(lstNewAccounts,mapOldAccounts);
        // END of code from CS_Geocode.trigger 
        
    }// end of onAfterUpdate
    
    /*public void onBeforeDelete(list<Account> lstOldAccounts){
        
        //helper.logPersonAccountChange(lstOldAccounts);
        
    }*/ // end of onbeforeDelete
    
    /*public void onAfterUndelete(list<Account> lstOldAccounts){
        
        //helper.logPersonAccountChange(lstOldAccounts);
        
    }*/ // end of onafterInsert

}