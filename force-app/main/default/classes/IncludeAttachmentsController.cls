global class IncludeAttachmentsController {

/* Variables and Constants */

global String PageContents{ get; set; }
global String contactObjectId{ get; set {
    UpdateContents(value);
} }

public void UpdateContents(String contactObjectID) 
{
    try {
        PageReference pageRef = Page.Invoice;
        pageRef.getParameters().put('contactId', contactObjectID);
    
        PageContents = pageRef.getContent().toString().replace('<html style="display:none !important;">', '<html>');
    } catch(exception ex) { 
        PageContents = 'An error has occurred while trying to generate this invoice.  Please contact customer service.';
    }
}
}