public class displayContentExtension{
    public List<ContentDocument> lstContentDocument;
    public List<wrapperContentDocument> lstwrapperContentDocument {get; set;}
    public List<wrapperFilterOptions> lstwrapperFilterOptions {get; set;}
    public boolean blnSelAllContentDocument {get; set;}
    public boolean displayFeaturedContent {get; set;}
    public boolean displayTagsContent {get; set;}
    public string strSelLibrary {get; set;}
    public string strSearchLibrary {get; set;}
    public integer intFilterHideSize {get; set;}
    public integer intFilterSize {get; set;}
    Map<Id, Integer> mapTotalDownload;
    
    //Pagination variables
    Public Integer intPageSize{get;set;}
    Public Integer intFirstRecord{get;set;}
    Public Integer intLastRecord{get;set;}
    Public Integer intTotalRecords{get;set;}
    Public Integer intCurrentPage{get;set;}
    Public Integer intTotalPages{get;set;}
    Public String strNoResultVisibility{get;set;}
    Public String strFooterVisibility{get;set;}
    Public Boolean blnHasPrevious{get;set;}
    Public Boolean blnHasNext{get;set;}
    Public Boolean blnSelAll{get;set;}
    Public Integer intTotalSelCL{get;set;}
    Public Boolean blnGoNext{get;set;}
    Public String strSelectedIds {get;set;}
    Public Map<Id, boolean> mapSubscribedContent {get;set;}
    string strSearchTags;
    public displayContentExtension(Apexpages.standardcontroller stdCon){
        displayFeaturedContent = false;
        strSearchLibrary = '';
        intFilterSize = 100; // Put 30
        intFilterHideSize = 4; // Put  4
        intPageSize = 20; // Put 20
        Reset();
        strSearchTags = apexpages.currentpage().getParameters().get('searchTags');
        strSelLibrary = apexpages.currentpage().getParameters().get('selectedWorkspaceId');
        strSearchLibrary = apexpages.currentpage().getParameters().get('searchStr');
        mapSubscribedContent = new Map<Id, boolean>();
        List<aggregateresult> agrSubscribedContent = [select ContentDocumentId, Field from ContentDocumentHistory group by ContentDocumentId, field];
        for(aggregateresult agr: agrSubscribedContent){
            if(agr.get('Field') == 'contentDocSubscribed'){
                //mapSubscribedContent.Put((ID)agr.get('ContentDocumentId'), true);
            }else if(mapSubscribedContent.containskey((ID)agr.get('ContentDocumentId')) == false){
               // mapSubscribedContent.Put((ID)agr.get('ContentDocumentId'), false);
            }
        }
        
        string strSOQL = 'select id, title, ParentId , ContentSize, FileExtension, LastModifieddate, ownerid, owner.name from ContentDocument LIMIT 50000';
        
        lstContentDocument = database.query(strSOQL);
        
        //pagination
        intTotalRecords = lstContentDocument.size();
        intTotalPages=integer.valueOf(Math.ceil(double.valueOf(intTotalRecords)/double.valueOf(intPageSize)));        
        intFirstRecord=1;
        if(intTotalRecords>intPageSize){
            intLastRecord=intPageSize;
        }else{
            intLastRecord=intTotalRecords;
        }
        intCurrentPage=1;
         
        mapTotalDownload = new Map<Id, Integer>();
        List<AggregateResult> lstAgr = [select count(id) total, ContentVersion.ContentDocumentId cvid from ContentVersionHistory where Field = 'contentVersionDownloaded' group by ContentVersion.ContentDocumentId];
        for(AggregateResult ar: lstAgr){
            mapTotalDownload.put((id)ar.get('cvid'), integer.valueof(ar.get('total')));
        }
        LoadContentDocument();      
       
        
        // Category
        String strSOQLCV = '';
        strSOQLCV = 'select ContentDocumentId, TagCsv, FileExtension, Category__c from ContentVersion ';
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        
        
        lstContentVersion = database.query(strSOQLCV);
        lstwrapperFilterOptions = new List<wrapperFilterOptions>();
        wrapperFilterOptions objwrapperFilterOptions = new wrapperFilterOptions();        
        objwrapperFilterOptions.strFilterLabel = 'Category';
        
        List<wrapperInnerFilterOptions> lstwrapperInnerFilterOptions = new List<wrapperInnerFilterOptions>();
        wrapperInnerFilterOptions objwrapperInnerFilterOptions;
        Map<string, wrapperInnerFilterOptions> mapWrapperInnerCategory = new Map<string, wrapperInnerFilterOptions>();
        Integer intTotalCategoryRec = 0;
        for(ContentVersion cv: lstContentVersion){
            if(cv.Category__c != null){                        
                if(mapWrapperInnerCategory.containskey(cv.Category__c) == false){
                    objwrapperInnerFilterOptions = new wrapperInnerFilterOptions();
                    objwrapperInnerFilterOptions.sContentDocId = new set<Id>();
                    objwrapperInnerFilterOptions.strFilterValue = cv.Category__c.toUpperCase();
                    objwrapperInnerFilterOptions.intFilterCount = intTotalCategoryRec + 1;
                    objwrapperInnerFilterOptions.blnFilterSelected = false;                        
                    objwrapperInnerFilterOptions.sContentDocId.add(cv.ContentDocumentId);
                    lstwrapperInnerFilterOptions.add(objwrapperInnerFilterOptions);  
                    mapWrapperInnerCategory.Put(cv.Category__c, objwrapperInnerFilterOptions);                      
                }else{
                    mapWrapperInnerCategory.get(cv.Category__c).intFilterCount += 1;
                    mapWrapperInnerCategory.get(cv.Category__c).sContentDocId.add(cv.ContentDocumentId);
                }   
            }
        }        
        objwrapperFilterOptions.lstInnerFilter = new List<wrapperInnerFilterOptions>();
        objwrapperFilterOptions.lstInnerFilter = lstwrapperInnerFilterOptions;
        lstwrapperFilterOptions.add(objwrapperFilterOptions);
        
        // Featured Content
        /*objwrapperFilterOptions = new wrapperFilterOptions();        
        objwrapperFilterOptions.strFilterLabel = 'Featured Content';
        
        lstwrapperInnerFilterOptions = new List<wrapperInnerFilterOptions>();
        objwrapperInnerFilterOptions = new wrapperInnerFilterOptions();
        objwrapperInnerFilterOptions.strFilterValue = 'Featured';
        LIST<AggregateResult> lstAgrFeature = [select count(id) totalFeature, ContentDocumentId cntId from ContentVersion where FeaturedContentBoost = 1 group by ContentDocumentId];
        objwrapperInnerFilterOptions.intFilterCount = lstAgrFeature.size();
        objwrapperInnerFilterOptions.sContentDocId = new set<Id>();
        for(AggregateResult ar: lstAgrFeature){
            objwrapperInnerFilterOptions.sContentDocId.add((id)ar.get('cntId'));
        }
        objwrapperInnerFilterOptions.blnFilterSelected = false;
        lstwrapperInnerFilterOptions.add(objwrapperInnerFilterOptions);
        objwrapperFilterOptions.lstInnerFilter = new List<wrapperInnerFilterOptions>();
        objwrapperFilterOptions.lstInnerFilter = lstwrapperInnerFilterOptions;
        lstwrapperFilterOptions.add(objwrapperFilterOptions);*/
        
        // Tags
        objwrapperFilterOptions = new wrapperFilterOptions();
        objwrapperFilterOptions.strFilterLabel = 'Tags';
        lstwrapperInnerFilterOptions = new List<wrapperInnerFilterOptions>();
        objwrapperFilterOptions.lstInnerFilter = new List<wrapperInnerFilterOptions>();
        objwrapperInnerFilterOptions = new wrapperInnerFilterOptions();
        map<String, set<Id>> mapTagCsv = new map<String, set<Id>>();
        Integer intTotalCsvRec = 0;
        objwrapperInnerFilterOptions.sContentDocId = new set<Id>();
        Map<string, wrapperInnerFilterOptions> mapWrapperInnderFO = new Map<string, wrapperInnerFilterOptions>();
        for(ContentVersion cv: lstContentVersion){            
            if(cv.TagCsv != null){
                string[] arrTagCsv = cv.TagCsv.split(',');
                set<Id> sContentDocId = new set<Id>();
                sContentDocId.add(cv.ContentDocumentId);
                for(string tg: arrTagCsv){
                    
                    if(!mapTagCsv.containskey(tg.trim())){
                        mapTagCsv.put(tg.trim(), sContentDocId);
                    }else{
                        mapTagCsv.get(tg.trim()).addall(sContentDocId );
                    }
                }
            }
        }
        system.debug('@@@@@@@mapTagCsv'+mapTagCsv);
        for(string tg: mapTagCsv.keyset()){
            if(mapWrapperInnderFO.size() > intFilterSize){
                break;
            }
            objwrapperInnerFilterOptions = new wrapperInnerFilterOptions();
            objwrapperInnerFilterOptions.sContentDocId = new set<Id>();
            objwrapperInnerFilterOptions.strFilterValue = tg.toUpperCase();
            objwrapperInnerFilterOptions.intFilterCount = mapTagCsv.get(tg).size();
            objwrapperInnerFilterOptions.blnFilterSelected = false; 
            if(tg == strSearchTags){
                objwrapperInnerFilterOptions.blnFilterSelected = true;
            }                       
            objwrapperInnerFilterOptions.sContentDocId.addall(mapTagCsv.get(tg));
            lstwrapperInnerFilterOptions.add(objwrapperInnerFilterOptions);  
            mapWrapperInnderFO.Put(tg, objwrapperInnerFilterOptions);        
        }
        
        //objwrapperFilterOptions.lstInnerFilter = new List<wrapperInnerFilterOptions>();
        objwrapperFilterOptions.lstInnerFilter = lstwrapperInnerFilterOptions;
        lstwrapperFilterOptions.add(objwrapperFilterOptions);
        
        // File Formats        
        objwrapperFilterOptions = new wrapperFilterOptions();        
        objwrapperFilterOptions.strFilterLabel = 'File Formats';
        objwrapperFilterOptions.lstInnerFilter = new List<wrapperInnerFilterOptions>();
        lstwrapperInnerFilterOptions = new List<wrapperInnerFilterOptions>();
        List<aggregateresult> agrFileFormat = [select count(id) total, FileExtension fileExt from ContentDocument group by FileExtension LIMIT 50000];
         
        set<String> setFileExtension = new set<String>();
        Map<string, wrapperInnerFilterOptions> mapFileExtension = new Map<string, wrapperInnerFilterOptions>();
        for(aggregateresult agrCvfe: agrFileFormat){
            string strFileType = '';
            if((string)agrCvfe.get('fileExt') == 'txt'){
                strFileType = 'Plain Text';                
            }else if((string)agrCvfe.get('fileExt') == 'pdf'){
                strFileType = 'Adobe PDF';                
            }else if((string)agrCvfe.get('fileExt') == 'docx' || (string)agrCvfe.get('fileExt') == 'doc'){
                strFileType = 'Word';                 
            }else if((string)agrCvfe.get('fileExt') == 'xlsm' || (string)agrCvfe.get('fileExt') == 'xlsx' || (string)agrCvfe.get('fileExt') == 'xls'){
                strFileType = 'Excel';                 
            }else if((string)agrCvfe.get('fileExt') == 'pptx'){
                strFileType = 'Power Point';                
            }else if((string)agrCvfe.get('fileExt') == 'mp4'){
                strFileType = 'mp';                
            }
            if(mapFileExtension.containskey(strFileType) == false){
                if(mapFileExtension.size() > intFilterSize){
                    break;
                }
                objwrapperInnerFilterOptions = new wrapperInnerFilterOptions();
                objwrapperInnerFilterOptions.sContentDocId = new set<Id>();
                
                objwrapperInnerFilterOptions.strFilterValue = strFileType.toUpperCase();
                objwrapperInnerFilterOptions.strFileExtension = (string)agrCvfe.get('fileExt');                
                objwrapperInnerFilterOptions.intFilterCount = (integer)agrCvfe.get('total');                    
                objwrapperInnerFilterOptions.blnFilterSelected = false;
                lstwrapperInnerFilterOptions.add(objwrapperInnerFilterOptions);
                mapFileExtension.Put(strFileType, objwrapperInnerFilterOptions);
            }else{
                mapFileExtension.get(strFileType).intFilterCount += 1;
                //mapFileExtension.get(strFileType).sContentDocId.add(cv.ContentDocumentId);
            }
        }
        
        objwrapperFilterOptions.lstInnerFilter = lstwrapperInnerFilterOptions;
        lstwrapperFilterOptions.add(objwrapperFilterOptions);
        
        // Authors    
        objwrapperFilterOptions = new wrapperFilterOptions();        
        objwrapperFilterOptions.strFilterLabel = 'Authors';
        objwrapperFilterOptions.lstInnerFilter = new List<wrapperInnerFilterOptions>();
        lstwrapperInnerFilterOptions = new List<wrapperInnerFilterOptions>();
        
        List<aggregateresult> agrContentDocument = [select count(id) total, ownerid owid, owner.Name owname from ContentDocument group by ownerid, owner.Name LIMIT 50000];
        set<Id> sUserId = new set<Id>();
        for(aggregateresult agrcd: agrContentDocument){
            if(sUserId.size() > intFilterSize){
                break;
            }
            objwrapperInnerFilterOptions = new wrapperInnerFilterOptions();
            objwrapperInnerFilterOptions.sContentDocId = new set<Id>();
            if(!sUserId.contains((id)agrcd.get('owid'))){
                sUserId.add((id)agrcd.get('owid'));
                objwrapperInnerFilterOptions.strFilterValue = string.valueof(agrcd.get('owname')).toUpperCase();
                objwrapperInnerFilterOptions.strAuthoerId = (string)agrcd.get('owid');
                //objwrapperInnerFilterOptions.sContentDocId.add((id)agrcd.get('id'));
                objwrapperInnerFilterOptions.blnFilterSelected = false;
                objwrapperInnerFilterOptions.intFilterCount = (integer)agrcd.get('total');
                lstwrapperInnerFilterOptions.add(objwrapperInnerFilterOptions);
            }
        }
        objwrapperFilterOptions.lstInnerFilter = lstwrapperInnerFilterOptions;
        lstwrapperFilterOptions.add(objwrapperFilterOptions);
                
        // My Libraries      
        objwrapperFilterOptions = new wrapperFilterOptions();        
        objwrapperFilterOptions.strFilterLabel = 'My Libraries';
        objwrapperFilterOptions.lstInnerFilter = new List<wrapperInnerFilterOptions>();
        List<aggregateresult> agrLibrary = [select count(id) total, ContentWorkspaceId libId, ContentWorkspace.Name libName from ContentWorkspaceDoc group by ContentWorkspaceId, ContentWorkspace.Name];
        lstwrapperInnerFilterOptions = new List<wrapperInnerFilterOptions>();
        set<Id> sLibraryId = new set<Id>();
        for(aggregateresult agrLib: agrLibrary){
            if(sLibraryId.size() > intFilterSize){
                break;
            }
            objwrapperInnerFilterOptions = new wrapperInnerFilterOptions();
            objwrapperInnerFilterOptions.sContentDocId = new set<Id>();
            if(!sLibraryId.contains((id)agrLib.get('libId'))){
                sLibraryId.add((id)agrLib.get('libId'));
                objwrapperInnerFilterOptions.strFilterValue = string.valueOf(agrLib.get('libName')).toUpperCase();
                objwrapperInnerFilterOptions.strLibraryId = (string)agrLib.get('libId');
                //objwrapperInnerFilterOptions.sContentDocId.add(cnt.id);
                objwrapperInnerFilterOptions.blnFilterSelected = false;
                
                 if(strSelLibrary != 'ALL_WORKSPACES' && (id)agrLib.get('libId') == strSelLibrary){
                    objwrapperInnerFilterOptions.blnFilterSelected = true;
                }
                
                objwrapperInnerFilterOptions.intFilterCount = (integer)agrLib.get('total');
                lstwrapperInnerFilterOptions.add(objwrapperInnerFilterOptions);
            }
        }
        objwrapperFilterOptions.lstInnerFilter = lstwrapperInnerFilterOptions;
        lstwrapperFilterOptions.add(objwrapperFilterOptions);
        if(strSearchTags != null && strSearchTags != ''){
            filterContentRecords();
        }
        if(strSearchLibrary != null && strSearchLibrary != ''){
            searchContentRecords();
        }
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
        
    public void filterContentRecords(){
        set<Id> sCVId = new set<Id>();
        set<Id> sAuthorId = new set<Id>();
        set<Id> sLibraryId = new set<Id>();
        set<String> sFileExtensionId = new set<String>();
        for(wrapperFilterOptions wrFO: lstwrapperFilterOptions){
            for(wrapperInnerFilterOptions wrInnFO: wrFO.lstInnerFilter){
                if(wrInnFO.blnFilterSelected){
                    sCVId.addAll(wrInnFO.sContentDocId);
                    if(wrInnFO.strAuthoerId != null){
                        sAuthorId.add(wrInnFO.strAuthoerId);
                    }
                    if(wrInnFO.strLibraryId != null){
                        sLibraryId.add(wrInnFO.strLibraryId);
                    }
                    if(wrInnFO.strFileExtension != null){
                        sFileExtensionId.add(wrInnFO.strFileExtension);
                    }
                }
            }
        }
                        
        if(!sCVId.isEmpty() || !sAuthorId.isEmpty() || !sLibraryId.isEmpty() || !sFileExtensionId.isEmpty()){            
            string strSOQL = 'select id, title, ContentSize, LastModifieddate, ownerid, owner.name from ContentDocument '; 
            string strWhereClause = '';
            if(!sCVId.isEmpty()){
                strWhereClause = ' where id in: sCVId';
            }
            if(!sFileExtensionId.isEmpty()){
                if(strWhereClause == ''){
                    strWhereClause = ' where FileExtension in: sFileExtensionId';
                }else{
                    strWhereClause += ' or FileExtension in: sFileExtensionId';
                }
            }
            if(!sAuthorId.isEmpty()){
                if(strWhereClause == ''){
                    strWhereClause = ' where ownerid in: sAuthorId';
                }else{
                    strWhereClause += ' or ownerid in: sAuthorId';
                }
            }
            if(!sLibraryId.isEmpty()){
                if(strWhereClause == ''){
                    strWhereClause = ' where parentid in: sLibraryId';
                }else{
                    strWhereClause += ' or parentid in: sLibraryId';
                }
            }
            strSOQL += strWhereClause + ' LIMIT 50000';
            lstContentDocument = database.query(strSOQL);
            system.debug('@@@@@@'+lstContentDocument);
        }else{       
            lstContentDocument = [select id, title, ContentSize, LastModifieddate, ownerid, owner.name from ContentDocument LIMIT 50000];
            
        }
        intTotalRecords = lstContentDocument.size();
        intTotalPages=integer.valueOf(Math.ceil(double.valueOf(intTotalRecords)/double.valueOf(intPageSize)));        
        intFirstRecord=1;
        if(intTotalRecords>intPageSize){
            intLastRecord=intPageSize;
        }else{
            intLastRecord=intTotalRecords;
        }
        intCurrentPage=1;
        LoadContentDocument();        
        strSearchLibrary = '';
        
    }
    
    public void searchContentRecords(){
        for(wrapperFilterOptions wrFo: lstwrapperFilterOptions){
            for(wrapperInnerFilterOptions wInnFo: wrFo.lstInnerFilter){
                wInnFo.blnFilterSelected = false;
            }
        }
        string strSOQL = 'select id, title, ContentSize, LastModifieddate, ownerid, owner.name from ContentDocument '; 
        string strWhereClause = '';
        string strTempSearchLib = '%' + strSearchLibrary + '%';
        if(strSearchLibrary  != '' && strSelLibrary != null){
            strWhereClause = ' where title LIKE: strTempSearchLib ';
        }
        if(strSelLibrary != 'ALL_WORKSPACES'){
            if(strWhereClause == ''){
                strWhereClause = ' where parentid =: strSelLibrary';
            }else{
                strWhereClause += ' and parentid =: strSelLibrary ';
            }
        }
        
        strSOQL += strWhereClause + ' LIMIT 50000';
        lstContentDocument = database.query(strSOQL);
        
        intTotalRecords = lstContentDocument.size();
        intTotalPages=integer.valueOf(Math.ceil(double.valueOf(intTotalRecords)/double.valueOf(intPageSize)));        
        intFirstRecord=1;
        if(intTotalRecords>intPageSize){
            intLastRecord=intPageSize;
        }else{
            intLastRecord=intTotalRecords;
        }
        intCurrentPage=1;
        LoadContentDocument();          
    }
    
    public void clearSearchContentRecords(){
        for(wrapperFilterOptions wrFo: lstwrapperFilterOptions){
            for(wrapperInnerFilterOptions wInnFo: wrFo.lstInnerFilter){
                wInnFo.blnFilterSelected = false;
            }
        }
        string strSOQL = 'select id, title, ContentSize, LastModifieddate, ownerid, owner.name from ContentDocument LIMIT 50000'; 
        lstContentDocument = database.query(strSOQL);
        intTotalRecords = lstContentDocument.size();
        intTotalPages=integer.valueOf(Math.ceil(double.valueOf(intTotalRecords)/double.valueOf(intPageSize)));        
        intFirstRecord=1;
        if(intTotalRecords>intPageSize){
            intLastRecord=intPageSize;
        }else{
            intLastRecord=intTotalRecords;
        }
        intCurrentPage=1;
        LoadContentDocument();
            
    }
    
    public class wrapperFilterOptions{
        public string strFilterLabel {get; set;}
        public List<wrapperInnerFilterOptions> lstInnerFilter {get; set;}
    }
    public class wrapperInnerFilterOptions{
        public string strFilterValue {get; set;}
        public Integer intFilterCount  {get; set;}
        public Boolean blnFilterSelected {get; set;}
        public set<Id> sContentDocId {get; set;}
        public string strFileExtension {get; set;}
        public string strAuthoerId {get; set;}
        public string strLibraryId {get; set;}
        public wrapperInnerFilterOptions(){
            intFilterCount = 0;
        }
    }
    public class wrapperContentDocument{
        public boolean blnSelContentDocument {get; set;}
        public ContentDocument objContentDocument {get; set;}
        public Decimal decContentDocSize {get; set;}
        public String strContentDocSize {get; set;}
        public integer intNumberofDownloaded {get; set;}
        
    }
    Public Void GoNextClick(){
        intCurrentPage++; 
        intFirstRecord=intLastRecord+1;    
        intLastRecord=intCurrentPage*intPageSize;
        if(intLastRecord>intTotalRecords){
            intLastRecord=intTotalRecords;
        }       
        LoadContentDocument();
        //EnablePagging();
    }

    Public Void GoPreviousClick(){
        intCurrentPage--;             
        intLastRecord=intCurrentPage*intPageSize;        
        intFirstRecord=intLastRecord-intPagesize+1;
        LoadContentDocument();
       // EnablePagging();
    }
    void LoadContentDocument(){
        set<Id> sContentId = new set<Id>();
        for(integer contIndex=intFirstRecord-1;contIndex<intLastRecord;contIndex++){            
            sContentId.add(lstContentDocument[contIndex].ID);            
        }
        List<ContentDocument> lstContentDocumentTemp = [select id, LatestPublishedVersionId, title, ParentId, FileExtension, ContentSize, LastModifieddate, ownerid, owner.name from ContentDocument where id in: sContentId];
        lstwrapperContentDocument = new List<wrapperContentDocument>();
        wrapperContentDocument objwrapperContentDocument;
        for(ContentDocument cnt: lstContentDocumentTemp){
            objwrapperContentDocument = new wrapperContentDocument();
            objwrapperContentDocument.blnSelContentDocument = false;
            objwrapperContentDocument.objContentDocument = cnt;
            //objwrapperContentDocument.decContentDocSize = cnt.ContentSize/1024;
            If(cnt.ContentSize <1000000) {
                Decimal myDecContentSize = cnt.ContentSize;
                objwrapperContentDocument.decContentDocSize = myDecContentSize.divide(1024, 1, System.RoundingMode.UP);
                objwrapperContentDocument.strContentDocSize = String.valueOf(objwrapperContentDocument.decContentDocSize)+' KB';
            } else if (cnt.ContentSize >=1000000) {
                Decimal myDecContentSize = cnt.ContentSize;
                objwrapperContentDocument.decContentDocSize = myDecContentSize.divide(1000000, 1, System.RoundingMode.UP);
               
                objwrapperContentDocument.strContentDocSize = String.valueOf(objwrapperContentDocument.decContentDocSize)+' MB';
            }
            
            objwrapperContentDocument.intNumberofDownloaded = mapTotalDownload.get(cnt.id);
            lstwrapperContentDocument.add(objwrapperContentDocument);
        }
        EnablePagging();
    }
    
    Void EnablePagging(){       
        /*if((lstwrapperContentDocument!=null)&&(lstwrapperContentDocument.size()>0)){
            for(wrapperContentDocument cl:lstwrapperContentDocument){                
                if(strSelectedIds.indexOf(cl.objContentDocument.id)!=-1){
                    cl.blnSelContentDocument = !blnSelAll;
                }else{
                    cl.blnSelContentDocument = blnSelAll;
                }
            }
        } */ 
        
        system.debug('@@@@@'+intCurrentPage);
         system.debug('@@@@@'+intTotalPages);
        if(intCurrentPage==intTotalPages){
            blnHasNext=False;           
        }
        else{
            blnHasNext=True;                        
        }        
        if(intCurrentPage==1){
            blnHasPrevious=False;           
        }
        else{
            blnHasPrevious=True;                        
        }      
    }
    void Reset(){
             
        strNoResultVisibility='hidden';
        blnGoNext=false;
        strFooterVisibility='hidden';        
        intCurrentPage=1;  
        intTotalPages=0;
        intTotalRecords=0;
        intFirstRecord=1;
        intLastRecord=0;
        blnHasNext=False;
        blnHasPrevious=False;
        
    }
    
    public Component.Apex.pageBlockButtons getMyCommandButtons() {
        
        //the reRender attribute is a set NOT a string
        Set<string> theSet = new Set<string>();
        theSet.add('myPanel');
        theSet.add('myButtons');
                
        integer totalPages;
        if (math.mod(intTotalRecords, intPageSize) > 0) {
            totalPages = intTotalRecords/intPageSize + 1;
        } else {
            totalPages = (intTotalRecords/intPageSize);
        }
        
        integer currentPage;        
        if (intCurrentPage == 0) {
            currentPage = intFirstRecord/intPageSize + 1;
        } else {
            currentPage = integer.valueOf(intCurrentPage);
        }
     
        Component.Apex.pageBlockButtons pbButtons = new Component.Apex.pageBlockButtons();        
        pbButtons.location = 'top';
        pbButtons.id = 'myPBButtons';
        
        Component.Apex.outputPanel opPanel = new Component.Apex.outputPanel();
        opPanel.id = 'myButtons';
                                
        //the Previous button will alway be displayed
        Component.Apex.commandLink b1 = new Component.Apex.commandLink();
        b1.expressions.action = '{!GoPreviousClick}';
        b1.title = 'Go to the previous page of results';
        b1.value = '< Previous';
        b1.style = 'text-decoration:none;color:white;';
        //b1.expressions.disabled = '{!!blnHasPrevious}';
        b1.expressions.rendered = '{!blnHasPrevious}';        
        //b1.reRender = theSet;

        opPanel.childComponents.add(b1);        
                        
        for (integer i=0;i<totalPages;i++) {
            Component.Apex.commandLink btn = new Component.Apex.commandLink();
            
            if (i+1==1) {
                btn.title = 'Page 1';
                btn.value = '1';
                btn.rendered = true; 
                btn.style = 'text-decoration:none;color:white;';                                    
            /*} else if (i+1==totalPages) {
                btn.title = 'Go to the Last page of results';
                btn.value = 'Last Page';
                btn.rendered = true;  */                          
            } else {
                btn.title = 'Page ' + string.valueOf(i+1) + ' ';
                btn.value = ' ' + string.valueOf(i+1) + ' ';
                btn.rendered = false;
                btn.style = 'text-decoration:none;color:white;';             
            }
            
            if (   (i+1 <= 5 && currentPage < 5)
                || (i+1 >= totalPages-4 && currentPage > totalPages-4)
                || (i+1 >= currentPage-2 && i+1 <= currentPage+2))
            {
                btn.rendered = true;
            }
            btn.onclick = 'queryByPage(\''+string.valueOf(i+1)+'\');return false;';                                     
            if (i+1==currentPage) { 
                btn.style = 'color:white;text-decoration:none;cursor:unset';
                btn.styleClass = 'page on';
                btn.onclick = 'return false;'; 
            }            
                            
            opPanel.childComponents.add(btn);
            
            if (i+1 == 1 || i+1 == totalPages-1) { //put text after page 1 and before last page
                //Component.Apex.outputText text = new Component.Apex.outputText();
                //text.value = '...';        
                //opPanel.childComponents.add(text);
            } 
             
        }
        
        //the Next button will alway be displayed
        Component.Apex.commandLink b2 = new Component.Apex.commandLink();
        b2.expressions.action = '{!GoNextClick}';
        b2.title = 'Go to the next page of results';
        b2.value = 'Next >';
        b2.expressions.rendered = '{!blnHasNext}'; 
        b2.style = 'text-decoration:none;color:white;';       
        //b2.reRender = theSet;
        opPanel.childComponents.add(b2);
                
        //add all buttons as children of the outputPanel                
        pbButtons.childComponents.add(opPanel);  
  
        return pbButtons;

    }
    
    public PageReference refreshGrid() { //user clicked a page number        
        //system.debug('**** ' + selectedPage);
        intCurrentPage = integer.valueof(apexpages.currentpage().getparameters().get('firstParam'));             
        intLastRecord = intCurrentPage*intPageSize;        
        intFirstRecord = intLastRecord-intPagesize+1;
        
        if(intTotalRecords<=intLastRecord){
            intLastRecord=intTotalRecords;
        }
        LoadContentDocument();
        return null;
    }
}