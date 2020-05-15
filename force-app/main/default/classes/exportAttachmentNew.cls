public class exportAttachmentNew{

    public static string exportQuoteattachmentNew(){
        
        string strSessionId = logintoBigMachine.login();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');   
        req.setTimeout(60000);
        req.setEndpoint('https://actividentity.bigmachines.com/v1_0/receiver');
        req.setHeader('Content-Type', 'text/xml');        
        req.setHeader('SOAPAction', '""');
        //req.setHeader('Content-disposition','attachment; filename=someFile.pdf'); 
      
        req.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><bm:userInfo xmlns:bm="urn:soap.bigmachines.com"><bm:sessionId>' + strSessionId + '</bm:sessionId></bm:userInfo><bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category><bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com"><bm:schemaLocation>https://actividentity.bigmachines.com/bmfsweb/actividentity/schema/v1_0/commerce/transaction.xsd</bm:schemaLocation></bm:xsdInfo></soapenv:Header><soapenv:Body><bm:exportFileAttachments xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><bm:mode>content</bm:mode><bm:inline/><bm:attachments><bm:attachment><bm:document_number>1</bm:document_number><bm:variable_name>attachment1_quote</bm:variable_name></bm:attachment></bm:attachments><bm:transaction><bm:process_var_name>transaction</bm:process_var_name><bm:id>10021786</bm:id></bm:transaction></bm:exportFileAttachments></soapenv:Body></soapenv:Envelope>');
        HttpResponse res =  new Http().send(req);
        system.debug('response'+ res);
        system.debug('response'+ res.getBody());
        
        String fileContents = res.getBody();
        system.debug('@@@@@@@'+res.getBody());
        
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'AI File';
        objAttachment.ParentId = '001i000001bpYqr';
        objAttachment.ContentType = 'pdf';
        
        Integer intFirstIndexofPDF = res.getBody().indexOf('%PDF-');
        Integer intLastIndexofPDF = res.getBody().indexOf('EOF');
        system.debug('########intFirstIndexofPDF '+intFirstIndexofPDF );
        system.debug('########intLastIndexofPDF '+intLastIndexofPDF );
        string strPDFbody = res.getBody().substring(intFirstIndexofPDF, intLastIndexofPDF + 3);
        system.debug('########'+strPDFbody);
        

        string strbody = EncodingUtil.base64Encode(blob.valueOf(strPDFbody.escapeUnicode()));
        objAttachment.Body = blob.valueOf(strPDFbody); 
        
        insert objAttachment;
        
                        
        return null;
       
    }
}