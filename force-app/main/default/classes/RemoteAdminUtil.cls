public with sharing class RemoteAdminUtil 
{
	public static String readXMLResponse(XmlStreamReader reader, String sxmltag)
    {
    	string retValue; // Read through the XML
      	while(reader.hasNext())
  		{
        	if (reader.getEventType() == XmlTag.START_ELEMENT)
        	{
          		if (reader.getLocalName() == sxmltag) 
          		{
            		reader.next();
            		if (reader.getEventType() == XmlTag.characters)
              			retValue = reader.getText();
          		}
        	}
        	reader.next();
      	}
      	return retValue;
    }
}