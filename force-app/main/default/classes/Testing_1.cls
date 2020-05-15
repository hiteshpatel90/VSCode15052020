public class Testing_1 {
    public Testing_1(){
        
    	User currentUser = [SELECT id from User where id =: userinfo.getuserid() LIMIT 1];
    }
}