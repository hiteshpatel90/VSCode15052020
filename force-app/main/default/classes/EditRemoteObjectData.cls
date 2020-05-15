public with sharing class EditRemoteObjectData
{
    public String recordId {get;set;}
    private String sessionId;
    private String strClientName;
    public sObject objSobject{get;set;}
    public String serverUrl {get;set;}
    public List<sObject> lstSobject{get;set;}
    public String strObjectName {get;set;}
    public String strSelectedFields {get;set;}
    public List<String> lstColumn {get;set;}
    
    private Map<String, String> mapFieldNameToName = new Map<String, String>();
    public EditRemoteObjectData()
    {
        try
        {
            lstColumn = new List<String>();
            List<sObject> lstSobject = new List<sObject>();
            mapFieldNameToFieldMetadata = new Map<String, FieldMetadata>();
            
            recordId = ApexPages.currentPage().getParameters().get('cid');
            sessionId = ApexPages.currentPage().getParameters().get('sid');
            serverUrl  = ApexPages.currentPage().getParameters().get('surl');
            strClientName = ApexPages.currentPage().getParameters().get('client');
            strObjectName = ApexPages.currentPage().getParameters().get('oname');
            strSelectedFields = ApexPages.currentPage().getParameters().get('fields');
            
            lstColumn.addAll(strSelectedFields.split(','));
            for(String strField : lstColumn)
                mapFieldNameToName.put(strField, strField);
            lstColumn.remove(0);
            
            objMetadata = SendRequest.getObjectMetadata(serverUrl, sessionId, strObjectName);
            for(FieldMetadata objFD : objMetadata.fields)
                mapFieldNameToFieldMetadata.put(objFD.Name, objFD);
                
            HttpRequest request = new HttpRequest();
            PageReference theUrl = new PageReference(serverUrl + '/services/data/v22.0/query/');
            theUrl.getParameters().put('q','Select '+ strSelectedFields +' From '+ strObjectName +' where Id=\''+ recordId +'\'');
            request = new HttpRequest();
            request.setEndpoint(theUrl.getUrl());
            request.setMethod('GET');
            request.setHeader('Authorization', 'OAuth ' + sessionId);
            
            String body;
            if(!Test.isRunningTest())
                body = (new Http()).send(request).getBody();
            else
                body = '{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Account","url":"/services/data/v22.0/sobjects/Account/0019000000YTG3HAAX"},"Id":"0019000000YTG3HAAX","Name":"GenePoint Test","CreatedBy":{"attributes":{"type":"User","url":"/services/data/v22.0/sobjects/User/00590000001pnanAAA"},"FirstName":"Archana"},"CreatedById":"00590000001pnanAAA"}]}';
    
            JSONParser parser = JSON.createParser(body);
            do
            {
                parser.nextToken();
            }while(parser.hasCurrentToken() && !'records'.equals(parser.getCurrentName()));
    
            parser.nextToken();
    
            lstSobject = (List<sObject>) parser.readValueAs(List<sObject>.class);
            objSobject = lstSobject[0];
        }
        catch(Exception e)
        {
            System.debug('-------------------Exception ---------------'+e);
        }
    }
    
    public Pagereference updateRecord()
    {
        try
        {
            //createNewSobject();
            String strJson = '';
            integer i = 0;
            lstColumn.remove(0);
            strJson = createNewSobject();
            
            System.debug('-----------------strJson strJson----'+strJson);
            String pServerUrl = serverUrl + '/services/data/v20.0/sobjects/' + strObjectName + '/' + recordId + '?_HttpMethod=PATCH' ;
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
         
         
            req.setEndpoint(pServerUrl);
            req.setMethod('POST');
            req.setHeader('Authorization', 'OAuth ' + sessionId);
            req.setTimeout(120000);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(strJson);
            if(!Test.isRunningTest())
                res = h.send(req);
                
            Pagereference Pg = new Pagereference('/apex/FetchRemoteObjectData');
            return pg;
        }
        catch(Exception e)
        {
            System.debug('-------------------------update Account Ex------'+e);
        }
        return null;
    }
    
    public Pagereference  CancelUpdate()
    {
        Pagereference Pg = new Pagereference('/apex/FetchRemoteObjectData');
        return pg;
    }
    
    private ObjectMetadata objMetadata;
    private Schema.SObjectType coverageObjectToken;
    public Map<String, FieldMetadata> mapFieldNameToFieldMetadata {get;set;}
    private String createNewSobject()
    {
        Map<String, Schema.SObjectType> sobjectTypes = Schema.getGlobalDescribe();
        coverageObjectToken = sObjectTypes.get(strObjectName);
        
        sObject coverageSobject = coverageObjectToken.newSObject();
        for(FieldMetadata objFD : objMetadata.fields)
        {
            if(mapFieldNameToName.containsKey(objFD.name))
            {
                if(objFD.updateable)
                    coverageSobject.put(objFD.name , objSobject.get(objFD.name));
            }
        }
        return String.valueOf(JSON.serialize(coverageSobject));
    }
}