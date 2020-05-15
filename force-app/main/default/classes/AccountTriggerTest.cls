/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AccountTriggerTest {
    
    private static Account practitionerAccount1;
    private static Account practitionerAccount2;
    private static Account HCPAccount;
    private static User adminUser;
    private static User portalUser;
    private static Account practitioner;
    private static Account agencyAccount;
    private static Account healthCareProviderAccount;
    private static Contact portalUserContact;
    private static Contact providerContact;
    
    @testSetup static void testData_Create(){        
        
        adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin123@arthrex.com', 'testadmin123');
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        adminUser.UserRoleId = portalRole.Id;
        insert adminUser;
        
        system.runas(adminUser){
            DataFactoryCustomSetting.createCustomSettings();
            
            DataFactoryTerritory.setUpTerritoryForTestClasses();
            
            Territory2 objTerritory = [SELECT Id FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1'];
            agencyAccount = DataFactoryAccount.createAgencyAccount('Test Agency Account');
            agencyAccount.Ownerid = adminUser.id;
            insert agencyAccount;
            
            healthCareProviderAccount = DataFactoryAccount.createHealthCareProviderAccount();
            healthCareProviderAccount.Account_group__c = 'Z002';
            insert healthCareProviderAccount;
            
            ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = healthCareProviderAccount.Id,
                                                                                    Territory2Id = objTerritory.Id,
                                                                                    AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);
            insert objAssoc;
            
            portalUserContact = DataFactoryContact.createContacts('PortalContact');
            portalUserContact.AccountId = agencyAccount.Id;
            insert portalUserContact;
            
            providerContact = DataFactoryContact.createContacts('providerContact');
            //providerContact.AccountId = agencyAccount.Id;
            providerContact.AccountId = healthCareProviderAccount.Id;
            insert providerContact;
            
            portalUser = DataFactoryUser.preparePortalUser();
            portalUser.customer_number__c = 'ArthTest001';
            portalUser.ContactId = portalUserContact.Id;
            insert portalUser;
            
            UserTerritory2Association objTerrAssoc = new UserTerritory2Association(UserId = portalUser.Id,
                                                                                   Territory2Id = objTerritory.Id);
            insert objTerrAssoc;
            
            practitioner = DataFactoryAccount.createPractitionerAccount();
            insert practitioner;
            
            List<Recordtype> lstRecType = [SELECT id, Name FROM recordtype WHERE sObjectType = 'Account'];
            List<Account_Record_Types_for_Email_matrix__c> lstARTEM = new List<Account_Record_Types_for_Email_matrix__c>();
            Account_Record_Types_for_Email_matrix__c objARTEM;
            for(Recordtype recType: lstRecType){
                objARTEM = new Account_Record_Types_for_Email_matrix__c();
                //objARTEM.Name = recType.id;
                objARTEM.Name = string.valueOf(recType.id).substring(0,15);
                objARTEM.Recordtype__c = recType.Name;
                lstARTEM.add(objARTEM);
            }
            if(!lstARTEM.isEmpty()){
                insert lstARTEM;
            }
            List<Email_Matrix__c> insertEmailMatrixList=new List<Email_Matrix__c>();
            Email_Matrix__c EM =new Email_Matrix__c();
            EM.Type__c='Work';
            EM.Account__c=practitioner.Id;
            EM.Active__c=true;
            EM.Email__c= 'test@test.com';
            EM.Rep_Primary__c=True;
            insertEmailMatrixList.add(EM);
            
            INSERT insertEmailMatrixList;
           // DataFactoryCustomSetting.createCustomSettings();
        adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex.com', 'testadmin');
        system.runas(adminUser){
            
            //DataFactoryTerritory.setUpTerritoryForTestClasses();
            
        }
        HCPAccount = DataFactoryAccount.createHealthCareProviderAccount();
        practitionerAccount1 = DataFactoryAccount.createPractitionerAccount();
        //practitionerAccount1.Assigned_Agency__pc = 'TestAgencyTerritory';
        //practitionerAccount1.AXIS_Assigned_Agency_Team__pc = 'TestAgencyTerritory_TestTeamTerritory1';
        
      
        }
    }
  
    static testMethod void testDefaultOwnerOnAccount(){
        
      HCPAccount = DataFactoryAccount.createHealthCareProviderAccount();
       insert HCPAccount;
        HCPAccount = [SELECT Id, OwnerId FROM Account WHERE Id = :HCPAccount.Id LIMIT 1];
        
       // system.assertEquals(UserInfo.getUserId(), HCPAccount.OwnerId);
        
        
    }// end of testDefaultOwnerOnAccount
    
    static testMethod void testduplicateEmailCheck(){
         practitionerAccount1 = DataFactoryAccount.createPractitionerAccount();
        //practitionerAccount1.Assigned_Agency__pc = 'TestAgencyTerritory';
        //practitionerAccount1.AXIS_Assigned_Agency_Team__pc = 'TestAgencyTerritory_TestTeamTerritory1';
       
        insert practitionerAccount1;
       // practitionerAccount1 = [SELECT Id, PersonEmail FROM Account WHERE Id = :practitionerAccount1.Id LIMIT 1];
        
        //system.assertEquals('testpersonemail@arthrex.com', practitionerAccount1.PersonEmail);
        
        //practitionerAccount1.PersonEmail = 'testpersonemail2@arthrex.com';
        List<Email_Matrix__c> insertEmailMatrixList=new List<Email_Matrix__c>();
       List<Account> lstAcc = [SELECT id from Account];// where IsPersonAccount = True];
       integer i = 0;
            Email_Matrix__c EM;
            for(Account acc: lstAcc){
            i++;
                EM =new Email_Matrix__c();
                EM.Type__c='Work';
                EM.Account__c=acc.Id;
                EM.Active__c=true;
                EM.Email__c= 'test' + i +'@test.com';
                EM.Rep_Primary__c=True;
                insertEmailMatrixList.add(EM);
            }
            INSERT insertEmailMatrixList; 
        update practitionerAccount1;
        List<Account> lstAccdup = new List<Account>();
        lstAccdup.add(practitionerAccount1);
        AccountTriggerHelper objATH = new AccountTriggerHelper();
        objATH.duplicateEmailCheck(lstAccdup);
         //practitionerAccount1 = [SELECT Id, isPersonAccount, PersonEmail FROM Account WHERE Id = :practitionerAccount1.Id LIMIT 1];
           lstAccdup = new List<Account>();
        lstAccdup.add(practitionerAccount1);
          objATH.duplicateEmailCheck(lstAccdup);

        practitionerAccount2 = DataFactoryAccount.createPractitionerAccount();
        
        try{
            
            insert practitionerAccount2;
        }catch(exception e){
            
            system.debug('##--testduplicateEmailCheck.e.getMessage(): '+ e.getMessage());
            system.assertEquals('A practitioner with this email '
                               + 'address already exists.', e.getMessage());
        }
        
        //practitionerAccount2 = [SELECT Id, PersonEmail FROM Account WHERE Id = :practitionerAccount2.Id LIMIT 1];
        
       // system.assertEquals('testpersonemail@arthrex.com', practitionerAccount2.PersonEmail);
        
        //practitionerAccount1 = [SELECT Id, PersonEmail FROM Account WHERE Id = :practitionerAccount1.Id LIMIT 1];
        
        //system.assertEquals('testpersonemail2@arthrex.com', practitionerAccount1.PersonEmail);
        
        
    }// end of testduplicateEmailCheck
    
    static testMethod void testpopulateTerritoryAssignmentInsert(){
         practitionerAccount1 = DataFactoryAccount.createPractitionerAccount();
        //practitionerAccount1.Assigned_Agency__pc = 'TestAgencyTerritory';
        //practitionerAccount1.AXIS_Assigned_Agency_Team__pc = 'TestAgencyTerritory_TestTeamTerritory1';
       
        insert practitionerAccount1;
        
        list<ObjectTerritory2Association> lstObjectTerritory2Association = [SELECT Id FROM ObjectTerritory2Association 
                                                                                        WHERE ObjectId = :practitionerAccount1.Id
                                                                                        AND AssociationCause = :Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL];
                                                                                        List<Account> lstAcc = new List<Account>();
lstAcc.add(practitionerAccount1);
AccountTriggerHelper objATH = new AccountTriggerHelper();
objATH.populateTerritoryAssignmentsOnShipToUsingSoldTo(lstAcc);
        system.assertEquals(1, lstObjectTerritory2Association.size());
    }// end of testpopulateTerritoryAssignmentInsert
    
    static testMethod void testpopulateTerritoryAssignmentonUpdate(){
         practitionerAccount1 = DataFactoryAccount.createPractitionerAccount();
        //practitionerAccount1.Assigned_Agency__pc = 'TestAgencyTerritory';
        //practitionerAccount1.AXIS_Assigned_Agency_Team__pc = 'TestAgencyTerritory_TestTeamTerritory1';
      
        insert practitionerAccount1;
        
        //practitionerAccount1.AXIS_Assigned_Agency_Team__pc = 'TestAgencyTerritory_TestTeamTerritory2';
        update practitionerAccount1;
        
        list<ObjectTerritory2Association> lstObjectTerritory2Association = [SELECT Id FROM ObjectTerritory2Association 
                                                                                        WHERE ObjectId = :practitionerAccount1.Id
                                                                                        AND AssociationCause = :Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL];
        system.assertEquals(2, lstObjectTerritory2Association.size());
    }// end of testpopulateTerritoryAssignmentonUpdate
    
    static testMethod void testpopulateTerritoryAssignmentsOnShipToUsingSoldTo(){
        
       HCPAccount = DataFactoryAccount.createHealthCareProviderAccount();
        insert HCPAccount;
        
        Territory2 objTerritory= [SELECT Id FROM Territory2 LIMIT 1];
        ObjectTerritory2Association objTerritory2Association= new ObjectTerritory2Association(ObjectId = HCPAccount.Id,
                                                                      AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL,
                                                                      Territory2Id = objTerritory.Id);
        insert objTerritory2Association;
        
        Account HCPShipToAccount = DataFactoryAccount.createHealthCareProviderAccount();
        HCPShipToAccount.Account_Group__c = Constant.ACCOUNT_GROUP_ZOO2;
        insert HCPShipToAccount;
        
        HCPShipToAccount.ParentId = HCPAccount.Id;
        update HCPShipToAccount;
        
        list<ObjectTerritory2Association> lstObjectTerritory2Association = [SELECT Id FROM ObjectTerritory2Association 
                                                                                        WHERE ObjectId = :HCPShipToAccount.Id
                                                                                        AND AssociationCause = :Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL];
        system.assertEquals(1, lstObjectTerritory2Association.size());
        HCPShipToAccount.Active__c = True;
        update HCPShipToAccount;
        HCPShipToAccount.Active__c = False;
        update HCPShipToAccount;
    }// end of testpopulateTerritoryAssignmentInsert
    
   static testMethod void createPrimaryEmailMatrixRecord_Test(){
        
      
      practitionerAccount1 = DataFactoryAccount.createPractitionerAccount();
      //practitionerAccount1.PersonEmail = null;
      insert practitionerAccount1;
        map<Id, Account> mapOldAccounts = new map<Id, Account>();//([SELECT id, PersonEmail, RecordTypeId from Account where PersonEmail = null]);
        List<Account> lstAcc;// = [SELECT id, RecordTypeId, PersonEmail from Account where Id =: practitionerAccount1.Id];
        //lstAcc[0].PersonEmail = 'test@test.com';
        AccountTriggerHelper objAccHelper = new AccountTriggerHelper();
        objAccHelper.createPrimaryEmailMatrixRecord(lstAcc, mapOldAccounts);
        
        List<Email_Matrix__c> lstEM = [SELECT id FROM Email_Matrix__c where Account__c =: practitionerAccount1.id];
        delete lstEM;
        
        objAccHelper.updatePrimaryEmailMatrixRecord(lstAcc, mapOldAccounts);
    }//end of createPrimaryEmailMatrixRecord_test
    
    static testMethod void updatePrimaryEmailMatrixRecord_Test(){
              
        practitionerAccount1 = DataFactoryAccount.createPractitionerAccount();
        //practitionerAccount1.PersonEmail = null;
        insert practitionerAccount1;
        map<Id, Account> mapOldAccounts = new map<Id, Account>([SELECT id, RecordTypeId from Account where id = null and id =: practitionerAccount1.id]);
        List<Account> lstAcc = [SELECT id, RecordTypeId from Account where Id =: practitionerAccount1.Id];
        //lstAcc[0].PersonEmail = 'test9999@test.com';
        AccountTriggerHelper objAccHelper = new AccountTriggerHelper();
        objAccHelper.updatePrimaryEmailMatrixRecord(lstAcc, mapOldAccounts);
                
    }//end of updatePrimaryEmailMatrixRecord_test
    
    static testMethod void changeRecordtype_Undefined_Test(){
        Id undefinedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_UNDEFINED).getRecordTypeId();        
        List<Account> lstAcc = [SELECT id FROM Account where Recordtype.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER];
        for(Account acc: lstAcc){
            acc.RecordtypeId = undefinedRecordTypeId;
        }
        update lstAcc;
    }// End of changeRecordtype_Undefined_Test
    
    static testMethod void changeRecordtype_NonPractitioner_Test(){
        Id nonPractitionerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_SURGEON_CONTACT).getRecordTypeId();
        List<Account> lstAcc = [SELECT id FROM Account where Recordtype.Name =: Constant.RECORDTYPE_NAME_UNDEFINED];
        for(Account acc: lstAcc){
            acc.RecordtypeId = nonPractitionerRecordTypeId;
        }
        update lstAcc;
    }// End of changeRecordtype_NonPractitioner_Test    
    
    static testMethod void changeRecordtype_Practitioner_Test(){
        Id PractitionerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_SURGEON_CONTACT).getRecordTypeId();
        List<Account> lstAcc = [SELECT id FROM Account where Recordtype.Name =: Constant.RECORDTYPE_NAME_PRACTITIONER];
        for(Account acc: lstAcc){
            acc.RecordtypeId = PractitionerRecordTypeId;
        }
        update lstAcc;
    }// End of changeRecordtype_Practitioner_Test
    
}