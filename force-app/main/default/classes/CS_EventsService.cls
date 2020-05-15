public with sharing class CS_EventsService {

  public static final String AXIS_MASTER_CALENDAR_NAME = 'Arthrex Master';
  public static final String AXIS_EVENT_RECORD_TYPE = 'Axis Event';
  public static final String BACKEND_EVENT_RECORD_TYPE = 'Arthrex Events';
  public static final String GEMS_EVENT_RECORD_TYPE = 'GEMS Events';
  public static final String AXIS_EVENT_TYPE_SURG_CASE = 'Surgical Case';
  public static final String AXIS_EVENT_TYPE_OUT_OF_OFFICE = 'Out of Office';
  public static final String AXIS_EVENT_TYPE_MEETING = 'Meeting';
  public static final String AXIS_EVENT_TYPE_RIDE_ALONG = 'Ride Along';
  public static final String AXIS_EVENT_TYPE_TRAINING = 'Training';
  public static final String AXIS_EVENT_TYPE_DEMONSTRATION = 'Demonstration';
  public static final String AXIS_EVENT_TYPE_LOCAL_LAB = 'Local Lab';

  class GeneralPurposeException extends Exception {}

  public static List<EventWrapper> getEvents( ) {
    
    String tzStr = null;
    Date today = Date.today();

    Record_Selection_Date_Range__c dateRange = Record_Selection_Date_Range__c.getInstance('Events');
    Integer startDays = -1 * Integer.valueOf( dateRange.Days_In_Past__c );
    Integer endDays = Integer.valueOf( dateRange.Days_In_Future__c );
    Date startDate = today.addDays( startDays );
    Date endDate = today.addDays( endDays );

    return getEventsByCriteriaOrById(startDate,endDate,tzStr, null);
  }

  public static List<EventWrapper> getEventById(String eventId) {
    return getEventsByCriteriaOrById(null,null,null, eventId);
  }

  public static List<EventWrapper> getEventsByCriteriaOrById(Date startDate, Date endDate, String tzStr, String existingEventId ) {
    // this method can handle returning a list of events based on startDate,endDate and tzStr or if existingEventId
    // is passed in it will override the other arguments and only return that single event. This way the code to 
    // build wrappers for one event works exactly the same as building wrappers for multiple events

    // setup current user properites

    String myTeam = null;
    List<String> myTeams = CS_ARTerritoryService.retreiveMyTerritoryNames();
    if ( myTeams != null && myTeams.size() > 0 ) {
      myTeam = myTeams[0];
    }

    String myAgency = null;
    String myContactId = null;
    String myColor = null;
    String myName = null;
    User me = [select Distributor__c, Name, ContactId,Contact.Name,Contact.Role_In_Agency__c, Calendar_Color__c from User where Id=:UserInfo.getUserId()];
    if ( me != null ) {
      myAgency = me.Distributor__c;
      myContactId = me.ContactId;
      myColor = me.Calendar_Color__c;
      myName = me.Contact.Name;

    }

    List<User> myAgencyUsers = [select Id from User where Distributor__c =: myAgency];
    List<String> agencyUserIds = new List<String>();
    if ( myAgencyUsers != null ) { 
      for ( User agencyUser : myAgencyUsers ) {
        agencyUserIds.add(agencyUser.Id);
      }
    }

    List<User> myTeamUsers = CS_ARTerritoryService.retrieveUsersInMyTerritory();
    Set<String> myTeamUserIds = new Set<String>();
    if ( myTeamUsers != null ) {
      for ( User teamUser : myTeamUsers) {
        agencyUserIds.add(teamUser.Id);
        myTeamUserIds.add(teamUser.Id);
      }
    }

    // retrieve master list of events
    // very strange issue, the inner class "without sharing" trick is only working on the task service
    List<String> recordTypes = new List<String>();
    recordTypes.add(AXIS_EVENT_RECORD_TYPE);
    recordTypes.add(GEMS_EVENT_RECORD_TYPE);
    recordTypes.add(BACKEND_EVENT_RECORD_TYPE);

    // calendar names can be the user's agency or arthrex master
    List<String> calendarNames = new List<String>();
    calendarNames.add(AXIS_MASTER_CALENDAR_NAME);
    calendarNames.add(myAgency);
    
    List<Event> events = null;
    if ( existingEventId == null ) {
      //events = CS_ARTasksService.getEvents(startDate, endDate, agencyUserIds, calendarNames, recordTypes);
      //CS_EventDML eventDML = new CS_EventDML();
      //events = eventDML.retrieveEvents(startDate, endDate, agencyUserIds, AXIS_MASTER_CALENDAR_NAME, recordTypes);
    } else {
      //events = CS_ARTasksService.getEvent(existingEventId);
      //CS_EventDML eventDML = new CS_EventDML();
      //events = eventDML.retrieveEvent(existingEventId);
    }


    // now need to setup master lists and association of objects related to the event list to avoid soql query exceptions
    Map<String,List<String>> whatObjectMap = new Map<String,List<String>>();
    Set<String> eventIds = new Set<String>();
    Set<String> ownerIds = new Set<String>();
    Set<String> relatedAccountIds = new Set<String>();
    if(events != null){
    for ( Event e : events ) {
      eventIds.add(e.Id);
      ownerIds.add(e.OwnerId);

      // map what types ot the list of id for example whatType='Case__c' -> list of Case__c ids
      String whatType = e.What.Type;
      List<String> whatIds = new List<String>();
      if ( whatObjectMap.containsKey(whatType) ) {
        whatIds = whatObjectMap.get(whatType);
      }
      whatIds.add(e.WhatId);
      whatObjectMap.put(whatType, whatIds);

      // setup a list of related account Ids
      if ( e.Related_Account__c != null ) {
        relatedAccountIds.add(e.Related_Account__c);
      }

    }
    }

    // create a map of associating account ids to the territory they belong to
    Map<Id,List<ObjectTerritory2Association>> relatedAccountTerritories = CS_ARTerritoryService.mapObjectIdsToTerritories(new List<String>(relatedAccountIds) );

    // create a map assocating eventId to list of attendees ( EventRelation fields and Contact fields combined into a Map )
    Map<String, List<Map<String,Object>>> eventAttendeeMap = new Map<String, List<Map<String,Object>>>();

    // all event relations for this events
    List<EventRelation> eventRelations = new List<EventRelation>(); //CS_ARTasksService.getWhoRelationsByEventIds(new List<String>(eventIds));
    if ( eventRelations == null ) { eventRelations = new List<EventRelation>(); }

    // build a map of Contacts based on event relations
    List<String> contactIds = new List<String>();
    for ( EventRelation er : eventRelations ) { contactIds.add( er.RelationId ); }
    Map<String,Contact> contactMap = new Map<String,Contact>(); //CS_ARTasksService.getContactsByIdsAsMap(contactIds);
    Map<String,User> contact2UserMap = new Map<String,User>();
    for ( User u : [select ContactId, Id, Calendar_Color__c, Profile.UserLicense.Name from User where ContactId in :contactMap.keySet()]) {
      contact2UserMap.put(u.ContactId, u);
    }
  

    for ( EventRelation eventRelation : eventRelations ) {
        // foreach eventRelation create a Map and add it to the list mapped to the event
        
        Contact relatedContact = contactMap.get(eventRelation.relationId);
        if ( relatedContact != null ) {

            Map<String,Object> attendeeMap = new Map<String,Object>();
            attendeeMap.put( 'ContactId', relatedContact.Id);
            attendeeMap.put( 'Name', relatedContact.Name);
            attendeeMap.put( 'Phone', relatedContact.Phone);
            attendeeMap.put( 'Email', relatedContact.Email);
            attendeeMap.put( 'Status', eventRelation.Status);
            attendeeMap.put( 'MailingCity', relatedContact.MailingCity);
            attendeeMap.put( 'MailingState', relatedContact.MailingState);

            String attendeeType = null;
            /*if ( relatedContact.Account.IsPersonAccount ) {
              attendeeType = relatedContact.Account.RecordType.Name;
            } else {
              attendeeType = relatedContact.Role_In_Agency__c;
            }*/
            attendeeMap.put('Type', attendeeType);

            User user = contact2UserMap.get(relatedContact.Id);
            if ( user != null ) {
              attendeeMap.put( 'calendarColor', user.Calendar_Color__c);
              if ( user.Profile.UserLicense.Name!='Partner Community' && user.Profile.UserLicense.Name !='Customer Community' ) {
                // if this is  a standard user then override Type to just 'Employee'
                attendeeMap.put('Type', 'Employee');
                attendeeMap.put('isCommunityMember', false);
              } else {
                attendeeMap.put('isCommunityMember', true);
              }
            }
            
            
            // add the attendee map to the list of attendee maps for this event
            String eventId = eventRelation.EventId;
            List<Map<String,Object>> relatedAttendees = new List<Map<String,Object>>();
            if ( eventAttendeeMap.containsKey(eventId) ) {
              relatedAttendees = eventAttendeeMap.get(eventId);
            }
            relatedAttendees.add(attendeeMap);
            eventAttendeeMap.put(eventId, relatedAttendees);

        }

    } // end for loop


    // create a map associating events to Surgical Case ( via CS_ARCalendarEventDTO )
    Map<String,CS_ARCalendarEventDTO> eventCaseMap = new Map<String,CS_ARCalendarEventDTO>();
    if ( whatObjectMap.get('Case__c') != null ) {
      // theres at least one event mapped to a Case__c

      // get the master list of surgical cases
      String surgicalcaseIds = '(\''+String.join(whatObjectMap.get('Case__c'),'\',\'')+'\')';
      String caseListSoql = CS_ARCalendarEventDTO.getCaseBuildSoql();
      caseListSoql += ' where Id in '+surgicalcaseIds;
      List<CS_ARCalendarEventDTO> caseList = CS_ARCasesCC.cases2CalendarEventDTOs(Database.query(caseListSoql));
      
      // map acount territories to the case list
      List<Id> accountIds = new List<Id>();
      for ( CS_ARCalendarEventDTO dto : caseList ) { accountIds.add( dto.providerId ); }
      Map<Id,List<ObjectTerritory2Association>> territoryMap = CS_ARTerritoryService.mapObjectIdsToTerritories(accountIds);

      for ( Event e : events ) {
        for ( CS_ARCalendarEventDTO dto : caseList ) {

          if ( e.WhatId == dto.url ) {

            // look up the territories
            List<ObjectTerritory2Association> territories = territoryMap.get(dto.providerId);
            if ( territories != null && territories.size() > 0 ){
              // assuming only one territory
              dto.providerTerritory = territories[0].Territory2.Name;
              dto.providerTerritoryId = territories[0].Territory2Id;
              dto.providerParentTerritoryId = territories[0].Territory2.ParentTerritory2Id;

            }

            eventCaseMap.put(e.Id, dto);
          }
        }
      }
    }

    // create a map associating events to Local Lab 
    Map<String,Local_Lab__c> localLabMap = new Map<String,Local_Lab__c>(); //CS_LocalLabService.getLocalLabsAsMap( whatObjectMap.get('Local_Lab__c') );

    // setup the team name map
    Map<Id,List<UserTerritory2Association>> ownerTeamsMap = CS_ARTerritoryService.mapUserIdsToTerritories(new List<String>(ownerIds));

    // setup the agency map
    Map<String,String> userAgencyMap = new Map<String,String>();
    Map<String,String> userColorMap = new Map<String,String>();
    List<User> usersWithAgencies = [select Id, Distributor__c,Calendar_Color__c from User where Id in: ownerIds];
    if ( usersWithAgencies != null && usersWithAgencies.size() > 0 ) {
      for ( User user : usersWithAgencies ) {
        userAgencyMap.put(user.Id, user.Distributor__c);
        userColorMap.put(user.Id, user.Calendar_Color__c);
      }
    }

    // build out wrapper list 
    List<EventWrapper> wrappers = new List<EventWrapper>();
    if(events != null){
    for (Event e : events ) {

      EventWrapper wrapper = new EventWrapper(e);

      // set attendees
      wrapper.setAttendeeDetails(eventAttendeeMap.get(e.Id));

      // set team
      List<UserTerritory2Association> ownerTeams = ownerTeamsMap.get(e.OwnerId);
      if ( ownerTeams != null && ownerTeams.size() > 0 ) {
        wrapper.teamName = ownerTeams[0].Territory2.Name;
        wrapper.teamId = ownerTeams[0].Territory2.Id;
      }

      // set agency name
      wrapper.agencyName = userAgencyMap.get(e.OwnerId);      

      // set the owning user's color
      wrapper.ownerColor = userColorMap.get(e.OwnerId);

      // set current user info
      wrapper.currentUserContactId = myContactId;
      wrapper.currentUserTeam = myTeam;
      wrapper.currentUserAgency = myAgency;
      wrapper.currentUserColor = myColor;
      wrapper.currentUserContactName = myName;

      // set the team id for this account if one eixsts
      if ( wrapper.accountId != null ) {
        List<ObjectTerritory2Association> territories = relatedAccountTerritories.get(wrapper.accountId);
        if ( territories != null && territories.size() > 0 ) {
          wrapper.accountTeamId = territories[0].Territory2Id;
        }
      }

      // set assocation for Surgical Case
      if ( e.What.Type == 'Case__c') {

        wrapper.associateCase( eventCaseMap.get(e.Id) );

      } else if ( e.What.Type == 'Local_Lab__c') {

        Local_Lab__c localLab = localLabMap.get(e.WhatId);
        wrapper.surgeonName = localLab.Surgeon__r.Name;
        wrapper.surgeonId = localLab.Surgeon__c;
        wrapper.associatedTo = localLab;
        wrapper.associatedToId = localLab.Id;
      
      }

      // set if the current user can edit the event
      if ( wrapper.event.OwnerId == UserInfo.getUserId() || myTeamUserIds.contains(wrapper.ownerId) ) {
        wrapper.currentUserCanEdit = true;
      }

      // last calculate the calendar name for this event
      // if calendar name is set always use that instead of deriving the calendar name
      if ( wrapper.event.Calendar_Name__c != null ) {
        // always balance to the event first
        wrapper.calendarName = wrapper.event.Calendar_Name__c;
        if ( wrapper.currentUserAgency != null && (wrapper.calendarName == wrapper.currentUserAgency) ) {
          wrapper.calendarName = 'Agency Master';

          if ( wrapper.event.OwnerId == UserInfo.getUserId() || wrapper.attendees.contains(wrapper.currentUserContactName)  ) {
            // not an agency event but either owned by the user or the user is in the attendee list, this is mine
            wrapper.calendarName = 'Agency Master Invited';        
          }
        }

      } else {

        // order is important,
        if ( wrapper.event.OwnerId == UserInfo.getUserId() || wrapper.attendees.contains(wrapper.currentUserContactName)  ) {
          // not an agency event but either owned by the user or the user is in the attendee list, this is mine
          wrapper.calendarName = 'Mine';        
        } else if ( (wrapper.teamName != null && (wrapper.teamName == wrapper.currentUserTeam)) || myTeamUserIds.contains(wrapper.ownerId) ) {
          // team name matches my team or event is owned by someone in my team
          wrapper.calendarName = 'My Team';
        } else {
          // everything else
          wrapper.calendarName = 'Other';
        }

      }

      wrappers.add(wrapper);
    }
    } 
    return wrappers;
  }

  public static List<CS_ARCasesCC.UserTerritoryWrapper> getTeamsAndTerritories() {
      // for filtering
      return CS_ARCasesCC.retrieveUserTerritories();
  }

  public static boolean updateEventTime(String eventId, Long startDateMs, Long endDateMs) {
    boolean updateOk = true;

    List<Event> events = new List<Event>(); //CS_ARTasksService.getEvent(eventId);
    if ( events != null && events.size() > 0 ) {
      Event e = events[0];
      e.StartDateTime = DateTime.newInstance(startDateMs);
      e.EndDateTime = DateTime.newInstance(endDateMs);
      //CS_ARTasksService.saveEvent(e);
      updateOk = true;
    } else {
      updateOK = false;
    }

    return updateOk;

  }

  public static boolean updateEventStatus(String eventId, String newStatus) {
    boolean updateOk = true;

    List<Event> events = new List<Event>(); //CS_ARTasksService.getEvent(eventId);
    if ( events != null && events.size() > 0 ) {
      Event e = events[0];
      e.Event_Status__c = newStatus;
      //CS_ARTasksService.saveEvent(e);
      updateOk = true;
    } else {
      updateOK = false;
    }

    return updateOk;
  }

    public static CS_EventsService.EventWrapper saveEvent(String etype, String eventParamsJson ) {

    Map<String,Object> eventParams = (Map<String,Object>)JSON.deserializeUntyped(eventParamsJson);

        if ( etype == null ) { return null; }
        if ( eventParams == null ) { return null; }


        

          

    Event event = getEventFromEventParams(eventParams);

    if ( etype == AXIS_EVENT_TYPE_SURG_CASE ) {

         // for surgical cases, the team must be a lowest level team
         String selectedTeamId = getMapStringId('selectedTeamId', eventParams);
        if ( selectedTeamId != null ) {
            String teamType = '';//CS_ARTerritoryService.retrieveTerritoryTypeById(selectedTeamId);
            if ( teamType == null || teamType != 'Team') {
              throw new GeneralPurposeException('Selected team is invalid');  
            }
        }

        CS_ARCalendarEventDTO calEventDTO = saveCalendarEventDTO(eventParams);
        saveSurgicalCaseEvent(event, calEventDTO, eventParams);

    } else if ( etype == AXIS_EVENT_TYPE_OUT_OF_OFFICE ) {

            event = saveOutOfOfficeEvent(event, eventParams);

        
    } else if( etype == AXIS_EVENT_TYPE_MEETING ) {

            event = saveMeetingEvent(event, eventParams);

    } else if( etype == AXIS_EVENT_TYPE_DEMONSTRATION ) {

            event = saveDemonstrationEvent(event, eventParams);

    } else if( etype == AXIS_EVENT_TYPE_RIDE_ALONG ) {

            event = saveRideAlongEvent(event, eventParams);

    } else if( etype == AXIS_EVENT_TYPE_TRAINING) {

            event = saveTrainingEvent(event, eventParams);

    } else if( etype == AXIS_EVENT_TYPE_LOCAL_LAB ) {

        // for local lab cases, the team must be a lowest level team
        String selectedTeamId = getMapStringId('selectedTeamId', eventParams);
        if ( selectedTeamId != null ) {
            String teamType = '';//CS_ARTerritoryService.retrieveTerritoryTypeById(selectedTeamId);
            if ( teamType == null || teamType != 'Team') {
              throw new GeneralPurposeException('Selected team is invalid');  
            }
        }
            event = saveLocalLabEvent(event, eventParams);

    }

        return getEventById(event.Id)[0];
    
    }
 

  @TestVisible private static Event saveOutOfOfficeEvent(Event event, Map<String, Object> eventParams) {

        event.Type = AXIS_EVENT_TYPE_OUT_OF_OFFICE;

        String ownerId = getMapStringId('selectedOwnerId', eventParams);
        if ( ownerId != null) {
          event.OwnerId = ownerId;
        }
        
        Decimal endMs = getMapDecimal('endDate', eventParams);
        Decimal startMs = getMapDecimal('startDate', eventParams);
        event.Subject = '';
        event.Event_Status__c = 'Confirmed';
        event.EndDateTime = DateTime.newInstance( endMs.longValue() );
        event.StartDateTime = DateTime.newInstance( startMs.longValue() );    
      
        //event = CS_ARTasksService.saveEvent(event); 

        return event;
        
  }
    @TestVisible
    private static Event saveSurgicalCaseEvent(Event event, CS_ARCalendarEventDTO calEventDTO, Map<String,Object> eventParams) {

        if ( calEventDTO == null || event == null ) { return null; }

        RecordType recType = [Select Id From RecordType  Where SobjectType = 'Event' and Name = :AXIS_EVENT_RECORD_TYPE];           
        event.RecordTypeId = recType.Id;

        event.Type = AXIS_EVENT_TYPE_SURG_CASE;
        event.Subject = getMapString('description', eventParams);

        //event.EndDateTime = calEventDTO.endDateTime;
        //event.StartDateTime = calEventDTO.startDateTime;

        // method getEventFromEventParams() will set Related_Account__c but we want to override it here
        // just to make sure it balances with the Case__c custom object
        event.Related_Account__c = calEventDTO.providerId;

        event.Event_Status__c = getMapString('status', eventParams);
        event.OwnerId = calEventDTO.OwnerId;
        event.WhatId = calEventDTO.url; /* calEventDTO.url contains the Case record ID */  
        event.Description = getMapString('comments', eventParams);      
        event.Location = getMapString('location', eventParams);

        List<String> attendeeIds = getMapListString('attendeeIds', eventParams);          
      
        if ( event.Id == null ) {
          // on insert need to save before syncing who relations and other rleated obejcts
          //event = CS_ARTasksService.saveEvent(event);        

          // NOTE: syncing surgical case participants will in turn add the required EventRelation records
          // via the CaseParticipantTriggerHandler
          syncSurgicalCaseParticipants(calEventDTO.url, new Set<String>(attendeeIds) );

          List<Contact> surgeonContact = [select Id from Contact where accountId=:calEventDTO.practitionerId];
          if ( surgeonContact != null && surgeonContact.size() > 0 ) {
            relateAttendingSurgeon(event, surgeonContact[0].Id);
          }
        } else {
          // on update need to sync prior to save

          // NOTE: syncing surgical case participants will in turn add the required EventRelation records
          // via the CaseParticipantTriggerHandler
          //system.assertEquals(attendeeIds, null);
          syncSurgicalCaseParticipants(calEventDTO.url, new Set<String>(attendeeIds) );

          List<Contact> surgeonContact = [select Id from Contact where accountId=:calEventDTO.practitionerId];
          if ( surgeonContact != null && surgeonContact.size() > 0 ) {
            relateAttendingSurgeon(event, surgeonContact[0].Id);
          }
          //event = CS_ARTasksService.saveEvent(event);   

        }

        return event;
    }

    public static void updateEventRelationByCaseParticipant(list<CaseParticipant__c> oldCaseParticipants, boolean add) {
      // when case participants are removed for surgical cases in the backend a trigger on CaseParticipant fires and calls this
      // method so that the corresponding EventRelation is removed
      List<String> whatIds = new List<String>();
      List<String> userIds = new List<String>();
      for ( CaseParticipant__c cp : oldCaseParticipants ) {
        whatIds.add(cp.Case__c);
        userIds.add(cp.Participant__c);
      }

      System.debug('*** what '+whatIds);
      System.debug('*** user '+userIds);

      List<Event> events = new List<Event>();//CS_ARTasksService.getEventsByWhatIds(whatIds);
      if ( events == null ) { events = new List<Event>(); }
      List<User> users = [select Id,ContactId from User where Id in :userIds];
      if ( users == null ) { users = new List<User>(); }

      for ( CaseParticipant__c cp : oldCaseParticipants ) {
        
        for ( Event e : events ) {
          
          for ( User u : users ) {

            System.debug('e.whatId='+e.WhatId+' CaseId='+cp.Case__c+' userId='+u.Id+' participantId='+cp.Participant__c);

            if ( e.WhatId == cp.Case__c &&  u.Id == cp.Participant__c ) {
              Set<String> contactIds = new Set<String>();
              contactIds.add(u.ContactId);
              if ( add ) {
                addWhoRelations(e, contactIds);
              } else {                
                removeWhoRelation(e, contactIds);
              }
            }

          }
        
        }
      }

    }


    
    @TestVisible private static Event saveMeetingEvent(Event event, Map<String,Object> eventParams) {
     
      event.Type = AXIS_EVENT_TYPE_MEETING;

      if ( getMapBool('isAgencyEvent', eventParams) ) {
        User me = [select Distributor__c from User where Id=:UserInfo.getUserId()];
        if ( me != null ) {
          event.Calendar_Name__c = me.Distributor__c;
        }
      }


      String ownerId = getMapStringId('selectedOwnerId', eventParams);
      if ( ownerId != null) {
        event.OwnerId = ownerId;
      }

      Decimal endMs = getMapDecimal('endDate', eventParams);
      Decimal startMs = getMapDecimal('startDate', eventParams);

      event.EndDateTime = DateTime.newInstance( endMs.longValue() );
      event.StartDateTime = DateTime.newInstance( startMs.longValue() );

      event.Subject = getMapString('description', eventParams);

      event.Location = getMapString('location', eventParams);
      event.Description = getMapString('comments', eventParams);
      event.Event_Status__c = getMapString('status', eventParams);
          
      List<String> attendeeIds = getMapListString('attendeeIds', eventParams);          
      
      if ( event.Id == null ) {
        // on insert need to save before syncing who relations and other rleated obejcts
        //event = CS_ARTasksService.saveEvent(event);        
        syncWhoRelations(event,new Set<String>(attendeeIds));
      } else {
        // on update need to sync prior to save
        syncWhoRelations(event,new Set<String>(attendeeIds));
        //event = CS_ARTasksService.saveEvent(event);   
      }


      return event;
    }

  @TestVisible private static Event saveTrainingEvent(Event event, Map<String,Object> eventParams) {
   
      event.Type = AXIS_EVENT_TYPE_TRAINING;
      if ( getMapBool('isAgencyEvent', eventParams) ) {
        User me = [select Distributor__c from User where Id=:UserInfo.getUserId()];
        if ( me != null ) {
          event.Calendar_Name__c = me.Distributor__c;
        }
      }
      String ownerId = getMapStringId('selectedOwnerId', eventParams);
      if ( ownerId != null) {
        event.OwnerId = ownerId;
      }

      Decimal endMs = getMapDecimal('endDate', eventParams);
      Decimal startMs = getMapDecimal('startDate', eventParams);
      event.EndDateTime = DateTime.newInstance( endMs.longValue() );
      event.StartDateTime = DateTime.newInstance( startMs.longValue() );

      event.Subject = getMapString('description', eventParams);

      event.Location = getMapString('location', eventParams);
      event.Description = getMapString('comments', eventParams);
      event.Event_Status__c = getMapString('status', eventParams);
      
      List<String> attendeeIds = getMapListString('attendeeIds', eventParams);          
      
      if ( event.Id == null ) {
        // on insert need to save before syncing who relations and other rleated obejcts
        //event = CS_ARTasksService.saveEvent(event);        
        syncWhoRelations(event,new Set<String>(attendeeIds));
      } else {
        // on update need to sync prior to save
        syncWhoRelations(event,new Set<String>(attendeeIds));
        //event = CS_ARTasksService.saveEvent(event);   
      }

      return event;
  }

  @TestVisible private static Event saveDemonstrationEvent(Event event, Map<String,Object> eventParams) {
   
      event.Type = AXIS_EVENT_TYPE_DEMONSTRATION;
      if ( getMapBool('isAgencyEvent', eventParams) ) {
        User me = [select Distributor__c from User where Id=:UserInfo.getUserId()];
        if ( me != null ) {
          event.Calendar_Name__c = me.Distributor__c;
        }
      }
      String ownerId = getMapStringId('selectedOwnerId', eventParams);
      if ( ownerId != null) {
        event.OwnerId = ownerId;
      }

      Decimal endMs = getMapDecimal('endDate', eventParams);
      Decimal startMs = getMapDecimal('startDate', eventParams);

      event.EndDateTime = DateTime.newInstance( endMs.longValue() );
      event.StartDateTime = DateTime.newInstance( startMs.longValue() );

      event.Subject = getMapString('description', eventParams);

      event.Location = getMapString('location', eventParams);
      event.Description = getMapString('comments', eventParams);
      event.Event_Status__c = getMapString('status', eventParams);
                  
      List<String> attendeeIds = getMapListString('attendeeIds', eventParams);          
      
      if ( event.Id == null ) {
        // on insert need to save before syncing who relations and other rleated obejcts
       // event = CS_ARTasksService.saveEvent(event);        
        syncWhoRelations(event,new Set<String>(attendeeIds));
      } else {
        // on update need to sync prior to save
        syncWhoRelations(event,new Set<String>(attendeeIds));
        //event = CS_ARTasksService.saveEvent(event);   
      }

      return event;
  }

  @TestVisible private static Event saveRideAlongEvent(Event event, Map<String,Object> eventParams) {
   
      event.Type = AXIS_EVENT_TYPE_RIDE_ALONG;
      
      String ownerId = getMapStringId('selectedOwnerId', eventParams);
      if ( ownerId != null) {
        event.OwnerId = ownerId;
      }

      Decimal endMs = getMapDecimal('endDate', eventParams);
      Decimal startMs = getMapDecimal('startDate', eventParams);

      event.EndDateTime = DateTime.newInstance( endMs.longValue() );
      event.StartDateTime = DateTime.newInstance( startMs.longValue() );

      event.Subject = getMapString('description', eventParams);

      event.Location = getMapString('location', eventParams);
      event.Description = getMapString('comments', eventParams);
      event.Event_Status__c = getMapString('status', eventParams);

      List<String> attendeeIds = getMapListString('attendeeIds', eventParams);          
      
      if ( event.Id == null ) {
        // on insert need to save before syncing who relations and other rleated obejcts
        event = CS_ARTasksService.saveEvent(event);        
        syncWhoRelations(event,new Set<String>(attendeeIds));
      } else {
        // on update need to sync prior to save
        syncWhoRelations(event,new Set<String>(attendeeIds));
        event = CS_ARTasksService.saveEvent(event);   
      }

      return event;
  }

  @TestVisible private static Event saveLocalLabEvent(Event event, Map<String,Object> eventParams) {
   
      event.Type = AXIS_EVENT_TYPE_LOCAL_LAB;
      if ( getMapBool('isAgencyEvent', eventParams) ) {
        User me = [select Distributor__c from User where Id=:UserInfo.getUserId()];
        if ( me != null ) {
          event.Calendar_Name__c = me.Distributor__c;
        }
      }
      String ownerId = getMapStringId('selectedOwnerId', eventParams);
      if ( ownerId != null) {
        event.OwnerId = ownerId;
      }

      Decimal endMs = getMapDecimal('endDate', eventParams);
      Decimal startMs = getMapDecimal('startDate', eventParams);
      event.Event_Subtype__c = getMapString('subtype', eventParams);
      event.EndDateTime = DateTime.newInstance( endMs.longValue() );
      event.StartDateTime = DateTime.newInstance( startMs.longValue() );

      event.Subject = getMapString('description', eventParams);

      event.Location = getMapString('location', eventParams);
      event.Description = getMapString('comments', eventParams);
      event.Event_Status__c = getMapString('status', eventParams);

      // such a long way to go to convert a personAccount Id to a Contact Id but this class
      // has strange behavior with respect to sharing rules so we're going to be safe - Chad
      String surgeonId = getMapStringId('practitionerId',eventParams);
      List<String> accountIds = new List<String>();
      accountIds.add(surgeonId);
      Map<String,Contact> surgeonContactMap = new Map<String,Contact>();//CS_ARTasksService.getContactsByAccountIdsAsMap(accountIds);
      List<Contact> surgeonContacts = surgeonContactMap.values();
      if ( surgeonContacts != null && surgeonContacts.size() > 0 ) {
        event.WhoId = surgeonContacts[0].Id;
      }

      List<String> attendeeIds = getMapListString('attendeeIds', eventParams);          

      if ( event.Id == null ) {
        event = CS_ARTasksService.saveEvent(event);

        // on insert need to save before syncing who relations and other rleated obejcts
        //Local_Lab__c localLab = CS_LocalLabService.updateSurgeon( null, surgeonId );
        //event.WhatId = localLab.Id;

        event = CS_ARTasksService.saveEvent(event);

        syncWhoRelations(event,new Set<String>(attendeeIds));

      } else {
        // on update need to sync prior to save
        //Local_Lab__c localLab = CS_LocalLabService.updateSurgeon( event.WhatId, surgeonId );

        //syncWhoRelations(event,new Set<String>(attendeeIds));        
        //event = CS_ARTasksService.saveEvent(event);   
      }

      return event;
  }        


  @TestVisible private static CS_ARCalendarEventDTO saveCalendarEventDTO(Map<String,Object> eventParams) {

      String id = getMapStringId('whatId', eventParams);            
      String ownerId = getMapStringId('selectedOwnerId', eventParams);
      if ( ownerId == null ) {
        ownerId = UserInfo.getUserId();
      }

      String providerId = getMapStringId('providerId', eventParams);
      System.debug('###providerId: '+providerId);
      String practitionerId = getMapStringId('practitionerId', eventParams);
      String notes = getMapString('comments', eventParams);

      Long startDateMS = getMapDecimal('startDate', eventParams).longValue();
      Long endDateMS = getMapDecimal('endDate', eventParams).longValue();

      String status = getMapString('status', eventParams);

      List<String> procedureIds = getMapListString('procedureIds', eventParams);
      if ( procedureIds == null ) { procedureIds = new List<String>(); }
      List<String> surgicalIds = getMapListString('surgicalIds', eventParams);
      if ( surgicalIds == null ) { surgicalIds = new List<String>(); }
      List<String> productIdList = getMapListString('productIdList', eventParams);
      if ( productIdList == null ) { productIdList = new List<String>(); }
      List<String> participantIdList = getMapListString('participantIdList', eventParams);
      if ( participantIdList == null ) { participantIdList = new List<String>(); }
      List<String> prefCardIds = getMapListString('prefCardIds', eventParams);
      if ( prefCardIds == null ) { prefCardIds = new List<String>(); }

      CS_ARCalendarEventDTO calEventDTO = CS_ARCasesService.csaveCase(id, 
        providerId, 
        practitionerId, 
        prefCardIds, 
        notes, 
        startDateMs, 
        endDateMs, 
        productIdList, 
        participantIdList, 
        status, 
        procedureIds, 
        surgicalIds, 
        ownerId);


      // sync case participants


      return calEventDTO;
  }


  public static void relateAttendingSurgeon(Event e, String surgeonContactId) {

    /*List<EventRelation> attendingSurgeon = [select Id from EventRelation where EventId=:e.Id and RelationId=:surgeonContactId];
    CS_ARTasksService.deleteEventRelation(attendingSurgeon);

    e.WhoId = surgeonContactId;
    CS_ARTasksService.saveEvent(e);*/

  }

  public static void addWhoRelations(Event e, Set<String> relatedContactIds) {

    if ( relatedContactIds == null || relatedContactIds.size() == 0 ) { return; }

    list<EventRelation> lstEventRelation = new list<EventRelation>();

    // make sure the incoming ids really map to a Contact record
    list<Contact> lstContacts = [select Id from Contact where Id IN :relatedContactIds];
    for ( Contact c : lstContacts ) {
      EventRelation objEventRelation = new EventRelation (EventId = e.Id, RelationId = c.Id);

      // per Jessica, all attendees are added as accepted by default until a later release
      objEventRelation.Status = 'Accepted';

      lstEventRelation.add(objEventRelation);
    }

    //lstEventRelation = CS_ARTasksService.saveEventRelation(lstEventRelation); 

    // no triggers available on EventRelation so notify from here when event relations are creaetd
    // respect the trigger switch custom settings though
    /*if( Test.isRunningTest() || Trigger_Switch__c.getInstance(Constant.CaseParticipantTrigger).Active__c) {
      CS_NotificationService.EventAttendeeInserted(lstEventRelation);
    }*/


  }

  public static void addAttendee(Event e, Set<String> relatedContactIds ) {
    /*List<Event> events = CS_ARTasksService.getEvent(e.Id);
    if ( events != null && events.size() > 0 ) {
      
      if ( events[0].WhatId != null && CS_ARTasksService.whatIs( events[0].WhatId) == 'Surgical Case' ) {
        // this is a case, add a case participant which in turn adds the event relation via a trigger
        
        for ( User u : [ select Id from User where ContactId in :relatedContactIds]) {
          CS_ARCasesService.cSaveCaseParticipant(events[0].WhatId, u.Id);
        }

      } else {
        // not a surgical case, just add the who relation
        
        addWhoRelations(e, relatedContactIds);

      }


    }*/
  }

  public static void removeAttendee(Event e, Set<String> relatedContactIds ) {
    List<Event> events = CS_ARTasksService.getEvent(e.Id);
    if ( events != null && events.size() > 0 ) {
      
      removeWhoRelation(e, relatedContactIds);

      if ( events[0].WhatId != null && CS_ARTasksService.whatIs( events[0].WhatId) == 'Surgical Case' ) {
        // this is a case, add a case participant to0
        
        for ( User u : [ select Id from User where ContactId in :relatedContactIds]) {
          //CS_ARCasesService.cDeleteCaseParticipantByUserId(events[0].WhatId, u.Id);
        }

      }
    }
  }

  public static void linkPreferenceCard(String eventId, String prefCardId) {

    // preference cards can only be linked to Surgical Cases or Local labs via
    // the whatId
    List<Event> events = CS_ARTasksService.getEvent(eventId);
    if ( events != null && events.size() > 0 ) {

      String whatId = events[0].WhatId;
      if ( whatId != null &&  CS_ARTasksService.whatIs(whatId) == 'Surgical Case') {
        // this is event is linked to a surgical case, link the pref card to the surgical case and not
        // this event directly

        CS_ARCasesService.addCasePreferenceCard(whatId, prefCardId);

      } else if ( whatId != null ) {
        // this is a local lab

        //CS_LocalLabService.linkPrefCard(whatId, prefCardId);

      }

    }


  }

  public static void unLinkPreferenceCards(String eventId, Set<String> prefCardIds) {
    
    // preference cards can only be linked to Surgical Cases or Local labs via
    // the whatId
    List<Event> events = CS_ARTasksService.getEvent(eventId);
    if ( events != null && events.size() > 0 ) {

      String whatId = events[0].WhatId;
      if ( whatId != null &&  CS_ARTasksService.whatIs(whatId) == 'Surgical Case') {
        // this is event is linked to a surgical case, link the pref card to the surgical case and not
        // this event directly
        for ( String prefCardId : prefCardIds ) {
          //CS_ARCasesService.cDeletePreferenceCard(whatId, prefCardId);
        }

      } else if ( whatId != null ) {
        // this is a local lab

        for ( String prefCardId : prefCardIds ) {
          //CS_LocalLabService.unlinkPrefCard(whatId, prefCardId);
        }
        

      }

    }  

  }

  public static List<Practitioner_Procedure__c> retrieveLinkedPreferenceCards(String eventId) {
    
    List<Practitioner_Procedure__c> prefCards = new List<Practitioner_Procedure__c>();

    // preference cards can only be linked to Surgical Cases or Local labs via
    // the whatId
    List<Event> events = CS_ARTasksService.getEvent(eventId);
    if ( events != null && events.size() > 0 ) {

      String whatId = events[0].WhatId;
      if ( whatId != null &&  CS_ARTasksService.whatIs(whatId) == 'Surgical Case') {
        // this is event is linked to a surgical case
        
        //prefCards = CS_ARCasesService.retrieveLinkedPrefCards(whatId);

      } else if ( whatId != null ) {
        // this is a local lab
        
        //prefCards = CS_LocalLabService.getLinkedPrefCards(whatId);
      }

    }

    return prefCards;

  }

  public static List<Practitioner_Procedure__c> retrieveAvailablePreferenceCards(String surgeonId) {

    List<Practitioner_Procedure__c> prefCards = CS_ARCasesService.retrievePreferenceCards(surgeonId);
    if ( prefCards == null ) { prefCards = new List<Practitioner_Procedure__c>(); }

    return prefCards;
    
  }

  public static List<Contact> retrieveAvailableAttendees(String selectedTeamId) {
    // returns every contact that can be an attendee to an event relative to teh current user and selected team

    Set<Contact> availableAttendees = new Set<Contact>();
    
    // step 1. all users in my agency and region ( agency level + 1 level up )
    /*List<User> agencyPlusRegionUsers = CS_ARTerritoryService.retrieveUsersInAgencyAndRegion();
    List<String> agencyPlusRegionContactIds = new List<String>();
    for ( User u : agencyPlusRegionUsers ) { 
      if ( u.IsActive ) {
        agencyPlusRegionContactIds.add(u.ContactId); 
      }
    }

    List<Contact> agencyPlusRegionContacts = CS_ARTasksService.getContactsByIdsAsMap(agencyPlusRegionContactIds).values();
    availableAttendees.addAll(agencyPlusRegionContacts);

    // step 2. all non-surgeons in my territory and below
    List<Id> nonSurgeonAccountIds = CS_ARTerritoryService.retrieveAccountIdsInMyTeamTerritoryByRecordType(Constant.RECORDTYPE_NAME_SURGEON_CONTACT);
    List<Contact> nonSurgeonAccountContacts = CS_ARTasksService.getContactsByAccountIdsAsMap(nonSurgeonAccountIds).values();
    availableAttendees.addAll(nonSurgeonAccountContacts);

    // step 3. all surgeons and contacts in selected territory
    if ( selectedTeamId != null ) {
      Set<Id> selectedTerritorySet = new Set<Id>();
      selectedTerritorySet.add(selectedTeamId);
      
      
      
      //selectedTerritorySet.addAll(CS_ARTerritoryService.retrieveChildTerritories(selectedTeamId));
      List<Id> accountIdsInSelectedTeam = new List<Id>(CS_ARTerritoryService.retrieveAccountIdsForGivenTerritories(selectedTerritorySet));
      List<Contact> selectedContactsAndSurgeons = CS_ARTasksService.getContactsByAccountIdsAsMap(accountIdsInSelectedTeam).values();
      availableAttendees.addAll(selectedContactsAndSurgeons);

    }
    */
    return new List<Contact>(availableAttendees);

  }

  public static void linkObjectToEvent(String eventId, String objId) {
    // uses the whatId to link the object to the event, overwrites any existing linkage
    List<Event> events = CS_ARTasksService.getEvent(eventId);
    if ( events != null || events.size() > 0 ) {
      
      Event event = events[0];
      String existingLink = event.WhatId;
      if ( event.WhatId == null ) {
        // no existing link so we can just link directly

        //CS_ARTasksService.linkObjectToEvent(eventId, objId);

      } else {
        // already linked to something

      }

    }

  }

  public static void linkOpportunity(String eventId, String oppId) {
    
    List<Event> events = CS_ARTasksService.getEvent(eventId);
    if ( events != null && events.size() > 0 ) {

      Event e = events[0];

      // ** NOTE - don't forget Local Labs cannot link to an opportunity

      String whatId = e.WhatId;
      if ( whatId != null &&  CS_ARTasksService.whatIs(whatid) == 'Surgical Case') {
        // this is event is linked to a surgical case, link the opp to the surgical case and not
        // this event directly

        List<String> oppIds = new List<String>();
        oppIds.add(oppId);
        CS_ARCasesService.cSaveLinkedOpportunities(whatId, oppIds);

      } else if ( oppId != null &&  CS_ARTasksService.whatIs(oppId) == 'Opportunity') {
        // this is not a surgical case, link directly to the whatid
        e.WhatId = oppId;
        CS_ARTasksService.saveEvent(e);

      }

    }

  }

  public static void unlinkOpportunity(String eventId, Set<String> unlinkOpIds ) {


    List<Event> events = CS_ARTasksService.getEvent(eventId);
    if ( events != null && events.size() > 0 ) {

      Event e = events[0];

      String whatId = e.WhatId;
      if ( whatId != null &&  CS_ARTasksService.whatIs(whatid) == 'Surgical Case') {
        // this is event is linked to a surgical case, unlink the opp from the surgical case and not
        // this event directly

        List<Opportunity_Case__c> oppCases = [select Id from Opportunity_Case__c where Case__c =:whatId and Opportunity__c in :unlinkOpIds];
        for ( Opportunity_Case__c oppCase : oppCases ) {
          CS_ARCasesService.cDeleteLinkedOpportunityCase(oppCase.Id);
        }

      } else if ( whatId != null &&  CS_ARTasksService.whatIs(whatId) == 'Opportunity') {
        // this is not a surgical case, unlink directly from the whatid
        e.WhatId = null;
        CS_ARTasksService.saveEvent(e);

      }

    }

  }


  public static List<CS_AROpportunityService.CS_AROpportunityWrapper> retrieveLinkedOpportunities(String eventId) {

    list<CS_AROpportunityService.CS_AROpportunityWrapper> linkedOpportunities = new list<CS_AROpportunityService.CS_AROpportunityWrapper>();

    List<Event> events = CS_ARTasksService.getEvent(eventId);
    if ( events != null && events.size() > 0 ) {

      Event e = events[0];

      String whatId = e.WhatId;
      /*if ( whatId != null &&  CS_ARTasksService.whatIs(whatId) == 'Surgical Case') {
        // this is event is linked to a surgical case, return the opps linked to the case
        
        list<Opportunity_Case__c> linkedOpps = CS_ARCasesService.retrieveLinkedOpportunities(whatId);
        if ( linkedOpps == null ) { linkedOpps = new List<Opportunity_Case__c>(); }
        for ( Opportunity_Case__c opCase : linkedOpps ) {
          // add a wrapped opportunity for each Opportunity_Case__c
          CS_AROpportunityService.CS_AROpportunityWrapper wrappedOpp = CS_AROpportunityService.buildCS_AROpportunityWrapper( opCase.Opportunity__c );
          if ( wrappedOpp != null ) { linkedOpportunities.add(wrappedOpp); }
        }

      } else if ( whatId != null &&  CS_ARTasksService.whatIs(whatId) == 'Opportunity') {

        // this is not a surgical case, return a wrapped opp based on the whatId
        CS_AROpportunityService.CS_AROpportunityWrapper wrappedOpp = CS_AROpportunityService.buildCS_AROpportunityWrapper(whatId);
        if ( wrappedOpp != null ) { linkedOpportunities.add(wrappedOpp); }

      }*/

    }

    return linkedOpportunities;

  }

  public static List<CS_AROpportunityService.CS_AROpportunityWrapper> retrieveAvailableOpportunities(String eventId) {    

    list<CS_AROpportunityService.CS_AROpportunityWrapper> wrappedOpps = new list<CS_AROpportunityService.CS_AROpportunityWrapper>();

    List<Event> events = CS_ARTasksService.getEvent(eventId);
    if ( events != null && events.size() > 0 ) { 
      Event e = events[0];
      String eventType = e.Type;

      if ( eventType == 'Local Lab') {
        // local labs can't link to any opps return the empty list

      } else if ( eventType == 'Surgical Case' && CS_ARTasksService.whatIs(e.WhatId) == 'Surgical Case' ) {    
        // cases link following the case service logic

        List<Case__c> cases = [select Practitioner__c,Id from Case__c where Id=:e.WhatId];
        if ( cases != null && cases.size() > 0 ) {
          Case__c c = cases[0];
          
          List<CS_ARCasesService.CS_LinkOpportunity> availableLinkOpps = CS_ARCasesService.retrieveOpportunitiesToBeLinked(c.Practitioner__c, c.Id);
          if ( availableLinkOpps == null ) { availableLinkOpps = new List<CS_ARCasesService.CS_LinkOpportunity>(); }
    
          for ( CS_ARCasesService.CS_LinkOpportunity linkOpp : availableLinkOpps ) {
            String oppId = linkOpp.objOpportunitySurgeon.Opportunity__c;

            CS_AROpportunityService.CS_AROpportunityWrapper wrappedOpp = CS_AROpportunityService.buildCS_AROpportunityWrapper(oppId);
            if ( wrappedOpp != null ) {
              wrappedOpps.add(wrappedOpp);
            }
          }          

        }
        

      } else {
        // everythign else can link to any available opp

        wrappedOpps = CS_AROpportunityService.retrieveOpportunitiesInMyTeamTerritory();

      }

    }

    return wrappedOpps;
    
  }


  public static List<Object> retrieveAssociatedActivity(String activityType, String eventId, String eventWhatId ) {

    List<Object> allActivities = new List<Object>();

    if ( CS_ARTasksService.whatIs(eventWhatId) == 'Surgical Case') {

      allActivities.addAll( (List<Object>)CS_ARCasesService.retrieveCaseActivity(activityType,eventWhatId) );

    } else {

      // all non-surgical case events have a default activities of creatd by and last modified by
      List<Event> events = CS_ARTasksService.getEvent(eventId);
      if ( events != null && events.size() > 0 ) {
        Event e = events[0];
        String lastModNotes = e.LastModifiedBy.Name+' Modified';
        /*CS_ARCasesService.CS_CaseActivityWrapper lastModLog = new CS_ARCasesService.CS_CaseActivityWrapper(e.LastModifiedDate, lastModNotes, 'LOG', e.Id);
        lastModLog.logOwner = e.LastModifiedBy.Name;
        allActivities.add((Object)lastModLog);

        String createdNotes = e.LastModifiedBy.Name+' Created';
        CS_ARCasesService.CS_CaseActivityWrapper createdLog = new CS_ARCasesService.CS_CaseActivityWrapper(e.CreatedDate, createdNotes, 'LOG', e.Id);
        createdLog.logOwner = e.LastModifiedBy.Name;
        allActivities.add((Object)createdLog);*/
      }
      

    }

    List<CS_AROpportunityService.CS_AROpportunityWrapper> oppList = retrieveLinkedOpportunities(eventId);
    for ( CS_AROpportunityService.CS_AROpportunityWrapper opp : oppList ) {

      allActivities.add( (Object)wrappedOpportunity2CaseWrapper(opp) );

    }

    return allActivities;
  }

  public static void standAloneSurgicalCase2EventBasedSurgicalCase(String surgicalCaseId) {
    // this method takes an existing case and converts it into an event based surgical case
    // it works by gathering all required parameters to call saveSurgicalCase which creates/syncs
    // an event object based on an existing CS_ARCalendarEventDTO and an incoming map of other parameters

    // get the existing surgical case
    CS_ARCalendarEventDTO calEventDTO = CS_ARCasesService.retrieveCalendarEventDTOByCaseId(surgicalCaseId);

    // put together the required map of parameters for saveSurgicalCaseEvent 
    // need status, attendeeIds, practitionerId, isAllDay=false in event params in order to call saveSurgicalCaseEvent
    Map<String,Object> simulatedParams = new Map<String,Object>();
    simulatedParams.put('status', calEventDTO.status);
    simulatedParams.put('practitionerId', calEventDTO.practitionerId);
    simulatedParams.put('isAllDay', false);

    // convert the participant Ids ( users ) to contact Ids
    Set<String> participantUserIds = new Set<String>();
    for ( Map<String,String> participant : calEventDTO.participants ) {
      participantUserIds.add(participant.get('Id'));
    }

    List<String> attendeeIds = new List<String>();
    List<User> pUsers = [select ContactId from User where Id in :participantUserIds];
    if ( pUsers != null ) {
      for ( User pUser :  pUsers ) {
        attendeeIds.add(pUser.ContactId);
      }
    }

    simulatedParams.put('attendeeIds', attendeeIds);

    // now create the event to match the surgical case
    Event event = getEventFromEventParams(simulatedParams);
    event.OwnerId = calEventDTO.ownerId;
    
    saveSurgicalCaseEvent(event, calEventDTO, simulatedParams);  

  }

  public static CS_ARCasesService.CS_CaseActivityWrapper wrappedOpportunity2CaseWrapper(CS_AROpportunityService.CS_AROpportunityWrapper wopp) {

    
    DateTime logDate = null;
    String closeDateStr = wopp.closeDate;
    if ( closeDateStr != null ) {
      // comes in the form yyyy-mm-dd
      String[] dateElems = closeDateStr.split('-');
      logDate = DateTime.newInstance(Integer.valueOf(dateElems[0]), Integer.valueOf(dateElems[1]), Integer.valueOf(dateElems[2]));
    }
    
    String notes = wopp.opportunityName+' - '+wopp.currentStage;
    String activityType = 'OPPORTUNITY';
    String recId = wopp.opportunityId;

    //CS_ARCasesService.CS_CaseActivityWrapper act = new CS_ARCasesService.CS_CaseActivityWrapper(logDate, notes, activityType, recId);
    //act.logOwner = wopp.opportunityOwner;
    return null;
    //return act;

  }

  public static void removeWhoRelation(Event e, Set<String> relatedContactIds) {

    List<EventRelation> toRemove = new List<EventRelation>();
    
    List<String> eventIds = new List<String>();
    eventIds.add(e.Id);

    /*List<EventRelation> relations = CS_ARTasksService.getWhoRelationsByEventIds(eventIds);
    for ( EventRelation relation : relations ) {
      if ( relatedContactIds.contains( relation.RelationId) ) {
        toRemove.add(relation);
      }
    }
    

    if( relations != null ) {

      CS_ARTasksService.deleteEventRelation(toRemove);

      // no triggers available on EventRelation so notify from here when event relations are deleted
      // respect the trigger switch custom setting
      if( Test.isRunningTest() || Trigger_Switch__c.getInstance(Constant.CaseParticipantTrigger).Active__c) {
        CS_NotificationService.EventAttendeeDeleted(toRemove);
      }

    }*/
    
  }

  public static void syncSurgicalCaseParticipants(String caseId, Set<String> attendeeIds) {

    if ( attendeeIds == null || attendeeIds.size() == 0 ) { return; }

    Set<String> caseParticipantIds = new Set<String>();
    List<User> users = [select Id from User where ContactId != null and ContactId in :attendeeIds];
    if ( users != null ) {
      for ( User user : users ) {
        caseParticipantIds.add(user.Id);
      }
    }

    // get who are mapped currently
    Set<Id> existingParticipantIds = new Set<Id>();
    List<CaseParticipant__c> existingParticipants = CS_ARCasesService.retrieveCaseParticipants(caseId);
    
    if ( existingParticipants != null ) {
      for( CaseParticipant__c cp : existingParticipants ) {
          existingParticipantIds.add(cp.Participant__r.Id);
      }      
    }


    // add any missing
    for(String participantId : caseParticipantIds ) {                         
        if( !existingParticipantIds.contains(participantId) ) {
          CS_ARCasesService.cSaveCaseParticipant(caseId, participantId);
        }
    }
        
    // remove any no longer needed
    for ( String existingParticipantId : existingParticipantIds ) {
      if ( !caseParticipantIds.contains(existingParticipantId) ) {
       // CS_ARCasesService.cDeleteCaseParticipantByUserId(caseId, existingParticipantId );
      }
    }

  }

  public static void syncWhoRelations(Event e, Set<String> relatedContactIds ) {
        
    if ( relatedContactIds == null || relatedContactIds.size() == 0 ) { return; }
  
    // get who are mapped currently

    Set<Id> existingContactIds = new Set<Id>();
    List<String> eventIds = new List<String>();
    eventIds.add(e.Id);
    /*for(EventRelation objEventRelation : CS_ARTasksService.getWhoRelationsByEventIds(eventIds) ) {
        existingContactIds.add(objEventRelation.RelationId);
    }

    // add any missing
    Set<String> contactIdsToAdd = new Set<String>();
    for(String contactId : relatedContactIds ) {                         
        if( !existingContactIds.contains(contactId) ) {
          contactIdsToAdd.add(contactId);
        }
    }
    addWhoRelations(e, contactIdsToAdd);
        
    // remove any no longer needed
    Set<String> contactIdsToRemove = new Set<String>();
    for ( String existingContactId : existingContactIds ) {
      if ( !relatedContactIds.contains(existingContactId) ) {
        contactIdsToRemove.add(existingContactId);
      }
    }
    removeWhoRelation(e, contactIdsToRemove);*/
    
  }

  @TestVisible private static Event getEventFromEventParams(Map<String,object> m) {
      // initializes an event which fields common to all event types

      Event event = null;

      // could be in param eventId or id
      String eventId = getMapStringId('eventId',m);
      if ( eventId == null ) { eventId = getMapStringId('id',m); }

      if ( eventId == null ) {
        event = new Event();
        RecordType recType = [Select Id From RecordType  Where SobjectType = 'Event' and Name = :AXIS_EVENT_RECORD_TYPE];
        event.RecordTypeId = recType.Id;
      } else {
        event = CS_ARTasksService.getEvent(eventId)[0];
      }

      // set the all day flag
      event.IsAllDayEvent = getMapBool('isAllDay', m);

      // only set the related account if it is the same as the location ( the user may override related account with location )
      String provId = getMapStringId('providerId', m);
      String location = getMapString('location',m);
      if ( provId != null ) {
        Account a = [select Id,Name,Preferred_Name__c from Account where Id=:provId];
        if ( a != null && (a.Name == location|| a.Preferred_Name__c == location) ) {
          event.Related_Account__c = provId;
        } else {
          event.Related_Account__c = null;
        }
      } else {
        event.Related_Account__c = null;
      }

      return event;
  }

  private static Boolean getMapBool(String key, Map<String,Object> m) {
    if ( m.containsKey(key)) {
      return (Boolean)m.get(key);
    } else {
      return null;
    }
  }
  @TestVisible private static String getMapString(String key, Map<String,Object> m) {
    if ( m.containsKey(key)) {
      return String.valueOf(m.get(key));
    } else {
      return null;
    }
  }  
  private static String getMapStringId(String key, Map<String,Object> m) {
    String str = null;
    if ( m.containsKey(key)) {
      str = String.valueOf(m.get(key));
      if ( str != null && str.length() == 0 ) {
        // id strings can't be blank
        str = null;
      } 
    }

    return str;
    
  }   
  @TestVisible private static Decimal getMapDecimal(String key, Map<String,Object> m) {
    if ( m.containsKey(key) ) {
      return (Decimal)m.get(key);
    } else {
      return null;
    }
  }  
  @TestVisible private static List<String> getMapListString(String key, Map<String,Object> m) {
    if ( m.containsKey(key)) {
      List<String> strs = new List<String>();
      List<Object> objects = (List<Object>)m.get(key);
      for ( Object o : objects ) {
        if ( o != null ) {
          strs.add( String.valueOf(o) );
        }
      }
      return strs;
    } else {
      return null;
    }
  
  }  

    public static EventWrapper calEventDTO2EventWrapper(CS_ARCalendarEventDTO edto, Event e) {

        EventWrapper w = new EventWrapper(e);

        return w;
    }

  public static List<Event> getEventActivityForSurgeon(String surgeonId) {
    // retrieve all events with the surgeon mapped to other related object

    //List<Event> surgeonEventActivity = CS_ARTasksService.getEventsBySurgeonId(surgeonId);
    //if ( surgeonEventActivity == null ) { surgeonEventActivity = new List<Event>(); }
    return null;
    //return surgeonEventActivity;
  }

  public static List<Event> getEventActivityForAccount(String accountId) {

    List<String> accountIds = new List<String>();
    accountIds.add(accountId);

    //List<Event> accountEventActivity = CS_ARTasksService.getEventsByAccountIds(accountIds);
    //if ( accountEventActivity == null) { accountEventActivity = new List<Event>(); }
    List<Event> accountEventActivity = [SELECT id, subject, Type, Location, CreatedBy.Name, StartDateTime from Event where whatid IN: accountIds]; 
    return accountEventActivity;
    //return null;
  }

  public static List<Event> getEventActivityForOpportunity(String oppId) {
    
    //List<Event> oppEventActivity = CS_ARTasksService.getEventsByOppId(oppId);
    //if ( oppEventActivity == null ) { oppEventActivity = new List<Event>(); }
    return null;
    //return oppEventActivity;
  }

  public class EventWrapper {

    public Event event {get;set;}
    public String eventId {get;set;}
    public String eType {get;set;}
    public String status { get;set;}

    public String currentUserContactId {get;set;}
    public String currentUserTeam {get;set;}
    public String currentUserContactName {get;set;}
    public String currentUserAgency {get;set;}
    public String currentUserColor {get;set;}
    public boolean currentUserCanEdit {get;set;}

    
    public String ownerName {get;set;}
    public String ownerId {get;set;}
    public String ownerColor {get;set;}
    public String teamName {get;set;}
    public String teamId {get;set;}

    public String accountName {get;set;}
    public String accountId {get;set;}
    public String accountTeamId {get;set;}


    public String locationAddress {get;set;}
    public String agencyName {get;set;}
    public String location {get;set;}
    public Decimal locationLatitude {get;set;}
    public Decimal locationLongitude {get;set;}
    
    public String surgeonName {get;set;}
    public String surgeonId {get;set;}
    public String caseProductTeam {get;set;}
    public List<String> caseProcedures {get;set;}
    public List<String> caseSurgicalTechniques {get;set;}  

    public String calendarName {get;set;}

    public Set<String> attendees {get;set;}
    public List<Map<String,Object>> attendeeDetails {get;set;}

    public Object associatedTo {get;set;}
    public Object associatedToId {get;set;}
    public Object otherRelatedObjects {get;set;}

    public EventWrapper(Event e) {


      this.event = e;      
      this.attendees = new Set<String>();
      this.attendeeDetails = new List<Map<String,Object>>();
      this.caseProcedures = new List<String>();
      this.caseSurgicalTechniques = new List<String>();
            this.eventId = e.Id;
      this.eType = e.Type;
      this.status = e.Event_Status__c;
      this.ownerName = e.Owner.Name;
      this.ownerId = e.OwnerId;
      this.accountName = e.Related_Account__r.Name;
      if(e.Related_Account__c != null && e.Related_Account__r.Preferred_Name__c != null && e.Related_Account__r.Preferred_Name__c != ''){
            this.accountName = e.Related_Account__r.Preferred_Name__c;
      }
      this.accountId = e.Related_Account__c;

      this.location = e.Location;
      if ( this.location == null || this.location == this.accountName ) {
        
        this.location = this.accountName;
      
        this.locationLatitude = e.Related_Account__r.ShippingLatitude;
        this.locationLongitude = e.Related_Account__r.ShippingLongitude;

        this.locationAddress = '';
        if(!string.isBlank(e.Related_Account__r.ShippingStreet)){
          this.locationAddress +=e.Related_Account__r.ShippingStreet + '<br/>'; 
        }
        if(!string.isBlank(e.Related_Account__r.ShippingCity)){
          this.locationAddress +=e.Related_Account__r.ShippingCity + ', ';  
        }
        if(!string.isBlank(e.Related_Account__r.ShippingState)){
          this.locationAddress +=e.Related_Account__r.ShippingState + ', '; 
        }
        if(!string.isBlank(e.Related_Account__r.ShippingCountry)){
          this.locationAddress += e.Related_Account__r.ShippingCountry + ', '; 
        }
        if(!string.isBlank( e.Related_Account__r.ShippingPostalCode)){
          this.locationAddress += e.Related_Account__r.ShippingPostalCode + ', ';  
        }
      }

      // default false
      this.currentUserCanEdit = false;

    }

    public void calculateCalendarName() {

      // if calendar name is set always use that instead of deriving the calendar name
      if ( this.event.Calendar_Name__c != null ) {
        // always balance to the event first
        this.calendarName = this.event.Calendar_Name__c;
        if ( this.currentUserAgency != null && (this.calendarName == this.currentUserAgency) ) {
          this.calendarName = 'Agency Master';
        }

      } else {

        // order is important,
        if ( this.event.OwnerId == UserInfo.getUserId() || this.attendees.contains(this.currentUserContactName)  ) {
          // not an agency event but either owned by the user or the user is in the attendee list, this is mine
          this.calendarName = 'Mine';
        } else if ( this.teamName != null && (this.teamName == this.currentUserTeam) ) {
          this.calendarName = 'My Team';
        } else {
          // everything else
          this.calendarName = 'Other';
        }

      }

    }

    public void setAttendeeDetails(List<Map<String,Object>> attendeeDetails) {
      if ( attendeeDetails != null ) {
        this.attendeeDetails = attendeeDetails;
        for ( Map<String,Object> attendeeDetail : attendeeDetails ) {
          if ( attendeeDetail.containsKey('Name') ) {
            this.attendees.add( (String)attendeeDetail.get('Name') );
          }        
        }
      }
    }

    public List<Map<String,Object>>  getAttendeeDetails() {
      return this.attendeeDetails;
    }

    public void associateCase(CS_ARCalendarEventDTO dto) {
      this.associatedTo = dto;
      this.associatedToId = dto.url;
      this.surgeonName = dto.practitioner;
      this.surgeonId = dto.practitionerId;

      // override the wrapper account info with the surgical case

      this.accountName = dto.provider;
      this.accountId = dto.providerId;
      this.accountTeamId = dto.providerTerritoryId;

      this.locationLatitude = dto.providerLatitude;
      this.locationLongitude = dto.providerLongitude;
      this.location = dto.provider;
      this.locationAddress = dto.providerAddress;
      this.teamName = dto.ownerProviderTerritory;
      this.teamId = dto.ownerProviderTerritoryId;

      /*if ( dto.lstCaseProceduresWrapper != null && dto.lstCaseProceduresWrapper.size() > 0 ) {
        CS_ARCalendarEventDTO.CS_CaseProceduresWrapper procWrapper = dto.lstCaseProceduresWrapper[0];
        if ( procWrapper != null ) {

          // set product team
          this.caseProductTeam = procWrapper.productName;

          // set procedures
          if ( procWrapper.mapProcedures != null ) {
            this.caseProcedures = procWrapper.mapProcedures.values();
          }

          // set surgical techniques
          if ( procWrapper.mapSurgicalTechniques != null ) {
            this.caseSurgicalTechniques = procWrapper.mapSurgicalTechniques.values();
          }
        }
      }*/

    }
        
    } // end inner class EventWrapper

  public class EventActivityWrapper {
        
        public DateTime logDate {get;set;}
        public String notes {get;set;}
        public String activityType {get;set;}
        public String recId {get;set;}
        public String stage {get;set;}
        
        public EventActivityWrapper(datetime p_logDate,
                                        string p_notes,
                                         string p_activityType,
                                         string p_recId){
            
            logDate = p_logDate;
            notes = p_notes;
            activityType = p_activityType; 
            recId = p_recId;
        }

        /* added by chad for 4.1 */
        public EventActivityWrapper(datetime p_logDate,
                                        string p_notes,
                                         string p_activityType,
                                         string p_recId,
                                         string p_stage){
            
            logDate = p_logDate;
            notes = p_notes;
            activityType = p_activityType; 
            recId = p_recId;
            stage = p_stage;
        }

  } // end inner class EventActivityWrapper
}