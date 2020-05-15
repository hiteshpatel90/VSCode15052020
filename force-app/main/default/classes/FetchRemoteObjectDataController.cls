public with sharing class FetchRemoteObjectDataController 
{
    //Login Domain May be test, prerellogin.pre
    private final String LOGIN_DOMAIN = 'www';
    public String pwd{get;set;}
    public String userName{get;set;}
    
    public List<sObject> lstSobject{get;set;}
    public List<SelectOption> lstClient {get;set;}
    public list<Selectoption> lstRemoteObject {get;set;}
    public List<String> lstColumn {get;set;}
    public List<Selectoption> lstRemoteObjectAllField{get;set;}
	public List<String> lstSelectedFromRemoteObjectAllFieldName {get;set;}
	public List<Selectoption> lstSelectedField{get;set;}
	public List<String> lstSelectedFieldName{get; set;}
	public Map<String, FieldMetadata> mapFieldAPIToField {get;set;}
	
    public String selectedClient {get;set;}
    public String sessionId {get;set;}
    public String serverUrl {get;set;}  
    public String strRemoteObject {get;set;}
    
    private ObjectMetadata objMetadata;
	
    /**** Constructor *****/
    public FetchRemoteObjectDataController()
    {
    	initialize();	    
        setClientNames();
    }
    
    private void initialize()
    {
    	lstSobject = new List<sObject>();
        lstClient = new List<SelectOption>();
        lstRemoteObject = new list<Selectoption>();
       	lstColumn = new  List<String>();
        lstRemoteObjectAllField = new List<Selectoption>();
	    lstSelectedFromRemoteObjectAllFieldName = new List<String>();
	    lstSelectedField = new List<Selectoption>();
	    lstSelectedFieldName = new List<String>();
		mapFieldAPIToField = new Map<String, FieldMetadata>();
    }
    /* Create Select option list to hold Name of All Client. 
        These names are fetching from Custom Setting. */
    public void setClientNames()
    {
        lstClient.add(new SelectOption('--None--', '--None--'));
        for(Client_Detail__c objCD : Client_Detail__c.getAll().values())
            lstClient.add(new SelectOption(objCD.Name, objCD.Name));
    }
    
    /* fetchDetails method pull out records from Client SFDC org in JSON Formate.
        Here we parse the JSON and store expected output in respected object list.**/
    public void fetchDetails()
    {
        try
        {	
        	clearValues();
        	lstRemoteObject = new list<Selectoption>();
        	strRemoteObject = '--None--';
            //Check None selection from Client Picklist on Page. 
            if(selectedClient.equals('--None--'))
            {
                customMessage(Label.Remote_Admin_Client_Name);
                return;
            }
            
            //Check Client Credential is set or not
            Client_Detail__c myCS = Client_Detail__c.getInstance(selectedClient);
            if((myCS.UserName__c != null && myCS.UserName__c.trim() != '') && (myCS.Password__c != null && myCS.Password__c.trim() != ''))
            {
                userName = myCS.UserName__c;
                pwd = myCS.Password__c;
            }
            else
            {
                customMessage(Label.Remote_Admin_Credencial_set_up);
                return;
            }
             
            //Set Session Id and Server Url
            setSessionIdAndServerUrl();
            lstRemoteObject = SendRequest.getRemoteObjects(serverUrl, sessionId);
            
            if(serverUrl != null && sessionId!= null)
            {
            	customMessage('Connection Established with Remote Org. Please select Remote Custom object Name from Dropdown list.');
            	return;
            }
        }
        catch(Exception e)
        {
        	customMessage(e.getMessage());
            System.debug('-----------------e--------------'+e);
        }
    }
    
  	public String strfields {get;set;}
    public void getResponse()
    {
    	try
    	{
    		
	    	lstColumn = new List<String>();
	    	Boolean isShare = SendRequest.hasShare(serverUrl, sessionId);
	    	if(isShare)
	    	{
	    		strfields = '';
	    		for(SelectOption selectedValue : lstSelectedField)
	    		{
	    			lstColumn.add(selectedValue.getValue());
	    			if(!selectedValue.getValue().equalsIgnoreCase('Id'))
	    				strfields += ',' + selectedValue.getValue();
	    		}
	    		if(!validateSelectedFields(lstColumn))
	    		{
	    			return;
	    		}
	    		strfields = 'Id' + strfields;
	    		
		        /*** Retrieve records via REST API ***/
		        HttpRequest request = new HttpRequest();
		        PageReference theUrl = new PageReference(serverUrl + '/services/data/v22.0/query/');
		        theUrl.getParameters().put('q','Select ' + strfields + ' From ' + strRemoteObject+' limit 10000');
		        request = new HttpRequest();
		        request.setEndpoint(theUrl.getUrl());
		        request.setMethod('GET');
		        request.setHeader('Authorization', 'OAuth ' + sessionId);
		        String body;
		        
		        if(!Test.isRunningTest())
		        {
		            body = (new Http()).send(request).getBody();
		            if(body.indexOf('"errorCode":"INVALID_TYPE"') != -1)
		            {
		            	customMessage(Label.Remote_Admin_Requested_Object_Missing);
		                return;      
		            }
		        }
		        else
		            body = '{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Account","url":"/services/data/v22.0/sobjects/Account/0019000000YTG3HAAX"},"Id":"0019000000YTG3HAAX","Phone":"(650) 867-3450","Name":"GenePoint Test","CreatedBy":{"attributes":{"type":"User","url":"/services/data/v22.0/sobjects/User/00590000001pnanAAA"},"FirstName":"Archana"},"CreatedById":"00590000001pnanAAA"}]}';
		        /**** Parse the JSON Respose ****/
		        JSONParser parser = JSON.createParser(body);
		        do
		        {
		            parser.nextToken();
		        }while(parser.hasCurrentToken() && !'records'.equals(parser.getCurrentName()));
		        parser.nextToken();
		        /*** Create List of records to be dispaly on page ***/
		        if(!Test.isRunningTest())
		        	lstSobject = (List<sObject>) parser.readValueAs(List<sObject>.class);
	    	}
	    	else
	    	{
	    		customMessage(Label.Remote_Admin_Data_Share_Error);
		        return;  
	    	}
    	}
    	catch(Exception e)
    	{
    		customMessage(e.getMessage());
    		return;
    	}
    }
    
    public boolean validateSelectedFields(List<String> lstColumn)
    {
    	Map<String, Schema.SObjectType> mapNameToSObjectType = Schema.getGlobalDescribe() ;
		Schema.SObjectType describeSobject = mapNameToSObjectType.get(strRemoteObject);
    	Map<String, Schema.SObjectField> mapNameTofieldDetail = describeSobject.getDescribe().fields.getMap();
    	
    	String strFieldsNotInCurrentOrg = '';
    	for(String strFieldName : lstColumn)
    	{
    		if(!mapNameTofieldDetail.containsKey(strFieldName))
    			strFieldsNotInCurrentOrg += strFieldName + ', ';
    	}
    	if(strFieldsNotInCurrentOrg.length() > 0)
    	{
    		strFieldsNotInCurrentOrg = strFieldsNotInCurrentOrg.substring(0, strFieldsNotInCurrentOrg.length() - 2);
    		String strMsg = strFieldsNotInCurrentOrg + ' Field(s) are not in current org. Please contact with Remote Admin or'+ 
							'<a style="color:red;cursor:pointer;text-align:right;" target="__blank"'+
							'href="../apex/DisplayRemoteObjectCustomFieldsDetail?surl='+serverUrl+'&sid='+sessionId+'&oname='+strRemoteObject+
							'&fields='+ strFieldsNotInCurrentOrg +'">View Field(s) Detail</a>';
			customMessage(strMsg);
    		return false;
    	}
    	return true;
    }
    
    public void setSessionIdAndServerUrl()
    {
        /**** Login via SOAP/XML web service api. Set All request Parameter *****/
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://' + LOGIN_DOMAIN + '.salesforce.com/services/Soap/u/22.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body>'+
                        '<login xmlns="urn:partner.soap.sforce.com">'+
                        '<username>' + userName+ '</username><password>' + pwd + '</password></login></Body></Envelope>');
        
        Dom.XmlNode resultElmt;
        try
        {
            if(!Test.isRunningTest())   
            { 
                HttpResponse res = (new Http()).send(request);
                XmlStreamReader reader = res.getXmlStreamReader();       
                String requestId = RemoteAdminUtil.readXMLResponse(reader, 'faultstring');
                if(requestId == null)
                {
                    resultElmt = (new Http()).send(request).getBodyDocument().getRootElement()
                                      .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                                      .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
                                      .getChildElement('result', 'urn:partner.soap.sforce.com');
                }
                else
                {
                    customMessage(Label.Remote_Admin_Invalid_Authentication);
                    return;      
                }
            }
        }
        catch(Exception e)
        {
            System.debug('--------------Exception-----------'+e);
            customMessage(e.getMessage());
            return;
        }
        /****Grab session id and server url***/
        if(!Test.isRunningTest())
        {
            serverUrl = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com').getText().split('/services')[0];
            sessionId = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com').getText();
            
        }
        else
        {
           sessionId = '00D90000000YYpr!AQkAQGItxGayPzRLb3g2z96MsVuJnidnW2fZAUpNEKcq_j5tjmV_oj.eZZHn90l0A9PbZtgvuTIVUlahKDPYqgXuhR5Y9Md4';
           serverUrl = 'https://ap1-api.salesforce.com/services/Soap/u/21.0/00D90000sfgfsf';
           String strTest = '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body>'+
                        '<login xmlns="urn:partner.soap.sforce.com">'+
                        '<username>1234</username><password>1234</password></login></Body></Envelope>';
           String requestId = RemoteAdminUtil.readXMLResponse(new XmlStreamReader(strTest), 'username');
        }
    }
    
    /* Set appropriate Error message. */
    public void customMessage(String strMessage)
    { 
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,strMessage);
      ApexPages.addMessage(myMsg); 
      lstSobject = new List<sObject>();
    }
   
	public void validateObjectWithUserOrg()
	{
		clearValues();
		if(strRemoteObject == '--None--')	
		{
			customMessage('Please Select Remote object name.');
			clearValues();
            return;
		}
		Map<String, Schema.SObjectType> mapNameToSObjectType = Schema.getGlobalDescribe() ;
		Schema.SObjectType stdContactsObject = mapNameToSObjectType.get(strRemoteObject);
		
		objMetadata = SendRequest.getObjectMetadata(serverUrl, sessionId, strRemoteObject);
		if(stdContactsObject == null)
		{
			String strMsg = 'Requested Remote object is not available in current org. Please contact with Remote org Administrator or'+ 
							'<a style="color:red;cursor:pointer;text-align:right;" target="__blank"'+
							'href="../apex/DisplayRemoteObjectCustomFieldsDetail?surl='+serverUrl+'&sid='+sessionId+'&oname='+strRemoteObject+
							'">View Object Detail</a>';
			customMessage(strMsg);
            return;
		}
		createMultiPicklist();
	}
	
	
	public void createMultiPicklist()
	{
		lstRemoteObjectAllField.clear();
		
		for(FieldMetadata objFMD : objMetadata.fields)
        {
        	lstRemoteObjectAllField.add(new Selectoption(objFMD.Name, objFMD.Name) );
        	mapFieldAPIToField.put(objFMD.Name, objFMD);
        }
        lstRemoteObjectAllField.sort();
	}
	
	 public void addClassNameToTag()
	 {
	    if(!lstSelectedFromRemoteObjectAllFieldName.isEmpty())	
	    {
			Set<String> setAllClassNames = new Set<String>(); 
 	 		for(String strSelectedField : lstSelectedFromRemoteObjectAllFieldName)
 	 		{
	 	 		lstSelectedField.add(new Selectoption(strSelectedField, strSelectedField));
	 	 	}
	 	 	for(SelectOption tmpSelectOption : lstRemoteObjectAllField)
	 	 	{
	 	 		setAllClassNames.add(tmpSelectOption.getValue());     	 		
	 	 	}
	 	 	setAllClassNames.removeAll(lstSelectedFromRemoteObjectAllFieldName);
	 	 	lstRemoteObjectAllField.clear();
	 	 	for(String strClassName : setAllClassNames)
	 	 	{
	 	 		lstRemoteObjectAllField.add(new Selectoption(strClassName, strClassName));
	 	 	}
	 	 	lstSelectedFromRemoteObjectAllFieldName.clear();
	 	 	//lstSelectedField.sort();
	 	 	lstRemoteObjectAllField.sort();
	    }
		else
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please Select Field(s) name.'));
    }
     
    //Method to move the selected Fields . 
	public void removeClassNameFromTag()
	{
		if(!lstSelectedFieldName.isEmpty())
		{
			Set<String> setAllClassNames = new Set<String>(); 
 	 		for(String strSelectedClass : lstSelectedFieldName)
 	 		{
	 	 		lstRemoteObjectAllField.add(new Selectoption(strSelectedClass, strSelectedClass));
	 	 	}
	 	 	
	 	 	for(SelectOption tmpSelectOption : lstSelectedField)
	 	 	{
	 	 		setAllClassNames.add(tmpSelectOption.getValue());     	 		
	 	 	}
	 	 	
	 	 	setAllClassNames.removeAll(lstSelectedFieldName);
	 	 	lstSelectedField.clear();
	 	 	for(String strClassName : setAllClassNames)
	 	 	{
	 	 		lstSelectedField.add(new Selectoption(strClassName, strClassName));
	 	 	}
	 	 	
	 	 	//lstSelectedField.sort();
	 	 	lstRemoteObjectAllField.sort();
		}
		else
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'List is Empty.'));
	}
	
	private void clearValues()
	{
		mapFieldAPIToField.clear();
		lstRemoteObjectAllField.clear();
		lstSelectedFromRemoteObjectAllFieldName.clear();
		lstSelectedField.clear();
		lstSelectedFieldName.clear();
		lstColumn.clear();
		lstSobject.clear();
	}
}