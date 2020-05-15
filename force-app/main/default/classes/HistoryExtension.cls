public class HistoryExtension{
    public List<Field_History__c> lstFieldHistoryTemp {get; set;}
    public List<Field_History__c> lstFieldHistory {get; set;}
    string strRecordId;
    public boolean isShowmore {get; set;}
    string strObjectName;
    public HistoryExtension(apexpages.standardController stdCon){
        Schema.DescribeSobjectResult sObjecttype = Schema.getGlobalDescribe().get('Opportunity').getDescribe();
        if (sObjecttype.isAccessible()){
            strRecordId = ApexPages.currentPage().getParameters().get('id');
            isShowmore = false;
            string strShowMore = ApexPages.currentPage().getParameters().get('showMore');
            ID sID = strRecordId;
            lstFieldHistoryTemp = new List<Field_History__c>();
            lstFieldHistory = new List<Field_History__c>();
            if(strRecordId != null){
                if(strShowMore == 'true'){
                    isShowmore = true;
                    lstFieldHistoryTemp = [select id, Edit_Date__c, Record_Id__c, User__c,User__r.Name, Field_Event__c, New_Value__c, Old_Value__c, sObject_Name__c from Field_History__c where Record_Id__c =: sID order by Createddate LIMIT 10000];
                }else{
                    lstFieldHistoryTemp = [select id, Edit_Date__c, Record_Id__c, User__c,User__r.Name, Field_Event__c, New_Value__c, Old_Value__c, sObject_Name__c from Field_History__c where Record_Id__c =: sID order by Createddate LIMIT 20];
                }
                
                for(Field_History__c fh: lstFieldHistoryTemp){
                    Schema.DescribeFieldResult field = sObjecttype.fields.getMap().get(fh.Field_Event__c).getDescribe();
                    if(field.isAccessible()){
                        lstFieldHistory.add(fh);
                    }
                }
                
                String keyCode = strRecordId.subString(0,3);
                
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                for(Schema.SObjectType objectInstance : gd.values()){
                    if(objectInstance.getDescribe().getKeyPrefix() == keyCode){
                        strObjectName = objectInstance.getDescribe().getName();
                        strObjectName = strObjectName.replaceAll('__c','');
                        strObjectName = strObjectName.replaceAll('__','');
                    }
                }
                
            }
            if(lstFieldHistory.isEmpty()){
                isShowmore = true;
            }
       }
    }
    public pagereference showMoreHistoryRecord(){
        pagereference pr = new pagereference('/apex/' + strObjectName + 'History?showMore=true&id='+strRecordId);
        pr.setRedirect(true);
        return pr;
    }
}