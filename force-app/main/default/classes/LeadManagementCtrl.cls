public with sharing class LeadManagementCtrl {

    private static String AccountType = 'Account';
    private static String ContactType = 'Contact';
    private static String LeadType = 'Lead';
    
    @AuraEnabled
    public static List<LeadManagementVO.SelectableOption> getCampaigns(){
        //LeadManagementService service = new LeadManagementService();
        
        //return service.getCampaigns();
        return null;
    }   //  end of getCampaigns
    
    
    @AuraEnabled
    public static list<LeadManagementVO.SelectableOption> getTeams(String conferenceId){
        //LeadManagementService service = new LeadManagementService();
        
        //return service.getTeams(conferenceId);
        return null;
    }   //  end of getTeams
    
    @AuraEnabled
    public static list<LeadManagementVO.KeyValue> getListOfCountries(){
        
        //LeadManagementService service = new LeadManagementService();
        
        //return service.getListOfCountries();
        return null;
    }   //  end of getListOfCountries
    
    
    @AuraEnabled
    public static list<LeadManagementVO.SelectableOption> getInterestsForTeam(String teamId, String campaignId){
        //LeadManagementService service = new LeadManagementService();
        
        //return service.getInterestsForTeam(teamId, campaignId);
        return null;
    }   //  end of getInterestsForTeam
    
    
    /**
     * Method to retrieve task information from lead activities
     */
    @AuraEnabled
    public static list<LeadsApp_LeadActivities__c> getActivities(){
       list<LeadsApp_LeadActivities__c> lstActivities = new list<LeadsApp_LeadActivities__c>();
        
        lstActivities = [SELECT Id, Name, Active__c, Section__c, Details_Ref__c  
                         FROM LeadsApp_LeadActivities__c 
                        WHERE Active__c = true
                         ORDER by Section__c, SortOrder__c];
        
        return lstActivities;
    }   //  end of getActivities
    
    
    @AuraEnabled
    public static Conference_Agent_Selection__c getUserSelection(){
        //LeadManagementService service = new LeadManagementService();
        //return service.getUserSelection();
        return null;
    }   //  end of getUserSelection
    
    
    @AuraEnabled
    public static Conference_Agent_Selection__c setUserSelection(String selectionId, String campaignId, String teamId){
        system.debug('##-- Selection ID: ' + selectionId + '\tCampaing Id: ' + campaignId + '\t TeamID: ' + teamId);
        Id currentUser = UserInfo.getUserId();
        
        Conference_Agent_Selection__c agentSelection = new Conference_Agent_Selection__c(Id= String.isBlank(selectionId) ? null : selectionId,
                                                                                         ConferenceId__c = campaignId,
                                                                                         TeamId__c = teamId,
                                                                                         User__c=currentUser);
        upsert agentSelection;
        system.debug('##-- Setting the User Selection: ' + agentSelection);
        return agentSelection;
    }   //  end of setUserSelection
    
    
    @AuraEnabled
    public static Attendee getAttendeeDetails(String campaignId, String objectId, String objectType){
        Attendee objAttendee;
        
        if(objectType.equalsIgnoreCase (ContactType)){
            objAttendee = fetchContactDetatils(campaignId, objectId);
        } else if(objectType.equalsIgnoreCase (LeadType)){
            //objAttendee = fetchLeadDetatils(objectId);
        }else {
            objAttendee = fetchAccountDetatils(campaignId, objectId);
        }
        
        return objAttendee;
    }   //  end of getAttendeeDetails
    
    
    @AuraEnabled
    public static Boolean createCampaignInteraction(String campaignId, String teamId, String attendeeId, String attendeeType){
        //LeadManagementService service = new LeadManagementService();
        System.debug('##--campaignId: ' + campaignId + '\tteamId: ' + teamId +'\tattendeeId: '+attendeeId+'\tattendeeType: '+attendeeType);
        
        /*try{
            service.createCampaignInteraction(campaignId, teamId, attendeeId, ContactType); //  changed the last param from attendeeType to COntactType as we will only have contacts now
        } catch(Exception e){
            AuraHandledException ae = new AuraHandledException('Selection missing from Campaign options, please open a ticket for campaign team to correct issue.');
            throw ae;
        }*/
        
        return true;
    }   //  end of createCampaignInteraction
    
    
    @AuraEnabled
    public static Boolean createPersonCampaignInterests(String campaignId, String teamId, String attendeeId, String attendeeType, String jsonInterests){
        //LeadManagementService service = new LeadManagementService();
        //LIST<String> lstInterestIds = (LIST<String>)System.JSON.deserialize(jsonInterests, LIST<String>.class);
        
        //service.createPersonCampaignInterests(campaignId, teamId, attendeeId, attendeeType, lstInterestIds);
        return true;
    }   //  end of createPersonCampaignInterests
    
    @AuraEnabled
    public static List<Person_Conference_Interest__c> interestHistoryForAttendee(String campaignId, String attendeeId, String attendeeType, String dateConvert){
        //LeadManagementService service = new LeadManagementService();
        //System.debug('##-- Got the request for interestHistoryForAttendee');
        //return service.interestHistoryForAttendee(campaignId, attendeeId, attendeeType, dateConvert);
        return null;
    }   //  end of interestHistoryForAttendee
    
    
    @AuraEnabled
    public static Attendee createNewAttendee(String campaignId, String teamId, String newAttendeeJSON){
        //LeadManagementService service = new LeadManagementService();
        /*LeadManagementServiceWOSharing service = new LeadManagementServiceWOSharing();
        Attendee newAttendee = new Attendee();
        Account objAcc;
        try{
            System.debug('##--Got create lead request: ' + newAttendeeJSON);
            newAttendee = (Attendee)System.JSON.deserialize(newAttendeeJSON, Attendee.class);
            objAcc = service.createNewAttendee(newAttendee);
            System.debug('##--LeadManagementCtrl.createNewAttendee.objAcc: ' + objAcc);
            System.debug('##--LeadManagementCtrl.createNewAttendee.objAcc: ' + objAcc.PersonContactId);
            service.createCampaignMember(campaignId, objAcc.Id, AccountType);
            
            if(! String.isNotBlank(teamId)){
                service.createCampaignInteraction(campaignId, teamId, objAcc.Id, AccountType);
            }
            
            //newAttendee = fetchLeadDetatils(objAcc.Id);
            newAttendee = fetchAccountDetatils(campaignId, objAcc.Id);
            System.debug('##--New Lead: ' + objAcc);
            
        } catch(DmlException de){
          
            AuraHandledException ae = new AuraHandledException(de.getDmlMessage(0));
            throw ae;
        }
        
        
        return newAttendee;*/
        return null;
    }   //  end of createNewAttendee
    
    
    @AuraEnabled
    public static void createTasks(String campaignId, String teamId, String attendeeId, String attendeeType, String tasksJSON){
        //LeadManagementService service = new LeadManagementService();
        //List<LeadManagementVO.AttendeeTaskInfo> lstTasks = (List<LeadManagementVO.AttendeeTaskInfo>)System.JSON.deserialize(tasksJSON, List<LeadManagementVO.AttendeeTaskInfo>.class);
        
        //service.createOrUpdateTasks(campaignId, teamId, attendeeId, attendeeType, lstTasks);
    }   //  end of createTasks
    
    @AuraEnabled
    public static String getUserName() {
        return userinfo.getName();
    }   //  end of getUserName
    
    
    @AuraEnabled
    public static Map<String,List<String>> GetDependentOptions() {
       // LeadManagementService service = new LeadManagementService();
       return null;
        //return service.GetDependentOptions('Account', 'PersonMailingCountryCode', 'PersonMailingStateCode');
    }   //  end of getUserName
    
    
    private static Attendee fetchContactDetatils(String campaignId, String contactId){
        Attendee objAttendee;
        List<ObjectTerritory2Association> lstObjTerritories;
        List<User> lstUsers;
        List<User> lstActiveUsers = new List<User>();
        List<String> lstTerritoryIds = new List<String>();
        
        Contact con = [SELECT Id, AccountId, NPI__c, Name, Salutation, FirstName, LastName, Practice_Name__c, 
                                Phone, MobilePhone, Email, MailingAddress, MailingStreet, MailingCity,
                                MailingStateCode, MailingPostalCode, MailingCountryCode,
                                Focus_of_my_practice__c
                         FROM Contact 
                        WHERE Id = :contactId];
        
        Address objAdd = con.MailingAddress;
        objAttendee = new Attendee(con);
        
        lstObjTerritories = getTerritories(objAttendee.attendeeAccountId);
        for(ObjectTerritory2Association obj : lstObjTerritories){
            lstTerritoryIds.add(obj.Territory2Id);
        }
        
        lstUsers = getUsersAssignedToTerritories(lstTerritoryIds);
        for(User objUser : lstUsers){
            if(objUser.IsActive){
                lstActiveUsers.add(objUser);
            }
        }   //  end of for-each user
        
        objAttendee.team = getAssignedTeam(lstObjTerritories);
        objAttendee.agency = getParentTerritory(lstUsers);
        objAttendee.teamReps = teamRepsAndCampaignRepsHighlighted(campaignId, lstActiveUsers);
        
        return objAttendee;
    }   //  end of fetchContactDetatils
    
    /*
    private static Attendee fetchLeadDetatils(String leadId){
        Attendee objAttendee;
        
        Lead objLead = [SELECT Id, Name, Salutation, FirstName, LastName, MobilePhone, Phone, Email, 
                                Address, Street, City, StateCode, PostalCode, CountryCode,
                                LeadsApp_Street__c, LeadsApp_City__c, LeadsApp_State__c, LeadsApp_Zip__c, 
                                Title, Designation__c, Account_Name__c, Practice_Name__c, RecordType.Name
                         FROM Lead 
                        WHERE Id = :leadId];
        
        Address objAdd = objLead.Address;
        objAttendee = new Attendee(objLead);
        if('Surgeon Attendee'.equalsIgnoreCase(objLead.RecordType.Name)){
            objAttendee.surgeon=true;
        }
        
        return objAttendee;
    }   //  end of fetchLeadDetatils
    */
    
    private static Attendee fetchAccountDetatils(String campaignId, String accId){
        Attendee objAttendee;
        List<ObjectTerritory2Association> lstObjTerritories;
        List<User> lstUsers;
        List<User> lstActiveUsers = new List<User>();
        List<String> lstTerritoryIds = new List<String>();
        
        /*Account acc = [SELECT Id, PersonContactId, NPI__c , Name, Salutation, FirstName, LastName, Practice_Name__c, Designation__c,
                                PersonMobilePhone, Phone, PersonEmail, PersonMailingStreet, 
                                PersonMailingCity, PersonMailingStateCode, PersonMailingPostalCode, PersonMailingCountryCode,
                                LeadsApp_State__c, LeadsApp_Account_Name__c, LeadsApp_Attendee_isSurgeon__c, 
                                Focus_of_my_practice__pc, Assigned_Agency__pc, Arthrex_com_Surgeon_Specialty__pc   
                         FROM Account WHERE Id = :accId];*/
        
        retrieveAccountDetails clsRetrieveAccountDetails = new retrieveAccountDetails();
        Account acc = clsRetrieveAccountDetails.c_retrieveAccountDetails(accId);
        objAttendee = new Attendee(acc);
        
        lstObjTerritories = getTerritories(objAttendee.attendeeAccountId);
        for(ObjectTerritory2Association obj : lstObjTerritories){
            lstTerritoryIds.add(obj.Territory2Id);
        }
        
        lstUsers = getUsersAssignedToTerritories(lstTerritoryIds);
        for(User objUser : lstUsers){
            if(objUser.IsActive){
                lstActiveUsers.add(objUser);
            }
        }   //  end of for-each user
        
        objAttendee.team = getAssignedTeam(lstObjTerritories);
        objAttendee.agency = getParentTerritory(lstUsers);
        objAttendee.teamReps = teamRepsAndCampaignRepsHighlighted(campaignId, lstActiveUsers);
        
        return objAttendee;
    }   //  end of fetchAccountDetatils
    
    private without sharing class retrieveAccountDetails{
        
        public Account c_retrieveAccountDetails(Id accId){
            
            Account acc = [SELECT Id    FROM Account WHERE Id = :accId];
            return acc;
        }// end of c_retrieveAccountDetails
        
    }// end of retrieveAccountDetails
    
    private static List<ObjectTerritory2Association> getTerritories(String accountId){
        List<ObjectTerritory2Association> lstObjTerritories = new List<ObjectTerritory2Association>();
        Map<Id,List<ObjectTerritory2Association>> mapIdTerritoryList = CS_ARTerritoryService.mapObjectIdsToTerritories(new List<Id> {accountId});
        if(mapIdTerritoryList != null && mapIdTerritoryList.get(accountId) !=null){
            lstObjTerritories = mapIdTerritoryList.get(accountId);
            if(lstObjTerritories != null && ! lstObjTerritories.isEmpty()){
                return lstObjTerritories;
            }
        }
        return lstObjTerritories;
    }   //  end of getTerritories
    
    private static List<User> getUsersAssignedToTerritories(List<String> lstTerritoryIds){
        List<User> lstUsers = new List<User>();
        
        lstUsers = CS_ARTerritoryService.usersOfGivenTerritories(lstTerritoryIds);
        
        if(lstUsers == null){
            lstUsers = new List<User>();
        }
        
        return lstUsers;
    }   //  end of getUsersAssignedToTerritories
    
    private Static String getParentTerritory(List<User> lstUsers){
        if(lstUsers != null && ! lstUsers.isEmpty()){
            return lstUsers[0].contact.Account.Name;
        }
        return '';
    }   //  end of getParentTerritory
    
    private Static String getAssignedTeam(List<ObjectTerritory2Association> lstObjTerritory){
        if(lstObjTerritory != null && ! lstObjTerritory.isEmpty()){
            return lstObjTerritory[0].Territory2.Name;
        }
        return '';
    }   //  end of getAssignedTeam
    
    private static String teamRepsAndCampaignRepsHighlighted(String campaignId, List<User> lstReps){
        Map<Id, User> mapUsers = new Map<Id, User>(lstReps);
        Set<Id> userIds = mapUsers.keySet();
        String strUsers = '';
        
        for(Conference_Rep__c objCampRep : [SELECT Id, Name, User__c, User__r.Name
                                                    FROM Conference_Rep__c WHERE Conference__c  = :campaignId]){
            if(userIds.contains(objCampRep.User__c)){
                strUsers += '<span class="highlight">' + objCampRep.User__r.Name + '</span>; ';
                mapUsers.remove(objCampRep.User__c);
            }
        }   //  end of for-each Campaign User
        
            //  Loop through rest of the Users and show them normally
        for(Id userId: mapUsers.keySet()){
            strUsers += mapUsers.get(userId).Name + '; ';
        }
        
        return strUsers;
    }   //  end of teamRepsAndCampaignRepsHighlighted
    
    /**
     * Key Value Object to be used in Presentation
     */
    public class SelectOptions
    {
        @AuraEnabled public String key {get; set;}
        @AuraEnabled public String value {get; set;}
         
        public SelectOptions(String p_key, String p_value)
        {
            this.key = p_key;
            this.value = p_value;
        }
    }   //  end of SelectOptions
    
    /*
     *  Attendee Container to be used in UI
     */
    public class Attendee{
        @AuraEnabled public String attendeeId {get; set;}
        @AuraEnabled public String attendeeAccountId {get; set;}
        @AuraEnabled public String attendeeContactId {get; set;}
        @AuraEnabled public String attendeeType {get; set;}
        @AuraEnabled public String npi {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String salutation {get; set;}
        @AuraEnabled public String firstName {get; set;}
        @AuraEnabled public String lastName {get; set;}
        @AuraEnabled public String designation {get; set;}
        @AuraEnabled public String practice {get; set;}
        @AuraEnabled public String speciality {get; set;}
        @AuraEnabled public String phone {get; set;}
        @AuraEnabled public String practicePhone {get; set;}
        @AuraEnabled public String email {get; set;}
        @AuraEnabled public String streetAddress {get; set;}
        @AuraEnabled public String city {get; set;}
        @AuraEnabled public String state {get; set;}
        @AuraEnabled public String zip {get; set;}
        @AuraEnabled public String country {get; set;}
        @AuraEnabled public String address {get; set;}
        @AuraEnabled public String agency {get; set;}
        @AuraEnabled public String team {get; set;}
        @AuraEnabled public String focusPractice {get; set;}
        @AuraEnabled public String salesRep {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String accountName {get; set;}
        @AuraEnabled public String teamReps {get; set;}
        @AuraEnabled public Boolean surgeon {get; set;}
        
        public Attendee(){}
        public Attendee(Account objAcc){
            this.attendeeId = objAcc.Id;
            this.attendeeAccountId = objAcc.Id;
            //this.attendeeContactId = objAcc.PersonContactId;
            this.attendeeType = AccountType;
            this.npi = objAcc.NPI__c;
            this.name= objAcc.Name;
            //this.salutation = objAcc.Salutation;
            
            //this.designation = objAcc.Designation__c;
            this.practice = objAcc.Practice_Name__c;
            //this.speciality = objAcc.Arthrex_com_Surgeon_Specialty__pc; 
           // this.phone = objAcc.PersonMobilePhone;
            this.practicePhone = objAcc.Phone;
            
            
            this.address = constructAddress();
           
            //this.surgeon = objAcc.LeadsApp_Attendee_isSurgeon__c;
        }
        public Attendee(Contact objCon){
            this.attendeeId = objCon.Id;
            this.attendeeAccountId = objCon.AccountId;
            this.attendeeContactId = objCon.Id;
            this.attendeeType = ContactType;
            this.npi = objCon.NPI__c;
            this.name= objCon.Name;
            this.salutation = objCon.Salutation;
            this.firstName = objCon.FirstName;
            this.lastName = objCon.LastName;
            //this.designation = objCon.Designation__c;
            this.practice = objCon.Practice_Name__c;
            //this.speciality = objCon.Account.Arthrex_com_Surgeon_Specialty__pc;
            this.phone = objCon.MobilePhone;
            this.practicePhone = objCon.Phone;
            this.email = objCon.Email;
            this.streetAddress = objCon.MailingStreet;
            this.city = objCon.MailingCity;
            this.state = objCon.MailingStateCode;
            this.zip = objCon.MailingPostalCode;
            this.country = objCOn.MailingCountryCode;
            this.address = constructAddress();
            this.focusPractice = objCon.Focus_of_my_practice__c;
            this.surgeon = true;
        }
        public Attendee(Lead objLead){
            this.attendeeId = objLead.Id;
            this.attendeeType = LeadType;
            this.attendeeAccountId = objLead.Id;
            this.attendeeContactId = objLead.Id;
            this.name= objLead.Name;
            this.salutation = objLead.Salutation;
            this.firstName = objLead.FirstName;
            this.lastName = objLead.LastName;
            this.phone = objLead.MobilePhone;
            this.practicePhone = objLead.Phone;
            this.email = objLead.Email;
            /*
            this.streetAddress = String.isBlank(objLead.Street) ? objLead.LeadsApp_Street__c : objLead.Street;
            this.city = String.isBlank(objLead.City) ? objLead.LeadsApp_City__c : objLead.City;
            this.state = String.isBlank(objLead.StateCode) ? objLead.LeadsApp_State__c : objLead.StateCode;
            this.zip = String.isBlank(objLead.PostalCode) ? objLead.LeadsApp_Zip__c : objLead.PostalCode;
            this.country = objLead.CountryCode;
            this.address = constructAddress();
            this.title = objLead.Title;
            this.designation = objLead.Designation__c;
            this.accountName = objLead.Account_Name__c;
            this.practice = objLead.Practice_Name__c;
            this.surgeon = false;
            */
        }
        public Attendee(String p_id, String p_attendeeType, String p_name, String p_practice, String p_phone, String p_email, String p_address, String p_agency, String p_salesRep){
            this.attendeeId = p_id;
            this.attendeeType = p_attendeeType;
            this.name = p_name;
            this.practice = p_practice;
            this.phone = p_phone;
            this.email = p_email;
            this.address = p_address;
            this.agency = p_agency;
            this.salesRep = p_salesRep;
        }
        
        private String constructAddress(){
            String address = '';
            if(String.isNotBlank(this.streetAddress)){
                address += this.streetAddress + '. ';
            }
            if(String.isNotBlank(this.city)){
                address += this.city + ', ';
            }
            if(String.isNotBlank(this.state)){
                address += this.state + ' ';
            }
            if(String.isNotBlank(this.zip)){
                address += this.zip;
            }
            if(String.isNotBlank(this.country)){
                address += ' ' + this.country;
            }
            return address;
        }
    }   //  end of Attendee class
    
}   //  end of LeadManagementCtrl