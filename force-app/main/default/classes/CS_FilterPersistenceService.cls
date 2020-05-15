public with sharing class CS_FilterPersistenceService {
    // This class is only responsible for saving and retrieving Filter_JSON__c records. Filter_JSON__c records contain the
    // JSON representation of a saved filter on the front end. There should be no logic implemented in this service other
    // than saving, updating, and retreiving Filter_JSON objects


    public static List<Filter_JSON__c> getFilterJsonByUserAndType(String userId, String filterType) {

    
        List<Filter_JSON__c> filterJSONs = [Select Id, Name, Filter__c, Global__c, Global_Order__c, json__c, User__c from Filter_JSON__c where User__c=:userId and Global__c=false and Filter__c=:filterType order by Name];
        if ( filterJSONs == null ) {
            filterJSONs = new List<Filter_JSON__c>();
        }

        // add in global filters
        List<Filter_JSON__c> globalFilterJSONs = [Select Id, Name, Filter__c, Global__c, Global_Order__c, json__c, User__c from Filter_JSON__c where Global__c=true and Filter__c=:filterType order by Name];
        if ( globalFilterJSONs != null ) {
            filterJSONs.addAll(globalFilterJSONs);
        }

        
        // get current user specific properties, we need to replace the general purpose values like 'me' or 'myteam' with the
        // values specific to the current user
        String curName = null;
        String curTeam = null;
        List<User> curUsers = [select Name from User where id=:UserInfo.getUserId()];
        if ( curUsers != null && curUsers.size() > 0 ) {
            User curUser = curUsers[0];
            curName = curUser.Name;
        }

        List<String> myTeams = CS_ARTerritoryService.retreiveMyTerritoryNames();
        if ( myTeams != null && myTeams.size() > 0 ) {
            // only use the first one
            curTeam = myTeams[0];
        }

        if ( curName != null ) {
            // replace "me" with the current user name. A filter with 'me' in the json is general purpose and is meant to apply
            // to the current user and not one specifically
            for ( Filter_JSON__c f : filterJSONs ) {
                String json = f.json__c;
                f.json__c = json.replaceAll('\'me\'', '\''+curName+'\'');
            }
        }

        if ( curTeam != null ) {
            // replace "myteam" with the current user's first team. A filter with 'myteam' in the json is general purpose and is meant to apply
            // to the current user's team and not one specifically
            for ( Filter_JSON__c f : filterJSONs ) {
                String json = f.json__c;
                f.json__c = json.replaceAll('\'myteam\'', '\''+curTeam+'\'');
            }
        }       

        return filterJSONs;
    }

    public static Filter_JSON__c saveFilterJson(String name, String jsonStr, String userId, String filterType ) {

        // remove any leading/trailing whitespace nad causes exception if name is null
        name = name.trim();

        // causes exception if name length is zero
        name.substring(0,1);    

        Filter_JSON__c filterJson = null;

        List<Filter_JSON__c>  filterJSONs = CS_FilterPersistenceService.getFilterJsonByUserAndType(userId, filterType);
        for ( Filter_JSON__c f : filterJSONs ) {
            if ( f.Name == name && f.Global__c == false ) { 
                filterJson = f;
                break;
            }
        }

        if ( filterJson == null ) { 
            filterJson = new Filter_JSON__c(); 
            filterJson.User__c = userId;
            filterJson.Filter__c = filterType;
            filterJson.Name = name;
        }

        filterJson.json__c = jsonStr;
        upsert filterJson;

        return filterJson;
    }

    public static void deleteFilterJson(String name, String userId, String filterType) {

        Filter_JSON__c filterJson = null;

        List<Filter_JSON__c> filterJSONs = CS_FilterPersistenceService.getFilterJsonByUserAndType(userId, filterType);
        for ( Filter_JSON__c f : filterJSONs ) {
            if ( f.Name == name && f.Global__c == false ) { 
                filterJson = f;
                break;
            }
        }

        if ( filterJson != null ) { delete filterJson; }


    }

}