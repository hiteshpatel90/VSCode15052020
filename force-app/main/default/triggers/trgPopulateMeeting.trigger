////////////////////////////////////////////////////////////////////
//Type                    :  Apex Trigger
//Name                    :  trgPopulateMeeting 
//Company                 :  Enterprise Technology Innovation
//Created By              :  Serge Kandukuri
//Created Date            :  10/05/2013
//Last Modified By        :  Serge Kandukuri
//Last Modified Date      :  10/16/2015
//Purpose                 :  This trigger is used to populate meeting value on docusign status record creation
/////////////////////////////////////////////////////////////////////
trigger trgPopulateMeeting on dsfs__DocuSign_Status__c (after insert) {
    string strCurrentUserProfileId = [select id, Profileid from user where id =: userinfo.getuserid()].Profileid;
    AZ_Docusign_Contract_Setting__c dsConSetting = AZ_Docusign_Contract_Setting__c.getInstance(strCurrentUserProfileId);
    if(dsConSetting.Enable_Docusign_Trigger__c == true){
        // initialize list of docusign status for update
        List<dsfs__DocuSign_Status__c> lstDocuSignStatusUpdate = new List<dsfs__DocuSign_Status__c>();
        // get newly created docusign status records
        List<dsfs__DocuSign_Status__c> lstDocuSign = [select id, Meeting_Speaker__r.Medical_Event_AZ__c from dsfs__DocuSign_Status__c where id in: trigger.newmap.keyset()];
        for(dsfs__DocuSign_Status__c ds: lstDocuSign){
            // set meeting field
            ds.Meeting__c = ds.Meeting_Speaker__r.Medical_Event_AZ__c;
            lstDocuSignStatusUpdate.add(ds);
        }
        // condition to check docusign list is not empty
        if(!lstDocuSignStatusUpdate.isEmpty()){
            // update docusign record list       
            update lstDocuSignStatusUpdate;
        }
    }
}