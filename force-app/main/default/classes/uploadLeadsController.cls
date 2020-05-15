public class uploadLeadsController {
    public transient blob csvFileBody {get; set;}
    public string leadDataAsString;
    public String[] leadDataLines;
    Map < String, Integer > fieldNumberMap = new Map < String, Integer > ();
    public List<String> lstFieldNames;
    public List<leadWrapper> lstLeadWrapper;
    public integer intTotalLeadCount {get; set;}
    String fieldValue;
    Integer fieldNumber;
    String strLeadFileHeader;
    public boolean readSuccess {get;set;}
    public void readFromFile(){
        readSuccess = false;
        intTotalLeadCount = 0;
        leadDataLines = new String[] {};
        lstLeadWrapper = new List<leadWrapper>();
        lstFieldNames = new List<String>();
        leadDataAsString = csvFileBody.toString();
        readCSVFile();
    }
    public void readCSVFile() {
        leadDataAsString = leadDataAsString.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        leadDataAsString = leadDataAsString.replaceAll('""','DBLQT');
        
        leadDataLines = leadDataAsString.split('\n');
        string[] csvFieldNames = leadDataLines[0].split(',');
        for (Integer i = 0; i < csvFieldNames.size(); i++) {
            fieldNumberMap.put(csvFieldNames[i], i);
            lstFieldNames.add(csvFieldNames[i].trim());
        }
        for (Integer i = 1; i < leadDataLines.size(); i++) {
            leadWrapper objLeadWrapper = new leadWrapper();
            string[] csvRecordData = leadDataLines[i].split(',');
            for (String fieldName: csvFieldNames) {
                fieldNumber = fieldNumberMap.get(fieldName);
                fieldValue = csvRecordData[fieldNumber];
                strLeadFileHeader = fieldName.trim();
                if(strLeadFileHeader  == 'Lead ID'){
                    objLeadWrapper.strLeadId = fieldValue.trim();
                }
                if(strLeadFileHeader  == 'Email Address'){
                    objLeadWrapper.strLeadEmail = fieldValue.trim();
                }
                if(strLeadFileHeader == 'ABM Tier (L)'){
                    objLeadWrapper.strABMTier = fieldValue.trim();
                }
                if(strLeadFileHeader == 'OwnerID'){
                    objLeadWrapper.strContactOwnerID = fieldValue.trim();
                }
                if(strLeadFileHeader == 'Account ID'){
                    objLeadWrapper.strLeadAccountID = fieldValue.trim();
                }
                if(strLeadFileHeader == 'Status'){
                    objLeadWrapper.strLeadStatus = fieldValue.trim();
                }
            }
            lstLeadWrapper.add(objLeadWrapper);                
        }
        if(lstLeadWrapper.size() > 0){
            readSuccess = true;
            intTotalLeadCount = lstLeadWrapper.size();
        }            
    }
    
    public void convertLead() {
        list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        Map<Id, Id> mapLeadWithOwnerId = new Map<Id, Id>();
        for(leadWrapper lw: lstLeadWrapper){
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lw.strLeadId);
            lc.setAccountId(lw.strLeadAccountID);
            
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(true);
            leadConverts.add(lc);
            mapLeadWithOwnerId.Put(lw.strLeadId, lw.strContactOwnerID);
        }
        Map<Id, Id> mapLeadWithConvertedContact = new Map<Id, Id>();
        if(!leadConverts.isEmpty()){
            for(Integer i = 0; i <= leadConverts.size()/100 ; i++){
                list<Database.LeadConvert> tempList = new list<Database.LeadConvert>();
                Integer startIndex = i*100;
                Integer endIndex = ((startIndex+100) < leadConverts.size()) ? startIndex+100: leadConverts.size();
                for(Integer j=startIndex;j<endIndex;j++){
                    tempList.add(leadConverts[j]);
                }
                Database.LeadConvertResult[] lcrList = Database.convertLead(tempList, false);
                for(Database.LeadConvertResult lcr : lcrList){
                    System.assert(lcr.isSuccess());
                    mapLeadWithConvertedContact.Put(lcr.getLeadId(), lcr.getContactId());
                }
            }
        }
        
        List<Contact> lstContactUpdate = new List<Contact>();
        Contact objCon;
        for(leadWrapper lw: lstLeadWrapper){
            if(mapLeadWithConvertedContact != null && mapLeadWithConvertedContact.containsKey(lw.strLeadId) && 
                mapLeadWithOwnerId != null && mapLeadWithOwnerId.containsKey(lw.strLeadId)){
                objCon = new Contact(id=mapLeadWithConvertedContact.get(lw.strLeadId));
                objCon.OwnerId = mapLeadWithOwnerId.get(lw.strLeadId);
                lstContactUpdate.add(objCon);
            }
        }
        if(!lstContactUpdate.isEmpty()){
            update lstContactUpdate;
        }
        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, 'Lead has been converted successfully.');
        ApexPages.addMessage(errorMessage);
    }
    
    public class leadWrapper{
        public string strLeadId;
        public string strLeadEmail;
        public string strABMTier;
        public string strContactOwnerID;
        public string strLeadAccountID;
        public string strLeadStatus;
    }
}