public class extsignQuote {
    public string strQuoteId;
    public List<wrapQuoteDocument> lstwrapQuoteDocument {get; set;}
    public extsignQuote(ApexPages.StandardController controller) {
        lstwrapQuoteDocument = new List<wrapQuoteDocument>();
        List<QuoteDocument> lstQuoteDocument = new List<QuoteDocument>();
        strQuoteId = apexpages.currentpage().getParameters().get('id');
        if(strQuoteId != null){
            lstQuoteDocument = [select id, Name from QuoteDocument where QuoteId =: strQuoteId];
            wrapQuoteDocument objwrapQuoteDocument;
            for(QuoteDocument qd: lstQuoteDocument){
                objwrapQuoteDocument = new wrapQuoteDocument();
                objwrapQuoteDocument.objQuoteDocument = qd;
                objwrapQuoteDocument.isSelQuotedoc = false;
                lstwrapQuoteDocument.add(objwrapQuoteDocument);
            }
        }
    }
    public class wrapQuoteDocument{
        public boolean isSelQuotedoc {get; set;}
        public QuoteDocument objQuoteDocument {get; set;}
    }

}