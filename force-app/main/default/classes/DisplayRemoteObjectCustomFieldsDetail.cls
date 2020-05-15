public with sharing class DisplayRemoteObjectCustomFieldsDetail 
{
	public ObjectMetadata objMetadata{get;set;}
	public String sessionId {get;set;}
    public String serverUrl {get;set;}
    public String strRemoteObject {get;set;}
    public List<FieldMetadata> lstFieldMetaData {get;set;}
	public DisplayRemoteObjectCustomFieldsDetail()
	{
		lstFieldMetaData = new List<FieldMetadata>();
        serverUrl = ApexPages.currentPage().getParameters().get('surl');
        sessionId = ApexPages.currentPage().getParameters().get('sid');          
        strRemoteObject = ApexPages.currentPage().getParameters().get('oname');
        objMetadata = SendRequest.getObjectMetadata(serverUrl, sessionId, strRemoteObject);
        
        for(FieldMetadata objFMD : objMetadata.fields)
        {
        	if(objFMD.name.endsWith('__c'))
        		lstFieldMetaData.add(objFMD);
        }
	}
}