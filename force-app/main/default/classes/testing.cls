public class testing{

    public testing(){
    
        
        User currentUser = [SELECT id from User where id =: userinfo.getuserid() LIMIT 1];
        
        
    }
}