public with sharing class JSONMetadataParser 
{
	//token names for Json Parsing
    public final string TOKEN_NAME = 'name';
    public final string TOKEN_LABEL = 'label';
    public final string TOKEN_CUSTOMSETTING = 'customSetting';
    
    //getting the list of Sobject list of remote SFDC org, returning the selectoption list
    public list<Selectoption> getSobjectList(string strJsonResponse)
    {
    	list<Selectoption> metadataObjectList = new list<Selectoption>();
    	metadataObjectList.add(new Selectoption('--None--', '--None--'));
        JSONParser parser = JSON.createParser(strJsonResponse);
	    try
	    {
	    	do
	        {
	            parser.nextToken();
	        }while(parser.hasCurrentToken() && !'sobjects'.equals(parser.getCurrentName()));
		    parser.nextToken();
		    list<ObjectMetadata> lstsobjectMetadata = new list<ObjectMetadata>();
		    lstsobjectMetadata = (List<ObjectMetadata>) parser.readValueAs(List<ObjectMetadata>.class);
		    for(ObjectMetadata objOM : lstsobjectMetadata)
		    {
		    	if(objOM.custom && !objOM.customSetting)
		    		metadataObjectList.add(new Selectoption(objOM.name, objOM.label));
		    }
	    }
	    catch(Exception e)
	    {
	     	System.debug('--------------Parsing Exception ---------------'+e);
	    }
	    return metadataObjectList;  
    }
    
    //getting the SObject metadata from connected remote Org, returning instance of ObjectMetadata class
     public ObjectMetadata getSobjectMetadata(string pJsonResponse)
     {
        ObjectMetadata objMetadata = new ObjectMetadata();
        JSONParser parser = JSON.createParser(pJsonResponse);
        list<ObjectMetadata> lstsobjectMetadata = new list<ObjectMetadata>();
	    while (parser.nextToken() != null) 
	    {
	    	//Read Metadata Json response as Class 'ObjectMetadata' 
            objMetadata = (ObjectMetadata)parser.readValueAs(ObjectMetadata.class);
        }
      
	    return objMetadata;     
    }
}