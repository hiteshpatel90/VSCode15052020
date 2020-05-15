@isTest
public class CS_EventsService_Test {
    
    public static final String AXIS_EVENT_RECORD_TYPE = 'Axis Event';
    public static final String AXIS_EVENT_TYPE_SURG_CASE = 'Surgical Case';
    public static final String AXIS_EVENT_TYPE_OUT_OF_OFFICE = 'Out of Office';
    public static final String AXIS_EVENT_TYPE_MEETING = 'Meeting';
    public static final String AXIS_EVENT_TYPE_RIDE_ALONG = 'Ride Along';
    public static final String AXIS_EVENT_TYPE_TRAINING = 'Training';
    public static final String AXIS_EVENT_TYPE_DEMONSTRATION = 'Demonstration';
    public static final String AXIS_EVENT_TYPE_LOCAL_LAB = 'Local Lab';
    
    private static User adminUser = null;
    private static User axisUser = null;
    private static User u = null;
    private static Account ac = null;
    private static Contact con = null;
    private static Case__c cas = null;
    private static CaseParticipant__c casPart = null;
    private static Event eveMeeting = null;
    private static Event eveTraining = null;
    private static Practitioner_Procedure__c prefCard = null;
    private static Procedure__c proc = null;
    private static Opportunity opp = null;
    private static DateTime datestart = null;
    private static DateTime dateend = null;

    private static Account ac2 = null;
    private static Contact con2 = null;
    private static User u2 = null;
    
    private static User portalUser;
    private static Contact portalUserContact;
    private static Account agencyAccount;
   
    private static Account practitioner = null;
    private static Account surgeon = null;
    private static Account healthCareProviderAccount = null;
    

    static testmethod void saveOutOfOfficeEventTest() {
        setupData();
        
        
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c, Subject from Event LIMIT 1];
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('id',eve.Id);
            eveMap.put('startDate',longStartDate);
            eveMap.put('endDate',longEndDate);
            eveMap.put('selectedOwnerId',eve.OwnerId);
            // eveMap.put('selectedOwnerId',eve.OwnerId);
            // eveMap.put('selectedOwnerId',eve.OwnerId);
            System.debug('###eveMap: '+ eveMap);
            System.debug('###eveMap: '+ eveMap);
            
            Test.startTest();
            
            CS_EventsService.getEvents();//System.today(), System.today(), 'eveMap');
            CS_EventsService.getTeamsAndTerritories();
            CS_EventsService.saveOutOfOfficeEvent(eve, eveMap);
            CS_EventsService.saveSurgicalCaseEvent(eve, null, eveMap);
            
            Case__c cas = [SELECT Id FROM Case__c LIMIT 1];
            // get the existing surgical case
            CS_ARCalendarEventDTO calEventDTO = new CS_ARCalendarEventDTO();
            calEventDTO.url = cas.id;
            
            eve = [SELECT Id, OwnerId, WhoId, StartDateTime, EndDateTime, Event_Status__c, IsAllDayEvent, Subject from Event LIMIT 1];
            
            eveMap = new Map<String, Object>();
            List<String> whoList = new List<String>();
            whoList.add(eve.WhoId);
            eveMap.put('attendeeIds',whoList);
            CS_EventsService.saveSurgicalCaseEvent(eve, calEventDTO, eveMap);
            
