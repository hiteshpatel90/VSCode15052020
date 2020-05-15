public class DataFactoryContact{

    public static Contact createContacts(string strConName){
        Contact objCon = new Contact();
        objCon.LastName = strConName;
        return objCon;
    }
    
}