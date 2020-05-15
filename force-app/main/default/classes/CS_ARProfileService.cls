/*
    @Author             : Jason Bandojo (CloudSherpas)
    @Date Created       : 23-MAR-2016
    @Date Modified      : 
    @Description        : service class for ARProfile.page
*/
public with sharing class CS_ARProfileService {
    
    public static void updateProfilePicture(Map<String,Object> profile) {
        
        String encodedFileContents = (String)profile.get('encodedFileContents');

        String fileMimeType = encodedFileContents.substring(5, encodedFileCOntents.indexOf(';') );
        Blob fileContents = EncodingUtil.base64Decode(encodedFileContents.substring( (encodedFileContents.indexOf(',')+1) ));
        String fileName = (String)profile.get('fileName');

        ConnectApi.BinaryInput uploadedImage = new ConnectApi.BinaryInput( fileContents, fileMimeType, fileName);
        ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(), UserInfo.getUserId(), uploadedImage);        
        
    }

    //Retrieve a list of color in HEX on User object from my team's user records
    public static List<string> retrieveMyTeamCalendarColors(){
        List<string> myTeamColors = new List<string>();

        for(User user : CS_ARTerritoryService.retrieveUsersInMyTerritory()){

                //if(user.Calendar_Color__c != null){
                    //myTeamColors.add(user.Calendar_Color__c);
               // }
        }

        return myTeamColors;

    }

    public static Map<String,Object> updateProfileSubsetTraining( Map<String,Object> params ) {
        /*String requestedProfile = UserInfo.getUserId();

        User u = CS_ARPRofileService.retrieveUserById(requestedProfile);
        Contact c = CS_ARPRofileService.retrieveContactById(u.ContactId);
        List<Work_Experience__c> existingWorkExps = CS_ARPRofileService.retrieveWorkExpsByContactId(u.ContactId);

        String dateStr = (String)params.get('hireDate');
        if ( dateStr != null ) {
            String[] dateComponents = dateStr.split('-');
            if  ( dateComponents.size() == 3 ) {
                Date hireDate = Date.newInstance(Integer.valueOf( dateComponents[2]),Integer.valueOf( dateComponents[0]), Integer.valueOf( dateComponents[1]));
                c.Hire_Date__c = hireDate;
            }
        }

        c.Primary_Product_Group__c = (String)params.get('primaryProductGroup');

        update c;

        return CS_ARProfileService.profileObjects2Map(requestedProfile, u,c, existingWorkExps);*/
        return null;
    }

    public static Map<String,Object> updateProfileSubsetContact( Map<String,Object> params ) {
        
        /*String requestedProfile = UserInfo.getUserId();

        User u = CS_ARPRofileService.retrieveUserById(requestedProfile);
        Contact c = CS_ARPRofileService.retrieveContactById(u.ContactId);
        List<Work_Experience__c> existingWorkExps = CS_ARPRofileService.retrieveWorkExpsByContactId(u.ContactId);

        c.Salutation = (String)params.get('salutation');
        c.FirstName = (String)params.get('firstName');

        if ( params.containsKey('lastName')) {
            c.LastName = (String)params.get('lastName');
        }
        
        c.Email = (String)params.get('email');
        c.MailingStreet = (String)params.get('street');
        c.MailingCity = (String)params.get('city');
        c.MailingState = (String)params.get('state');
        c.MailingPostalCode = (String)params.get('postalCode');
        c.MailingCountryCode = (String)params.get('countryCode');
        c.MobilePhone = (String)params.get('mobilePhone');
        c.Phone = (String)params.get('officePhone');
        c.Fax = (String)params.get('officeFax');
        c.Title = (String)params.get('title'); 
        
        c.Role_In_Agency__c = (String)params.get('roleInAgency');
        c.Consultant_Level__c = (String)params.get('consultantLevel');
        
        update c;

        return CS_ARProfileService.profileObjects2Map(requestedProfile, u,c, existingWorkExps);*/
        return null;
    }    

    public static Map<String,Object> updateProfileSubsetEducation( Map<String,Object> params ) {

        /*String requestedProfile = UserInfo.getUserId();

        User u = CS_ARProfileService.retrieveUserById(requestedProfile);
        Contact c = CS_ARPRofileService.retrieveContactById(u.ContactId);
        List<Work_Experience__c> existingWorkExps = CS_ARPRofileService.retrieveWorkExpsByContactId(u.ContactId);

        system.debug('##--Params at the begining: ' + params);
        c.Graduate_Institution__c =  (String)params.get('graduateInstitutionId');
        c.UnderGraduate_Institution__c = (String)params.get('undergraduateInstitutionId');
        c.Doctorate_Institution__c = (String)params.get('doctorateInstitutionId');

        c.Collegiate_Sport__c = (String)params.get('collegiateSport');
        c.Collegiate_Sport_Years__c = (String)params.get('collegiateSportYears');
        c.Professional_Sport__c = (String)params.get('professionalSport');
        c.Professional_Sport_Years__c = (String)params.get('professionalSportYears');
        
        c.Military_Status__c = (String)params.get('militaryStatus');
        c.Military_Branch__c = (String)params.get('militaryBranch');
        c.Clinical_Training__c = (String)params.get('clinicalTraining');
        c.Professional_Associations__c = (String)params.get('professionalAssociations');
        
        c.Professional_Certifications__c = (String)params.get('professionalCertifications');
        c.Professional_Sales_Training__c = (String)params.get('professionalSalesTraining');
        c.Management_Training__c = (String)params.get('managementTraining');
        
        c.Orthopedic_Sales__c = (String)params.get('orthopedicExp');
        if((String)params.get('orthopedicCompany') != null){
            c.Company_Orthopedic_Sales__c = ((String)params.get('orthopedicCompany')).replace(',', ';');
        }
        c.How_Many_Years_Orthopedic_Sales__c = (String)params.get('orthopedicExpYears');

        String priorOrExperience = (String)params.get('priorOrExperience');
        if ( 'true'.equalsIgnoreCase(priorOrExperience) ) {
            c.Prior_OR_Experience__c = true;
        } else {
            c.Prior_OR_Experience__c = false;
        }
        
        
        // delete any existing work experience records
        for ( Work_Experience__c eWorkExp : existingWorkExps ) { delete eWorkExp; }

        // now insert the new ones by breaking about the semicolon terminated pipe delimitted string
        // be careful about it to avoid NPEs generated by code bugs in the front end
        String workExpStrEnc = (String)params.get('workExp');
        if ( workExpStrEnc == null ) { workExpStrEnc = ''; }
        
        String workExpStr = EncodingUtil.urlDecode(workExpStrEnc, 'UTF-8');
        if ( workExpStr != null && workExpStr.indexOf(';') != -1  ) {

            String[] workExpRows = workExpStr.split(';');
            if ( workExpRows.size() > 0 ) {
                // at least one incoming record
                for ( String workExpRow : workExpRows ) {

                    if ( workExpRow.indexOf('|') != -1 ) {
                        // at least one field exists
                        String[] workExpElems = workExpRow.split('\\|');

                        if ( workExpElems.size() >= 4 ) {
                            // there's at least a value for every field, go ahead and try to create the row
                            Work_Experience__c workExp = new Work_Experience__c();
                            workExp.Company__c = workExpElems[0];
                            workExp.Job_Title__c = workExpElems[1];
                            workExp.Industry__c = workExpElems[2];
                            workExp.Years__c = workExpElems[3];
                            workExp.Contact__c = u.ContactId;
                            insert workExp;
                        }
                    }
                    
                }
            }

        }

        update c;

        // and select a fresh list
        List<Work_Experience__c> workExps = retrieveWorkExpsByContactId(u.ContactId);

        return CS_ARProfileService.profileObjects2Map(requestedProfile, u,c, workExps);*/
        return null;
    
    }

    public static Map<String,Object> retrieveProfile(String requestedProfile) {

        Map<String,Object> profileMap = new Map<String,Object>();

        if ( requestedProfile == null || requestedProfile.length() == 0 ) {
            requestedProfile = UserInfo.getUserId(); 
        }

        User u = CS_ARProfileService.retrieveUserById(requestedProfile);
        Contact userContact = CS_ARPRofileService.retrieveContactById(u.ContactId);
        List<Work_Experience__c> workExps = CS_ARPRofileService.retrieveWorkExpsByContactId(u.ContactId);
        
        
        profileMap = profileObjects2Map(requestedProfile, u, userContact, workExps);        
        system.debug('##--retrieveProfile.profileMap.workexp: '+ profileMap.get('workExp'));
        String thisUser = UserInfo.getUserId();
        if ( thisUser.equals(requestedProfile) ) {
            profileMap.put('isMe', true);
        } else {
            profileMap.put('isMe',false);
        }

        return profileMap;
    }

    public static List<Work_Experience__c> retrieveWorkExpsByContactId(String contactId) {

        List<Work_Experience__c> workExps = [ select Id, Company__c, 
                                Job_Title__c, Industry__c, Years__c from Work_Experience__c where Contact__c =:contactId];
        if ( workExps == null ) { workExps = new List<Work_Experience__c>(); }

        return workExps;
    }

    public static User retrieveUserById(String userId) {
        
        User user = [select Id,Username,FullPhotoUrl,TimeZoneSidKey,FirstName, LastName,ContactId,Customer_Number__c, Calendar_Color__c, 
        IsActive, CreatedDate, LastLoginDate from User where Id=:userId];

        return user;
    }

    public static Contact retrieveContactById(String contactId) {

        /*Contact userContact = null;

        List<Contact> userContacts = [Select Id, Graduate_Institution__r.Id, Graduate_Institution__r.Name, Undergraduate_Institution__r.Id, Undergraduate_Institution__r.Name,
            Doctorate_Institution__r.Id, Doctorate_Institution__r.Name, Collegiate_Sport__c, Collegiate_Sport_Years__c, Professional_Sport__c,
            Professional_Sport_Years__c, Military_Status__C, Military_Branch__c, Clinical_Training__c, Professional_Certifications__c,
            Company_Orthopedic_Sales__c,How_Many_Years_Orthopedic_Sales__c,Orthopedic_Sales__c,
            Professional_Sales_Training__c,Management_Training__c, Professional_Associations__c, Prior_OR_Experience__c,Primary_Product_Group__c,
            Hire_Date__c, Title,FirstName, LastName, Email, Salutation, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountryCode,
            Phone,Fax,MobilePhone,Consultant_Level__c, Role_In_Agency__c from Contact where Id=:contactId];
        

        if ( userContacts != null && userContacts.size() > 0 ) { 
            userContact = userContacts[0];
        }            

        return userContact;*/
        return null;
    }

    public static Map<String,Object> profileObjects2Map(String requestedProfile, User u, Contact c, List<Work_Experience__c> workExps ) {

        Map<String,Object> profile = new Map<String,Object>();

        if ( u == null ) {
            // no user or no contact, this is bad, just return an empty map and avoid lots of NPEs
            return profile;
        }

        profile.put('profileId', u.Id);

        // profile.put('suffix',);
        String profileImage = u.FullPhotoUrl;
        if ( profileImage.equals('/profilephoto/005/F') || profileImage.equals('/profilephoto/005/T')) {
            profileImage = CS_ARProfileService.getPathToDefaultProfileImage();
        }
        
        profile.put('profileImage', profileImage );
        profile.put('defaultProfileImage', CS_ARProfileService.getPathToDefaultProfileImage());
        profile.put('profileName', u.FirstName+' '+u.LastName);

        Timezone tz = Timezone.getTimeZone( u.TimeZoneSidKey );
        profile.put('userTz', tz.getID() );
        profile.put('userId', u.Id);
        
        //profile.put('acceptedEula', u.EULA__C);          

        String thisUser = UserInfo.getUserId();
        if ( thisUser.equals(requestedProfile) ) {
            profile.put('isMe', true);
        } else {
            profile.put('isMe',false);
        }

        profile.put('username',u.Username);
        profile.put('erpCode',u.Customer_Number__c);
       // profile.put('accountType',u.pi__Pardot_User_Role__c);

        List<String> teams = CS_ARTerritoryService.retrieveTerritoryNamesByUserId(u.Id);
        if ( teams.size() > 0 ) {
            profile.put('teams', String.join(teams,', '));
        }
        
        profile.put('active', u.IsActive);
        profile.put('createDate',u.CreatedDate);
        profile.put('lastLoginDateTime',u.LastLoginDate);       
        profile.put('calendarColor', u.Calendar_Color__c); 

        // contact fields
        if ( c != null ) {

            /*profile.put('graduateInstitutionId', c.Graduate_Institution__r.Id);
            profile.put('graduateInstitution', c.Graduate_Institution__r.Name);
            profile.put('underGraduateInstitutionId', c.UnderGraduate_Institution__r.Id);
            profile.put('underGraduateInstitution', c.UnderGraduate_Institution__r.Name);
            profile.put('doctorateInstitutionId', c.Doctorate_Institution__r.Id);
            profile.put('doctorateInstitution', c.Doctorate_Institution__r.Name);
            profile.put('collegiateSport', c.Collegiate_Sport__c);
            profile.put('collegiateSportYears', c.Collegiate_Sport_Years__c);
            profile.put('professionalSport', c.Professional_Sport__c);
            profile.put('professionalSportYears', c.Professional_Sport_Years__c);
            profile.put('militaryStatus', c.Military_Status__c);
            profile.put('militaryBranch', c.Military_Branch__c);
            profile.put('clinicalTraining', c.Clinical_Training__c);
            profile.put('professionalAssociations', c.Professional_Associations__c);
            profile.put('professionalCertifications', c.Professional_Certifications__c);
            profile.put('orthopedicExpYears', c.How_Many_Years_Orthopedic_Sales__c);
            profile.put('orthopedicExp', c.Orthopedic_Sales__c);
            profile.put('orthopedicCompany', c.Company_Orthopedic_Sales__c);
            profile.put('professionalSalesTraining', c.Professional_Sales_Training__c);
            profile.put('managementTraining', c.Management_Training__c);
            profile.put('priorORExperience', c.Prior_OR_Experience__c);*/
            // semicolon terminated pipe delimitted string
            String workExpAsCsv = '';
            for ( Work_Experience__c workExp : workExps ) {
                workExpAsCsv += workExp.Company__c+'|';
                workExpAsCsv += workExp.Job_Title__c+'|';
                workExpAsCsv += workExp.Industry__c+'|';
                workExpAsCsv += workExp.Years__c+'||';
            }
            profile.put('workExp', workExpAsCsv);        

            /*profile.put('primaryProductGroup', c.Primary_Product_Group__c);
            profile.put('hireDate', c.Hire_Date__c);
            profile.put('title', c.Title);
            profile.put('roleInAgency', c.Role_In_Agency__c);
            profile.put('consultantLevel', c.Consultant_Level__c);*/

            profile.put('salutation',c.Salutation);
            profile.put('firstName',c.FirstName);
            profile.put('lastName',c.LastName);
            profile.put('email', c.Email);
            profile.put('street', c.MailingStreet);
            profile.put('city', c.MailingCity);
            profile.put('state',c.MailingState);
            profile.put('postalCode',c.MailingPostalCode);
            profile.put('countryCode',c.MailingCountryCode);
            profile.put('mobilePhone', c.MobilePhone);
            profile.put('officePhone',c.Phone);
            profile.put('officeFax', c.Fax);
        }
        
        return profile;
        //return null;
    }

    public static void acceptEula() {
        /*String userId = UserInfo.getUserId();
        User u = [select id, EULA__c from User where Id=:userId];
        u.EULA__c = true;
        update u;*/
    }

    public static Map<String,Object> retrieveUserProperties() {
        User u = CS_ARProfileService.retrieveUserById(UserInfo.getUserId());
        Contact userContact = CS_ARPRofileService.retrieveContactById(u.ContactId);
        List<Work_Experience__c> workExps = CS_ARPRofileService.retrieveWorkExpsByContactId(u.ContactId);

        return profileObjects2Map(UserInfo.getUserId(), u, userContact, workExps); 
    }    

    public static String getPathToDefaultProfileImage() {

        String prefix = Site.getPathPrefix();
        if ( prefix == null ) { prefix = ''; }

        String staticResourceName = 'AxisTemplate';
        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :staticResourceName];
        if(resourceList.size() == 1) {
            String namespace = resourceList[0].NamespacePrefix;
            // Resource URL
            String resourceUrl = prefix+'/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + staticResourceName; 
            return resourceUrl += '/Axis/img/profile-default.png';

        } else {
            // regular salesforce default
            return '/profilephoto/005/F';
        }
    }
    
    public static String getPathToDefaultSurgeonProfileImage() {

        String prefix = Site.getPathPrefix();
        if ( prefix == null ) { prefix = ''; }

        String staticResourceName = 'AxisTemplate';
        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :staticResourceName];
        if(resourceList.size() == 1) {
            String namespace = resourceList[0].NamespacePrefix;
            // Resource URL
            String resourceUrl = prefix+'/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + staticResourceName; 
            return resourceUrl += '/Axis/img/profile-Surgeon.png';

        } else {
            // regular salesforce default
            return '/profilephoto/005/F';
        }
    }
}