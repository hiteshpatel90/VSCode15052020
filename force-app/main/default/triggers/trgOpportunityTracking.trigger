trigger trgOpportunityTracking on Opportunity (after update) { 
Field_History_Tracking_Admin_Setting__c ObjRecord = Field_History_Tracking_Admin_Setting__c.getInstance('Opportunity');
if(ObjRecord != null && ObjRecord.Enable_for_Field_Tracking__c == true){
if(helperOpportunityTracking.isFieldTrackingTriggerExecuted == false){
    helperOpportunityTracking.isFieldTrackingTriggerExecuted = true;
    List<Field_History__c> FieldHistoryUpdate = new List<Field_History__c>();
    List<Field_History_Tracking_Admin__c> FHTList = [select id, Fields_For_Tracking__c, sObject_Name__c from Field_History_Tracking_Admin__c where Enable_for_Field_Tracking__c = true and sObject_Name__c = 'Opportunity'];
    if(!FHTList.isEmpty()){
        string strFieldTracking = FHTList[0].Fields_For_Tracking__c;
        if(strFieldTracking != null){
            Boolean blnNeedToaddTrack = false;
            string[] arrFieldTracking = strFieldTracking.split(';');
            for(Opportunity ab: trigger.new){
                for(String strField: arrFieldTracking){
                strField = strField.tolowercase();
                    if(Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().keySet().contains(strField)){
                        if(ab.get(strField) != trigger.oldmap.get(ab.id).get(strField)){
                            Field_History__c objFieldHistory = new Field_History__c();
                            objFieldHistory.Edit_Date__c = system.now();
                            objFieldHistory.sObject_Name__c = FHTList[0].sObject_Name__c;
                            if(string.valueOf(ab.get(strField))  != null){
                                objFieldHistory.New_Value__c = string.valueOf(ab.get(strField)).abbreviate(255);
                            }
                            if(string.valueOf(trigger.oldmap.get(ab.id).get(strField)) != null){
                                objFieldHistory.Old_Value__c = string.valueOf(trigger.oldmap.get(ab.id).get(strField)).abbreviate(255);
                            }
                            objFieldHistory.Field_Event__c = strField;
                            objFieldHistory.User__c = system.userinfo.getuserid();
                            objFieldHistory.Record_Id__c = ab.id;
                            objFieldHistory.Opportunity__c = ab.id;
                            FieldHistoryUpdate.add(objFieldHistory);
                        }
                    }
                }
            }
            if(!FieldHistoryUpdate.isEmpty()){
                insert FieldHistoryUpdate;
            }
        }
    }
    }
    }
}