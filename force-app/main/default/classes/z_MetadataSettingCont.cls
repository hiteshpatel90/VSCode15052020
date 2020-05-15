public with sharing class z_MetadataSettingCont {
    
    private PageReference rPage;
    
    ApexPages.StandardSetController setCon;

    public z_MetadataSettingCont(ApexPages.StandardSetController controller) {
        setCon = controller;
        try {
            rPage = new PageReference(ApexPages.currentPage().getParameters().get('retUrl'));
            if(rPage.getUrl() == '')
                rPage = null;
        } catch (Exception e) {
            rPage = null;
        }
    }
    
    public PageReference deleteSelected() {
        List<SObject> records = setCon.getSelected();
        if(records.size() != 0)
            delete records;
    
        return rPage;
    }
    
    public PageReference deleteAll() {
        List<SObject> records = [Select id From z_MetaDumpSetting__c Limit 10000];
        if(records.size() != 0)
            delete records;
        
        return rPage;
    }
    
    public PageReference loadMetadataFromDB() {
        if(rPage == null) {
            return null;
        }
        return loadMetadata();
    }
    
    public PageReference loadMetadata() {
        deleteAll();
        List<z_MetaDumpSetting__c> dumps = new List<z_MetaDumpSetting__c>();

        for(String name : Schema.getGlobalDescribe().keySet()) {
        	if (name.endsWith('History') || name.endsWith('Share')) {
        		continue;
        	}
            	
        	if (name.equalsIgnoreCase('ApexComponent') || name.equalsIgnoreCase('ApexClass') || name.equalsIgnoreCase('ApexTrigger') || name.equalsIgnoreCase('ApexPage') || name.equalsIgnoreCase('ProcessInstance') || name.equalsIgnoreCase('ProcessInstanceHistory') || name.equalsIgnoreCase('ProcessInstanceStep') || name.equals('ProcessInstanceHistory') || name.equalsIgnoreCase('Document') || name.equalsIgnoreCase('DocumentAttachmentMap') || name.equalsIgnoreCase('Note') || name.equals('NoteAndAttachment') ||name.equalsIgnoreCase('EmailServicesAddress') || name.equalsIgnoreCase('EmailServicesFunction') || name.equalsIgnoreCase('EmailStatus') || name.equalsIgnoreCase('FiscalYearSettings') || name.equalsIgnoreCase('Folder') || name.equalsIgnoreCase('ForecastShare') || name.equalsIgnoreCase('Group') || name.equalsIgnoreCase('GroupMember')) {
        		continue;
        	}        	
            dumps.add(new z_MetaDumpSetting__c(name__c = name));
        }
        insert dumps;   
        return rPage;
    }
}