            Test.stopTest();
        
    }
    
    static testmethod void saveMeetingEventTest() {
        setupData();
        
        
            Event eve = [SELECT Id, 
                        StartDateTime, 
                        EndDateTime, 
                        Event_Status__c, 
                        Calendar_Name__c,
                        Description, 
                        Location,
                        Notes__c,
                        OwnerId,
                        RecordTypeId,
                        Related_Account__c,
                        Subject,
                        WhatId,
                        WhoId from Event 
                        LIMIT 1];
                        
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
            
                List<String> whoList = new List<String>();
                whoList.add(newCon.Id);
                
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('id',eve.Id);
            eveMap.put('isAgencyEvent',TRUE);
            eveMap.put('startDate',longStartDate);
            eveMap.put('endDate',longEndDate);
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('calendarName',eve.Calendar_Name__c);
            eveMap.put('description',eve.Subject);
            eveMap.put('location',eve.Location);
            eveMap.put('comments',eve.Description);
            eveMap.put('providerId',eve.Related_Account__c);
            eveMap.put('attendeeIds',whoList);
            
            Test.startTest();
            
            CS_EventsService.saveMeetingEvent(eve, eveMap);
            
            Test.stopTest();
            }
        
    }
    
    static testmethod void saveTrainingEventTest() {
        setupData();
        
            Event eve = [SELECT Id, 
                        StartDateTime, 
                        EndDateTime, 
                        Event_Status__c, 
                        Calendar_Name__c,
                        Description, 
                        Location,
                        Notes__c,
                        OwnerId,
                        RecordTypeId,
                        Related_Account__c,
                        Subject,
                        WhatId,
                        Type,
                        WhoId from Event
                        Where Type =: AXIS_EVENT_TYPE_TRAINING
                        LIMIT 1];
                        
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
            
                List<String> whoList = new List<String>();
                whoList.add(newCon.Id);
                
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('id',eve.Id);
            eveMap.put('isAgencyEvent',TRUE);
            eveMap.put('startDate',longStartDate);
            eveMap.put('endDate',longEndDate);
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('calendarName',eve.Calendar_Name__c);
            eveMap.put('description',eve.Subject);
            eveMap.put('location',eve.Location);
            eveMap.put('comments',eve.Description);
            eveMap.put('providerId',eve.Related_Account__c);
            eveMap.put('attendeeIds',whoList);
            
            Test.startTest();
            
            System.debug('###eve: ['+eve+']');
            System.debug('###eveMap: ['+eveMap+']');
            
            CS_EventsService.saveTrainingEvent(eve, eveMap);
            
            Test.stopTest();
            }
        
    }
    
    static testmethod void saveDemonstrationEventTest() {
        setupData();
        
            Event eve = [SELECT Id, 
                        StartDateTime, 
                        EndDateTime, 
                        Event_Status__c, 
                        Calendar_Name__c,
                        Description, 
                        Location,
                        Notes__c,
                        OwnerId,
                        RecordTypeId,
                        Related_Account__c,
                        Subject,
                        WhatId,
                        WhoId from Event 
                        LIMIT 1];
                        
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
            
                List<String> whoList = new List<String>();
                whoList.add(newCon.Id);
                
        
           
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('id',eve.Id);
            eveMap.put('isAgencyEvent',TRUE);
            eveMap.put('startDate',longStartDate);
            eveMap.put('endDate',longEndDate);
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('calendarName',eve.Calendar_Name__c);
            eveMap.put('description',eve.Subject);
            eveMap.put('location',eve.Location);
            eveMap.put('comments',eve.Description);
            eveMap.put('providerId',eve.Related_Account__c);
            eveMap.put('attendeeIds',whoList);
            
            Test.startTest();
            
            CS_EventsService.saveDemonstrationEvent(eve, eveMap);
            
            Test.stopTest();
            
            }
        
    }
    
    static testmethod void saveRideAlongEventTest() {
        setupData();
        
            Event eve = [SELECT Id, 
                        StartDateTime, 
                        EndDateTime, 
                        Event_Status__c, 
                        Calendar_Name__c,
                        Description, 
                        Location,
                        Notes__c,
                        OwnerId,
                        RecordTypeId,
                        Related_Account__c,
                        Subject,
                        WhatId,
                        WhoId from Event 
                        LIMIT 1];
                        
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
            
                List<String> whoList = new List<String>();
                whoList.add(newCon.Id);
                
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('endDate',longEndDate);
            eveMap.put('startDate',longStartDate);
            eveMap.put('description',eve.Subject);
            eveMap.put('location',eve.Location);
            eveMap.put('comments',eve.Description);
            eveMap.put('providerId',eve.Related_Account__c);
            eveMap.put('attendeeIds',whoList);
            
            Test.startTest();
            
            CS_EventsService.saveRideAlongEvent(eve, eveMap);
            
            Test.stopTest();
            }
        
    }
    
    static testmethod void saveRideAlongEventNegativeTest() {
        setupData();
        
            Event eve = [SELECT 
                        StartDateTime, 
                        EndDateTime, 
                        Event_Status__c, 
                        Calendar_Name__c,
                        Description, 
                        Location,
                        Notes__c,
                        OwnerId,
                        RecordTypeId,
                        Related_Account__c,
                        Subject,
                        WhatId,
                        WhoId from Event 
                        LIMIT 1];
                        
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
            
                List<String> whoList = new List<String>();
                whoList.add(newCon.Id);
                
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('endDate',longEndDate);
            eveMap.put('startDate',longStartDate);
            eveMap.put('description',eve.Subject);
            eveMap.put('location',eve.Location);
            eveMap.put('comments',eve.Description);
            eveMap.put('providerId',eve.Related_Account__c);
            eveMap.put('attendeeIds',whoList);
            
            Test.startTest();
            
            CS_EventsService.saveRideAlongEvent(eve, eveMap);
            
            Test.stopTest();
            }
        
    }
    
    static testmethod void saveLocalLabEventTest() {
        
        setupData();
        
                        
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Id eventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Axis Event').getRecordTypeId();
                
                // Account practitioner1 = DataFactoryAccount.createPractitionerAccount(
                //     practitioner1.PersonEmail = 'testpersonemailXXX@arthrex.com');
                // insert practitioner1;
                
                Account practitioner1 = new Account(Name = 'TestPractitionerFirstName',
                                        //LastName = 'TestPractitionerLastName',
                                        //PersonEmail = 'testpersonemailXX@arthrex.com',
                                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_PRACTITIONER).getRecordTypeId()
                );
                                        
                Database.Insert(practitioner1);
                
                Account healthCareProviderAccount1 = DataFactoryAccount.createHealthCareProviderAccount();
                insert healthCareProviderAccount1;       
                
                Account surgeon1 = DataFactoryAccount.createSurgeonContact();
                insert surgeon1;
                
                Account newAcc = new Account(name ='TestAcc1', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact1',AccountId = ac.Id);
                Database.Insert(newCon);
                
                Local_Lab__c lab = new Local_Lab__c(
                    Surgeon__c = surgeon1.Id
                );
                Database.Insert(lab);
                
                Case__c cas = new Case__c(
                    Health_Care_Provider__c = healthCareProviderAccount1.Id,
                    //Surgeon__c = surgeon.Id,
                    Practitioner__c = practitioner1.Id,
                    Status__c = 'Pending'
                );
            
                Database.Insert(cas);
                
                Event eveNew = new Event(
                    //AccountId = ac2.Id,
                    Type = AXIS_EVENT_TYPE_MEETING,
                    Related_Account__c = healthCareProviderAccount1.Id,
                    WhoId = con.Id,
                    WhatId = lab.Id,
                    Calendar_Name__c = 'Test Calendar',
                    Location = 'Room XYZ',
                    Event_Status__c = 'Pending',
                    RecordTypeId = eventRecordTypeId,
                    //Priority = 'High',
                    Subject = 'Out of Office',
                    Description = 'Test Desc',
                    IsAllDayEvent = True,
                    EndDateTime = System.Today(),
                    StartDateTime = System.Today()//,
                    // ActivityDateTime = System.Today(),
                    // DurationInMinutes = 0
                        
                );
                //Database.Insert(eveNew);
                
                DateTime dtstartMS = eveNew.StartDateTime;
                DateTime dtendMS = eveNew.EndDateTime;
                Long longStartDate = dtstartMS.getTime();
                Long longEndDate = dtendMS.getTime();
            
                List<String> whoList = new List<String>();
                whoList.add(newCon.Id);
            
            Map<String, Object> eveMap = new Map<String, Object>();
            
            //if(whoList.size() >= 1){
                
                eveMap.put('isAgencyEvent',TRUE);
                eveMap.put('selectedOwnerId',eveNew.OwnerId);
                eveMap.put('endDate',longEndDate);
                eveMap.put('startDate',longStartDate);
                eveMap.put('subtype',eveNew.Event_Subtype__c);
                eveMap.put('description',eveNew.Subject);
                eveMap.put('location',eveNew.Location);
                eveMap.put('comments',eveNew.Description);
                eveMap.put('status',eveNew.Event_Status__c);
                eveMap.put('providerId',eveNew.Related_Account__c);
                eveMap.put('attendeeIds',whoList);
            //}
            
            
            
            System.debug('###eve: '+ eveNew);
            System.debug('###eveMap: '+ eveMap);
            
            Test.startTest();
            
            
            //CS_EventsService.saveLocalLabEvent(eveNew, eveMap);
            
            
            
            Test.stopTest();
            }
        
    }
    
    static testmethod void saveCalendarEventDTOTest() {
        setupData();
        
            Event eve = [SELECT Id, 
                        StartDateTime, 
                        EndDateTime, 
                        Event_Status__c, 
                        Calendar_Name__c,
                        Description, 
                        Location,
                        Notes__c,
                        OwnerId,
                        Event_Subtype__c,
                        RecordTypeId,
                        Related_Account__c,
                        Subject,
                        WhatId,
                        WhoId from Event 
                        LIMIT 1];
                        
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            List<String> whoList = new List<String>();
            whoList.add(eve.WhoId);
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('whatId',eve.WhatId);
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('providerId',eve.Related_Account__c);
            eveMap.put('comments',eve.Description);
            eveMap.put('startDate',longStartDate);
            eveMap.put('endDate',longEndDate);
            eveMap.put('status',eve.Event_Status__c);
            
            Test.startTest();
            
            CS_EventsService.saveCalendarEventDTO(eveMap);
            
            Test.stopTest();
        
    }
    
    static testmethod void saveEventTest1() {
        setupData();
        
        
             Event eve = [SELECT Id, 
                        StartDateTime, 
                        EndDateTime, 
                        Event_Status__c, 
                        Calendar_Name__c,
                        Description, 
                        Location,
                        Notes__c,
                        OwnerId,
                        Event_Subtype__c,
                        RecordTypeId,
                        Related_Account__c,
                        Subject,
                        WhatId,
                        IsAllDayEvent,
                        WhoId from Event 
                        LIMIT 1];
                        
                        
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            List<String> whoList = new List<String>();
            whoList.add(eve.WhoId);
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('id',eve.Id);
            eveMap.put('startDate',longStartDate);
            eveMap.put('endDate',longEndDate);
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('calendarName',eve.Calendar_Name__c);
            eveMap.put('description',eve.Subject);
            eveMap.put('location',eve.Location);
            eveMap.put('comments',eve.Description);
            eveMap.put('providerId',eve.Related_Account__c);
            eveMap.put('attendeeIds',whoList);
            eveMap.put('isAllDay',eve.IsAllDayEvent);
        
             String str = '';
             str = JSON.serialize(eveMap);
             Test.startTest();
            
             //CS_EventsService.saveEvent(AXIS_EVENT_TYPE_OUT_OF_OFFICE, str);
             
            
             Test.stopTest();
        
    }
    
    static testmethod void saveEventTest2() {
        setupData();
        
        
             Event eve = [SELECT Id, 
                        StartDateTime, 
                        EndDateTime, 
                        Event_Status__c, 
                        Calendar_Name__c,
                        Description, 
                        Location,
                        Notes__c,
                        OwnerId,
                        Event_Subtype__c,
                        RecordTypeId,
                        Related_Account__c,
                        Subject,
                        WhatId,
                        IsAllDayEvent,
                        WhoId from Event 
                        LIMIT 1];
                        
                        
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
            
                List<String> whoList = new List<String>();
                whoList.add(newCon.Id);
                
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('id',eve.Id);
            eveMap.put('isAgencyEvent',TRUE);
            eveMap.put('startDate',longStartDate);
            eveMap.put('endDate',longEndDate);
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('calendarName',eve.Calendar_Name__c);
            eveMap.put('description',eve.Subject);
            eveMap.put('location',eve.Location);
            eveMap.put('comments',eve.Description);
            eveMap.put('providerId',eve.Related_Account__c);
            eveMap.put('attendeeIds',whoList);
            eveMap.put('isAllDay',eve.IsAllDayEvent);
        
             String str = '';
             str = JSON.serialize(eveMap);
             Test.startTest();
            
             //CS_EventsService.saveEvent(AXIS_EVENT_TYPE_MEETING, str);
             
            
             Test.stopTest();
            }
        
    }
    
    static testmethod void saveEventTest3() {
        setupData();
        
        
             Event eve = [SELECT Id, 
                        StartDateTime, 
                        EndDateTime, 
                        Event_Status__c, 
                        Calendar_Name__c,
                        Description, 
                        Location,
                        Notes__c,
                        OwnerId,
                        Event_Subtype__c,
                        RecordTypeId,
                        Related_Account__c,
                        Subject,
                        WhatId,
                        IsAllDayEvent,
                        WhoId from Event 
                        LIMIT 1];
                        
                        
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
            
                List<String> whoList = new List<String>();
                whoList.add(newCon.Id);
                
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('id',eve.Id);
            eveMap.put('isAgencyEvent',TRUE);
            eveMap.put('startDate',longStartDate);
            eveMap.put('endDate',longEndDate);
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('calendarName',eve.Calendar_Name__c);
            eveMap.put('description',eve.Subject);
            eveMap.put('location',eve.Location);
            eveMap.put('comments',eve.Description);
            eveMap.put('providerId',eve.Related_Account__c);
            eveMap.put('attendeeIds',whoList);
            eveMap.put('isAllDay',eve.IsAllDayEvent);
        
             String str = '';
             str = JSON.serialize(eveMap);
             Test.startTest();
            
             //CS_EventsService.saveEvent(AXIS_EVENT_TYPE_DEMONSTRATION, str);
            
             Test.stopTest();
            }
        
    }
    
    static testmethod void saveEventTest4() {
        setupData();
        
        
             Event eve = [SELECT Id, 
                        StartDateTime, 
                        EndDateTime, 
                        Event_Status__c, 
                        Calendar_Name__c,
                        Description, 
                        Location,
                        Notes__c,
                        OwnerId,
                        Event_Subtype__c,
                        RecordTypeId,
                        Related_Account__c,
                        Subject,
                        WhatId,
                        IsAllDayEvent,
                        WhoId from Event 
                        LIMIT 1];
                        
                        
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
            
                List<String> whoList = new List<String>();
                whoList.add(newCon.Id);
                
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('id',eve.Id);
            eveMap.put('startDate',longStartDate);
            eveMap.put('endDate',longEndDate);
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('calendarName',eve.Calendar_Name__c);
            eveMap.put('description',eve.Subject);
            eveMap.put('location',eve.Location);
            eveMap.put('comments',eve.Description);
            eveMap.put('providerId',eve.Related_Account__c);
            eveMap.put('attendeeIds',whoList);
            eveMap.put('isAllDay',eve.IsAllDayEvent);
        
             String str = '';
             str = JSON.serialize(eveMap);
             Test.startTest();
            
             //CS_EventsService.saveEvent(AXIS_EVENT_TYPE_RIDE_ALONG, str);
             
            
             Test.stopTest();
            }
        
    }
    
    static testmethod void saveEventTest5() {
        setupData();
        
        
             Event eve = [SELECT Id, 
                        StartDateTime, 
                        EndDateTime, 
                        Event_Status__c, 
                        Calendar_Name__c,
                        Description, 
                        Location,
                        Notes__c,
                        OwnerId,
                        Event_Subtype__c,
                        RecordTypeId,
                        Related_Account__c,
                        Subject,
                        WhatId,
                        IsAllDayEvent,
                        WhoId from Event 
                        LIMIT 1];
                        
                        
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
            
                List<String> whoList = new List<String>();
                whoList.add(newCon.Id);
                
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('id',eve.Id);
            eveMap.put('isAgencyEvent',TRUE);
            eveMap.put('startDate',longStartDate);
            eveMap.put('endDate',longEndDate);
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('calendarName',eve.Calendar_Name__c);
            eveMap.put('description',eve.Subject);
            eveMap.put('location',eve.Location);
            eveMap.put('comments',eve.Description);
            eveMap.put('providerId',eve.Related_Account__c);
            eveMap.put('attendeeIds',whoList);
            eveMap.put('isAllDay',eve.IsAllDayEvent);
        
             String str = '';
             str = JSON.serialize(eveMap);
             Test.startTest();
            
             //CS_EventsService.saveEvent(AXIS_EVENT_TYPE_TRAINING, str);
             
            
             Test.stopTest();
            }
        
    }
    
    static testmethod void saveEventTest6() {
        setupData();
        
        
             Event eve = [SELECT Id, 
                        StartDateTime, 
                        EndDateTime, 
                        Event_Status__c, 
                        Calendar_Name__c,
                        Description, 
                        Location,
                        Notes__c,
                        OwnerId,
                        Event_Subtype__c,
                        RecordTypeId,
                        Related_Account__c,
                        Subject,
                        WhatId,
                        IsAllDayEvent,
                        WhoId from Event 
                        LIMIT 1];
                        
                        
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            List<String> whoList = new List<String>();
            whoList.add(eve.WhoId);
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('id',eve.Id);
            eveMap.put('isAgencyEvent',TRUE);
            eveMap.put('startDate',longStartDate);
            eveMap.put('endDate',longEndDate);
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('calendarName',eve.Calendar_Name__c);
            eveMap.put('description',eve.Subject);
            eveMap.put('location',eve.Location);
            eveMap.put('comments',eve.Description);
            eveMap.put('providerId',eve.Related_Account__c);
            eveMap.put('attendeeIds',whoList);
            eveMap.put('isAllDay',eve.IsAllDayEvent);
        
             String str = '';
             str = JSON.serialize(eveMap);
             Test.startTest();
            
             //CS_EventsService.saveEvent(AXIS_EVENT_TYPE_LOCAL_LAB, str);
             
            
             Test.stopTest();
        
    }
    
    static testmethod void getEventByIdTest() {
        setupData();
        
        
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime from Event LIMIT 1];
            
            Test.startTest();
            
            //CS_EventsService.getEventById(eve.Id);
            CS_EventsService.getEvents();
            
            Test.stopTest();
        
    }
    
    static testmethod void updateEventTimeTest() {
        setupData();
        
            
            
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime from Event LIMIT 1];
            DateTime dtstartMS = eve.StartDateTime;
            DateTime dtendMS = eve.EndDateTime;
            Long longStartDate = dtstartMS.getTime();
            Long longEndDate = dtendMS.getTime();
            
            Test.startTest();
            
            CS_EventsService.updateEventTime(eve.Id, longStartDate, longEndDate);
            
            Test.stopTest();
        
    }
    
    static testmethod void updateEventStatusTest() {
        setupData();
        
            
            
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
            
            Test.startTest();
            
            CS_EventsService.updateEventStatus(eve.Id, eve.Event_Status__c);
            
            Test.stopTest();
        
    }
    
