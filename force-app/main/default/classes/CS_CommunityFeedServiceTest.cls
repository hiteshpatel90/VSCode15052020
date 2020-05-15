/**********************************************************
**Description: A test class for CS_CommunityFeedService class
**Parameters:   None
**Returns:   None
**Author:    JBANDOJO - CloudSherpas Inc.
**Date Created:  07-APR-2016
**********************************************************/
@IsTest(SeeAllData = true)
public class CS_CommunityFeedServiceTest {

    @IsTest
    public static void testGetFeedElements() {
        Test.StartTest();

        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedElement> testItemList = new List<ConnectApi.FeedElement>();
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(new ConnectApi.FeedItem());
        testPage.elements = testItemList;

        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(Network.getNetworkId(), ConnectApi.FeedType.News, 'me',15, ConnectApi.FeedDensity.FewerUpdates, null, 5,ConnectApi.FeedSortOrder.LastModifiedDateDesc, testPage);
        CS_CommunityFeedService.feedElements('news', null);
        CS_CommunityFeedService.feedElements('default', null);
        
         Account objAcc = new Account();
        objAcc.Name = 'Test Account';
        insert objAcc;
        
        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(Network.getNetworkId(), ConnectApi.FeedType.Record, objAcc.id,15, ConnectApi.FeedDensity.FewerUpdates, null, 5,ConnectApi.FeedSortOrder.LastModifiedDateDesc, testPage);
       
        CS_CommunityFeedService.feedElements(objAcc.id, null);
        
                
        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(Network.getNetworkId(), ConnectApi.FeedType.Bookmarks, 'me',15, ConnectApi.FeedDensity.FewerUpdates, null, 5,ConnectApi.FeedSortOrder.LastModifiedDateDesc, testPage);
        CS_CommunityFeedService.feedElements('bookmarks', null);
    
        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(Network.getNetworkId(), ConnectApi.FeedType.To, 'me',15, ConnectApi.FeedDensity.FewerUpdates, null, 5,ConnectApi.FeedSortOrder.LastModifiedDateDesc, testPage);
        CS_CommunityFeedService.feedElements('me', null);
        

        Test.StopTest();

    }

    @IsTest
    public static void testPostFeedElement() {
        ConnectApi.FeedElement elem = CS_CommunityFeedService.postFeedElement('me','test', 'test attachment name', 'test body');
        System.assertNotEquals(null, elem);
    }

    @IsTest
    public static void testLikeAndUnlikeFeedItem() {
        ConnectApi.FeedElement elem = CS_CommunityFeedService.postFeedElement('me','test', 'test attachment name', 'test body');
        ConnectApi.ChatterLike likeObj = CS_CommunityFeedService.likeFeedItem( elem.Id );
        CS_CommunityFeedService.unlikeFeedItem( likeObj.Id );
            
    }

    @IsTest
    public static void testBookmarkAndUnbookmarkFeedElement() {

        ConnectApi.FeedElement elem = CS_CommunityFeedService.postFeedElement('me','test','test attachment name', 'test body');
        ConnectApi.BookmarksCapability bookmark = CS_CommunityFeedService.bookmarkFeedElement(elem.Id);
        System.assertNotEquals(null, bookmark);

        CS_CommunityFeedService.unbookmarkFeedElement(elem.Id);

    }

    @IsTest
    public static void testGroups() {
        ConnectApi.UserGroupPage groupPage = CS_CommunityFeedService.getGroups(null,null);
        if ( groupPage.groups.size() > 0 ) {
            ConnectApi.ChatterGroupSummary chatGroup = groupPage.groups[0];
            ConnectApi.AnnouncementPage anonPage = CS_CommunityFeedService.getFeedsFromGroup(chatGroup.Id, null, null);
            System.assertNotEquals(null, anonPage);
        }

    }

    @IsTest
    public static void testComments() {

        ConnectApi.FeedElement elem = CS_CommunityFeedService.postFeedElement('me','test', 'test attachment name', 'test body');
        ConnectApi.CommentPage commentPage = CS_CommunityFeedService.getFeedElementComments(elem.Id);
        System.assertNotEquals(null, commentPage);

        ConnectApi.Comment comment = CS_CommunityFeedService.postFeedElementComment(elem.Id, 'test comment');
        System.assertNotEquals(null, comment);

        ConnectApi.ChatterLike commentLike = CS_CommunityFeedService.likeComment(comment.Id);
        System.assertNotEquals(null, commentLike);

        CS_CommunityFeedService.unlikeComment(commentLike.Id);



    }

    
    @IsTest
    public static void testp_FollowRecord() {
        Account objAcc = new Account();
        objAcc.Name = 'Test acc';
        insert objAcc;
        CS_CommunityFeedService.createSubscription cs = new CS_CommunityFeedService.createSubscription();
        cs.p_createSubscription(objAcc.id);
        
        Account objAcc1 = new Account();
        objAcc1.Name = 'Test acc';
        insert objAcc1;
        
        CS_CommunityFeedService.p_FollowRecord(objAcc1.id);
        
        CS_CommunityFeedService.retrieveEntitySubscription(objAcc.id);
    }
    
    @IsTest
    public static void testp_UnFollowRecord() {
        CS_CommunityFeedService.p_UnFollowRecord(null);
    }
    
    @IsTest
    public static void retrieveEntitySubscription_test() {
        
        CS_CommunityFeedService.CS_TerrritoryUsersAndGroupsWrapper ctug = new CS_CommunityFeedService.CS_TerrritoryUsersAndGroupsWrapper(null, null);
    }
    
    @IsTest
    public static void buildTerrritoryUsersAndGroups_test() {
        CollaborationGroup objCG = new CollaborationGroup();
        objCG.Name = 'Test Group';
        objCG.CollaborationType = 'Public';
        objCG.Description = 'Test Description';
        insert objCG;
        
        CS_CommunityFeedService.buildTerrritoryUsersAndGroups();
    }
}