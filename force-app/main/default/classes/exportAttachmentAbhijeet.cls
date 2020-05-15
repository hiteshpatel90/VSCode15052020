public class exportAttachmentAbhijeet{

    public static string exportQuoteattachmentNew(){
        
        string strSessionId = logintoBigMachine.login();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');   
        req.setTimeout(60000);
        req.setEndpoint('http://actividentity.bigmachines.com/v1_0/receiver');
        req.setHeader('Content-Type', 'text/xml; charset=ISO-8859-4');      
        req.setHeader('SOAPAction', '""');
  
        req.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><bm:userInfo xmlns:bm="urn:soap.bigmachines.com"><bm:sessionId>' + strSessionId + '</bm:sessionId></bm:userInfo><bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category><bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com"><bm:schemaLocation>https://actividentity.bigmachines.com/bmfsweb/actividentity/schema/v1_0/commerce/transaction.xsd</bm:schemaLocation></bm:xsdInfo></soapenv:Header><soapenv:Body><bm:exportFileAttachments xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><bm:mode>content</bm:mode><bm:inline/><bm:attachments><bm:attachment><bm:document_number>1</bm:document_number><bm:variable_name>attachment1_quote</bm:variable_name></bm:attachment></bm:attachments><bm:transaction><bm:process_var_name>transaction</bm:process_var_name><bm:id>10021786</bm:id></bm:transaction></bm:exportFileAttachments></soapenv:Body></soapenv:Envelope>');
        HttpResponse res =  new Http().send(req);
        system.debug('response'+ res);
        system.debug('response'+ res.getBodyAsBlob());
        
        //Blob fileContents = res.getBodyAsBlob(); // blob[1297]
        String fileContents = res.getBody(); // blob[1297]
        //system.debug('@@@@@@@'+fileContents.toString());
    
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'AI File.pdf';
        objAttachment.ParentId = '001i000001Sl1iP';
        objAttachment.ContentType = '.pdf';
        
        Integer intFirstIndexofPDF = string.valueOf(fileContents).indexOf('%PDF-');
        Integer intLastIndexofPDF = string.valueOf(fileContents).lastindexOf('EOF');
        system.debug('########intFirstIndexofPDF '+intFirstIndexofPDF );
        system.debug('########intLastIndexofPDF '+intLastIndexofPDF );
        string bodysplit = res.getBody().substring(intFirstIndexofPDF , intLastIndexofPDF +3);
        system.debug('########body  '+bodysplit);
        //String encoded = EncodingUtil.urlDecode(strPDFbody, 'UTF-8');
        //objAttachment.Body = blob.valueOf(encoded);
        //objAttachment.Body = EncodingUtil.base64Decode(encoded);
        //string strbody = EncodingUtil.base64Encode(blob.valueOf(strPDFbody));
        //objAttachment.Body = blob.valueOf(strPDFbody); 
        
        //objAttachment.Body = blob.valueOf(EncodingUtil.base64Encode(fileContents)); // System.StringException: Unrecognized base64 character: %
        //blob body = EncodingUtil.base64Decode(bodysplit);
        //objAttachment.Body = body;
        //insert objAttachment;
        
                        
        return null;
       
    }
}