//  static testmethod void retrieveEventActivityTest() {
//      setupData();
        
            
            
//             Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
            
//             Test.startTest();
            
//             CS_EventsService.retrieveEventActivity(AXIS_EVENT_TYPE_MEETING, eve.Id);
//             //CS_EventsService.retrieveEventActivity('Task', eve.Id);
            
//             Test.stopTest();
        
//  }
    
    static testmethod void relateAttendingSurgeonTest() {
        setupData();
        
            
            
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
            Contact con = [SELECT Id From Contact LIMIT 1];
            
            String c = con.Id;
            
            Test.startTest();
            
            CS_EventsService.relateAttendingSurgeon(eve, c);
            //CS_EventsService.retrieveEventActivity('Task', eve.Id);
            
            Test.stopTest();
        
    }
    
    static testmethod void addWhoRelationsTest() {
        setupData();
        
            
            
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
            Contact con = [SELECT Id From Contact LIMIT 1];
            
            
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
            
            Set<String> c = new Set<String>();
            c.add(newCon.Id);
            
            Test.startTest();
            
            CS_EventsService.addWhoRelations(eve, c);
            //CS_EventsService.retrieveEventActivity('Task', eve.Id);
            
            Test.stopTest();
            
            }
            
        
    }
    
    static testmethod void removeWhoRelationTest() {
        setupData();
        
            
            
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
            Contact con = [SELECT Id From Contact LIMIT 1];
            
            Set<String> c = new Set<String>();
            c.add(con.Id);
            
            Test.startTest();
            
            CS_EventsService.removeWhoRelation(eve, c);
            //CS_EventsService.retrieveEventActivity('Task', eve.Id);
            
            Test.stopTest();
        
    }
    
    static testmethod void addAttendeeTest() {
        setupData();
        
            
            
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
            Contact con = [SELECT Id From Contact LIMIT 1];
            
            // Id roleId2 = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
            
            // User u = new User(
            //      ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            //      LastName = 'last',
            //      Email = 'puser000@amamama.com',
            //      Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            //      CompanyName = 'TEST',
            //      Title = 'title',
            //      Alias = 'alias',
            //      TimeZoneSidKey = 'America/Los_Angeles',
            //      EmailEncodingKey = 'UTF-8',
            //      LanguageLocaleKey = 'en_US',
            //      LocaleSidKey = 'en_US',
            //      UserRoleId = roleId2,
            //      ContactId = con.Id
            // );
            
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
                
                DataFactoryTerritory.setUpTerritoryForTestClasses();
                Territory2 objTerritory = [SELECT Id FROM Territory2 WHERE DeveloperName = 'TestTeamTerritory1'];
                
                agencyAccount = DataFactoryAccount.createAgencyAccount('Test Agency Account');
                insert agencyAccount;
                
                portalUserContact = DataFactoryContact.createContacts('PortalContact');
                portalUserContact.AccountId = agencyAccount.Id;
                insert portalUserContact;
                
                portalUser = DataFactoryUser.preparePortalUser();
                portalUser.customer_number__c = 'ArthTest001';
                portalUser.ContactId = portalUserContact.Id;
                insert portalUser;
                
                UserTerritory2Association objTerrAssoc = new UserTerritory2Association(UserId = portalUser.Id,
                                                                                   Territory2Id = objTerritory.Id);
                insert objTerrAssoc;
                
                
            
            Set<String> c = new Set<String>();
            c.add(newCon.Id);
            
            Test.startTest();
            
            CS_EventsService.addAttendee(eve, c);
            CS_EventsService.retrieveAvailableAttendees(newCon.Id);
            //CS_EventsService.retrieveEventActivity('Task', eve.Id);
            
            Test.stopTest();
            
            }
        
    }
    
    static testmethod void removeAttendeeTest() {
        setupData();
        
            
            
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
            Contact con = [SELECT Id From Contact LIMIT 1];
            
            Set<String> c = new Set<String>();
            c.add(con.Id);
            
            Test.startTest();
            
            CS_EventsService.removeAttendee(eve, c);
            //CS_EventsService.retrieveEventActivity('Task', eve.Id);
            
            Test.stopTest();
        
    }
    
    static testmethod void linkPreferenceCardTest() {
        setupData();
        
            
            
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
            Practitioner_Procedure__c prefCard = [Select Id FROM Practitioner_Procedure__c LIMIT 1];
            
            Test.startTest();
            
            CS_EventsService.linkPreferenceCard(eve.Id, prefCard.Id);
            Test.stopTest();
        
    }
    
    static testmethod void unLinkPreferenceCardsTest() {
        setupData();
        
            
            
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
            Practitioner_Procedure__c prefCard = [Select Id FROM Practitioner_Procedure__c LIMIT 1];
            
            Set<String> prefCardSet = new Set<String>();
            prefCardSet.add(prefCard.Id);
            
            Test.startTest();
            
            CS_EventsService.unLinkPreferenceCards(eve.Id, prefCardSet);
            Test.stopTest();
        
    }
    
    static testmethod void retrieveLinkedPreferenceCardsTest() {
        setupData();
        
            
            
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
            Practitioner_Procedure__c prefCard = [Select Id FROM Practitioner_Procedure__c LIMIT 1];
            
            Set<String> prefCardSet = new Set<String>();
            prefCardSet.add(prefCard.Id);
            
            Test.startTest();
            
            CS_EventsService.retrieveLinkedPreferenceCards(eve.Id);
            Test.stopTest();
        
    }
    
    static testmethod void retrieveAvailablePreferenceCardsTest() {
        setupData();
        
            
            
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
            Practitioner_Procedure__c prefCard = [Select Id FROM Practitioner_Procedure__c LIMIT 1];
            
            Set<String> prefCardSet = new Set<String>();
            prefCardSet.add(prefCard.Id);
            
            Test.startTest();
            
            CS_EventsService.retrieveAvailablePreferenceCards(eve.Id);
            Test.stopTest();
        
    }
    
    static testmethod void syncWhoRelationsTest() {
        setupData();
        
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                
                Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
                
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
            
                Set<String> c = new Set<String>();
                c.add(newCon.Id);
                
            
            Test.startTest();
            
            CS_EventsService.syncWhoRelations(eve, c);
            //CS_EventsService.retrieveEventActivity('Task', eve.Id);
            
            Test.stopTest();
            }
        
    }
    
    static testmethod void getEventFromEventParamsTest() {
        setupData();
        
        
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c, IsAllDayEvent, Subject from Event LIMIT 1];
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('eventId',eve.Id);
            eveMap.put('selectedOwnerId',eve.OwnerId);
            eveMap.put('isAllDay',eve.IsAllDayEvent);
            // eveMap.put('selectedOwnerId',eve.OwnerId);
            // eveMap.put('selectedOwnerId',eve.OwnerId);
            
            Test.startTest();
            
            //CS_EventsService.getEventFromEventParams(eveMap);
            
            
            Test.stopTest();
        
    }
    
    static testmethod void getMapStringTest() {
        setupData();
        
        
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c, IsAllDayEvent, Subject from Event LIMIT 1];
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('eventId',eve.Id);
            // eveMap.put('selectedOwnerId',eve.OwnerId);
            // eveMap.put('selectedOwnerId',eve.OwnerId);
            
            Test.startTest();
            
            CS_EventsService.getMapString('eventId', eveMap);
            
            
            Test.stopTest();
        
    }
    
    static testmethod void getMapDecimalTest() {
        setupData();
        
        
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c, IsAllDayEvent, Subject from Event LIMIT 1];
            
            
            
            DateTime dtstartMS = eve.StartDateTime;
            Long longStartDate = dtstartMS.getTime();
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('startDate',longStartDate);
            
            Test.startTest();
            
            CS_EventsService.getMapDecimal('eventId', eveMap);
            
            
            Test.stopTest();
        
    }
    
    static testmethod void getMapListStringTest() {
        setupData();
        
        
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c, IsAllDayEvent, Subject from Event LIMIT 1];
            
            Map<String, Object> eveMap = new Map<String, Object>();
            eveMap.put('eventId',eve.Id);
            
            Test.startTest();
            
            CS_EventsService.getMapListString('startDate', eveMap);
            
            
            Test.stopTest();
        
    }
    
    static testmethod void linkOpportunityTest() {
        setupData();
        
        
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c, IsAllDayEvent, Subject from Event LIMIT 1];
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            
            Test.startTest();
            
            CS_EventsService.linkOpportunity(eve.Id, opp.Id);
            
            
            Test.stopTest();
        
    }
    
    static testmethod void unlinkOpportunityTest() {
        setupData();
        
        
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c, IsAllDayEvent, Subject from Event LIMIT 1];
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            
            Set<String> oppSet = new Set<String>();
            oppSet.add(opp.Id);
            
            Test.startTest();
            
            CS_EventsService.unlinkOpportunity(eve.Id, oppSet);
            
            
            Test.stopTest();
        
    }
    
    static testmethod void retrieveLinkedOpportunitiesTest() {
        setupData();
        
        
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c, IsAllDayEvent, Subject from Event LIMIT 1];
            
            Test.startTest();
            
            CS_EventsService.retrieveLinkedOpportunities(eve.Id);
            
            
            Test.stopTest();
        
    }
    
    static testmethod void retrieveAvailableOpportunitiesTest() {
        setupData();
        
        
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c, IsAllDayEvent, Subject, WhatId from Event LIMIT 1];
            Case__c cas = [select Practitioner__c,Id from Case__c where Id=:eve.WhatId];
            
            Test.startTest();
            
            CS_EventsService.retrieveAvailableOpportunities(eve.Id);
            
            
            Test.stopTest();
        
    }
    
    static testmethod void retrieveAssociatedActivityTest() {
        setupData();
        
            Event eve = [SELECT Id, WhatId, OwnerId, StartDateTime, EndDateTime, Event_Status__c, IsAllDayEvent, Subject from Event LIMIT 1];
            
            Test.startTest();
            
            CS_EventsService.retrieveAssociatedActivity('Meeting', eve.Id, eve.WhatId);
            
                       
            Event objEvent = new Event();
            objEvent.whatid = healthCareProviderAccount.id;
            objEvent.subject = 'test';
            objEvent.ActivityDate = system.today();
            objEvent.ActivityDateTime = system.now();
            objEvent.DurationInMinutes = 120;
            //objEvent.Event_Priority__c = 'Normal';
            insert objEvent;
            
            CS_EventsService.retrieveAssociatedActivity('Meeting', objEvent.Id, objEvent.WhatId);
                        
            Test.stopTest();
        
    }
    
    static testmethod void getEventActivityForSurgeonTest() {
        setupData();
            Id surgeonRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Surgeons').getRecordTypeId();
        
            Account acc = [SELECT Id, RecordTypeId, Name  from Account Where RecordTypeId =: surgeonRecordTypeId LIMIT 1];
            
            Test.startTest();
            
            CS_EventsService.getEventActivityForSurgeon(acc.Id);
            
            Test.stopTest();
        
    }
    
    static testmethod void getEventActivityForAccountTest() {
        setupData();
        
            Account acc = [SELECT Id, RecordTypeId, Name  from Account LIMIT 1];
            
            Test.startTest();
            
            CS_EventsService.getEventActivityForAccount(acc.Id);
            
            Test.stopTest();
        
    }
    
    static testmethod void getEventActivityForOpportunityTest() {
        setupData();
        
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            
            Test.startTest();
            
            CS_EventsService.getEventActivityForOpportunity(opp.Id);
            
            
            Test.stopTest();
        
    }
    
    static testmethod void updateEventRelationByCaseParticipantTest() {
        setupData();
        
            List<CaseParticipant__c> casPart = [SELECT Id, Case__c, Participant__c, Name FROM CaseParticipant__c LIMIT 1];
            
            Test.startTest();
            
            CS_EventsService.updateEventRelationByCaseParticipant(casPart, TRUE);
            
            
            Test.stopTest();
        
    }
    
    static testmethod void syncSurgicalCaseParticipantsTest() {
        setupData();
        
            Case__c cas = [SELECT Id FROM Case__c LIMIT 1];
            Event eve = [SELECT Id, OwnerId, StartDateTime, EndDateTime, Event_Status__c from Event LIMIT 1];
            Contact con = [SELECT Id From Contact LIMIT 1];
            
            
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex1.com', 'testadmin1');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Account newAcc = new Account(name ='TestAcc', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact',AccountId = ac.Id);
                Database.Insert(newCon);
            
            Set<String> c = new Set<String>();
            c.add(newCon.Id);
            
            Test.startTest();
            
            CS_EventsService.syncSurgicalCaseParticipants(cas.Id, c);
            
            
            Test.stopTest();
        
            }
    }
    //need to fix after the release--vishnu 
    static void standAloneSurgicalCase2EventBasedSurgicalCaseTest() {
        setupData();
        
            //Case__c cas = [SELECT Id FROM Case__c LIMIT 1];
            
            User user = [select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user) {
                Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;
    
                adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex12.com', 'testadmin12');
                adminUser.UserRoleId = roleId;
                Database.insert(adminuser);
            }
    
            System.runAs(adminUser) {
                Id eventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Axis Event').getRecordTypeId();
                
                Account newAcc = new Account(name ='TestAcc12', OwnerId = adminuser.Id) ;
                Database.Insert(newAcc); 
    
                Contact newCon = new Contact(LastName ='TestContact12',AccountId = newAcc.Id);
                Database.Insert(newCon);
                
                Account healthCareProviderAccountNew = DataFactoryAccount.createHealthCareProviderAccount();
                insert healthCareProviderAccountNew;
                
                Account practitioner1 = new Account(Name = 'TestPractitionerFirstName',
                                        //LastName = 'TestPractitionerLastName',
                                        //PersonEmail = 'testpersonemailXXXX@arthrex.com',
                                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_PRACTITIONER).getRecordTypeId()
                );
                                        
                Database.Insert(practitioner1);
                
                Account healthCareProviderAccount1 = DataFactoryAccount.createHealthCareProviderAccount();
                insert healthCareProviderAccount1;       
                
                Account surgeon1 = DataFactoryAccount.createSurgeonContact();
                insert surgeon1;
                
                Case__c cas = new Case__c(
                    Health_Care_Provider__c = healthCareProviderAccount1.Id,
                    //Surgeon__c = surgeon.Id,
                    Practitioner__c = practitioner1.Id,
                    Status__c = 'Pending'
                );
            
                Database.Insert(cas);
                
                datetime datestart = Datetime.newInstance(2015, 20 , 12, 00, 00, 00);
                datetime dateend = Datetime.newInstance(2015, 20 , 12, 01, 00, 00);
                
                
                
                Datetime strtDate = System.today();
                Datetime endDate = strtDate.addMinutes(30);
                
                Event eveSurgical = new Event(
                    //AccountId = ac2.Id,
                    Type = AXIS_EVENT_TYPE_MEETING,
                    Related_Account__c = healthCareProviderAccountNew.Id,
                    WhoId = newCon.Id,
                    WhatId = cas.Id,
                    Calendar_Name__c = 'Test Calendar',
                    Location = 'Room XYZ',
                    Event_Status__c = 'Pending',
                    Event_Subtype__c = 'Office',
                    RecordTypeId = eventRecordTypeId,
                    //Priority = 'High',
                    Subject = 'Out of Office',
                    Description = 'Test Desc',
                    IsAllDayEvent = False,
                    EndDateTime = endDate,
                    StartDateTime = strtDate,
                    ActivityDateTime = strtDate,
                    DurationInMinutes = 30
                        
                );
                
                Database.Insert(eveSurgical);

            Test.startTest();
            
            
            CS_EventsService.standAloneSurgicalCase2EventBasedSurgicalCase(eveSurgical.Id);
            
            cas = [SELECT Id FROM Case__c LIMIT 1];
            CS_EventsService.standAloneSurgicalCase2EventBasedSurgicalCase(cas.Id);
            
            Test.stopTest();
        
            }
    }
    
    
    
    static void setupData(){
        
        
        date myDate = date.newInstance(2017, 03, 07);
        Id eventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Axis Event').getRecordTypeId();
        
        
        User user = [select Id from User where Id=:UserInfo.getUserId()];
        System.runAs(user) {
            Id roleId = [select Id from UserRole Where PortalType = 'None' limit 1].Id;

            adminUser = DataFactoryUser.createUser('System Administrator', 'testadmin@arthrex.com', 'testadmin');
            adminUser.UserRoleId = roleId;
            Database.insert(adminuser);
        }

        System.runAs(adminUser) {
            ac = new Account(name ='Grazitti', OwnerId = adminuser.Id) ;
            Database.Insert(ac); 

            con = new Contact(LastName ='testCon',AccountId = ac.Id);
            Database.Insert(con);


            ac2 = new Account(name ='Grazitti2', OwnerId = adminuser.Id) ;
            Database.Insert(ac2); 

            con2 = new Contact(LastName ='testCon2',AccountId = ac2.Id);
            Database.Insert(con2);
            
            practitioner = DataFactoryAccount.createPractitionerAccount();
            insert practitioner;
            
            healthCareProviderAccount = DataFactoryAccount.createHealthCareProviderAccount();
            insert healthCareProviderAccount;
            
            surgeon = DataFactoryAccount.createSurgeonContact();
            insert surgeon;
            
            cas = new Case__c(
                Health_Care_Provider__c = healthCareProviderAccount.Id,
                //Surgeon__c = surgeon.Id,
                Practitioner__c = practitioner.Id,
                Status__c = 'Pending'
            );
            
            Database.Insert(cas);
            
            casPart = new CaseParticipant__c(
                Case__c = cas.Id,
                Name = 'TestCaseParticipant',
                Participant__c = adminUser.Id
            );
            Database.Insert(casPart);
            
            proc = new Procedure__c(
                Procedure_Name__c = 'Test Procedure'
                
            );
            
            Database.Insert(proc);
            
            prefCard = new Practitioner_Procedure__c(
                Pref_Card_Name__c = 'Test prefCard',
                Procedure__c = proc.Id,
                Practitioner__c = practitioner.Id
                
            );
            
            Database.Insert(prefCard);
            
            opp = new Opportunity(
                Name = 'Test1 Opportunity',
                StageName = 'Closed - Won',
                CloseDate = Date.newInstance(2016, 2, 17)
            );
            
            Database.Insert(opp);
            
            // datetime datestart = Datetime.newInstance(2015, 20 , 12, 00, 00, 00);
            // datetime dateend = Datetime.newInstance(2015, 20 , 12, 01, 00, 00);
            
            eveMeeting = new Event(
                //AccountId = ac2.Id,
                Type = AXIS_EVENT_TYPE_MEETING,
                Related_Account__c = healthCareProviderAccount.Id,
                WhoId = con.Id,
                WhatId = cas.Id,
                Calendar_Name__c = 'Test Calendar',
                Location = 'Room XYZ',
                Event_Status__c = 'Pending',
                RecordTypeId = eventRecordTypeId,
                //Priority = 'High',
                Subject = 'Out of Office',
                Description = 'Test Desc',
                IsAllDayEvent = True,
                EndDateTime = System.Today(),
                StartDateTime = System.Today()//,
                // ActivityDateTime = System.Today(),
                // DurationInMinutes = 0
                    
            );
              
            Database.Insert(eveMeeting);
            
            eveTraining = new Event(
                //AccountId = ac2.Id,
                Type = AXIS_EVENT_TYPE_TRAINING,
                Related_Account__c = healthCareProviderAccount.Id,
                WhoId = con.Id,
                WhatId = cas.Id,
                Calendar_Name__c = 'Test Calendar',
                Location = 'Room XYZ',
                Event_Status__c = 'Pending',
                RecordTypeId = eventRecordTypeId,
                //Priority = 'High',
                Subject = 'Out of Office',
                Description = 'Test Desc',
                IsAllDayEvent = True,
                EndDateTime = System.Today(),
                StartDateTime = System.Today()//,
                // ActivityDateTime = System.Today(),
                // DurationInMinutes = 0
                    
            );
              
            Database.Insert(eveTraining);
            Local_Lab__c objLL = new Local_Lab__c();
            objLL.Name = 'test';
            objLL.Surgeon__c = surgeon.Id;
            insert objLL;
            
            Event eveLocalLab = new Event(
                //AccountId = ac2.Id,
                Type = AXIS_EVENT_TYPE_TRAINING,
                Related_Account__c = healthCareProviderAccount.Id,
                WhoId = con.Id,
                WhatId = objLL.Id,
                Calendar_Name__c = 'Test Calendar',
                Location = 'Room XYZ',
                Event_Status__c = 'Pending',
                RecordTypeId = eventRecordTypeId,
                //Priority = 'High',
                Subject = 'Out of Office',
                Description = 'Test Desc',
                IsAllDayEvent = True,
                EndDateTime = System.Today(),
                StartDateTime = System.Today()//,
                // ActivityDateTime = System.Today(),
                // DurationInMinutes = 0
                    
            );
              
            Database.Insert(eveLocalLab);
            

            Profile p = [SELECT Id FROM Profile WHERE Name='AXIS Partner Community User'];
            u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, ContactId = con.Id, IsActive=true,
                TimeZoneSidKey='America/Los_Angeles', UserName='unittestuser@testorg.com');

            Database.insert(u);

            u2 = new User(Alias = 'standt2', Email='standarduser@testorg.com2',
                EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, ContactId = con2.Id, IsActive=true,
                TimeZoneSidKey='America/Los_Angeles', UserName='unittestuser2@testorg.com');

            Database.insert(u2);

        }
        
        Record_Selection_Date_Range__c objRSD = new Record_Selection_Date_Range__c();
        objRSD.Name = 'Events';
        objRSD.Days_In_Past__c = 10;
        objRSD.Days_In_Future__c = 10;
        insert objRSD;
    }
    
    static testmethod void EventActivityWrapper_Test() {
        DateTime logDate;
        String notes;
        String activityType;
        String recId;
        CS_EventsService.EventActivityWrapper objEvWrapper = new CS_EventsService.EventActivityWrapper(logDate, notes, activityType, recId);
        
        String stage;
        CS_EventsService.EventActivityWrapper objEvWrapper1 = new CS_EventsService.EventActivityWrapper(logDate, notes, activityType, recId, stage);
        
    }
    
    static testmethod void calculateCalendarName_Test() {
        setupData();
        Event eve = [SELECT Id, OwnerId, Location, Calendar_Name__c, Related_Account__r.ShippingLatitude, Related_Account__r.ShippingLongitude, Related_Account__r.ShippingStreet, Related_Account__r.ShippingCity, Related_Account__r.ShippingState, Related_Account__r.ShippingCountry, Related_Account__r.ShippingPostalCode, Owner.Name, Related_Account__r.Name, Related_Account__r.Preferred_Name__c, StartDateTime, EndDateTime, Type, Event_Status__c, Subject from Event LIMIT 1];
        
        CS_EventsService.EventWrapper objES = new CS_EventsService.EventWrapper(eve);
        objES.calculateCalendarName();
        
        
    }
    
    static testmethod void saveSurgicalCaseEvent_Test() {
        setupData();
        
        Case__c cas = [SELECT Id FROM Case__c LIMIT 1];            
        CS_ARCalendarEventDTO calEventDTO = new CS_ARCalendarEventDTO();
        calEventDTO.url = cas.id;
        
        Event eve = [SELECT Id, OwnerId, Location, Related_Account__c, Description, WhoId, Calendar_Name__c, StartDateTime, EndDateTime, Event_Status__c, IsAllDayEvent, Subject from Event LIMIT 1];
        List<String> whoList = new List<String>();
        whoList.add(eve.WhoId);
        DateTime dtstartMS = eve.StartDateTime;
        DateTime dtendMS = eve.EndDateTime;
        Long longStartDate = dtstartMS.getTime();
        Long longEndDate = dtendMS.getTime();
        
        Event objEvent = new Event();
        objEvent.whatid = healthCareProviderAccount.id;
        objEvent.subject = 'test';
        objEvent.ActivityDate = system.today();
        objEvent.ActivityDateTime = system.now();
        objEvent.DurationInMinutes = 120;
        insert objEvent;
        
        eve = [SELECT Id, OwnerId, Location, Related_Account__c, Description, WhoId, Calendar_Name__c, StartDateTime, EndDateTime, Event_Status__c, IsAllDayEvent, Subject from Event WHERE id =: objEvent.id LIMIT 1];
           
        Map<String, Object> eveMap = new Map<String, Object>();        
        
        eveMap.put('id',eve.Id);
        eveMap.put('isAgencyEvent',TRUE);
        eveMap.put('startDate',longStartDate);
        eveMap.put('endDate',longEndDate);
        eveMap.put('selectedOwnerId',eve.OwnerId);
        eveMap.put('calendarName',eve.Calendar_Name__c);
        eveMap.put('description',eve.Subject);
        eveMap.put('location',eve.Location);
        eveMap.put('comments',eve.Description);
        eveMap.put('providerId',eve.Related_Account__c);
        eveMap.put('attendeeIds',whoList);
        eveMap.put('isAllDay',eve.IsAllDayEvent);
        
        
        eveMap.put('attendeeIds',whoList);
        List<Event> lstEvent = [SELECT id FROM Event];
        delete lstEvent;
        CS_EventsService.saveSurgicalCaseEvent(eve, calEventDTO, eveMap);
    }
}