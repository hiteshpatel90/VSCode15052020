public class LeadManagementVO {

    public class NewAttendeeLead {
        
        @AuraEnabled public String leadType {get; set;}
        @AuraEnabled public String firstName {get; set;}
        @AuraEnabled public String lastName {get; set;}
        @AuraEnabled public String email {get; set;}
        @AuraEnabled public String phone {get; set;}
        @AuraEnabled public String street {get; set;}
        @AuraEnabled public String city {get; set;}
        @AuraEnabled public String state {get; set;}
        @AuraEnabled public String zip {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String practiceName {get; set;}
        @AuraEnabled public String designation {get; set;}
        @AuraEnabled public String accountName {get; set;}
        
        public NewAttendeeLead(){}
        
    }   //  end of NewAttendeeLead
    
    public class KeyValue {
        @AuraEnabled public String key {get; set;}
        @AuraEnabled public String value {get; set;}
        
        public KeyValue(){}
        
        public KeyValue(String k, String v){
            this.key = k;
            this.value = v;
        }
    }   //  end of KeyValue
    
    public class AttendeeTaskInfo {
        @AuraEnabled public String campaignId {get; set;}
        @AuraEnabled public String teamId {get; set;}
        @AuraEnabled public String attendeeId {get; set;}
        @AuraEnabled public String attendeeType {get; set;}
        @AuraEnabled public String taskType {get; set;}
        @AuraEnabled public String taskDetails {get; set;}
        
        public AttendeeTaskInfo(){}
        
    }   //  end of AttendeeTaskInfo
    
    public class SelectableOption{
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String Name {get; set;}
        @AuraEnabled public boolean Selected {get; set;}
        @AuraEnabled public boolean Preferred {get; set;}
        
        public SelectableOption(){}
        public SelectableOption(String p_Id, String p_Name){
            this(p_Id, p_Name, false);
        }
        public SelectableOption(String p_Id, String p_Name, boolean p_Selected){
            this.Id = p_Id;
            this.Name = p_Name;
            this.Selected = p_Selected;
        }
        
        public SelectableOption(String p_Id, String p_Name, boolean p_Selected, boolean p_Preferred){
            this(p_Id, p_Name, false);
            this.Preferred = p_Preferred;
        }
        
    }   //  end of SelectableOption
    
     /*
     * @Summary: Entity to represent a json version of a picklist entry
     * so that the validFor property becomes exposed
    */
    public class TPicklistEntry{
        public string active {get;set;}
        public string defaultValue {get;set;}
        public string label {get;set;}
        public string value {get;set;}
        public string validFor {get;set;}
        public TPicklistEntry(){
            
        }
    }
}   //  end of LeadManagementVO