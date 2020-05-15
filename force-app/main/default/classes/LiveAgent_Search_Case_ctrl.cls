public class LiveAgent_Search_Case_ctrl{
    
    public string strSearchCase {get; set;}
    public List<Case> lstCaseSearchResult {get; set;}
    public string searchCaseId {get; set;}
    string strNorthAmericaRecType;
    public String chatKeyId {get;set;}
    
    public String PersonEmail {get;set;}
    public String firstName {get;set;}
    public String lastname {get;set;}
    public String locationId {get;set;}
    public String strDepartment {get;set;}
    
    public LiveAgent_Search_Case_ctrl(){
        strSearchCase = '';
        lstCaseSearchResult = new List<Case>();
        strNorthAmericaRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SMSC North America').getRecordTypeId();
        
    }
    
    public void loadExistingCases(){
        system.debug('@@@@@@@@@@@@' +locationId);
        string strSOQL = 'SELECT id, (SELECT Id, caseNumber, Account.Name, createddate, Status, Subject, LocID__c, Latest_SMSC_Record_Type_2__c from Cases) from Contact where Email =: PersonEmail';
        if(locationId != null && locationId != ''){
            strSOQL += ' OR Account_LocID__c =: locationId';
        }
        List<Contact> contactList = database.query(strSOQL);
        
        lstCaseSearchResult = new List<Case>();
        for(Contact con: contactList){
            system.debug(con.id + '@@@@@@@@@@@@' + con.cases);
            lstCaseSearchResult.addAll(con.cases);
        }
        
    }
    
    public pagereference redirectToNewCase(){
        if(strSearchCase == ''){
            pagereference pr = new pagereference('/apex/new_smsc_page?ent=Case&nooverride=0&RecordType=' + strNorthAmericaRecType + '&chatKey=' + chatKeyId + '&retURL=/500/o');
            return pr;
        }else{
            //, Serial_Number__c
            if(strSearchCase.length() == 1){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'search term must be longer than one character:' + strSearchCase + '*.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            string strSearchCaseTemp = strSearchCase + '*';
            List<List<sObject>> searchList = [FIND :strSearchCaseTemp IN ALL FIELDS RETURNING Case(Id, caseNumber, Account.Name, createddate, Status, Subject, LocID__c, Latest_SMSC_Record_Type_2__c Where RecordType.Name ='SMSC North America' LIMIT 25)];
            lstCaseSearchResult = new List<Case>();       
            lstCaseSearchResult = searchList[0];
            
            
            strSearchCaseTemp = '%' + strSearchCase + '%';
            set<Id> sCaseCommentParentId = new set<Id>();
            List<AggregateResult> lstCaseComment = [SELECT Parentid prtId from casecomment where CommentBody like: strSearchCase group by parentid];
            if(!lstCaseComment.isEmpty()){
                for(AggregateResult agr: lstCaseComment){
                    sCaseCommentParentId.add(string.valueOf(agr.get('prtId')));
                }
                if(!sCaseCommentParentId.isEmpty()){
                    List<Case> lstCaseComemntSearch = [SELECT Id, caseNumber, Account.Name, createddate, Status, Subject, LocID__c, Latest_SMSC_Record_Type_2__c from Case where id in: sCaseCommentParentId];
                    lstCaseSearchResult.addall(lstCaseComemntSearch);
                }
            }
            system.debug('###########'+lstCaseSearchResult);
            return null;
        }
    }
    
    public pagereference redirectToCaseDetailPage(){
        
        Case objCase = new Case(id=searchCaseId);
        objCase.Live_Chat_Transcript_Chat_Key__c = chatKeyId;
            
        update objCase;
        
        pagereference pr = new pagereference('/'+searchCaseId);
        return pr;
    }
    
    public pagereference createNewCase(){
        pagereference pr = new pagereference('/apex/new_smsc_page?ent=Case&nooverride=0&RecordType=' + strNorthAmericaRecType + '&chatKey='+chatKeyId+'&retURL=/500/o');
        return pr;
            
    }
    public pagereference cloneCaseRecord(){
        List<Case> caseList = [select id, AccountId, ContactId, Origin, Subject, (select id, ContentType, Description, IsPartnerShared, IsPrivate, Name, OwnerId, ParentId from Attachments), (select id, CommentBody, ConnectionReceivedId, ConnectionSentId, IsPublished, ParentId from Casecomments) from Case where id =: searchCaseId];
        if(!caseList.isEmpty()){
            // Clone Existing Closed Case
            Case objCase = new Case();
            objCase.AccountId = caseList[0].AccountId;
            objCase.ContactId = caseList[0].ContactId;
            objCase.Origin = caseList[0].Origin;
            objCase.Subject = caseList[0].Subject;
            objCase.RecordtypeId = strNorthAmericaRecType;
            objCase.Live_Chat_Transcript_Chat_Key__c = chatKeyId;
            insert objCase;
            
            // Clone Case Comments of Existing Closed Case
            List<CaseComment> lstCaseCommentInsert = new List<CaseComment>();
            for(Casecomment ccm: caseList[0].Casecomments){
                Casecomment objCasecomment = ccm.clone();
                objCasecomment.ParentId = objCase.id;          
                lstCaseCommentInsert.add(objCasecomment);
            }
            if(!lstCaseCommentInsert.isEmpty()){
                insert lstCaseCommentInsert;
            }
            
            // Clone Attachemnts of Existing Closed Case
            Map<Id, Blob> mapAttachmentBody = new  Map<Id, Blob>();
            List<Attachment> lstAttachment = [select id, Body from Attachment where id in: caseList[0].Attachments];
            for(Attachment attch: lstAttachment){
                mapAttachmentBody.Put(attch.id, attch.body);
            }
            
            List<Attachment> lstAttachmentInsert = new List<Attachment>();
            for(Attachment attch: caseList[0].Attachments){
                Attachment objAttachment = attch.clone();
                objAttachment.ParentId = objCase.id;
                objAttachment.Body = mapAttachmentBody.get(attch.id);      
                lstAttachmentInsert.add(objAttachment);
            }
            if(!lstAttachmentInsert.isEmpty()){
                insert lstAttachmentInsert;
            }
            
            pagereference pr = new pagereference('/'+objCase.id);
            return pr;
        }
        return null;
    }
}