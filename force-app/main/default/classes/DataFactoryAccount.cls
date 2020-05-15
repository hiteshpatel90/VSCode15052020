public with sharing class DataFactoryAccount {
    
    public static Account createHealthCareProviderAccount(){
        
        Account objHCPAccount = new Account(Name = 'Test HCP Account',
                                        Phone = '5556667777',
                                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_HEALTH_CARE_PROVIDER).getRecordTypeId());
                                        
        return objHCPAccount;
    }// end of createHealthCareProviderAccount
    
    public static Account createAgencyAccount(string accountName){
        
        Account objAgencyAccount = new Account(Name = accountName,
                                        Phone = '5556667777',
                                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_AGENCY).getRecordTypeId());
                                        
        return objAgencyAccount;
    }// end of createAgencyAccount
    
    public static Account createPractitionerAccount(){
        
        Account objPractitionerAccount = new Account(Name = 'TestPractitionerFirstName TestPractitionerLastName',
                                        //LastName = 'TestPractitionerLastName',
                                        //PersonEmail = 'testpersonemail@arthrex.com',
                                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_PRACTITIONER).getRecordTypeId());
                                        
        return objPractitionerAccount;
        
    }// end of createPractitionerAccount
    
    public static Account createSurgeonContact(){
        
        Account objSurgeonContact = new Account(Name = 'TestSurgeonFirstName TestSurgeonLastName',
                                        Phone = '5556667777',
                                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_SURGEON_CONTACT).getRecordTypeId());
                                        
        return objSurgeonContact;
    }// end of createAgencyAccount  

}