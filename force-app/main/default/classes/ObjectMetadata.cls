public with sharing class ObjectMetadata 
{
    public string name{get;set;}
    public string label{get;set;}
    public list<FieldMetadata> fields {get;set;}
   	public list<ChildRelationshipMetadata> childRelationships = new list<ChildRelationshipMetadata>();
    public Boolean custom{get;set;}
	public string keyPrefix{get;set;}
	public Boolean updateable{get;set;}
	public Boolean searchable{get;set;}
	public string labelPlural{get;set;}
	public Boolean layoutable{get;set;}
	public Boolean activateable{get;set;}
	public string describe{get;set;}
	public string rowTemplate{get;set;}
	public Boolean createable{get;set;}
	public Boolean customSetting{get;set;}
	public Boolean deletable{get;set;}
	public Boolean deprecatedAndHidden{get;set;}
	public Boolean feedEnabled{get;set;}
	public Boolean mergeable{get;set;}
	public Boolean queryable{get;set;}
	public Boolean replicateable{get;set;}
	public Boolean retrieveable{get;set;}
	public Boolean undeletable{get;set;}
	public Boolean triggerable{get;set;}
	
	public ObjectMetadata()
	{
		fields = new list<FieldMetadata>();
	}
}