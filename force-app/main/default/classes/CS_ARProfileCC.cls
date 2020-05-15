/*
    @Author             : Jason Bandojo (CloudSherpas)
    @Date Created       : 23-MAR-2016
    @Date Modified      : 
    @Description        : controller class for ARProfile.page
*/
public class CS_ARProfileCC {

    @RemoteAction
    public static void updateProfilePicture(Map<String,Object> profile) {
        CS_ARProfileService.updateProfilePicture(profile);
    }

    @RemoteAction
    public static List<Institution__c> searchInstitutions(String q) {
        return CS_ARSearch.searchInstitutions(q);
    }

    @RemoteAction
    public static Map<String,Object> retrieveProfile(String userId) {
        return CS_ARProfileService.retrieveProfile(userId);
    }
    
    @RemoteAction
    public static Map<String,Object> updateProfileSubsetEducation(Map<String,Object> params) {
        return CS_ARProfileService.updateProfileSubsetEducation(params);
    }
    @RemoteAction
    public static Map<String,Object> updateProfileSubsetTraining(Map<String,Object> params) {
        return CS_ARProfileService.updateProfileSubsetTraining(params);
    }    
    @RemoteAction
    public static Map<String,Object> updateProfileSubsetContact(Map<String,Object> params) {
        return CS_ARProfileService.updateProfileSubsetContact(params);
    }            
    @RemoteAction
    public static List<SelectOption> retrievePrimaryProductGroupValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'Primary_Product_Group__c', null);        
    }
    @RemoteAction
    public static List<SelectOption> retrieveCountryCodeValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'MailingCountryCode', null);        
    }    
    @RemoteAction
    public static List<SelectOption> retrieveSalutationValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'Salutation', null);        
    }
    @RemoteAction
    public static List<SelectOption> retrieveRoleInAgencyValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'Role_In_Agency__c', null);        
    }
    @RemoteAction
    public static List<SelectOption> retrieveConsultantLevelValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'Consultant_Level__c', null);        
    }        
    @RemoteAction
    public static List<SelectOption> retrieveStateValues() {
        Contact c = new Contact();
        c.MailingCountryCode = 'US';
        return CS_ARContactsService.getPickValues(c, 'MailingStateCode', null);        
    }        
    @RemoteAction
    public static List<SelectOption> retrieveCollegiateSportValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'Collegiate_Sport__c', null);        
    }
    @RemoteAction
    public static List<SelectOption> retrieveCollegiateSportYearsValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'Collegiate_Sport_Years__c', null);        
    }
    @RemoteAction
    public static List<SelectOption> retrieveProfessionalSportValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'Professional_Sport__c', null);        
    }
    @RemoteAction
    public static List<SelectOption> retrieveProfessionalSportYearsValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'Professional_Sport_Years__c', null);        
    }    
    @RemoteAction
    public static List<SelectOption> retrieveMilitaryBranchValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'Military_branch__c', null);        
    }
    @RemoteAction
    public static List<SelectOption> retrieveMilitaryStatusValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'Military_Status__c', null);        
    }
    @RemoteAction
    public static List<SelectOption> retrieveClinicalTrainingValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'Clinical_Training__c', null);        
    }   
    @RemoteAction
    public static List<SelectOption> retrieveWorkExpCompanyValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'Company_Orthopedic_Sales__c', null);
    }
    @RemoteAction
    public static List<SelectOption> retrieveOrthopedicWorkExpYearsValues() {
        return CS_ARContactsService.getPickValues(new Contact(), 'How_Many_Years_Orthopedic_Sales__c', null);        
    }
    @RemoteAction
    public static List<SelectOption> retrieveWorkExpYearsValues() {
        return CS_ARContactsService.getPickValues(new Work_Experience__c(), 'Years__c', null);        
    }
    @RemoteAction    
    public static List<SelectOption> retrieveWorkExpIndustryValues() {
        return CS_ARContactsService.getPickValues(new Work_Experience__c(), 'Industry__c', null);        
    } 

    @RemoteAction
    public static List<string> retrieveMyTeamCalendarColors(){
        return CS_ARProfileService.retrieveMyTeamCalendarColors();
    }    

    @RemoteAction
    public static boolean updateTeamCalendarColor(Map<Id, string> teamColorMap){
        system.debug('*** length of team corlor map: ' + teamColorMap.keySet().size());
        return CS_ARCasesService.updateCalendarColor(teamColorMap);
    } 

    // below added by Chad for notification setting support
    
    @RemoteAction
    public static List<Notification_Type__c>  getNotificationTypes() {
        return null;
        //return CS_NotificationService.getNotificationTypes();
        
    }

    @RemoteAction
    public static List<Notification_Subscription__c> getMySubscriptions() {
        return null;
        /*List<Notification_Subscription__c> mySubscriptions = CS_NotificationService.getSubscriptionsByUser(UserInfo.getUserId());
        if ( mySubscriptions == null ) { mySubscriptions = new List<Notification_Subscription__c>(); }

        return mySubscriptions;*/
    }

    @RemoteAction
    public static void subscribe(List<String> notificationTypeIds, List<String> pushEnabledIds) {

        CS_NotificationService.subscribe(UserInfo.getUserId(), notificationTypeIds, pushEnabledIds);
    }    
    
    @RemoteAction    
    public static List<SelectOption> retrieveUserTimeZoneValues() {
        return CS_ARContactsService.getPickValues(new User(), 'TimeZoneSidKey', null);        
    }   
    
    @RemoteAction
    public static void updateUserTimeZone(Id userId, string userTimeZoneSidKey){
        
        User objUser = new User(Id = userId, TimeZoneSidKey = userTimeZoneSidKey);
        
        update objUser;
    }                

}