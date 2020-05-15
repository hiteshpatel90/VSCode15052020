public without sharing class CS_NotificationService {
    
    // limit 25 chars on push topic names
    private static Decimal API_VERSION = 28.0;
    private static String BROADCAST_PUSH_TOPIC = 'apex_web_broadcast';
    private static String APPLE_PUSH_NOTIFICATION_APP = '';

    
    public enum NType { CASE_CANCELLED, CASE_MOVED, CASE_REP_CHANGE, CHATTER_POST_COMMENT, DIRECT_MESSAGE, BROADCAST, TICKET_ASSIGNED, TICKET_CREATED }

    /* Supported notifications
    1. ticket assigned to user TEST
    2. surgeon assigned to ticket TEST
    3. calendar event cancelled DONE
    4. calendar event changed times or moved location DONE
    5. calendar owner/participant added/removed DONE
    6. reply to chatter post DONE
    */

    // delivers undelivered notifications to users ( costs 1 soql query )
    public static void deliver() {

        // retrieve all undelivered messages
        List<Notification_Instance__c> undeliveredNotifications = [select Id, Read__c, Notification__r.Message__c, 
            Notification__r.Data__c,Notification__r.Subject__c, Notification__r.CreatedDate, 
            Notification__r.Notification_Type__c, Push_Notification_Required__c, User__c, User__r.Username from Notification_Instance__c 
            where Delivered__c = false order by Notification__r.Id];

        if ( undeliveredNotifications == null ) { undeliveredNotifications = new List<Notification_Instance__c>(); }

        // create a map of userid -> msg count to get a current unread msg count for each user in this delivery
        Map<String, Integer> unreadMsgMap = new Map<String,Integer>();
        AggregateResult[] groupedResults = [select User__c usr,count(Id) cnt from Notification_Instance__c where Read__c = false group by User__c];
        for (AggregateResult ar : groupedResults)  {
            unreadMsgMap.put(String.valueOf(ar.get('usr')), Integer.valueOf(ar.get('cnt')));
        }

        for (Notification_Instance__c undeliveredNotification : undeliveredNotifications ) {
            // deliver each instance of the notification

            String userName = undeliveredNotification.User__r.Id;
            String userId = undeliveredNotification.User__c;

            Integer unreadMsgCount = null;
            if ( unreadMsgMap.containsKey(userId) ) {
                unreadMsgCount = unreadMsgMap.get(userId);
            }
        
            if ( undeliveredNotification.Push_Notification_Required__c ) {
                // @Future annotated methods cannot have standard objects passed in
                //Map<String,Object> uaPush = CS_UrbanAirshipService.notificationInstance2PushObject(userName, unreadMsgCount, undeliveredNotification);
                //deliverMobile(JSON.serialize(uaPush));
            }

            undeliveredNotification.Delivered__c = true;
            undeliveredNotification.Delivered_On__c = DateTime.Now();
                    
        }

        update undeliveredNotifications;    

    }

    // delivers notification instances for the same notification to mobile users
    private static void deliverMobile(String uaPushStr) {               
        
        //CS_UrbanAirshipService.push(uaPushStr);     

    }   

    // short cut for enqueing a simple message
    public static void enqueue(NType ntype, String notificationBody, Map<String,Object> data) {
        enqueue(ntype, notificationBody, null, data, null);     
    }

    // sets up an notification for delivery ( costs 1 soql query )
    public static void enqueue(NType ntype, String notificationBody, String originatedByUserId, Map<String,Object> data, Set<String> possibleToUsers) {

        // derive the type
        Notification_Type__c notificationType = string2NotificationType(ntype.name());
        if ( notificationType == null ) {
            // fast return if this notification type is unsupported
            System.debug('Unsupported notification type '+ntype.name());
            return;
        }

        // create the notification
        Notification__c notification = new Notification__c();
        notification.Originated_From_Action_By__c = originatedByUserId;
        notification.Message__c = notificationBody;
        notification.Subject__c = notificationType.Human_Friendly_Name__c;
        notification.Notification_Type__c = notificationType.Id;

        notification.Data__c = JSON.serialize(data);

        insert notification;

        // create instances for each user subscribed to this type which is a subset of possible users if the possible user set is not empty
        List<Notification_Subscription__c> subscriptions = null;
        if ( possibleToUsers != null && possibleToUsers.size() > 0 ) { 
            subscriptions = [select Id, User__c, Enable_Push_Notification__c from Notification_Subscription__c where Notification_Type__c=:notificationType.Id and User__c in :possibleToUsers];
        } else {
            subscriptions = [select Id, User__c, Enable_Push_Notification__c from Notification_Subscription__c where Notification_Type__c=:notificationType.Id];
        }

        List<Notification_Instance__c> newInstances = new List<Notification_Instance__c>();
        for ( Notification_Subscription__c subscription : subscriptions ) {

            Notification_Instance__c notificationInstance = new Notification_Instance__c();
            notificationInstance.Push_Notification_Required__c = subscription.Enable_Push_Notification__c;
            notificationInstance.Notification__c = notification.Id;
            notificationInstance.User__c = subscription.User__c;
            newInstances.add(notificationInstance);
        
        }

        
        insert newInstances;

    }

    // retrieves all delivered messages for a user between a date range
    public static List<Notification_Instance__c> getInboxByUserIdBetween(String userId, Date fromDate, Date toDate) {

        List<Notification_Instance__c> instances = null;

        if ( fromDate != null && toDate != null ) {
            // betweeen to dates

            // toDate is non-inclusive so add 1 day
            toDate = toDate.addDays(1);

            instances = [select Id, Read__c, Notification__r.Message__c, Notification__r.Data__c,
                Notification__r.CreatedDate, Notification__r.Notification_Type__c from Notification_Instance__c
                where User__c = :userId and Delivered__c = true and CreatedDate >= :fromDate and CreatedDate < :toDate ];
        } else if ( fromDate != null && toDate == null ) {
            // start date to current
            instances = [select Id, Read__c, Notification__r.Message__c, Notification__r.Data__c,
                Notification__r.CreatedDate, Notification__r.Notification_Type__c from Notification_Instance__c
                where User__c = :userId and Delivered__c = true and CreatedDate >= :fromDate ];
        
        } else if ( fromDate == null && toDate == null ) {
            // all messages
            instances = [select Id, Read__c, Notification__r.Message__c, Notification__r.Data__c,
                Notification__r.CreatedDate, Notification__r.Notification_Type__c from Notification_Instance__c
                where User__c = :userId and Delivered__c = true];
        }

        if ( instances == null ) { instances = new List<Notification_Instance__c>(); }

        return instances;

    }   


    // retrieves all delivered messages for a user between a date range
    public static List<Notification_Instance__c> getNewMsgsByUserAsOf(String userId, DateTime asOf) {

        List<Notification_Instance__c> instances = [select Id, Read__c, Notification__r.Message__c, Notification__r.Data__c,
                Notification__r.CreatedDate, Notification__r.Notification_Type__c from Notification_Instance__c
                where User__c = :userId and Delivered__c = true and CreatedDate > :asOf ];

        if ( instances == null ) { instances = new List<Notification_Instance__c>(); }

        return instances;

    }   

    // retrieves the current unread msg count
    public static Integer getUnreadMsgCountByUser(String userId) {

        List<Notification_Instance__c> unreadMsgs = [select Id from Notification_Instance__c where User__c = :userId and Delivered__c = true and Read__c = false];
        if ( unreadMsgs == null ) {
            unreadMsgs = new List<Notification_Instance__c>();
        } 
        
        return unreadMsgs.size();

    }   

    // ticket ( salesforce case ) has been created
    public static void TicketCreated(List<Case> newList) {

        Set<String> communityUserIds = getCommunityUserIds();
        List<Id> accountIds = new List<Id>();
        for ( Case newOne : newList ) {
            if ( newOne.AccountId != null && isNotifiableTicket(newOne)) {
                accountIds.add(newOne.AccountId);
            }
        }

        List<Account> surgList = [select Id,name from Account  where RecordType.Name ='Practitioner' and Id in :accountIds order by Name Asc];
        if ( surgList != null && surgList.size() == 1 ) {

            Account surgeon = surgList[0];
            String surgeonName = 'test';//surgeon.Salutation+' '+surgeon.FirstName+' '+surgeon.LastName;

            // resolve accountId to a list of UserOrGroupIds
            List<AccountShare> ashares = [Select Id, UserOrGroupId, AccountId from AccountShare where (RowCause='TerritoryManual' or RowCause='Territory') and AccountId in :accountIds];
            if ( ashares == null ) { ashares = new List<AccountShare>(); }

            List<Id> groupIds = new List<Id>();
            for ( AccountShare ashare : ashares) {
                groupIds.add( ashare.UserOrGroupId );
            }

            // resolve list of UserOrGroupIds to territory ids
            List<Group> groups = [Select Id, RelatedId from Group where Type='Territory' and Id IN :groupIds];
            if ( groups == null ) { groups = new List<Group>(); }

            List<Id> surgTerritoryIds = new List<Id>();
            for ( Group grp : groups ) {
                surgTerritoryIds.add(grp.RelatedId);
            }

            // resolve territory ids to user ids
                        
            List<UserTerritory2Association> userTerrAssocs = [SELECT Id, UserId FROM UserTerritory2Association WHERE Territory2Id in :surgTerritoryIds ];
            for ( UserTerritory2Association userTerrAssoc : userTerrAssocs) {

                String userId = userTerrAssoc.UserId;
                if ( communityUserIds.contains(userId) ) {
                    // this is a community user, trigger a notification
                    
                    String msgTemplate = Label.Notification_Ticket_Surgeon_Assigned;
                    Map<String,String> templateVariables = new Map<String,String>();
                    templateVariables.put(':surgeon_name:', surgeonName );
                    
                    Map<String,Object> data = new Map<String,Object>();
                    data.put('comm_href','/ARTasks');
                    
                    Set<String> toUsers = new Set<String>();
                    toUsers.add(userId);
                    enqueue(NType.TICKET_CREATED, mergeCustomLabelTemplate(msgTemplate, templateVariables), null, data, toUsers);

                }
            }

        }

        deliver();
    }



    // ticket (salesforce case) has been updated
    public static void TicketUpdate(List<Case> newList, Map<Id,Case> oldMap) {

        for(Case newOne : newList ) {

            // only interested in tickets that should trigger a notification
            if ( !isNotifiableTicket(newOne) ) { continue; }

            if ( oldMap.containsKey(newOne.Id) ) {
                Case oldOne = oldMap.get(newOne.Id);

                if ( oldOne.OwnerId != newOne.OwnerId && isCommunityMember(newOne.OwnerId) ) {
                    // ticket owner has changed, notify the new owner if they are community user

                    List<Account> surgList = [select Id from Account  where RecordType.Name ='Practitioner' and Id=:newOne.AccountId order by Name Asc];
                    /*if ( surgList != null && surgList.size() == 1 ) {
                        // surgeon is available
                        Account surgeon = surgList[0]; 
                        Map<String,String> templateVariables = new Map<String,String>();
                        templateVariables.put(':surgeon_name:', surgeon.Salutation+' '+surgeon.FirstName+' '+surgeon.LastName );
                        
                        Map<String,Object> data = new Map<String,Object>();
                        data.put('comm_href','/ARTasks');

                        String msgTemplate = Label.Notification_Assigned_Ticket;
                        Set<String> toUsers = new Set<String>();
                        toUsers.add(newOne.OwnerId);
                        enqueue(NType.TICKET_ASSIGNED, mergeCustomLabelTemplate(msgTemplate, templateVariables), newOne.lastModifiedById, data, toUsers);
                    
                    }*/

                }

                    
            }

        }

        deliver();

    }

    // FeedItem ( a chatter comment has been created )

    public static void ChatterCommentCreated(list<FeedComment> newFeedItemComments) {

        boolean deliverRequired = false;

        for ( FeedComment newComment : newFeedItemComments ) {

            FeedItem parentItem = [select Id,CreatedById from FeedItem where Id=:newComment.FeedItemId];
            FeedComment comment = [select Id,CreatedById, CreatedBy.Name from FeedComment where Id=:newComment.Id];
            if ( isCommunityMember(parentItem.CreatedById) ) {
                // a comment was on a Post from a community member
                
                if ( parentItem.CreatedById != comment.CreatedById ) {
                    // comment was created by someone other than the parent author, notify the parent author of the comment

                    Set<String> notifyUsers = new Set<String>();
                    notifyUsers.add(parentItem.CreatedById);

                    Map<String,String> templateVariables = new Map<String,String>();
                    templateVariables.put(':comment_author:', comment.CreatedBy.Name );
                        
                    Map<String,Object> data = new Map<String,Object>();
                    data.put('comm_href','/ARHome');
                        
                    String msgTemplate = Label.Notification_Chatter_Post_Comment;
                    
                    enqueue(NType.CHATTER_POST_COMMENT, mergeCustomLabelTemplate(msgTemplate, templateVariables), comment.CreatedById, data, notifyUsers);
                    deliverRequired = true;
                }
            }

        }

        if ( deliverRequired ) {
            deliver();
        }

    }

    public static List<Notification_Subscription__c> getSubscriptionsByUser(String userId) {

        List<Notification_Subscription__c> subscriptions = [select Id,Notification_Type__c,Enable_Push_Notification__c from Notification_Subscription__c where User__c=:userId];
        if ( subscriptions == null ) { subscriptions = new List<Notification_Subscription__c>(); }
        return subscriptions;
    }

    // optimized
    public static void CaseParticipantInserted(List<CaseParticipant__c> newList) {

        List<String> cIds = new List<String>();
        for ( CaseParticipant__c p : newList ) { cIds.add(p.Case__c); }
        Map<Id,Case__c> caseMap = new Map<Id,Case__c>([select Id, Status__c, OwnerId, LastModifiedById,Event_Start_Date__c,Event_End_Date__c,Health_Care_Provider__r.Id,Health_Care_Provider__c,Health_Care_Provider__r.Name,Practitioner__r.Name,Practitioner__r.Id from Case__c where Id in :cIds]);
        
        for ( CaseParticipant__c added : newList ) {

            // notify the user being removed
            Set<String> notifyUsers = new Set<String>();
            notifyUsers.add(added.Participant__c);

            Map<String,String> templateVariables = new Map<String,String>();
            Case__c calEvent = caseMap.get(added.Case__c);
            if ( calEvent != null ) {
                templateVariables.put(':hcp_name:', calEvent.Health_Care_Provider__r.Name );
                templateVariables.put(':start_time:', calEvent.Event_Start_Date__c.format('MM/dd/yyyy h:mm a') );
                templateVariables.put(':end_time:', calEvent.Event_End_Date__c.format('MM/dd/yyyy h:mm a'));
                templateVariables.put(':surgeon_name:', calEvent.Practitioner__r.Name );
            }   
                            
            Map<String,Object> data = new Map<String,Object>();
            data.put('comm_href','/ARCases');
                            
            String msgTemplate = Label.Notification_Case_Participant_Added;             
            enqueue(NType.CASE_REP_CHANGE, mergeCustomLabelTemplate(msgTemplate, templateVariables), UserInfo.getUserId(), data, notifyUsers);
            
        }

        deliver();


    }

    // optimized
    public static void CaseParticipantDeleted(List<CaseParticipant__c> oldListOrg) {
        
        List<String> cIds = new List<String>();
        for ( CaseParticipant__c p : oldListOrg ) { cIds.add(p.Case__c); }
        Map<Id,Case__c> caseMap = new Map<Id,Case__c>([select Id, Status__c, OwnerId, LastModifiedById,Event_Start_Date__c,Event_End_Date__c,Health_Care_Provider__r.Id,Health_Care_Provider__c,Health_Care_Provider__r.Name,Practitioner__r.Name,Practitioner__r.Id from Case__c where Id in :cIds]);
        

        for ( CaseParticipant__c removed : oldListOrg ) {
        
            // notify the user being removed
            Set<String> notifyUsers = new Set<String>();
            notifyUsers.add(removed.Participant__c);

            Map<String,String> templateVariables = new Map<String,String>();
            Case__c calEvent = caseMap.get(removed.Case__c);
            if ( calEvent != null ) {
                templateVariables.put(':hcp_name:', calEvent.Health_Care_Provider__r.Name );
                templateVariables.put(':start_time:', calEvent.Event_Start_Date__c.format('MM/dd/yyyy h:mm a') );
                templateVariables.put(':end_time:', calEvent.Event_End_Date__c.format('MM/dd/yyyy h:mm a'));
                templateVariables.put(':surgeon_name:', calEvent.Practitioner__r.Name );
            }       
                            
            Map<String,Object> data = new Map<String,Object>();
            data.put('comm_href','/ARCases');
                            
            String msgTemplate = Label.Notification_Case_Participant_Removed;               
            enqueue(NType.CASE_REP_CHANGE, mergeCustomLabelTemplate(msgTemplate, templateVariables), UserInfo.getUserId(), data, notifyUsers);
            
        }

        deliver();
    }

    // optimized
    public static void CaseUpdated(List<Case__c> newListOrg, Map<Id,Case__c> oldMap) {


        // avoid SOQL query limit by not iterating over the incoming list of cases since it could be > 100
        List<Case__c> newList = new List<Case__c>();
        List<CaseParticipant__c> allCaseParticipants = new List<CaseParticipant__c>();
        
        if ( newListOrg != null ) {
            List<String> newCaseIds = new List<String>();
            for ( Case__c c : newListOrg ) { newCaseIds.add(c.Id); }            
            newList = [select Id, Status__c, OwnerId, LastModifiedById,Event_Start_Date__c,Event_End_Date__c,Health_Care_Provider__r.Id,Health_Care_Provider__c,Health_Care_Provider__r.Name,Practitioner__r.Name,Practitioner__r.Id from Case__c where Id in :newCaseIds ];                    
            allCaseParticipants = [select Id, Case__c, Participant__c from CaseParticipant__c where Case__c in :newCaseIds];
        }

        Map<Id,Account> oldHcps = new Map<Id,Account>();
        List<String> oldHcpIds = new List<String>();
        if ( oldMap != null ) {
            List<Case__c> oldCases = oldMap.values();
            for ( Case__c oldCase : oldCases ) {
                oldHcpIds.add(oldCase.Health_Care_Provider__c);
            }
            oldHcps = new Map<Id,Account>([select Id,Name from Account where Id=:oldHcpIds]);
        }

        boolean deliverRequired = false;

        for( Case__c newOne : newList ) {
            
            if ( oldMap.containsKey(newOne.Id) ) {
                Case__c oldOne = oldMap.get(newOne.Id);

                if ( newOne.Status__c == 'Cancelled' && oldOne.Status__c != 'Cancelled') {
                    // this case was cancelled, tell the owner and participants

                    Set<String> notifyUsers = new Set<String>();
                    for ( CaseParticipant__c cp : allCaseParticipants ) {
                        if ( cp.Case__c == newOne.Id ) {

                            // don't notify the lastmodified user since they're the one that made the chnage
                            if ( cp.Participant__c == newOne.LastModifiedById ) { continue; }
                            notifyUsers.add(cp.Participant__c);

                        }
                    }
                   

                    if ( newOne.OwnerId != newOne.LastModifiedById ) {
                        // don't notify the lastmodified user since they're the one that made the chnage
                        notifyUsers.Add(newOne.OwnerId);
                    }

                    Map<String,String> templateVariables = new Map<String,String>();
                    templateVariables.put(':surgeon_name:', newOne.Practitioner__r.Name );
                    templateVariables.put(':hcp_name:', newOne.Health_Care_Provider__r.Name );
                    templateVariables.put(':start_time:', newOne.Event_Start_Date__c.format('MM/dd/yyyy h:mm a') );
                    templateVariables.put(':end_time:', newOne.Event_End_Date__c.format('MM/dd/yyyy h:mm a'));

                    Map<String,Object> data = new Map<String,Object>();
                    data.put('comm_href','/ARCases');

                    String msgTemplate = Label.Notification_Case_Cancelled;

                    enqueue(NType.CASE_CANCELLED, mergeCustomLabelTemplate(msgTemplate, templateVariables), newOne.lastModifiedById, data, notifyUsers);
                    deliverRequired = true;

                } else {

                    // modification besides cancelling the case happened, next priority is to see if the owner has changed
                    if ( newOne.OwnerId != oldOne.OwnerId && newOne.LastModifiedById != newOne.OwnerId ) {
                        // owner has changed and not by the person who now owns the case

                        // notify the new owner
                        Set<String> notifyUsers = new Set<String>();
                        notifyUsers.add(newOne.OwnerId);

                        Map<String,String> templateVariables = new Map<String,String>();
                        templateVariables.put(':surgeon_name:', newOne.Practitioner__r.Name );
                        templateVariables.put(':hcp_name:', newOne.Health_Care_Provider__r.Name );
                        templateVariables.put(':start_time:', newOne.Event_Start_Date__c.format('MM/dd/yyyy h:mm a') );
                        templateVariables.put(':end_time:', newOne.Event_End_Date__c.format('MM/dd/yyyy h:mm a'));
                        

                        Map<String,Object> data = new Map<String,Object>();
                        data.put('comm_href','/ARCases');
                            
                        String msgTemplate = Label.Notification_Case_Owner_Change;          

                        enqueue(NType.CASE_REP_CHANGE, mergeCustomLabelTemplate(msgTemplate, templateVariables), newOne.lastModifiedById, data, notifyUsers);
                        deliverRequired = true; 

                    }


                    // check to see if the location / time changed, and if it has tell the owner and participants
                    Datetime newStart = newOne.Event_Start_Date__c;
                    Datetime newEnd = newOne.Event_End_Date__c;
                    String newHCPId = newOne.Health_Care_Provider__c;

                    Datetime oldStart = oldOne.Event_Start_Date__c;
                    Datetime oldEnd = oldOne.Event_End_Date__c;
                    String oldHCPId = oldOne.Health_Care_Provider__c;

                    boolean datetimeOrLocationChanged = newStart != oldStart;
                    datetimeOrLocationChanged = (datetimeOrLocationChanged || (newEnd != oldEnd));
                    datetimeOrLocationChanged = (datetimeOrLocationChanged || (newHcpId != oldHcpId));


                    if ( datetimeOrLocationChanged ) {
                        // notify the owner and participants of the location/time change
                            
                        Set<String> notifyUsers = new Set<String>();
                        for ( CaseParticipant__c cp : allCaseParticipants ) {
                            if ( cp.Case__c == newOne.Id ) {

                                // don't notify the lastmodified user since they're the one that made the chnage
                                if ( cp.Participant__c == newOne.LastModifiedById ) { continue; }
                                notifyUsers.add(cp.Participant__c);

                            }
                        }


                        if ( newOne.OwnerId != newOne.LastModifiedById ) {
                            // don't notify the lastmodified user since they're the one that made the chnage
                            notifyUsers.Add(newOne.OwnerId);
                        }

                        // get the old hcpName
                        String oldHcpName = null;
                        if ( oldHcps.containsKey(oldHcpId) ) {
                            oldHcpName = oldHcps.get(oldHcpId).Name;
                        }

                        Map<String,String> templateVariables = new Map<String,String>();
                        templateVariables.put(':hcp_name:', newOne.Health_Care_Provider__r.Name );
                        templateVariables.put(':start_time:', newOne.Event_Start_Date__c.format('MM/dd/yyyy h:mm a') );
                        templateVariables.put(':end_time:', newOne.Event_End_Date__c.format('MM/dd/yyyy h:mm a'));
                        templateVariables.put(':surgeon_name:', newOne.Practitioner__r.Name );
                        if ( oldHcpName != null ) {
                            templateVariables.put(':old_hcp_name:', oldHcpName );
                        }
                        templateVariables.put(':old_start_time:', oldOne.Event_Start_Date__c.format('MM/dd/yyyy h:mm a') );
                        templateVariables.put(':old_end_time:', oldOne.Event_End_Date__c.format('MM/dd/yyyy h:mm a') );
                        templateVariables.put(':old_surgeon_name:', oldOne.Practitioner__r.Name );
                            
                        Map<String,Object> data = new Map<String,Object>();
                        data.put('comm_href','/ARCases');
                            
                        String msgTemplate = Label.Notification_Case_Moved;                 

                        enqueue(NType.CASE_MOVED, mergeCustomLabelTemplate(msgTemplate, templateVariables), newOne.lastModifiedById, data, notifyUsers);
                        deliverRequired = true;             

                    }


                }
            }

        }

        if ( deliverRequired ) {
            deliver();
        }

    }


    public static String mergeCustomLabelTemplate(String customLabelStr, Map<String,String> mergeVars) {

        if ( customLabelStr == null ) { return customLabelStr; }
        if ( mergeVars == null || mergeVars.size() == 0 ) { return customLabelStr; }

        for ( String key : mergeVars.keySet() ) {
            String mergeVal = mergeVars.get(key);
            if ( mergeVal != null ) {
                customLabelStr = customLabelStr.replaceAll(key, mergeVars.get(key) );
            }
        }

        return customLabelStr;

    }

    public static boolean isCommunityMember(Id userId) {

        List<User> users = [SELECT id FROM User WHERE Id=:userId AND (Profile.UserLicense.Name='Partner Community' OR Profile.UserLicense.Name='Customer Community')];
        return (users != null && users.size() > 0);     
    }

    public static Set<String> getCommunityUserIds() {
        
        List<User> users = [SELECT Id FROM User WHERE (Profile.UserLicense.Name='Partner Community' OR Profile.UserLicense.Name='Customer Community')];
        
        Set<String> userIds = new Set<String>();
        for ( User u : users ) { userIds.add(u.Id);}
        users.clear();

        return userIds;
    }


    public static boolean isNotifiableTicket(Case c ) {

        // fast fail
        if ( c == null || c.AccountId == null ) { return false; }

        boolean shouldNotify = false;

        List<Case> caseDetail = [select Conference__c, RecordTypeId from Case where Id=:c.Id];
        if ( caseDetail != null && caseDetail.size() == 1 ) {
            Case thisCase = caseDetail[0];
        
            // checks that this is the right record type

            // only look in the custom setting if a test is not running
            String recordTypeStr = 'all';
            if ( !Test.isRunningTest() ) {
                recordTypeStr = Notification_Service_Settings__c.getValues('Current').Notifiable_Ticket_Record_Types__c;
            }

            if ( recordTypeStr == null ) {
                shouldNotify = false;
            } else if (recordTypeStr.equalsIgnoreCase('all') ) {
                shouldNotify = true;
            } else if ( recordTypeStr.contains(c.RecordTypeId) ){               
                shouldNotify = true;
            }

            // TODO check that this is not a duplicate ( same conference, same surgeon, same record type )
            // 

        }

        return shouldNotify;
        
    }


    public static List<Notification_Type__c> getNotificationTypes() {

        return [select Id, Name, Human_Friendly_Name__c, Category__c, Abbreviated_Human_Friendly_Name__c, Description__c from Notification_Type__c];
    }

    public static List<Notification_Instance__c> markAsRead(List<String> notificationIds) {

        return updateRead(notificationIds, true);

    }

    public static List<Notification_Instance__c> markAsUnread(List<String> notificationIds) {

        return updateRead(notificationIds, false);

    }

    private static List<Notification_Instance__c> updateRead(List<String> notificationIds, boolean read) {

        List<Notification_Instance__c> instances = [select Id, Read__c, Notification__r.Message__c, Notification__r.Data__c,
                Notification__r.CreatedDate, Notification__r.Notification_Type__c from Notification_Instance__c
                where Id in :notificationIds];

        if ( instances == null ) { instances = new List<Notification_Instance__c>(); }

        for ( Notification_Instance__c instance : instances ) {
            instance.Read__c = read;
            update instance;
        }

        return instances;

    }


    public static Notification_Type__c string2NotificationType(String str) {

        Notification_Type__c notificationType = null;
        List<Notification_Type__c> notificationTypes = [select Id,Name,Human_Friendly_Name__c from Notification_Type__c where Name=:str];
        if (  notificationTypes != null && notificationTypes.size() > 0 ) {
            notificationType = notificationTypes[0];
        }
        return notificationType;


    }

    public static void subscribe(String userId, List<String> notificationTypeIds, List<String> pushEnabledTypeIds) {

        List<Notification_Subscription__c> oldSubs = CS_NotificationService.getSubscriptionsByUser(userId);
        delete oldSubs;

        List<Notification_Subscription__c> newSubs = new List<Notification_Subscription__c>();
        for ( String notificationTypeId : notificationTypeIds ) {
            Notification_Subscription__c sub = new Notification_Subscription__c();
            sub.Notification_Type__c = notificationTypeId;
            sub.User__c = userId;
            for ( String pushEnabledId : pushEnabledTypeIds ) {
                if ( notificationTypeId == pushEnabledId ) {
                    sub.Enable_Push_Notification__c = true;
                } else {
                    sub.Enable_Push_Notification__c = false;
                }
            }
            newSubs.add(sub);
        }

        if ( newSubs.size() > 0 ) {
            insert newSubs;
        }

    }
}