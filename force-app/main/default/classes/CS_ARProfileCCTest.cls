@IsTest
public class CS_ARProfileCCTest {
    
    private static User owner;
    private static User portalUser;
    private static Contact portalUserContact;
    private static Account provider;

    
    public static void testData() {
        
        owner = CS_TestDataBuilder.CreateUser();
        insert owner;
        System.runAs(owner) {
            provider = DataFactoryAccount.createHealthCareProviderAccount();
            insert provider;
            
            //Contact c = new Contact(AccountId=provider.Id,lastname='testing',firstname='apex');
            portalUserContact = CS_TestDataBuilder.CreateContact(provider.Id);
            insert portalUserContact;
            
            portalUser = CS_TestDataBuilder.CreatePartnerUser(portalUserContact);
            insert portalUser;
            
            portalUserContact.ownerId = portalUser.Id;
            update portalUserContact;

        }
    }
    
    @IsTest
    public static void testRetrievePickListValues() {

    
        List<SelectOption> result = CS_ARProfileCC.retrievePrimaryProductGroupValues();
        System.assertNotEquals(null, result);
        result = CS_ARProfileCC.retrieveCountryCodeValues();
        System.assertNotEquals(null, result);  
        result = CS_ARProfileCC.retrieveSalutationValues();
        System.assertNotEquals(null, result);    
        result = CS_ARProfileCC.retrieveStateValues();
        System.assertNotEquals(null, result);    
        result = CS_ARProfileCC.retrieveCollegiateSportValues();
        System.assertNotEquals(null, result);    
        result = CS_ARProfileCC.retrieveCollegiateSportYearsValues();
        System.assertNotEquals(null, result);    
        result = CS_ARProfileCC.retrieveProfessionalSportValues();
        System.assertNotEquals(null, result);    
        result = CS_ARProfileCC.retrieveProfessionalSportYearsValues();
        System.assertNotEquals(null, result);    
        result = CS_ARProfileCC.retrieveMilitaryBranchValues();
        System.assertNotEquals(null, result);    
        result = CS_ARProfileCC.retrieveMilitaryStatusValues();
        System.assertNotEquals(null, result);    
        result = CS_ARProfileCC.retrieveClinicalTrainingValues();
        System.assertNotEquals(null, result);    
        result = CS_ARProfileCC.retrieveWorkExpCompanyValues();
        System.assertNotEquals(null, result);    
        result = CS_ARProfileCC.retrieveWorkExpYearsValues();
        System.assertNotEquals(null, result);        
        result = CS_ARProfileCC.retrieveWorkExpIndustryValues();
        System.assertNotEquals(null, result);     
        result = CS_ARProfileCC.retrieveRoleInAgencyValues();
        System.assertNotEquals(null, result);     
        result = CS_ARProfileCC.retrieveConsultantLevelValues();
        System.assertNotEquals(null, result);
        result = CS_ARProfileCC.retrieveOrthopedicWorkExpYearsValues();
        System.assertNotEquals(null, result);     
    }

    @IsTest
    public static void testUpdateProfileMethods() {
    
        testData();    
        

        System.runAs(portalUser) {
            Test.StartTest();
                

            Map<String,Object> params = new Map<String,Object>();
                
            params.put('orthopedicCompany', 'Medtronic');
            params.put('priorOrExperience', 'true');
            Map<String,Object> results = CS_ARProfileCC.updateProfileSubsetEducation(params);
            //System.assertNotEquals(null, results);
                
            //PriorOrExperience set to false
            params.put('priorOrExperience', 'false');
            params.put('workExp', 'company|title|industry|years;');
            results = CS_ARProfileCC.updateProfileSubsetEducation(params);
            //System.assertNotEquals(null, results);
                
            params.put('hireDate', '12-12-2016');
            results = CS_ARProfileCC.updateProfileSubsetTraining(params);                
            //System.assertNotEquals(null, results);
                
            params.put('lastName', 'testLastName');
            results = CS_ARProfileCC.updateProfileSubsetContact(params);
            //System.assertNotEquals(null, results);
                
            Map<Id, String> colorMap = new Map<Id, String>();
            boolean resultColor = CS_ARProfileCC.updateTeamCalendarColor(colorMap);
            //System.assertNotEquals(null, resultColor);               
               
                
            Test.StopTest();
        }

    }

    @IsTest
    public static void testRetrieveProfile() {
        
        Map<String,Object> results = CS_ARProfileCC.retrieveProfile(null);
        System.assertNotEquals(null, results);
    }

    @IsTest
    public static void testSearchInstitutions() {
        List<Institution__c> results = CS_ARPRofileCC.searchInstitutions(null);
        System.assertNotEquals(null, results);            
    }
    
    @IsTest
    public static void testRetrieveMyTeamCalendarColors() {
        
        List<String> myTeamColors = CS_ARProfileCC.retrieveMyTeamCalendarColors();
        System.assertNotEquals(null, myTeamColors);
           
    }
    
    @IsTest(SeeAllData=true)
    public static void testUpdateProfilePicture() {
            
        testData();

        System.runAs(portalUser) {
            Test.StartTest();
                
            Map<String,Object> params = new Map<String,Object>();
            String fileContents = CS_TestDataBuilder.getProfileFileContents();
            params.put('encodedFileContents', fileContents);
            params.put('fileMimeType', 'image/jpeg');
            params.put('fileName', 'prof1.jpg');
                
            CS_ARProfileCC.updateProfilePicture(params);
                
            Test.StopTest();
        }    
    }
    
    @isTest
    public static void testgetNotificationTypes() {        
        List<Notification_Type__c> lstNotification = CS_ARProfileCC.getNotificationTypes();          
    }//end of testgetNotificationTypes
    
    @isTest
    public static void testgetMySubscriptions() {        
        List<Notification_Subscription__c> lstSubscriptions = CS_ARProfileCC.getMySubscriptions();           
    }//end of testgetNotificationTypes
    
    @isTest
    public static void testsubscribe() {
        List<String> notificationTypeIds = new List<String>();
        List<Notification_Type__c> lstNotificationType = [select id from Notification_Type__c];
        for(Notification_Type__c nt: lstNotificationType){
            notificationTypeIds.add(nt.id);
        }
        
        List<String> pushEnabledTypeIds = new List<String>();
        CS_ARProfileCC.subscribe(notificationTypeIds, pushEnabledTypeIds);         
    }//end of testsubscribe
    
    @isTest
    public static void testretrieveUserTimeZoneValues() {        
        List<SelectOption> lstSelectOption = CS_ARProfileCC.retrieveUserTimeZoneValues();
        System.assertNotEquals(null, lstSelectOption);           
    }//end of testretrieveUserTimeZoneValues
    
    @isTest
    public static void testupdateUserTimeZone() {
        User objUser = [select id, TimeZoneSidKey from User where id =: system.userinfo.getuserid()];      
        CS_ARProfileCC.updateUserTimeZone(objUser.id, objUser.TimeZoneSidKey);          
    }//end of testupdateUserTimeZone
    
}