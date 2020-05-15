public class PDFDownloader {

    // called from trigger
 
    public static string download() {
        PageReference ref = Page.testPage;

        Blob b = ref.getContentAsPDF();
        system.debug('########'+b);
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'binaryPDF.pdf';
        objAttachment.ParentId = '001i000001Sl1iP';
        objAttachment.ContentType = '.pdf';
        
        objAttachment.Body = b;
        //insert objAttachment;
        return null;
    }

}