public with sharing class ChildRelationshipMetadata 
{
	public string relationshipName{get;set;}
  	public string childSObject{get;set;}
  	public Boolean cascadeDelete{get;set;}
  	public string field{get;set;}
  	public Boolean deprecatedAndHidden{get;set;}
  	public Boolean restrictedDelete{get;set;}
}