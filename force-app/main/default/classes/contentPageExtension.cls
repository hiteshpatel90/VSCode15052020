public class contentPageExtension{
    public ContentVersion objCV {get; set;}
    string strCVId;
    List<RecentlyViewed> lstRecentlyViewed {get; set;}
    public List<wrapperRecentlyViewd> lstwrapperRecentlyViewd {get; set;}
    public Map<Id, Id> mapContentVersionId {get; set;}
    public List<string> lstTags {get; set;}
    public Map<Id, string> mapLibraries {get; set;}
    public string strSelLibrary {get; set;}
    public string strSearchLibrary {get; set;}
    public contentPageExtension(apexpages.standardController stdCon){
        strCVId = apexpages.currentpage().getParameters().get('id');
        if(strCVId != null && strCVId != ''){
            objCV = [select id, TagCSV, ContentSize from ContentVersion where id =: strCVId];
            if(objCV.TagCSV != null){
                lstTags = objCV.TagCSV.split(',');
            }
        }
        mapLibraries = new Map<Id, string>();
        List<ContentWorkspace> lstContentWorkspace = [select id, name from ContentWorkspace];
        for(ContentWorkspace cwd: lstContentWorkspace){
            mapLibraries.Put(cwd.id,cwd.Name);
        }
        
        lstwrapperRecentlyViewd = new List<wrapperRecentlyViewd>();
        List<RecentlyViewed> lstRecentlyViewedAll = [Select id, Type, Title, Name from RecentlyViewed where Type = 'ContentDocument' or Type = 'Case' or type = 'KnowledgeArticle' LIMIT 10];
        
        // Case Filter
        set<Id> sCaseId = new set<Id>();
        for(RecentlyViewed rec: lstRecentlyViewedAll){
            if(rec.Type == 'Case'){
                sCaseId.add(rec.id);
            }
        }
        List<Case> lstCase = [select id from case where id in: sCaseId and IsVisibleInSelfService__c =: true];
        sCaseId = new set<Id>();
        for(case cs: lstCase){
            sCaseId.add(cs.id);
        }
        
        // Work Order Filter
        set<Id> sWorkOrderId = new set<Id>();
        for(RecentlyViewed rec: lstRecentlyViewedAll){
            if(rec.Type == 'Work_Order__c'){
                sCaseId.add(rec.id);
            }
        }
        List<Work_Order__c> lstWorkOrder = [select id from Work_Order__c where id in: sWorkOrderId and Sales_Type__c != 'Internal'];
        sWorkOrderId = new set<Id>();
        for(Work_Order__c cs: lstWorkOrder){
            sWorkOrderId.add(cs.id);
        }
        
        lstRecentlyViewed = [Select id, Type, Title, Name from RecentlyViewed where (Type = 'ContentDocument') or (Type = 'Case' and ID IN: sCaseId) or (Type = 'Work_Order__c' and ID IN: sWorkOrderId) LIMIT 10];
        
        set<Id> sContentDocId = new set<Id>();
        for(RecentlyViewed rec: lstRecentlyViewed){
            if(rec.Type == 'ContentDocument'){
                sContentDocId.add(rec.id);
            }
        }
        
        mapContentVersionId = new Map<Id, Id>();
        List<ContentDocument> lstContentDocument = [select id, LatestPublishedVersionId from ContentDocument where id in: sContentDocId];
        for(ContentDocument cd: lstContentDocument){
            mapContentVersionId.Put(cd.id, cd.LatestPublishedVersionId);
        } 
        wrapperRecentlyViewd objwrapperRecentlyViewd;
        for(RecentlyViewed rw: lstRecentlyViewed){
            objwrapperRecentlyViewd = new wrapperRecentlyViewd();
            objwrapperRecentlyViewd.recordId = rw.id;
            objwrapperRecentlyViewd.strRecordType = rw.Type;
            if(rw.Type == 'ContentDocument'){
                system.debug('@@@@@@@'+rw.id);
                system.debug('@@@@@@@'+mapContentVersionId.get(rw.id));
                system.debug('@@@@@@@'+mapContentVersionId);
                objwrapperRecentlyViewd.recordId = mapContentVersionId.get(rw.id);
            }            
            objwrapperRecentlyViewd.strRecordName = rw.Name;
            
            lstwrapperRecentlyViewd.add(objwrapperRecentlyViewd);
        }  
    }
    
    public pagereference downloadPDFfile(){
        pagereference pr = new pagereference('/sfc/servlet.shepherd/version/download/' + strCVId + '?asPdf=false&operationContext=CHATTER');
        return pr;
    }
    
    public pagereference searchContentRecords(){
        //if(strSelLibrary == 'ALL_WORKSPACES'){
        //    strSelLibrary = '';
        //}
        pagereference pr = new pagereference('/apex/displayContent?selectedWorkspaceId=' + strSelLibrary + '&searchStr=' + strSearchLibrary);
        return pr;
    }
    public List<SelectOption> getLibraries() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('ALL_WORKSPACES','All Libraries'));
        List<ContentWorkspace> lstContentWorkspace = [select id, name from ContentWorkspace];
        for(ContentWorkspace cwd: lstContentWorkspace){
            options.add(new SelectOption(cwd.id,cwd.Name));
        }
        
        return options;
    }
    
    public class wrapperRecentlyViewd{
        public id recordId {get; set;}
        public string strRecordType {get; set;}
        public string strRecordName {get; set;}
    }
}