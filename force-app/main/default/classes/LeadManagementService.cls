public with sharing class LeadManagementService {
    
    public List<LeadManagementVO.SelectableOption> getCampaigns(){
        List<LeadManagementVO.SelectableOption> lstCampaigns =new List<LeadManagementVO.SelectableOption>();
        
        Conference_Agent_Selection__c objUserSelection = this.getUserSelection();
        
        for(Conference__c objConf : [SELECT Id, Name, Start_Date__c, End_Date__c 
                                       FROM Conference__c 
                                      WHERE Parent_Conference__c = null
                                        AND Active__c = true
                                        AND End_Date__c >= TODAY
                                      ORDER BY Start_Date__c]){
            System.debug('##--Conf: ' + objConf);
            if(objUserSelection.ConferenceId__c == objConf.Id){
                lstCampaigns.add(new LeadManagementVO.SelectableOption(objConf.Id, objConf.Name, true));
            } else{
                lstCampaigns.add(new LeadManagementVO.SelectableOption(objConf.Id, objConf.Name, false));
            }
            
        }   //  end of for each Conference
        system.debug('##--lstCampaigns: ' + lstCampaigns);
        return lstCampaigns;
    }   //  end of getCampaigns
    
    
    public list<LeadManagementVO.SelectableOption> getTeams(String conferenceId){
        list<LeadManagementVO.SelectableOption> lstTeams =new list<LeadManagementVO.SelectableOption>();
        
        Conference_Agent_Selection__c objUserSelection = this.getUserSelection();
        
        for(Conference_Team__c  obj: [SELECT Id, Team__c, Team__r.Id, Team__r.Name 
                                        FROM Conference_Team__c  
                                       WHERE Conference__c  = :conferenceId 
                                       ORDER BY Sort_Order__c]){
                                     
            if(objUserSelection.TeamId__c == obj.Team__r.Id){
                lstTeams.add(new LeadManagementVO.SelectableOption(obj.Team__r.Id, obj.Team__r.Name, true));
            } else{
                lstTeams.add(new LeadManagementVO.SelectableOption(obj.Team__r.Id, obj.Team__r.Name, false));
            }
        }
        //lstTeams = [SELECT Id, Name FROM LeadsApp_Team__c ORDER BY Name];
        
        return lstTeams;
    }   //  end of getCampaigns
    
    public list<LeadManagementVO.SelectableOption> getInterestsForTeam(String teamId, String campaignId){
        System.debug('##-- Selected Team: ' + teamId);
        list<LeadManagementVO.SelectableOption> lstInterests = new list<LeadManagementVO.SelectableOption>();
        
        for(Conference_Interest__c objInterest : [SELECT Id, Name, Interest__r.Id, Interest__r.Name, Preferred__c 
                                                    FROM Conference_Interest__c 
                                                   WHERE Team__c =:teamId 
                                                     AND Conference__c = :campaignId 
                                                   ORDER BY preferred__c DESC, Interest__r.Name]){
            lstInterests.add(new LeadManagementVO.SelectableOption(objInterest.Id, objInterest.Interest__r.Name, false, objInterest.preferred__c));
        }   //  end of for-each
        
        
        System.debug('##-- Team Interests: ' + lstInterests);
        return lstInterests;
    }   //  end of getInterestsForTeam
    
    
    public Conference_Agent_Selection__c getUserSelection(){
        Conference_Agent_Selection__c agentSelection = new Conference_Agent_Selection__c();
        
        //Id currentUser = UserInfo.getUserId();
        
        try{
           // agentSelection = [SELECT Id, ConferenceId__c, TeamId__c From Conference_Agent_Selection__c where User__c= :currentUser LIMIT 1];
           retrieveUserSelection clsretrieveUserSelection = new retrieveUserSelection();
           agentSelection  = clsretrieveUserSelection.c_retrieveUserSelection();
        } catch(QueryException qe){
            system.debug('##-- Error: ' + qe.getMessage());
        }
        return agentSelection;
    }   //  end of getUserSelection
    
    
    public without sharing class retrieveUserSelection{
    
        public Conference_Agent_Selection__c c_retrieveUserSelection(){
        
            Conference_Agent_Selection__c agentSelection = new Conference_Agent_Selection__c();
             Id currentUser = UserInfo.getUserId();
        
            try{
               agentSelection = [SELECT Id, ConferenceId__c, TeamId__c From Conference_Agent_Selection__c where User__c= :currentUser LIMIT 1];
               
            } catch(QueryException qe){
                system.debug('##-- Error: ' + qe.getMessage());
            }
        
            return agentSelection;
        } // end of c_retrieveUserSelection
    
    }// end of retrieveUserSelection
    
    
    public void createCampaignMember(String campaignId, String attendeeId, String attendeeType){
        Conference_Member__c newCM = new Conference_Member__c();
        String lookupId = attendeeId;
        System.debug('##--createCampaignMember.campaignId: ' + campaignId);
        System.debug('##--createCampaignMember.attendeeType: ' + attendeeType);
        System.debug('##--createCampaignMember.attendeeId: ' + attendeeId);
        if(attendeeType.equalsIgnoreCase('Account')){
           // Account objAcc = [SELECT Id, Name, PersonContactId FROM Account WHERE Id= : attendeeId];
            retrieveAccountDetails clsRetrieveAccountDetails = new retrieveAccountDetails();
            Account objAcc = clsRetrieveAccountDetails.c_retrieveAccountDetails(attendeeId);
            
            //lookupId = objAcc.PersonContactId;
        }
        newCM = new Conference_Member__c(
                        Conference__c = campaignId,
                        Contact__c = lookupId);
        /*
        if(attendeeType.equalsIgnoreCase('Lead')){
            newCM = new CampaignMember(
                CampaignId = campaignId,
                LeadId = attendeeId);
        } else{
            newCM = new Conference_Member__c(
                Conference__c = campaignId,
                Contact__c = attendeeId);
        } 
        */
        insert newCM;
    }   //  end of createCampaignMember
    
    private without sharing class retrieveAccountDetails{
        
        public Account c_retrieveAccountDetails(Id attendeeId){
            
            Account acc = [SELECT Id, Name FROM Account WHERE Id= : attendeeId];
            return acc;
        }// end of c_retrieveAccountDetails
        
    }// end of retrieveAccountDetails
    
    public void createCampaignInteraction(String campaignId, String teamId, String attendeeId, String attendeeType){
        
        String lookupId = attendeeId;
        
        if(attendeeType.equalsIgnoreCase('Account')){
            Account objAcc = [SELECT Id, Name FROM Account WHERE Id= : attendeeId];
            //lookupId = objAcc.PersonContactId;
        }
            //  need to create a Conference member to the parent Campaign if one doesnt exist
        LIST<Conference_Member__c> lstParentMembers = [SELECT Id FROM Conference_Member__c
                                                        WHERE Conference__c = :campaignId
                                                          AND Contact__c =:lookupId];
        if(lstParentMembers == null || lstParentMembers.size()==0){
            this.createCampaignMember(campaignId, lookupId, 'Contact');
        }
        
        Conference__c interactionsCampaign = [SELECT Id, Name, Parent_Conference__c, Team__c,
                                                    (SELECT Id FROM Conference_Members__r WHERE Contact__c=:lookupId)
                                                FROM Conference__c
                                               WHERE Parent_Conference__c= :campaignId AND Team__c = :teamId];
        if(interactionsCampaign.Conference_Members__r != null && interactionsCampaign.Conference_Members__r.size()>0){
            return; 
            //  We do not want to add the interaction if it already exists
        }
        Conference_Member__c newCM = new Conference_Member__c(Conference__c = interactionsCampaign.Id,
                                                                Contact__c = lookupId);
        
        /*
        if(attendeeType.equalsIgnoreCase('Lead')){
            newCM = new CampaignMember(
                CampaignId = interactionsCampaign.Id,
                LeadId = attendeeId);
        } else{
            newCM = new CampaignMember(
                CampaignId = interactionsCampaign.Id,
                ContactId = attendeeId);
        }
        */
        
        insert newCM;
        
    }   //  end of createCampaignInteraction
    
    
    public List<LeadManagementVO.KeyValue> getListOfCountries(){
        List<LeadManagementVO.KeyValue> lstCountries = new List<LeadManagementVO.KeyValue>();
        
        /*Schema.DescribeFieldResult fieldResult =  Account.PersonMailingCountryCode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry a : ple) { //for all values in the picklist list
            lstCountries.add(new LeadManagementVO.KeyValue(a.value, a.label));
        }*/
        return lstCountries;
    }   //  end of getListOfCountries
    
    
    public Boolean createPersonCampaignInterests(String campaignId, String teamId, String attendeeId, String attendeeType, List<String> lstInterestIds){
        List<Person_Conference_Interest__c> lstNewInterests = new List<Person_Conference_Interest__c>();

        Conference__c childConf = this.getChildConference(campaignId, teamId);
        List<Conference__c> lstChildConfs = this.getChildConferences(campaignId);
        
        List<Person_Conference_Interest__c> lstDelInterests = [SELECT Id, Name, Conference_Interest__c 
                                                                 FROM Person_Conference_Interest__c 
                                                                WHERE Conference__c IN  :lstChildConfs
                                                                  AND Contact__c = :attendeeId              //(Contact__c = :attendeeId OR Lead__c = :attendeeId)
                                                                  AND Conference_Interest__c NOT IN :lstInterestIds];
        
        List<Person_Conference_Interest__c> lstPersonInterests = [SELECT Id, Name, Conference_Interest__c 
                                                                    FROM Person_Conference_Interest__c 
                                                                   WHERE Conference__c IN  :lstChildConfs 
                                                                     AND Contact__c = :attendeeId           //(Contact__c = :attendeeId OR Lead__c = :attendeeId)
                                                                     AND Conference_Interest__c IN :lstInterestIds];
        
        
        
        if(lstDelInterests != null && ! lstDelInterests.isEmpty()){
            delete lstDelInterests;
        }
        
        if(lstPersonInterests == null){
            lstPersonInterests = new LIST<Person_Conference_Interest__c>();
        }
        
        System.debug('##--lstPersonInterests: ' + lstPersonInterests);
        
        
        for(String campaignIntertestId : lstInterestIds){
            System.debug('##--campaignIntertestId: ' + campaignIntertestId);
            if(interestAlreadyCreated(lstPersonInterests, campaignIntertestId)){
                continue;
            }
            lstNewInterests.add(new Person_Conference_Interest__c(Conference__c = childConf.Id,
                                                                  Conference_Interest__c = campaignIntertestId,
                                                                  Contact__c = attendeeId));
            /*
            if(attendeeType.equalsIgnoreCase('Lead')){
                lstNewInterests.add(new Person_Conference_Interest__c(Conference__c = campaignId,
                                                                      Conference_Interest__c = campaignIntertestId,
                                                                      Lead__c  = attendeeId));
            } else {
                lstNewInterests.add(new Person_Conference_Interest__c(Conference__c = childConf.Id,
                                                                      Conference_Interest__c = campaignIntertestId,
                                                                      Contact__c = attendeeId));
            }*/
            
        }
        
        if(! lstNewInterests.isEmpty()){
            insert lstNewInterests;
        }
        return true;
    }   //  end of campaignInterestsFor
    
    public List<Person_Conference_Interest__c> interestHistoryForAttendee(String campaignId, String attendeeId, String attendeeType, String dateConvert){
        System.debug('##--Inside interestHistoryForAttendee: ' + campaignId + '\tAttendeeId: ' + attendeeId);
        List<Person_Conference_Interest__c> lstPersonInterests = new List<Person_Conference_Interest__c>();
        List<Conference__c> lstChildConfs = getChildConferences(campaignId);
        
        lstPersonInterests = [SELECT Id, Name, createdDate, createdBy.Name, Contact__c, contact__r.Name, Conference__c, Conference__r.Name, 
                              Conference_Interest__c, Conference_Interest__r.interest__r.Name 
                              FROM Person_Conference_Interest__c
                              WHERE Conference__c IN  :lstChildConfs 
                                AND Contact__c = :attendeeId        //(Contact__c = :attendeeId OR Lead__c = :attendeeId)
                              ORDER BY createdDate DESC];
        for(Person_Conference_Interest__c lpi : lstPersonInterests){
            
            //used to convert from dateTime to format in mockup
            Datetime myDateTime = lpi.CreatedDate;
            dateConvert = myDateTime.format('MM/dd/yyyy h:mm a');
            system.debug('======'+dateConvert);
            
        }
        
        return lstPersonInterests;
    }   //  end of interestHistoryForAttendee
    
    
    public Account createNewAttendee(LeadManagementCtrl.Attendee newLead){
        system.debug('##-- Create request for: ' + newLead);
        Account objAcc = new Account();
                                    /*Phone = newLead.practicePhone,
                                    
                                    
                                    Designation__c = newLead.designation,
                                    
                                    Practice_Name__c = newLead.practice
                                    );*/
        
        objAcc.RecordTypeId = getRecordTypeSelectedId('Undefined');
        
        /*if(newLead.surgeon){
            objAcc.RecordTypeId = getRecordTypeSelectedId('Surgeon Attendee');
        } else{
            objAcc.RecordTypeId = getRecordTypeSelectedId('Non Surgeon Attendee');
        }*/
        
        System.debug('##-- Going to save the new Lead: ' + objAcc);
        insert objAcc;
        
        return objAcc;
    }   //  end of createNewAttendee
    
    public void createOrUpdateTasks(String campaignId, String teamId, String attendeeId, String attendeeType, List<LeadManagementVO.AttendeeTaskInfo> lstTasks){
        
        Conference__c interactionsCampaign = getInteractionsCampaign(campaignId, teamId);
        Map<String, String> mapRecordTypeNameID = getCaseRecordTypes();
        Map<String, Case> mapRecordTypeCase = getCasesFor(interactionsCampaign.Id, attendeeId);
        List<Case> lstNewCases = new List<Case>();
        
        for(LeadManagementVO.AttendeeTaskInfo task : lstTasks){
            if(mapRecordTypeCase.containsKey(task.taskType)){
                Case objCase = mapRecordTypeCase.get(task.taskType);
                objCase.Description = task.taskDetails;
                lstNewCases.add(objCase);
                
            } else {
                Case objCase = new Case(RecordTypeId = mapRecordTypeNameID.get(task.taskType),
                                        Subject = task.taskType,
                                        Description = task.taskDetails,
                                        Conference__c  = interactionsCampaign.Id);
                objCase.ContactId = attendeeId;
                /*
                if(attendeeType.equalsIgnoreCase('Lead')){
                    objCase.Lead__c = attendeeId;
                } else {
                    objCase.ContactId = attendeeId;
                }*/
                lstNewCases.add(objCase);
            }
        }   //  end of for-each new Task
        System.debug('##--lstNewCases: ' + lstNewCases);
        if(! lstNewCases.isEmpty()){
            upsert lstNewCases;
        }
        
    }   //  end of createOrUpdateTasks
    
    
    
    public static List<Campaign> getAllParentCampaigns(){
        List<Campaign> lstParentCampaigns = [SELECT Id, Name, StartDate, EndDate, Type, Status FROM Campaign WHERE isActive=true AND ParentId=null];
        
        return  lstParentCampaigns;
    }   //  end of getAllParentCampaigns
    
    
    public static List<Campaign> getAllDependentCampaigns(List<string> lstCampaignIds){
        List<Campaign> lstDependentCampaigns = [SELECT Id, Name, StartDate, EndDate FROM Campaign WHERE ParentId= :lstCampaignIds];
        
        return  lstDependentCampaigns;
    }   //  end of 
    
    public static List<CampaignMember> getAllDependentCampaignMembers(List<string> lstCampaignIds){
        List<CampaignMember> lstDependentCampaignMembers = [SELECT Id, Name, FirstName, LastName, Status, CampaignId, LeadOrContactId 
                                FROM CampaignMember WHERE CampaignId = :lstCampaignIds];
        
        return  lstDependentCampaignMembers;
    }   //  end of 
    
    public static map<string, list<CampaignMember>> getAllActiveCampaignsAndCampaignMembers(){
        
        map<string, list<CampaignMember>> mapCampaignAndListCampaignMembers = new map<string, list<CampaignMember>>();
        for(CampaignMember objCampaignMember : [SELECT Id, Name, FirstName, LastName, Status, CampaignId, LeadOrContactId, Campaign.Name
                                                        FROM CampaignMember WHERE Campaign.ParentId = null AND Campaign.IsActive = true]    ){
                                                            
            if(mapCampaignAndListCampaignMembers.get(objCampaignMember.Campaign.Name) == null){
                mapCampaignAndListCampaignMembers.put(objCampaignMember.Campaign.Name, new list<CampaignMember>());
            }   
            mapCampaignAndListCampaignMembers.get(objCampaignMember.Campaign.Name).add(objCampaignMember);                                      
        }// end of each
        
        return mapCampaignAndListCampaignMembers;
    }// end of getAllActiveCampaignsAndCampaignMembers
    
    public static list<Person_Conference_Interest__c> getAllPersonCampaignInterests(string campaignId, string leadId, string contactId){
        
        system.debug('##--getAllPersonCampaignInterests.campaignId: '+ campaignId);
        system.debug('##--getAllPersonCampaignInterests.leadId: '+ leadId);
        system.debug('##--getAllPersonCampaignInterests.contactId: '+ contactId);
        string query = 'SELECT Id, Conference_Interest_Name__c, Conference_Interest__c, Contact__c, Contact__r.Name, Conference__r.Name, ';
              query += 'Team_Name__c, Lead__r.Name FROM Person_Conference_Interest__c WHERE Conference__c = :campaignId ';
              query += ' AND Contact__c = :contactId';
             /*
             if(leadId != null && leadId != ''){
                
                query += ' AND Lead__c = :leadId';
              }else if(contactId != null || contactId != ''){
                query += ' AND Contact__c = :contactId';
              }
              */
              
        system.debug('##--getAllPersonCampaignInterests.query: '+ query);
        List<Person_Conference_Interest__c> lstPersonCampaignInterests = database.query(query);  
        /*List<LeadsApp_PersonCampaignInterest__c> lstPersoncampaign  = [SELECT Id, Campaign_Interest_Name__c, CampaignInterest__c, Contact__c, Contact__r.Name,
                                                                                    Lead__c, Team_Name__c, Lead__r.Name
                                                                                    FROM LeadsApp_PersonCampaignInterest__c 
                                                                                    WHERE Campaign__c = :campaignId];*/
        
        return  lstPersonCampaignInterests;
    }// end of getAllPersonCampaignInterests
    
    public static list<Conference_Member__c> getAllConferenceMembers(){
        
        list<Conference_Member__c> lstConferenceMembers = [SELECT Id, Attended__c, Conference__c, Conference__r.Name, Contact__c, Contact__r.AccountId, Contact__r.Name,  
                                                                    Contact__r.FirstName, Contact__r.LastName, RSVP__c, Invited__c
                                                                    
                                                                    FROM Conference_Member__c WHERE Conference__r.Parent_Conference__c  = ''];
        system.assertEquals(lstConferenceMembers.size(), 10);
        return lstConferenceMembers;
    }// end of getAllConferenceMembers
    
    public class ConferenceMemberWrapper{
        
        string teamName {get; set;}
        Conference_Member__c objConferenceMember {get;set;}
        string status {get;set;}
        string productTeam {get;set;}
        
        
        public ConferenceMemberWrapper(string p_TeamName, Conference_Member__c p_ObjConferenceMember){
            
            teamName = p_TeamName;
            objConferenceMember = p_ObjConferenceMember;
            status = p_ObjConferenceMember.Attended__c == true? 'Lead' : '';
        }//ConferenceMemberWrapper 
        
    }// end of ConferenceMemberWrapper
    
    public static list<Conference_Member__c> getArthrexCafeConferenceMember(Id ConfereceId, Id ContactId){
        
        list<Conference_Member__c> lstArthrexCafeConferenceMembers = [SELECT Id, Attended__c, Conference__c, Conference__r.Name, Contact__c, Contact__r.AccountId, Contact__r.Name,  
                                                                        Contact__r.FirstName, Contact__r.LastName, RSVP__c, Invited__c 
                                                                            FROM Conference_Member__c 
                                                                            WHERE Conference__r.Parent_Conference__c =:confereceId
                                                                            AND Contact__c =:contactId
                                                                            AND Conference__r.Name Like '%Arthrex Cafe%'];
                                                                    
        return lstArthrexCafeConferenceMembers;
        
    }
    
    public static list<ConferenceMemberWrapper> getAllConferenceMemberWrappers(){
        
        list<ConferenceMemberWrapper> lstConferenceMemberWrapper = new list<ConferenceMemberWrapper>();
        list<Conference_Member__c> lstConferenceMembers = getAllConferenceMembers();
        set<Id> setConferenceMemberAccountIds = new set<Id>();
        map<Id, string> mapAccountIdAndTerrirtoryName = new map<Id, string>();
        
        for(Conference_Member__c objConferenceMember : lstConferenceMembers){
            
            if(objConferenceMember.Contact__r.AccountId != null){
                setConferenceMemberAccountIds.add(objConferenceMember.Contact__r.AccountId);
            }
        }// end of for-each
        
        if(setConferenceMemberAccountIds.size() > 0){
            mapAccountIdAndTerrirtoryName = retriveMapAccountIdAndTerrirtoryName(setConferenceMemberAccountIds);
        }
        
        for(Conference_Member__c objConferenceMember : lstConferenceMembers){
            
            string territoryName = '';
            if(mapAccountIdAndTerrirtoryName.get(objConferenceMember.contact__r.AccountId) != null){
                territoryName = mapAccountIdAndTerrirtoryName.get(objConferenceMember.contact__r.AccountId);
            }
            
            lstConferenceMemberWrapper.add(new ConferenceMemberWrapper(territoryName, objConferenceMember));
        }
        
        populateProductTeam(lstConferenceMemberWrapper);
        
        return lstConferenceMemberWrapper;
    }// end of getAllConferenceMemberWrappers
    
    public static void populateProductTeam(list<ConferenceMemberWrapper> lstConferenceMembers){
        
        set<Id> setConferenceMemberIds = new set<Id>();
        set<Id> setConferenceIds = new set<Id>();
        map<string, set<string>> mapKeyAndProductTeam = new map<string, set<string>>();
        for(ConferenceMemberWrapper objConferenceWrapper : lstConferenceMembers){
            
            if(objConferenceWrapper.objConferenceMember.Contact__c != null){
                setConferenceMemberIds.add(objConferenceWrapper.objConferenceMember.Contact__c);
            }
            
            if(objConferenceWrapper.objConferenceMember.Conference__c != null){
                setConferenceIds.add(objConferenceWrapper.objConferenceMember.Conference__c);
            }
        }// end of for-each
        
        
        for(Person_Conference_Interest__c objPersonConferenceInterest :[SELECT Id, Contact__c, Conference__c, Conference_Interest_Name__c, Team_Name__c
                                                                                FROM Person_Conference_Interest__c
                                                                                WHERE Conference__c IN :setConferenceIds
                                                                                AND Contact__c IN :setConferenceMemberIds ] ){
            
            string keyContactAndConferenceId =  objPersonConferenceInterest.Contact__c +'_'+ objPersonConferenceInterest.Conference__c;                                     
            if(mapKeyAndProductTeam.get(keyContactAndConferenceId) == null){
                mapKeyAndProductTeam.put(keyContactAndConferenceId, new set<string>());
            }
            mapKeyAndProductTeam.get(keyContactAndConferenceId).add(objPersonConferenceInterest.Team_Name__c); 
                                                                                    
        }// end of for-each
        
        for(ConferenceMemberWrapper objConferenceWrapper : lstConferenceMembers){
            
            string c_keyContactAndConferenceId =    objConferenceWrapper.objConferenceMember.Contact__c +'_'+ objConferenceWrapper.objConferenceMember.Conference__c;
            
            if(mapKeyAndProductTeam.get(c_keyContactAndConferenceId) != null){
                
                list<string> lstProductTeam = new list<string>();
                lstProductTeam.addALL(mapKeyAndProductTeam.get(c_keyContactAndConferenceId));
                string p_ProductTeam = string.join(lstProductTeam, '; ');
                objConferenceWrapper.productTeam = p_ProductTeam;
            }
            
        }// end of for-each
        
        
    }// end of populateProductTeam 
    
    
    public static map<Id, string> retriveMapAccountIdAndTerrirtoryName(set<Id>setAccountIds){
        
        map<Id, string> mapAccountIdAndTerrirtoryName = new map<Id, string>();
        for(ObjectTerritory2Association objTerritory2Association : [SELECT Id, Territory2.Name, objectId FROM ObjectTerritory2Association 
                                                                            WHERE objectId IN :setAccountIds]){
                                                                                
                                                                                
            mapAccountIdAndTerrirtoryName.put(objTerritory2Association.objectId, objTerritory2Association.Territory2.Name);                                                                 
        }
        
        return mapAccountIdAndTerrirtoryName;
    }// end of retriveMapAccountIdAndTerrirtoryName
    
    public static list<Case> retrieveGeneralComments(Id ConferenceId, Id ContactId){
        
        list<Case> lstGeneralComments = [SELECT Id, Description, RecordType.Name, Subject, Conference__r.Team__r.name
                                                    FROM Case 
                                                    WHERE Conference__r.Parent_Conference__c = :ConferenceId 
                                                    AND ContactId =:ContactId
                                                    ORDER BY  Conference__r.Team__r.name ASC];
        
        return lstGeneralComments;
    }// end of retrieveGeneralComments
    
    
    public static map<string, list<Person_Conference_Interest__c>> retrievePersonCoferenceInterests(Id ConferenceId, Id ContactId){ 
                                                                                        
        map<string, list<Person_Conference_Interest__c>> mapTeamNameAndListPersonConfInterest = new map<string, list<Person_Conference_Interest__c>> ();
        
        for(Person_Conference_Interest__c objPersonConfInterest : [SELECT Id, Team_Name__c, Conference_Interest_Name__c
                                                                                        FROM Person_Conference_Interest__c 
                                                                                        WHERE Conference__r.Parent_Conference__c = :ConferenceId 
                                                                                        AND Contact__c =:ContactId 
                                                                                        AND Conference_Interest_Name__c != 'Attended Arthrex Café'
                                                                                        ORDER BY Team_Name__c ASC]){
                                                                                            
            if(mapTeamNameAndListPersonConfInterest.get(objPersonConfInterest.Team_Name__c) == null){
                mapTeamNameAndListPersonConfInterest.put(objPersonConfInterest.Team_Name__c, new list<Person_Conference_Interest__c> ());
            }   
            mapTeamNameAndListPersonConfInterest.get(objPersonConfInterest.Team_Name__c).add(objPersonConfInterest);                                                                            
        }// end of for-each
        return mapTeamNameAndListPersonConfInterest;
    }// end of retrievePersonCoferenceInterests
    
    public static List<Conference_Team__c> getConferenceTeams(Id ConferenceId){
        List<Conference_Team__c> lstTeams = new List<Conference_Team__c>();
        lstTeams = [SELECT Id, Team__c, Team__r.Id, Team__r.Name 
                        FROM Conference_Team__c  
                        WHERE Conference__c  = :conferenceId 
                        ORDER BY Sort_Order__c];
        return lstTeams;
    }   //  end of getConferenceTeams
    
    /*
public Map<String,List<String>> GetDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName){
Map<String,List<String>> objResults = new Map<String,List<String>>();
//get the string to sobject global map
Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
if (!objGlobalMap.containsKey(pObjName))
return objResults;
//get the type being dealt with
Schema.SObjectType pType = objGlobalMap.get(pObjName);
Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
//verify field names
if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName))
return objResults;     
//get the control values   
List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
//get the dependent values
List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
//iterate through the values and get the ones valid for the controlling field name
Bitset objBitSet = new Bitset();
//set up the results
for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){           
//get the pointer to the entry
Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
//get the label
String pControllingLabel = ctrl_entry.getLabel();
//create the entry with the label
objResults.put(pControllingLabel,new List<String>());
}
//cater for null and empty
objResults.put('',new List<String>());
objResults.put(null,new List<String>());
//check the dependent values
for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){          
//get the pointer to the dependent index
Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
//get the valid for
String pEntryStructure = JSON.serialize(dep_entry);                
LeadManagementVO.TPicklistEntry objDepPLE = (LeadManagementVO.TPicklistEntry)JSON.deserialize(pEntryStructure, LeadManagementVO.TPicklistEntry.class);
//if valid for is empty, skip
if (objDepPLE.validFor==null || objDepPLE.validFor==''){
continue;
}
//iterate through the controlling values
for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){    
if (objBitSet.testBit(objDepPLE.validFor,pControllingIndex)){                   
//get the label
String pControllingLabel = ctrl_ple[pControllingIndex].getLabel();
objResults.get(pControllingLabel).add(objDepPLE.label);
}
}
} 
return objResults;

}   //  end of GetDependentOptions
*/
    
    public Map<String,List<String>> GetDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName){
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!Schema.getGlobalDescribe().containsKey(pObjName))
            return objResults;
        //get the type being dealt with
        Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
        return GetDependentOptionsImpl(pType,pControllingFieldName,pDependentFieldName);        
    }   //  end of GetDependentOptions
    
    public Map<String,List<String>> GetDependentOptionsImpl(Schema.SObjectType pType, String pControllingFieldName, String pDependentFieldName){
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        if (pType==null)
            return objResults;
        Bitset BitSetInstance = new Bitset();
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        //verify field names
        if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName))
            return objResults;     
        //get the control values   
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        //get the dependent values
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
        objFieldMap = null;
        List<Integer> lstControllingIndexes = new List<Integer>();
        //iterate through the values and get the ones valid for the controlling field name
        //set up the results
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){           
            //get the pointer to the entry
            Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
            //get the label
            String pControllingLabel = ctrl_entry.getLabel();
            //create the entry with the label
            objResults.put(pControllingLabel,new List<String>());
            //keep track of the controlling indexes
            lstControllingIndexes.add(pControllingIndex);
        }
        //cater for null and empty
        objResults.put('',new List<String>());
        objResults.put(null,new List<String>());
        //load all dep entries
        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<LeadManagementVO.TPicklistEntry> objDS_Entries = new List<LeadManagementVO.TPicklistEntry>();
        //add all entries
        for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){          
            //get the pointer to the dependent index
            Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
            objEntries.add(dep_entry);
            
        } 
        //serialize once        
        objDS_Entries = (List<LeadManagementVO.TPicklistEntry>)JSON.deserialize(JSON.serialize(objEntries), List<LeadManagementVO.TPicklistEntry>.class);
        List<Integer> validIndexes;
        for (LeadManagementVO.TPicklistEntry objDepPLE : objDS_Entries){
            //if valid for is empty, skip    
            if (objDepPLE.validFor==null || objDepPLE.validFor==''){
                continue;
            }
            //get the test for the controlling indexes
            /*validIndexes = BitSetInstance.testBits(objDepPLE.validFor,lstControllingIndexes);
            for (Integer validIndex : validIndexes){                
                //get the label
                String pControllingLabel = ctrl_ple[validIndex].getLabel();
                objResults.get(pControllingLabel).add(objDepPLE.label);
            }*/
        }
        objEntries = null;
        objDS_Entries = null;
        return objResults;
    }   //  end of GetDependentOptionsImpl
    
    
    private Boolean interestAlreadyCreated(List<Person_Conference_Interest__c> lstPersonInterests, String campaignIntertestId){
        
        for(Person_Conference_Interest__c personInterest : lstPersonInterests){
            if(campaignIntertestId.equalsIgnoreCase(personInterest.Conference_Interest__c)){
                return true;
            }
        }
        return false;
    }   //  end of interestAlreadyCreated
    
    private Conference__c getChildConference(String conferenceId, String teamId){
        Conference__c childConf;
        try{
            childConf = [SELECT Id, Name, Parent_Conference__c
                           FROM Conference__c
                          WHERE Parent_Conference__c = :conferenceId
                            AND Team__c = :teamId];
        } catch(Exception e){
            AuraHandledException ae = new AuraHandledException('Selection missing from Campaign options, please open a ticket for campaign team to correct issue.');
            throw ae;
        }
        
        return childConf;
    }   //  end of getChildConference
    
    private List<Conference__c> getChildConferences(String conferenceId){
        return [SELECT Id, Name, Parent_Conference__c
                  FROM Conference__c
                 WHERE Parent_Conference__c = :conferenceId];
    }   //  end of getChildConferences
    
    
    private String getRecordTypeSelectedId(String recordTypeName){
        
        String rtId;
        List<RecordType> rtList = New List<RecordType>([Select Id, Name From RecordType Where sObjectType = 'Account']);
        for(RecordType rt : rtList) {
            if(rt.Name == recordTypeName) {
                rtId = rt.Id;
            }
        }
        return rtId;        
    }   //  end of getRecordTypeSelectedId
    
    private Map<String, String> getCaseRecordTypes(){
        Map<String, String> mapNameId = new Map<String, String>();
        
        List<RecordType> rtList = New List<RecordType>([Select Id, Name From RecordType Where sObjectType = 'Case']);
        for(RecordType rt : rtList){
            mapNameId.put(rt.Name, rt.Id);
        }   //  end of for-each recordtype
        return mapNameId;
    }   //  end of getCaseRecordTypes
    
    private Conference__c getInteractionsCampaign(String campaignId, String teamId){
        Conference__c objCampaign = [SELECT Id FROM Conference__c WHERE Parent_Conference__c = :campaignId AND Team__c = :teamId];
        
        return objCampaign;
    }   //  end of getInteractionsCampaign
    
    
    private Map<String, Case> getCasesFor(String interactionCampaingId, String attendeeId){
        Map<String, Case> mapSubjectCase = new Map<String, Case>();
        
        for(Case objCase : [SELECT Id, Subject, Description, ContactId, Conference__c, RecordType.Name
                            FROM Case
                            WHERE Conference__c = :interactionCampaingId
                            AND ContactId = :attendeeId]){  //  (ContactId = :attendeeId OR Lead__c = :attendeeId)
                                mapSubjectCase.put(objCase.RecordType.Name, objCase);  
                            }   //end of for-eac case
        
        return mapSubjectCase;
    }   //  end of getCasesFor
    
    
}   //  end of LeadManagementService