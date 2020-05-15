/* 
-------------------------------------------------------------------------------------------
- Type             : Apex Class
- Name             : opportunityHistoryExtension
- Created by       : 
- Created Date     : 30th April 2016
- Purpose          : Controller is used to display Field Tracking history for Opportunity sObject
---------------------------------------------------------------------------------------------- 
*/
public class opportunityHistoryExtension{
    public List<Field_History__c> lstFieldHistory {get; set;}
    string strOppId;
    public boolean isShowmore {get; set;}
    public opportunityHistoryExtension(apexpages.standardController stdCon){
        strOppId = ApexPages.currentPage().getParameters().get('id');
        isShowmore = false;
        string strShowMore = ApexPages.currentPage().getParameters().get('showMore');
        
        ID sID = strOppId;
        lstFieldHistory = new List<Field_History__c>();
        if(strOppId != null){
            if(strShowMore == 'true'){
                isShowmore = true;
                lstFieldHistory = [select id, Edit_Date__c, Record_Id__c, User__c,User__r.Name, Field_Event__c, New_Value__c, Old_Value__c, sObject_Name__c from Field_History__c where Record_Id__c =: sID order by Createddate LIMIT 10000];
            }else{
                lstFieldHistory = [select id, Edit_Date__c, Record_Id__c, User__c,User__r.Name, Field_Event__c, New_Value__c, Old_Value__c, sObject_Name__c from Field_History__c where Record_Id__c =: sID order by Createddate LIMIT 20];
            }
        }
        if(lstFieldHistory.isEmpty()){
            isShowmore = true;
        }
    }
    
    public pagereference showMoreHistoryRecord(){
        pagereference pr = new pagereference('/apex/opportunityHistory?showMore=true&id='+strOppId);
        pr.setRedirect(true);
        return pr;
    }
}