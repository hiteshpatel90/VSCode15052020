public with sharing class z_DescribeHelper {
    
    static private z_ChildRelationship__c createChildRelationshipRecord(Id parentId, Schema.ChildRelationship schema) {
        z_ChildRelationship__c record = new z_ChildRelationship__c();
        record.z_ParentSObjectDescription__c = parentId;
        record.isCascadeDelete__c = schema.isCascadeDelete();
        //record.name = schema.getRelationshipName();
        record.fieldname__c = schema.getField().getDescribe().getName();
        record.childobjectname__c = schema.getChildSObject().getDescribe().getName();       
        return record;
    }

    static public Id insertSObjectDescriptionRecord(String objName) {
        Schema.DescribeSObjectResult obj = Schema.getGlobalDescribe().get(objName).getDescribe();   

        z_SObjectDescription__c sobj = new z_SObjectDescription__c();
        sobj.keyPrefix__c = obj.getKeyPrefix();
        sobj.label__c = obj.getLabel();
        sobj.labelPlural__c = obj.getLabelPlural();
        sobj.localName__c = obj.getLocalName();
        sobj.name = obj.getName();
        sobj.isAccessible__c = obj.isAccessible();
        sobj.isCreateable__c = obj.isCreateable();
        sobj.isCustom__c = obj.isCustom();
        sobj.isCustomSetting__c = obj.isCustomSetting();
        sobj.isDeltable__c = obj.isDeletable();
        sobj.isDeprecatedAndHidden__c = obj.isDeprecatedAndHidden();
        sobj.isFeedEnabled__c = obj.isFeedEnabled();
        sobj.isMergeable__c = obj.isMergeable();
        sobj.isQueryable__c = obj.isQueryable();
        sobj.isSearchable__c = obj.isSearchable();
        sobj.isUndeletable__c = obj.isUndeletable();
        sobj.isUpdateable__c = obj.isUpdateable();
        
        insert sobj;


        // Child Relationships
        List<z_ChildRelationship__c> childRelationList = new List<z_ChildRelationship__c>();
        for(Schema.ChildRelationship childRelation : obj.getChildRelationships()) {
            childRelationList.add(createChildRelationshipRecord(sobj.id, childRelation));
        }
        insert childRelationList;
        return sobj.id;
    }   
    
    static public z_FieldDescription__c createFieldDescriptionRecord(Id objid, String objname, String fieldname) {
        Schema.DescribeSObjectResult obj = Schema.getGlobalDescribe().get(objname).getDescribe();

        Map<String, Schema.SObjectField> fMap = obj.fields.getMap();

        List<Schema.SObjectField> fTokens = fMap.values() ;
        Schema.DescribeFieldResult field;
        for( Integer i = 0 ; i < fTokens.size() ; i++ ){
            Schema.DescribeFieldResult f = fTokens.get(i).getDescribe() ;
            if( f.getName() == fieldname) {
                field = f;
            }
        }       

        z_FieldDescription__c fd = new z_FieldDescription__c();
        fd.z_SObjectDescription__c = objid;
        fd.type__c = field.getType().name();
        fd.soaptype__c = field.getSoapType().name();
        fd.byteLength__c = field.getByteLength();
        fd.calculatedFormula__c = field.getCalculatedFormula();
        fd.defaultValueFormula__c = field.getDefaultValueFormula();
        fd.digits__c = field.getDigits();
        fd.inlineHelpText__c = field.getInlineHelpText();
        fd.label__c = field.getLabel();
        fd.length__c = field.getLength();
        fd.localName__c = field.getLocalName();
        fd.name = field.getName();
        fd.precision__c = field.getPrecision();
        fd.relationshipName__c = field.getRelationshipName();
        fd.relationshipOrder__c = field.getRelationshipOrder();
        fd.scale__c = field.getScale();
        fd.isAccessible__c = field.isAccessible();
        fd.isAutoNumer__c = field.isAutoNumber();
        fd.isCalculated__c = field.isCalculated();
        fd.isCaseSensitive__c = field.isCaseSensitive();
        fd.isCreateable__c = field.isCreateable();
        fd.isCustom__c = field.isCustom();
        fd.isDefaultedOnCreate__c = field.isDefaultedOnCreate();
        fd.isDependentPicklist__c = field.isDependentPicklist();
        fd.isDeprecatedAndHidden__c = field.isDeprecatedAndHidden();
        fd.isExternalID__c = field.isExternalId();
        fd.isFilterable__c = field.isFilterable();
        fd.isGroupable__c = field.isGroupable();        
        fd.isHtmlFormatted__c = field.isHtmlFormatted();
        fd.isIdLookup__c = field.isIdLookup();
        fd.isNameField__c = field.isNameField();
        fd.isNamePointing__c = field.isNamePointing();
        fd.isNillable__c = field.isNillable();   
        fd.isRestrictedPicklist__c = field.isRestrictedPicklist();
        fd.isSortable__c = field.isSortable();
        fd.isUnique__c = field.isUnique();
        fd.isUpdateable__c = field.isUpdateable();
        fd.isWriteRequiredMasterRead__c = field.isWriteRequiresMasterRead();
        
        String picklistentries = '';
        Integer i = 0;
        for(Schema.PicklistEntry entry : field.getPicklistValues()) {
            if(i++ != 0) {
                picklistentries += '\n';
            }
            
            String label = entry.getLabel();
            String value = entry.getValue();
            Boolean isActive = entry.isActive();
            Boolean isDefaultValue = entry.isDefaultValue();
            String line = '' + label + ' : ' + value;
            picklistentries += line;
        }
        fd.picklistentries__c = picklistentries;
        return fd;          
    }
    
    static public List<String> getFieldNames( String objName ){
        List<String> result = new List<String>{} ;      
        //Get the token for this object
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objName) ;
        Map<String, Schema.SObjectField> fMap = s.getDescribe().fields.getMap() ;
        List<Schema.SObjectField> fTokens = fMap.values() ;
        for( Integer i = 0 ; i < fTokens.size() ; i++ ){
            Schema.DescribeFieldResult f = fTokens.get(i).getDescribe() ;
            result.add( f.getName() ) ;
        }
        return result ;
    }  
}