/*
    @Author             : Jason Bandojo
    @Date Created       : 1-Feb-2016
    @Date Modified      : 
    @Description        : controller class for ARHome.page
*/
public with sharing class CS_ARHomeCC {
    
    public PageReference forwardToStartPage() {

        String prefix = Site.getPathPrefix();
        if ( prefix == null ) { prefix = ''; }
       
        String communityUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+prefix;
        String customHomePage = prefix+'/ARHome';
        if (UserInfo.getUserType().equals('Guest')) {
            return new PageReference(communityUrl + '/ARLogin?startURL=' + EncodingUtil.urlEncode(customHomePage, 'UTF-8'));
        }else {
            return null;
        }
    }
    
    public String getMyTerritoryName(){
      return CS_ARTerritoryService.retreiveMyTerritoryNames().get(0);
    }  //  end of getMyTerritoryName
    
    
    public List<Territory2> getSubAgencyOrTeamDropDown(){
      List<Territory2> lstOptions = new List<Territory2>();
      
      map<Id, list<Territory2>> mapparentTerritoryAndListTerritories = CS_ARTerritoryService.parentTerritoryAndListTerritories();
      system.debug('##--getSubAgencyOrTeamDropDown.mapparentTerritoryAndListTerritories: '+ mapparentTerritoryAndListTerritories);
      
      for(ID territory : mapparentTerritoryAndListTerritories.keySet()){
        lstOptions.addAll(mapparentTerritoryAndListTerritories.get(territory));
      }
      
      /*Map<ID, Territory2> mapTerritories = CS_ARTerritoryService.territoryMapOfGivenIds(mapparentTerritoryAndListTerritories.values());
      system.debug('##--getFirstDropDown.mapTerritories: '+ mapTerritories);
      
      for(ID territory : mapparentTerritoryAndListTerritories.keySet()){
        lstOptions.add(mapTerritories.get(territory));
      }*/
      
      return lstOptions;
    }  //  end of getFirstDropDown
    
    public List<Territory2> getAgencyDropDown(){
      List<Territory2> lstOptions = new List<Territory2>();
      
      map<Id, list<Territory2>> mapparentTerritoryAndListTerritories = CS_ARTerritoryService.parentTerritoryAndListTerritories();
      system.debug('##--getFirstDropDown.mapparentTerritoryAndListTerritories: '+ mapparentTerritoryAndListTerritories);
      Map<ID, Territory2> mapTerritories = CS_ARTerritoryService.territoryMapOfGivenIds(mapparentTerritoryAndListTerritories.KeySet());
      system.debug('##--getFirstDropDown.mapTerritories: '+ mapTerritories);
      
      for(ID territory : mapparentTerritoryAndListTerritories.keySet()){
        lstOptions.add(mapTerritories.get(territory));
      }
      
      return lstOptions;
    }  //  end of getSecondDropDown
    
    public boolean getShowSecondDD(){
      return 'Agency'.equals(CS_ARTerritoryService.myTerritoryType());
    }  //  end of getShowSecondDD
    

    // added by chad
    @RemoteAction
    public static List<Map<String,Object>> retrieveCategoryReports(String asOfDateStr, String qualifier) {
        if ( asOfDateStr == null || asOfDateStr.length() == 0  ) {  
            return new List<Map<String,Object>>();
        } else {
            return CS_ReportService.retrieveCategoryReports(Date.valueOf(asOfDateStr), qualifier, true);
        }
    }    
    
    @RemoteAction
    public static Date getLatestCaregoryReportDataDate(String qualifier) {
        return CS_ReportService.retrieveLatestSalesDataDate(qualifier);
    }    
    
    @RemoteAction
    public static ConnectApi.FeedElementPage retrieveFeedElements(String feedTypeStr, String pageToken) {
        return CS_CommunityFeedService.feedElements(feedTypeStr,pageToken);
    }   
    @RemoteAction
    public static ConnectApi.FeedElement postFeedElement(String subjectId, String msg) {
        if ( subjectId.equals('0') ) { subjectId = null; }
        //return CS_CommunityFeedService.postFeedElement(subjectId, msg);
        return null;
    }
    @RemoteAction
    public static ConnectApi.ChatterLike likeUnlikeFeedElement(String postId, String likeId) {
        ConnectApi.ChatterLike chatterLike = null;
        if ( likeId != null && likeId.length() > 0 ) {
            // no return val on unlike, just return null
            CS_CommunityFeedService.unlikeFeedItem(likeId);
        } else {
            chatterLike = CS_CommunityFeedService.likeFeedItem(postId);
        }
        return chatterLike;
    }


    @RemoteAction
    public static List<user> searchUsers(String query)  {
        return CS_ARSearch.searchUsers(query);
    } 
    @RemoteAction
    public static ConnectApi.UserGroupPage  getGroups(){
        return CS_CommunityFeedService.getGroups(null,null);
    }  
    /**********************************************************
    **Description: get feeds from a specific group
    **Parameters:   None
    **Returns:   None
    **Author:    JBANDOJO - CloudSherpas Inc.
    **Date Created:  22-MAR-2016
    **********************************************************/
    @RemoteAction
    public static ConnectApi.AnnouncementPage getFeedsFromGroup(String groupId){
        return CS_CommunityFeedService.getFeedsFromGroup(groupId, null, null);
    }

    @RemoteAction
    public static ConnectApi.Comment postFeedElementComment(String elementId, String text) {
        return CS_CommunityFeedService.postFeedElementComment(elementId, text);
    }

    @RemoteAction
    public static ConnectApi.CommentPage getFeedElementComments(String elementId) {
        return CS_CommunityFeedService.getFeedElementComments(elementId);
    }

    @RemoteAction
    public static ConnectApi.BookmarksCapability bookmarkFeedElement(String elementId) {
        return CS_CommunityFeedService.bookmarkFeedElement(elementId);
    }

    @RemoteAction
    public static ConnectApi.BookmarksCapability unbookmarkFeedElement(String elementId) {
        return CS_CommunityFeedService.unbookmarkFeedElement(elementId);
    }
    
    @RemoteAction
    public static ConnectApi.ChatterLike likeUnlikeComment(String postId, String likeId) {
        ConnectApi.ChatterLike chatterLike = null;
        if ( likeId != null && likeId.length() > 0 ) {
            // no return val on unlike, just return null
            CS_CommunityFeedService.unlikeComment(likeId);
        } else {
            chatterLike = CS_CommunityFeedService.likeComment(postId);
        }
        return chatterLike;
    }    
}