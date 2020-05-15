public class InsertCaseAttribute{
    @InvocableMethod
    public static void insertAttribute(List<List<Case>> inputList){
        set<Id> sCaseId = new set<Id>();
        set<Id> sOppId = new set<Id>();
        for(List<Case> thisCaseList : inputList){
            for(Case thisCase : thisCaseList){
                sCaseId.add(thisCase.id);
                sOppId.add(thisCase.Opportunity__c);
            }
        }
        // Get Existing Case records based on Opportunity ids
        List<Case> lstCase = [select id,Opportunity__c,casenumber,status, opportunity_product_id__c from case where id in:sCaseId];
        
                
        // Get Existing Opportunity Records - START    
        List<Schema.SObjectField> fldObjMapValues = returnAllfields('Opportunity');
        String strSOQLOpp = 'SELECT ';        
        for(Schema.SObjectField s : fldObjMapValues) {           
            String theName = s.getDescribe().getName();           
            // Continue building your dynamic query string           
            strSOQLOpp += theName + ',';       
        }       
        strSOQLOpp += ' Account.name ';    
        // Finalize query string       
        strSOQLOpp += ' FROM Opportunity where id IN :sOppId';
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>((List<Opportunity>)Database.query(strSOQLOpp));
        // Get Existing Opportunity Records - END
        
        // Get Existing Opportunity Line Items Records - START
        List<Schema.SObjectField> fldObjMapValuesOLI = returnAllfields('OpportunityLineItem');
        String strSOQLOLI = 'SELECT ';        
        for(Schema.SObjectField s : fldObjMapValuesOLI){           
            String theName = s.getDescribe().getName();           
            // Continue building your dynamic query string           
            strSOQLOLI += theName + ',';       
         }       
        strSOQLOLI += ' Opportunity.name ';    
        // Finalize query string       
        strSOQLOLI += ' FROM OpportunityLineitem where opportunityId IN :sOppId'; 
        
        Map<Id, OpportunityLineItem> mapOpportunityLineItem = new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)Database.query(strSOQLOLI));
        // Get Existing Opportunity Line Items Records - END
        
        // Get Active Case Attibute Mapping records
        List<Case_Attribute_Mapping__c> lstCAM = [select id,Field_Mapping_with_Label__c,Object_Type__c, Case_Record_Type__c from Case_Attribute_Mapping__c where Active__c = true and Case_Record_Type__c = 'Altegra Implementation'];
        
        
        Map<String, List<String>> mapObjectFields = new Map<String, List<String>>();
        // Condition to check Active Case Attibute Mapping records is not empty
        if(!lstCAM.isEmpty()){
            for(Case_Attribute_Mapping__c objCAM : lstCAM){
                if(objCAM.Field_Mapping_with_Label__c != null && objCAM.Field_Mapping_with_Label__c !=''){
                     if(objCAM.Object_Type__c != null && objCAM.Case_Record_Type__c == null){
                         list<string> lstSplitFields= new list<string>(objCAM.Field_Mapping_with_Label__c.split(','));
                         
                         mapObjectFields.put(objCAM.Object_Type__c, lstSplitFields);
                     }else if(objCAM.Object_Type__c != null && objCAM.Case_Record_Type__c != null){
                         list<string> lstSplitFields= new list<string>(objCAM.Field_Mapping_with_Label__c.split(','));
                         
                         mapObjectFields.put(objCAM.Object_Type__c + '_' + objCAM.Case_Record_Type__c, lstSplitFields);
                     }
                     
                }
            }
        }        
        // variable declaration for insert Case Attribute records
        List<Case_Attribute__c> lstCaseAttributeInsert = new list<Case_Attribute__c>();
        // variable declaration for insert OpportunityLineItem records
        List<OpportunityLineItem> lstOPLIUpdate = new List<OpportunityLineItem>();
        
        set<Id> sOLIIds = new set<Id>();
        // Condition to check Case records is not empty
        if(!lstCase.isEmpty()){
            for(Case objcase : lstcase){
                if(!mapObjectFields.isEmpty()){
                    for(string strObjectlabel : mapObjectFields.keyset()){
                        for(string strFieldLabel: mapObjectFields.get(strObjectlabel)){
                            // Create record in Case Attribute object
                            Case_Attribute__c objCA = new Case_Attribute__c();
                            objCA.name = strfieldlabel;
                            objCA.Case__c = objCase.id;
                                           
                            objCA.Opportunity__c = objCase.Opportunity__c;
                            
                            // OpportunityLineItemFields
                            if(strObjectlabel.equals('OpportunityLineItem') == false){
                                objCA.Initial_Value__c = string.valueOf(mapOpportunity.get(objCase.Opportunity__c).get(strFieldLabel));
                                objCA.Current_Value__c = string.valueOf(mapOpportunity.get(objCase.Opportunity__c).get(strFieldLabel));
                                
                                string strDatatype = fetchDatatype('Opportunity', strFieldLabel);
                                
                                system.debug('$$$$$$$$$$$'+strDatatype+'$$$$$$'+strFieldLabel);
                                if(strDatatype != ''){
                                    if(strDatatype == 'DATE'){
                                        objCA.Date_Value__c = date.valueOf(mapOpportunity.get(objCase.Opportunity__c).get(strFieldLabel));
                                    }else if(strDatatype == 'DOUBLE'){
                                        objCA.Number_Value__c = double.valueOf(mapOpportunity.get(objCase.Opportunity__c).get(strFieldLabel));
                                    }else{
                                        objCA.String_Value__c = string.valueOf(mapOpportunity.get(objCase.Opportunity__c).get(strFieldLabel));
                                    }
                                }
                            }else{
                                // Opportunity Fields
                                objCA.Initial_Value__c = string.valueOf(mapOpportunityLineItem.get(objCase.opportunity_product_id__c).get(strFieldLabel));
                                objCA.Current_Value__c = string.valueOf(mapOpportunityLineItem.get(objCase.opportunity_product_id__c).get(strFieldLabel));
                                string strDatatype = fetchDatatype('OpportunityLineItem', strFieldLabel);
                                if(strDatatype != ''){
                                    if(strDatatype == 'DATE'){
                                        objCA.Date_Value__c = date.valueOf(mapOpportunityLineItem.get(objCase.opportunity_product_id__c).get(strFieldLabel));
                                    }else if(strDatatype == 'DOUBLE'){
                                        objCA.Number_Value__c = integer.valueOf(mapOpportunityLineItem.get(objCase.opportunity_product_id__c).get(strFieldLabel));
                                    }else{
                                        objCA.String_Value__c = string.valueOf(mapOpportunityLineItem.get(objCase.opportunity_product_id__c).get(strFieldLabel));
                                    }
                                }
                            }
                            system.debug('@@@@@@@@'+objCase.opportunity_product_id__c);
                            if(objCase.opportunity_product_id__c != null && sOLIIds.contains(objCase.opportunity_product_id__c) == false){
                                sOLIIds.add(objCase.opportunity_product_id__c);
                                OpportunityLineItem objOppLI = new OpportunityLineItem(id=objCase.opportunity_product_id__c);
                                objOppLI.Project_ID__c = objCase.CaseNumber;
                                objOppLI.Project_Status__c = objCase.status;
                                lstOPLIUpdate.add(objOPPLI);
                            }
                            system.debug('@@@@@@@@'+lstOPLIUpdate);
                            objCA.FieldUnique__c = strfieldlabel + objCase.id;
                            lstCaseAttributeInsert.add(objCA);   
                        }
                    }
                }
            }
            
            // Case Attribute insert - START
            if(!lstCaseAttributeInsert.isEmpty()){
                try{
                    insert lstCaseAttributeInsert;
                    system.debug('##########'+lstCaseAttributeInsert);
                }catch (exception ex){
                    system.debug('Exception Message :- ' + ex.getMessage());
                }
            }
            // Case Attribute insert - END
            
            // Opportunity Line Item Update - START
            if(!lstOPLIUpdate.isEmpty()){
                try{
                    update lstOPLIUpdate;
                    system.debug('##########'+lstOPLIUpdate);
                }catch (exception ex){
                    system.debug('Exception Message :- ' + ex.getMessage());
                }
            }
            // Opportunity Line Item Update - END
            
        }
    }
    
    // Method to return list of fields of particular object using schema method
    public static List<Schema.SObjectField> returnAllfields(string strsObjectType){
        SObjectType accountType = Schema.getGlobalDescribe().get(strsObjectType);
        Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();        
        return mfields.values();    
    }
    
    // Get Data type of particular field
    public static string fetchDatatype(string strObject, string fieldName){
        string strObjectDatatype = '';
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectSchema = schemaMap.get(strObject);
        Map<String, Schema.SObjectField> fieldMap = sObjectSchema.getDescribe().fields.getMap();
        
        String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
        Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
        strObjectDatatype = string.valueOf(fielddataType);
        system.debug('#############'+fieldName+'######'+strObjectDatatype);
        return strObjectDatatype;
    }
}