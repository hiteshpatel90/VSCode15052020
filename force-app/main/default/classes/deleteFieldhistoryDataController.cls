public class deleteFieldhistoryDataController{
    public deleteFieldhistoryDataController(){
    
    }
    
    public void deleteFieldhistoryData(){
        List<Field_History__c> existingFHData = [select id from Field_History__c];
        delete existingFHData;
    }
}