public with sharing class FieldMetadata 
{
	public string label{get;set;}
	public string name{get;set;}
	public Decimal length{get;set;}
	public Decimal precision{get;set;}
	public Decimal scale{get;set;}
	public string relationshipName{get;set;}
	public Boolean autoNumber{get;set;}
	public Boolean createable{get;set;}
	public Boolean custom{get;set;}
	public Boolean namePointing{get;set;}
	public Boolean externalId{get;set;}
	public Boolean unique{get;set;}
	public Boolean updateable{get;set;}
	public Boolean dependentPicklist{get;set;}
	public string calculatedFormula{get;set;}
	public Decimal byteLength{get;set;}
	public String inlineHelpText{get;set;}
	public string controllerName{get;set;} 
	public string defaultValue{get;set;}
	public Decimal digits{get;set;}
	public string relationshipOrder{get;set;}
	public string calculated{get;set;}
	public string cascadeDelete{get;set;}
	public Boolean caseSensitive{get;set;}
	public Boolean filterable{get;set;}
	public Boolean deprecatedAndHidden{get;set;}
	public Boolean groupable{get;set;}
	public Boolean htmlFormatted{get;set;}
	public Boolean idLookup{get;set;}
	public Boolean nillable{get;set;}
	public string permissionable{get;set;}
	public string restrictedDelete{get;set;}
	public string restrictedPicklist{get;set;}
	public Boolean sortable{get;set;}
	public string writeRequiresMasterRead{get;set;}
	public string type{get;set;}
	public string soapType{get;set;}
	public list<Picklist> picklistValues = new list<Picklist>();

}