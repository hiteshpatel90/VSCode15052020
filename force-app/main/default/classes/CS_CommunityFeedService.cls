/*
    @Author             : Jason Bandojo, 
    @Date Created       : 3-MAR-2016
    @Date Modified      : 
    @Description        : Service class for chatter page
*/
public with sharing class CS_CommunityFeedService {
    /**********************************************************
    **Description: gets the feed element
    **Parameters:   None
    **Returns:   None
    **Author:    JBANDOJO - CloudSherpas Inc.
    **Date Created:  03-MAR-2016
    **********************************************************/
    public static ConnectApi.FeedElementPage feedElements(String feedTypeStr, String pageToken) {
        String subjectId = 'me';
         
        ConnectApi.FeedType feedType = null;
        if ( feedTypeStr == 'bookmarks' ) {
            feedType = ConnectApi.FeedType.Bookmarks;
        } else if ( feedTypeStr == 'me') {
            feedType = ConnectApi.FeedType.To;
        } else if ( feedTypeStr == 'news' ) {
            feedType = ConnectApi.FeedType.News;
        } else if ( feedTypeStr == 'default') {
            //feedType = ConnectApi.FeedType.UserProfile;
            feedType = ConnectApi.FeedType.News;
           // feedType = ConnectApi.FeedType.Company;//updated by srinivas sattoor on 10.16.2017
        } else {
            feedType = ConnectApi.FeedType.Record;
            subjectId = feedTypeStr;
            //subjectId = recordId;
            //feedType = feedTypeStr;
        }

        if ( feedType == ConnectApi.FeedType.Bookmarks ) {
            return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(Network.getNetworkId(), feedType, subjectId, 15, ConnectApi.FeedDensity.FewerUpdates, pageToken, 5, ConnectApi.FeedSortOrder.LastModifiedDateDesc  );
        } else if ( feedType == ConnectApi.FeedType.News) {
            return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(Network.getNetworkId(), feedType, subjectId, 15, ConnectApi.FeedDensity.FewerUpdates, pageToken, 5, ConnectApi.FeedSortOrder.LastModifiedDateDesc);
        } else if ( feedType == ConnectApi.FeedType.To) {
            return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(Network.getNetworkId(), feedType, subjectId, 15, ConnectApi.FeedDensity.FewerUpdates, pageToken, 5, ConnectApi.FeedSortOrder.LastModifiedDateDesc);
        } else if ( feedType == ConnectApi.FeedType.UserProfile ) {
           return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(Network.getNetworkId(), feedType, subjectId, 15, ConnectApi.FeedDensity.FewerUpdates, pageToken, 5, ConnectApi.FeedSortOrder.LastModifiedDateDesc, ConnectApi.FeedFilter.CommunityScoped);
        } else {
            //return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(Network.getNetworkId(), feedType, subjectId, 15, ConnectApi.FeedDensity.FewerUpdates, pageToken, 5, ConnectApi.FeedSortOrder.LastModifiedDateDesc);
            return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(Network.getNetworkId(), feedType, subjectId, 15, ConnectApi.FeedDensity.FewerUpdates, pageToken, 5, ConnectApi.FeedSortOrder.LastModifiedDateDesc);
        }
        
        //return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(Network.getNetworkId(), ConnectApi.FeedType.Bookmarks, '006c000000GjzD5AAJ', null, 1,ConnectApi.FeedSortOrder.LastModifiedDateDesc);
    }    
    /**********************************************************
    **Description: post the feed Item
    **Parameters:   None
    **Returns:   None
    **Author:    JBANDOJO - CloudSherpas Inc.
    **Date Created:  03-MAR-2016
    **********************************************************/
    public static ConnectApi.FeedElement postFeedElement(String subjectId, String message, string attachmentBody, string attachmentName) {
        if ( subjectId == null ) { subjectId = 'me'; } 
        
        //return ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), input);
        system.debug('##--postFeedElement.message: '+ message);
        
        list<string> lstAttachmentIds = new list<string>();
        
        system.debug('##--attachmentBody: '+ attachmentBody);
        system.debug('##--attachmentName: '+ attachmentName);
        if(string.isNotBlank(attachmentBody)){
            
            lstAttachmentIds.add(saveChatterAttachment(attachmentBody, attachmentName));
            
        }
        system.debug('##--lstAttachmentIds: '+ lstAttachmentIds);
        //return ConnectApiHelper.postFeedItemWithRichText(Network.getNetworkId(), subjectId, message, lstAttachmentIds);
        
        return ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), subjectId, ConnectApi.FeedElementType.FeedItem, message);
    } 
    /**********************************************************
    **Description: 'Like' a specific feed Item
    **Parameters:   None
    **Returns:   None
    **Author:    JBANDOJO - CloudSherpas Inc.
    **Date Created:  03-MAR-2016
    **********************************************************/
    public static ConnectApi.ChatterLike likeFeedItem(Id recordId) {
        return ConnectApi.ChatterFeeds.likeFeedElement(Network.getNetworkId(),recordId);
    } 
    /**********************************************************
    **Description: 'Unlike' a specific feed Item
    **Parameters:   None
    **Returns:   None
    **Author:    JBANDOJO - CloudSherpas Inc.
    **Date Created:  03-MAR-2016
    **********************************************************/
    public static void unlikeFeedItem(Id recordId) {
        ConnectApi.ChatterFeeds.deleteLike(Network.getNetworkId(), recordId);
    }  
    /**********************************************************
    **Description: get groups
    **Parameters:   None
    **Returns:   None
    **Author:    JBANDOJO - CloudSherpas Inc.
    **Date Created:  15-MAR-2016
    **********************************************************/
    public static ConnectApi.UserGroupPage getGroups(Integer pageParam, Integer pageSize){

        return ConnectApi.ChatterUsers.getGroups(Network.getNetworkId(), UserInfo.getUserId(), pageParam, pageSize);
    }  
    /**********************************************************
    **Description: get feeds from a specific group
    **Parameters:   None
    **Returns:   None
    **Author:    JBANDOJO - CloudSherpas Inc.
    **Date Created:  22-MAR-2016
    **********************************************************/
    public static ConnectApi.AnnouncementPage getFeedsFromGroup(String groupId, Integer pageParam, Integer pageSize){
        return ConnectApi.ChatterGroups.getAnnouncements(Network.getNetworkId(), groupId, pageParam, pageSize);
    }

    public static ConnectApi.Comment postFeedElementComment(String elementId, String text) {
        return ConnectAPI.ChatterFeeds.postCommentToFeedElement(Network.getNetworkId(), elementId, text);
    }

    public static ConnectApi.CommentPage getFeedElementComments(String elementId) {
        return ConnectApi.ChatterFeeds.getCommentsForFeedElement(Network.getNetWorkId(), elementId);
    }

    public static ConnectApi.BookmarksCapability bookmarkFeedElement(String elementId) {
        return ConnectApi.ChatterFeeds.updateFeedElementBookmarks(Network.getNetworkId(), elementId, true);
    }

    public static ConnectApi.BookmarksCapability unbookmarkFeedElement(String elementId) {
        return ConnectApi.ChatterFeeds.updateFeedElementBookmarks(Network.getNetworkId(), elementId, false);
    }
    public static ConnectApi.ChatterLike likeComment(Id recordId) {
        return ConnectApi.ChatterFeeds.likeComment(Network.getNetworkId(),recordId);
    } 
    public static void unlikeComment(Id recordId) {
        ConnectApi.ChatterFeeds.deleteLike(Network.getNetworkId(), recordId); 
    }
    
    public static EntitySubscription p_FollowRecord(string recordId){ 
        createSubscription cls = new createSubscription();
        return cls.p_createSubscription(recordId);
    }
    
    public static void p_UnFollowRecord(string recordId){ 
        createSubscription cls = new createSubscription();
        cls.p_deleteSubscription(recordId);
    } 
    
    
    public without sharing class createSubscription{
        
        public  EntitySubscription p_createSubscription(string recordId){
            
            EntitySubscription objSubscription = new  EntitySubscription(ParentId = recordId, 
                                                                    SubscriberId = UserInfo.getUserId(),
                                                                    NetworkId = Network.getNetworkId()); 
            insert objSubscription;
            
            return objSubscription;
        }
        
        public  void p_deleteSubscription(string recordId){
            
            list<EntitySubscription> lstEntitySubscriptions = [SELECT Id, ParentId, SubscriberId 
                                                            FROM EntitySubscription 
                                                            WHERE ParentID = :recordId
                                                            AND  SubscriberId =:UserInfo.getUserId() LIMIT 1]; 
            delete lstEntitySubscriptions; 
        }
    } 
    
    public static boolean  retrieveEntitySubscription(string recordId){
        
        list<EntitySubscription> lstEntitySubscriptions = [SELECT Id, ParentId, SubscriberId 
                                                            FROM EntitySubscription 
                                                            WHERE ParentID = :recordId
                                                            AND  SubscriberId =:UserInfo.getUserId() LIMIT 1];
        return lstEntitySubscriptions.size() > 0;
    } 
    
    //Added by srinivas sattoor on 10.10.2017 for CID-000448
    public static list<CS_TerrritoryUsersAndGroupsWrapper> buildTerrritoryUsersAndGroups(){
        
        list<CS_TerrritoryUsersAndGroupsWrapper> lstTerrritoryUsersAndGroups = new list<CS_TerrritoryUsersAndGroupsWrapper>();
        
        /*for(User objUser :CS_ARTerritoryService.retrieveUsersInAgencyAndRegion()){
            CS_TerrritoryUsersAndGroupsWrapper obj = new CS_TerrritoryUsersAndGroupsWrapper(objUser.Id, objUser.Name);
            lstTerrritoryUsersAndGroups.add(obj);
        }// end of for-each*/
        system.debug('##-- buildTerrritoryUsersAndGroups.communitygroups: '+ CS_CommunityFeedService.getGroups(null,null).groups);
        
        for(ConnectAPI.ChatterGroupSummary objGroup :CS_CommunityFeedService.getGroups(null,null).groups){
            CS_TerrritoryUsersAndGroupsWrapper obj = new CS_TerrritoryUsersAndGroupsWrapper(objGroup.id, objGroup.name);
            lstTerrritoryUsersAndGroups.add(obj); 
            
        }
        list<GroupMember> lstUserGroups = [SELECT Id, GroupId,Group.Name, UserorGroupId 
                                                FROM GroupMember 
                                                WHERE UserorGroupId = :UserInfo.getUserId()];
        if(lstUserGroups.size() > 0){
            for(GroupMember objGroupMember :lstUserGroups){
                CS_TerrritoryUsersAndGroupsWrapper obj = new CS_TerrritoryUsersAndGroupsWrapper(objGroupMember.GroupId, objGroupMember.Group.Name);
                lstTerrritoryUsersAndGroups.add(obj); 
            }// end of for-each 
        }
        
        return lstTerrritoryUsersAndGroups;
    }
    
    //Added by srinivas sattoor on 10.10.2017 for CID-000448
    public class CS_TerrritoryUsersAndGroupsWrapper{
        
        public string Id {get;set;}
        public string Name {get;set;}
        
        public CS_TerrritoryUsersAndGroupsWrapper(string p_RecordId, string p_Name){
            
            Id = p_RecordId;
            Name = p_Name;
            
        }// end of CS_TerrritoryUsersAndGroupsWrapper
        
    }// end of CS_TerrritoryUsersAndGroupsWrapper 
    
    
    public static Id saveChatterAttachment(string attachmentBody, string attachmentName){
        system.debug('##--saveChatterAttachment.attachmentBody: '+ attachmentBody);
        system.debug('##--saveChatterAttachment.attachmentName: '+ attachmentName);
        ContentVersion objContentVersion = new ContentVersion();
        objContentVersion.versionData = EncodingUtil.base64Decode(attachmentBody);
        objContentVersion.title = attachmentName;
        objContentVersion.pathOnClient = '/'+attachmentName;
        insert objContentVersion;
        
        Id contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :objContentVersion.Id].ContentDocumentId;
        system.debug('##--contentDocumentId: '+ contentDocumentId);
        return contentDocumentId;
    }// end of saveChatterAttachment
     
}