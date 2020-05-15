public class createCaseAttMappingExtension{
    public Case_Attribute_Mapping__c objCAM  {get; set;}
    
    public string strSelFields {get; set;}
    public string strUnSelFields {get; set;}
    
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
    string strCAMId = '';
    public createCaseAttMappingExtension(Apexpages.standardcontroller stdCon){
        objCAM = new Case_Attribute_Mapping__c();
        leftselected = new List<String>();
        rightselected = new List<String>();
        //leftvalues.addAll(originalValues);
        
        strCAMId = apexpages.currentpage().getparameters().get('id');
        if(strCAMId != null){
            objCAM = [select id, Active__c, Field_Mapping_with_Label__c, Case_Record_Type__c, Object_Type__c from Case_Attribute_Mapping__c where id =: strCAMId];
            
            string[] arrTempSelectedFields = objCAM.Field_Mapping_with_Label__c.split(',');
            for(String str: arrTempSelectedFields){
                leftselected.add(str);
            }
            
        }
        populateFields();
        populateSelectedFields();
    }
    
    public void populateFields(){
        leftvalues.clear();
        rightvalues.clear();
        if(objCAM.Object_Type__c != null){
            SObjectType accountType = Schema.getGlobalDescribe().get(objCAM.Object_Type__c);
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            
            for(String str: mfields.keyset()){
                SObjectField fieldToken = mfields.get(str);
                DescribeFieldResult selectedField = fieldToken.getDescribe();
                leftvalues.add(selectedField.getName());
            }
            
            
           
            if(strCAMId != null){
                List<Case_Attribute_Mapping__c> lstCAM = [select id, Active__c, Field_Mapping_with_Label__c, Case_Record_Type__c, Object_Type__c from Case_Attribute_Mapping__c where id =: strCAMId and Object_Type__c =: objCAM.Object_Type__c];
                if(!lstCAM.isEmpty()){
                    objCAM = lstCAM[0];
                    string[] arrTempSelectedFields = objCAM.Field_Mapping_with_Label__c.split(',');
                    for(String str: arrTempSelectedFields){
                        leftselected.add(str);
                    }
                    
                    for(String s : leftselected){
                        leftvalues.remove(s);
                        rightvalues.add(s);
                    }
                }
            }
        }
    }
    
    public void populateSelectedFields(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
       
    }
    
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    
    public List<SelectOption> getCaseRecordTypes(){
        List<SelectOption> options1 = new List<SelectOption>();
        options1.add(new SelectOption('','--None--'));
        Schema.DescribeSObjectResult R = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        for(Schema.RecordTypeInfo crt: RT){
            options1.add(new SelectOption(crt.getName(), crt.getName()));
        }
        return options1;
    }
    
     public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
     
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
    }
    
    public pagereference saveCAM(){
        try{
            string strTempSelFields = '';
            for(SelectOption str: getSelectedValues()){
                strTempSelFields += str.getValue() + ',';
                
            }
            
            objCAM.Field_Mapping_with_Label__c = strTempSelFields;
            upsert objCAM;
            
            pagereference pr = new pagereference('/'+objCAM.id);
            return pr;
        }catch (exception ex){
            system.debug('Exception Message :- ' + ex.getMessage());
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
}