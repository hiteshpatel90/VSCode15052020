public class populateUserIdInContact{
    // Added future method to solve Mixed DML exception
    @future
    public static void updateContact(Map<Id, Id> mapContactUser){
        List<Contact> contactList = [select id from contact where id in: mapContactUser.keyset()];
        if(!contactList.isEmpty()){
            for(Contact con: contactList){
                if(mapContactUser.containsKey(con.id)){
                    con.User_Id__c = mapContactUser.get(con.id);
                }
            }
            update contactList;
        }
    }
}