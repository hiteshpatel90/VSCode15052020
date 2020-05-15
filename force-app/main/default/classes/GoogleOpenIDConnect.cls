global class GoogleOpenIDConnect implements Auth.RegistrationHandler{
  global User createUser(Id portalId, Auth.UserData data){
    List<User> lstExistingUser = [SELECT Id, timeZoneSidKey, localesidkey, languagelocalekey FROM user where email =: data.email];
    User u = new User();
    if(!lstExistingUser.isEmpty()){
        u = lstExistingUser[0];
    }
    Profile p = [SELECT Id FROM profile WHERE name='System Administrator'];
    //u.username = data.email;
    u.username = 'hiteshpatel_90@salesforce.com';
    u.email = data.email;
    u.lastName = data.lastName;
    u.firstName = data.firstName;
    u.timeZoneSidKey = 'America/Los_Angeles';
    u.localesidkey = 'en_US';
    u.emailEncodingKey = 'ISO-8859-1';
    u.languagelocalekey = 'en_US';
    String alias = data.firstName + data.lastName;
    if(alias.length() > 8) {
      alias = alias.substring(0, 8);
    }
    u.alias = alias;
    u.profileId = p.Id;
    return u;
  }

  global void updateUser(Id userId, Id portalId, Auth.UserData data){
    User u = new User(id=userId);
    u.email = data.email;
    u.lastName = data.lastName;
    u.firstName = data.firstName;
    update(u);
  }
}