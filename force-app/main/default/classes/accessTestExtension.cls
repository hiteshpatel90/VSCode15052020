public class accessTestExtension {
    public string strLeadAccess {get; set;}
    public accessTestExtension(ApexPages.StandardController controller) {
        strLeadAccess = 'PPP';
        //strLeadAccess = Schema.DescribeSObjectResultisAccessible();
        strLeadAccess = string.valueOf(Schema.sObjectType.Lead.isAccessible());
        User u = new User();
        system.runAs(u){
        
        }
        
        set<Id> sAgreementRecId = new set<Id>();
        List<Agreement__c> lstAgreement = [SELECT id, (SELECT id FROM Attachments ORDER BY createddate DESC LIMIT 1) FROM Agreement__c WHERE Id IN: sAgreementRecId];
        Map<Id, Id> mapAgreementWithAttachment = new Map<Id, Id>();
        for(Agreement__c ag: lstAgreement){
            if(!ag.Attachments.isEmpty()){
                mapAgreementWithAttachment.Put(ag.id, ag.Attachments[0].id);
            }
        }
    }

}