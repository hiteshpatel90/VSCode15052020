public class CreaNewFatturaCtrl { 

      public Fattura__c fattura {get;set;}    
      private String idQuote;     
      public Quote prev {get;set;}   
      public List <QuoteLineItem> qli {get;set;}
      public Integer selectedIndex   {get;set;}
      Public QuoteLineItem quotelineitem{get;set;}
          
                                                             
     public CreaNewFatturaCTRL(ApexPages.StandardController stdcontroller) {
               
        idQuote= ApexPages.currentPage().getParameters().get('idQuote');
        this.fattura=(Fattura__c) stdController.getRecord();
        //fattura.preventivo__c = idQuote;
               
        qli = [SELECT Id, ListPrice, UnitPrice, Quantity, Importo_IVA__c, Importo_ancora_da_fatturare__c , Totale__c, Description FROM QuoteLineItem 
                WHERE Quote.Id = :idQuote]; 
     
        
        }
        
        
        
      public ApexPages.PageReference AddRow () {
                          
        QuoteLineItem quotelineitem = new quotelineitem();
          
         
        system.debug('====selectedIndex===='+selectedIndex);
        /*if(selectedIndex == qli.size()-1)
        {
            qli.add(quotelineitem);     
        }
        else
        {
            qli.add(selectedIndex+1, quotelineitem);     
        }*/
          
        qli.add(selectedIndex+1, quotelineitem);  
        return null; 
     }
         
                       
    public ApexPages.PageReference saveRecord() {
     insert fattura;
     return new PageReference('/'+fattura.id);
    }
    
    public ApexPages.PageReference cancelRecord() {
     return new PageReference('/'+idQuote);
    }
}