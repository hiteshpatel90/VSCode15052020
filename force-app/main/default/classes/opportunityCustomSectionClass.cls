public class opportunityCustomSectionClass{
    public opportunityCustomSectionClass(){
    
    }
    
    @AuraEnabled
    public static Opportunity getOpportunity(String strRecordId){
        Opportunity objOpp = [select id, Name, Closedate, StageName from Opportunity where id =: strRecordId];
        return objOpp;
    }
}