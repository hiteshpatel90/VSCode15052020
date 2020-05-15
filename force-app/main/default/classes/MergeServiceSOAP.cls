global class MergeServiceSOAP{
    

    //Contact Merge logic
    webservice static MergeResponse ContactMerge(MergeInput MergeIDs) {
 
        MergeResponse  response = new MergeResponse();
        set<string> vctmids = new set<string>();
        set<id> vctmcntctids = new set<id>();        
        List<SObject> updatechilds = new List<SObject>();
        for(string vctmloop : MergeIDs.VictimPartyIDs){
            vctmids.add(vctmloop);
        }
        id svrcntctid = [select id from Contact where Contact_Party_ID__c = :MergeIDs.SurvivorPartyID].id;
        id svrAccountId = [select Accountid from Contact where Contact_Party_ID__c = :MergeIDs.SurvivorPartyID].Accountid;
        list<Contact> vctmcntctid = [select id
                                     ,(select whatId from Tasks)
                                     ,(select whatId from Events)
                                     ,(select ContactId from cases)
                                     ,(select ParentId from Attachments)
                                     ,(select Bill_To_Contact__c from Invoice_History__r)
                                     ,(select Contact__c from Leads__r)
                                     ,(select Contact__c from Campaign_History__r)                                    
                                     from Contact where Contact_Party_ID__c in :vctmids];
        //,(select ContactId from Opportunities)
        //,(select Zuora__Account__c from R00N40000001kyLcEAI__r)
        //,(select Party_ID__c from PaymentProfiles__r)
        //,(select AccountId from Orders)
        //,(select Fulfill_To_Account_Id__c from Invoice_Line_Item_History__r)
        //,(select Bill_To_Account__c from Payment_History__r)
        
        for(Contact vctmcntctidlp: vctmcntctid ){
            vctmcntctids.add(vctmcntctidlp.id);
        }
        
        try{
            list<Account_Relationship__c> delAccRelationShipRec = [select Contact_To__c from Account_Relationship__c 
                                                         where Contact_To__c in :vctmcntctids and Parent_Account__c =: svrAccountId];
            if(!delAccRelationShipRec.isEmpty()){
                delete delAccRelationShipRec;
            }
            
            list<Account_Relationship__c> cntctrellst = [select Contact_To__c from Account_Relationship__c 
                                                         where Contact_To__c in :vctmcntctids];
            for(Account_Relationship__c cntctrellstlp : cntctrellst ){
                cntctrellstlp.Contact_To__c = svrcntctid;
                updatechilds.add(cntctrellstlp);
            }
        }catch(exception e){
            // No action required as this error is no records for this relations 
        } 
        //
        for(Contact vctmcntctloop : vctmcntctid){
            //Reparenting  Tasks
            try{
                list<Task>  tasklst = new list<Task>(vctmcntctloop.Tasks);
                for(Task tasklstlp :  tasklst){
                    tasklstlp.whatId = svrcntctid;
                    updatechilds.add(tasklstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Events
            try{
                list<Event> Eventlst = new list<Event>(vctmcntctloop.Events);
                for(Event Eventlstlp :  Eventlst){
                    Eventlstlp.whatId = svrcntctid;
                    updatechilds.add(Eventlstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  case
            try{
                list<case> caselst = new list<case>(vctmcntctloop.cases);
                for(case caselstlp :  caselst){
                    caselstlp.AccountId = svrcntctid;
                    updatechilds.add(caselstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Attachments
            try{
                list<Attachment> Attachmentlst = new list<Attachment>(vctmcntctloop.Attachments);
                for(Attachment Attachmentlstlp :  Attachmentlst){
                    Attachmentlstlp.ParentId = svrcntctid;
                    updatechilds.add(Attachmentlstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Invoice_History__c
            try{
                list<Invoice_History__c> Invoicehistorylst = new list<Invoice_History__c>(vctmcntctloop.Invoice_History__r);
                for(Invoice_History__c Invoicehistorylstlp :  Invoicehistorylst){
                    Invoicehistorylstlp.Bill_To_Account__c = svrcntctid;
                    updatechilds.add(Invoicehistorylstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Lead
            try{
                list<Lead> Leadslst = new list<Lead>(vctmcntctloop.Leads__r);
                for(Lead Leadslstlp :  Leadslst){
                    Leadslstlp.Account__c = svrcntctid;
                    updatechilds.add(Leadslstlp);
                }            
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Campaign_History__c
            try{
                list<Campaign_History__c> Campaignhistorylst = new list<Campaign_History__c>(vctmcntctloop.Campaign_History__r);
                for(Campaign_History__c Campaignhistorylstlp :  Campaignhistorylst){
                    Campaignhistorylstlp.Account__c = svrcntctid;
                    updatechilds.add(Campaignhistorylstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
        }
        try{
            update updatechilds;
            delete vctmcntctid;
            response.Status = 'Success';
            response.ErrorMessage = null;
            response.SurvivorSFDCID = svrcntctid;
            response.SurvivorPartyID = MergeIDs.SurvivorPartyID;
            return response;
        }catch(exception e){
            response.Status = 'Error';
            response.ErrorMessage = e.getMessage();
            response.SurvivorSFDCID = svrcntctid;
            response.SurvivorPartyID = MergeIDs.SurvivorPartyID;                
            return response;
        }
        return response;
    }
    
    //Input from CDH via SOA
    global class MergeInput {
        webservice String SurvivorPartyID;
        webservice list<string> VictimPartyIDs;
        webservice string EntityName;
    }
    
    //Response to CDH via SOA
    global class MergeResponse {
        webservice String Status;
        webservice String ErrorMessage;
        webservice String SurvivorSFDCID;
        webservice String SurvivorPartyID;
    }
}