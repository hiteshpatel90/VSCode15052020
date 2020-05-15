public class triggerBody{
     public static String getTriggerBody(String objectName,String strSelectedObjectAPIName){
        String varName = objectName.replaceAll('','');
        varName = varName.replaceAll('_','');
        varName = varName.replaceAll('-','');
        string strTriggercode = '';         
        strTriggercode += 'trigger trg' + varName + 'Tracking on '+strSelectedObjectAPIName+' (after update) { \\n';
        strTriggercode += 'Field_History_Tracking_Admin_Setting__c ObjRecord = Field_History_Tracking_Admin_Setting__c.getInstance(\'' + strSelectedObjectAPIName + '\');\\n';
        strTriggercode += 'if(ObjRecord != null && ObjRecord.Enable_for_Field_Tracking__c == true){\\n';
        strTriggercode += 'if(helper' + varName + 'Tracking.isFieldTrackingTriggerExecuted == false){\\n';
        strTriggercode += '    helper' + varName + 'Tracking.isFieldTrackingTriggerExecuted = true;\\n';
        strTriggercode += '    List<Field_History__c> FieldHistoryUpdate = new List<Field_History__c>();\\n';
        strTriggercode += '    List<Field_History_Tracking_Admin__c> FHTList = [select id, Fields_For_Tracking__c, sObject_Name__c from Field_History_Tracking_Admin__c where Enable_for_Field_Tracking__c = true and sObject_Name__c = \'' + strSelectedObjectAPIName + '\'];\\n';
        strTriggercode += '    if(!FHTList.isEmpty()){\\n';
        strTriggercode += '        string strFieldTracking = FHTList[0].Fields_For_Tracking__c;\\n';
        strTriggercode += '        if(strFieldTracking != null){\\n';
        strTriggercode += '            Boolean blnNeedToaddTrack = false;\\n';
        strTriggercode += '            string[] arrFieldTracking = strFieldTracking.split(\';\');\\n';
        strTriggercode += '            for(' + strSelectedObjectAPIName + ' ab: trigger.new){\\n';       
        strTriggercode += '                for(String strField: arrFieldTracking){\\n';
        strTriggercode += '                    if(ab.get(strField) != trigger.oldmap.get(ab.id).get(strField)){\\n';
        strTriggercode += '                        Field_History__c objFieldHistory = new Field_History__c();\\n';
        strTriggercode += '                        objFieldHistory.Edit_Date__c = system.now();\\n';
        strTriggercode += '                        objFieldHistory.sObject_Name__c = FHTList[0].sObject_Name__c;\\n';
        strTriggercode += '                        objFieldHistory.New_Value__c = string.valueOf(ab.get(strField));\\n';
        strTriggercode += '                        objFieldHistory.Old_Value__c = string.valueOf(trigger.oldmap.get(ab.id).get(strField));\\n';
        strTriggercode += '                        objFieldHistory.Field_Event__c = strField;\\n';
        strTriggercode += '                        objFieldHistory.User__c = system.userinfo.getuserid();\\n';
        strTriggercode += '                        objFieldHistory.Record_Id__c = ab.id;\\n';
        strTriggercode += '                        FieldHistoryUpdate.add(objFieldHistory);\\n';
        strTriggercode += '                    }\\n';
        strTriggercode += '                }\\n';
        strTriggercode += '            }\\n';    
        strTriggercode += '            if(!FieldHistoryUpdate.isEmpty()){\\n';
        strTriggercode += '                insert FieldHistoryUpdate;\\n';
        strTriggercode += '            }\\n';        
        strTriggercode += '        }\\n';
        strTriggercode += '    }\\n';
        strTriggercode += '    }\\n';
        strTriggercode += '    }\\n';
        strTriggercode += '}\\n';      
               
        System.debug('************************* Trigger Body : ' + strTriggercode + '******************');
        return strTriggercode ;
    }
    
     public static String getStaticClassBody(String objectName,String strSelectedObjectAPIName){
    
        String varName = objectName.replaceAll('','');
        varName = varName.replaceAll('_','');
        varName = varName.replaceAll('-','');
        
        String strClassBody = 'public class helper' + varName + 'Tracking{\\n';
        strClassBody += 'public Static boolean isFieldTrackingTriggerExecuted = false;\\n';
        strClassBody += '}\\n';
        return strClassBody;
    }
    @Future(callout=true)
    public static void executeFromAnonymousBlock(string strSessionId){
        
        string staticClassBody = triggerBody.getStaticClassBody('Account','Account');
        string strUrl = URL.getSalesforceBaseUrl().toExternalForm();
        string objectName = 'Account';
        String jsonStaticClass = '{ "Name" : "helper' + objectName + '", "Body" : "' + staticClassBody + '" }';
        Httprequest reqClass = new HttpRequest();
        reqClass.setEndpoint(strUrl + '/services/data/v36.0/sobjects/ApexClass');
        reqClass.setMethod('POST');
        reqClass.setHeader('Content-Type', 'application/json');
        //req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        reqClass.setHeader('Authorization', 'Bearer ' + strSessionId);
        reqClass.setBody(jsonStaticClass);
        
        Http httpReqClass = new Http();
        HttpResponse resClass = httpReqClass.send(reqClass);
        System.debug('@@@@@@@@@@@@@@'+resClass.getBody());
        
        
        String strSelectedObjectAPIName = 'Account';
        String striggerBody = triggerBody.getTriggerBody('Account','Account');
        system.debug('@@@'+striggerBody);
        String json = '{ "Name" : "Toolingtr", \"TableEnumOrId" : "' + strSelectedObjectAPIName + '","Body" : "' + striggerBody + '" }'; // JSON format to create trigger
        Httprequest req = new HttpRequest();
        //string strUrl = URL.getSalesforceBaseUrl().toExternalForm();
        req.setEndpoint(strUrl + '/services/data/v27.0/sobjects/ApexTrigger');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization', 'OAuth ' +strSessionId);
        req.setBody(json);
        
        Http httpReq = new Http();
        
        HttpResponse res = httpReq.send(req); 
        System.debug('#########'+res.getBody());
        
    }
}