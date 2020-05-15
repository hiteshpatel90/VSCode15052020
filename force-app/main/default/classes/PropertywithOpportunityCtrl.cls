/*
Apex Class Name : PropertywithOpportunityCtrl
Createddate     :
Createdby       :
Lastmdifieddate:
Lastmodifiedby  :
Purpose         : This apex class is used to display list of Opportunity with Properties records
*/
public class PropertywithOpportunityCtrl{
    // Initialize list for display on visualforce page
    public List<Property__c> lstProperties {get; set;}
    public Map<Id, String> mapPropertyWithURL {get; set;}
    
    public string strDeleteProperty {get; set;}
    // Constructor
    public PropertywithOpportunityCtrl(){
        set<Id> sPropertyId = new set<Id>();
        lstProperties = [SELECT id, Name FROM Property__c];
        for(Property__c pr: lstProperties){
            sPropertyId.add(pr.id);
        }
        
        fetchPropertyURL(sPropertyId);
    }
    
    public void fetchPropertyURL(set<Id> sPropertyId){
        mapPropertyWithURL = new Map<Id, String>();
        List<Property_with_Opportunity__c> lstPWO = [SELECT id, Property__c, URL__c FROM Property_with_Opportunity__c 
                                                    WHERE Property__c in: sPropertyId];
        for(Property_with_Opportunity__c pwo: lstPWO){
            mapPropertyWithURL.Put(pwo.Property__c, pwo.URL__c);
        }
    }
    
    public void deleteProperty(){
        Property__c objProp = new Property__c(id=strDeleteProperty);
        delete objProp;
    }
    
}