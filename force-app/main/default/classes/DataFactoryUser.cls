/**
 * @author Srinivas Sattoor, Cloud Sherpas Inc.
 * @date Created: 03 June 2016
 * @description: User Data Factory
 */
 public with sharing class DataFactoryUser {
    
    
    /**
     * @author: Srinivas Sattoor, Cloud Sherpas
     * @date: 03 June 2016
     * @description: Prepare portal User record to test permission.
     * @param:  None
     * @return User: Portal user.
    */
    public static User preparePortalUser(){
        return createUser('AXIS Partner Community User', 
            'testsalesrep@arthrex.com', 'testSalesRep');
    }// end of preparePortalUser
    
    /**
     * @author: Srinivas Sattoor, Cloud Sherpas
     * @date: 03 June 2016
     * @description: Method to create the User.
     * @param:  profileName: user's profile.
     *          uName: user's login name.
     *          nName: user's nickname.
     *          primaryTeam: user's primary team name.
     * @return User: created user.
    */
    public static User createUser(String profileName, String uName, String nName) {
        
        String prefix = '.arthrex.com';
        
        Profile pf = [Select id From Profile Where Name =:profileName];

        User usr = new User(FirstName = 'FName', 
                            LastName = 'LName', 
                            UserName = uName + prefix, 
                            Email = 'testsalesrep@arthrex.com',
                            Alias ='UAlias', 
                            CommunityNickname = nName, 
                            TimeZoneSidKey = 'America/New_York', 
                            LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'UTF-8', 
                            ProfileId = pf.id,
                            IsActive = true);

        return usr;
    }
    public  static User CreateUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole role = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', FirstName='User1', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testclassstandarduser@test.com');
        return testUser;
    }

}