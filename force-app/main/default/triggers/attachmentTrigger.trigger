trigger attachmentTrigger on Attachment (after insert) {
    List<Opportunity> lstOppUpdate = new List<Opportunity>();
    for(Attachment atch: trigger.new){
        //Check if added attachment is related to Opportunity or not
        if(atch.ParentId.getSobjectType() == Opportunity.SobjectType){
            Opportunity objOpp = new Opportunity(id=atch.ParentId);
            objOpp.Latest_Attachment_File_Name__c = atch.Name;
            
            objOpp.Lates_Attachment_Content_Type__c = atch.contentType;
            if(atch.contentType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'){
                objOpp.Lates_Attachment_Content_Type__c = 'application/vnd.ms-excel';
            }
            lstOppUpdate.add(objOpp);
        }
    }
    if(!lstOppUpdate.isEmpty()){
        update lstOppUpdate;
    }
}