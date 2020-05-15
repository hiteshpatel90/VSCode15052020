public class ProductSelectorController
{
    public String quoteID {get;set;}
    public Quote__c objQuote {get;set;}
    
    public static Integer quantity {get; set;}
    public string strSortSequenceOrder {get; set;}
    public ProductSelectorController()
    {
        quoteID = ApexPages.currentPage().getParameters().get('Id');
        System.debug('quoteID: ' + quoteID);
        if(!String.isBlank(quoteID))
        {
            objQuote = [Select Id, Name, Grand_Total__c, Price_Book__c, Status__c From Quote__c Where Id = :quoteID Limit 1];
        }
    }
    
    @RemoteAction
    public static List<Quote_Line_Items__c> fetchItems(String qid)
    {
        List<Quote_Line_Items__c> items = new List<Quote_Line_Items__c>([Select Id, Sort_Sequence_Number__c, ACEWeb_Selector__r.Product_Name_Lookup2__r.ProductCode, Line_Item_Number__c, Selection_Box__c,Internal_generated_line_number__c,ACEWeb_Selector__c
                                                                   ,Icon_to_access_detail_view_of_product__c,Icon_to_edit_configuration__c, Authorize_Unit_Selling_Net_Price_Formula__c
                                                                   ,Group_Number__c,Order_Quantity__c,Unit_of_Measure__c,Designation__c,Price_Discount_Category__c, Product_Name_Lookup2__r.Unit_Of_Measure__c
                                                                   ,Shipping_location__c,Unit_List_Price__c,Extended_list_Price__c,Purchaser_Profile_Multiplier__c, Normal_Net_Extended_Price_Formula__c
                                                                   ,Customer_Profile_Multiplier__c,Normal_Net_Multiplier__c,Extended_Net_Multiplier__c,Normal_Net_Extended_Price__c
                                                                   ,Product_Name_Lookup2__r.product_category__r.Name,Price_Determination__c, System_Recommended_Fix__c, Requested_Sell_Net_Multiplier__c
                                                                   ,Fix_Requested_Price__c, Proposed_Sell_Net_Multiplier__c, Proposed_Extended_Price__c, Authorized_Selling_Net_Multiplier__c
                                                                   ,Warranty__c, FOB__c, Lead_Time__c, Quote_Name__c,Product_Name_Lookup2__c,Product_Name_Lookup2__r.Name,Product_Name_Lookup2__r.ProductCode, Extended_List_Price_Formula__c
                                                                   ,Product_Name_Lookup2__r.Description, Description__c,Discount__c,ListPrice__c,Quantity__c,Subtotal__c,Total_Price__c,
                                                                  
                                                                   (select Id, Sort_Sequence_Number__c, ACEWeb_Selector__r.Product_Name_Lookup2__r.ProductCode, Line_Item_Number__c, Selection_Box__c,Internal_generated_line_number__c,ACEWeb_Selector__c
                                                                   ,Icon_to_access_detail_view_of_product__c,Icon_to_edit_configuration__c, Normal_Net_Extended_Price_Formula__c, Authorize_Unit_Selling_Net_Price_Formula__c
                                                                   ,Group_Number__c,Order_Quantity__c,Unit_of_Measure__c,Designation__c,Price_Discount_Category__c, Product_Name_Lookup2__r.Unit_Of_Measure__c
                                                                   ,Shipping_location__c,Unit_List_Price__c,Extended_list_Price__c,Purchaser_Profile_Multiplier__c
                                                                   ,Customer_Profile_Multiplier__c,Normal_Net_Multiplier__c,Extended_Net_Multiplier__c,Normal_Net_Extended_Price__c
                                                                   ,Product_Name_Lookup2__r.product_category__r.Name,Price_Determination__c, System_Recommended_Fix__c, Requested_Sell_Net_Multiplier__c
                                                                   ,Fix_Requested_Price__c, Proposed_Sell_Net_Multiplier__c, Proposed_Extended_Price__c, Authorized_Selling_Net_Multiplier__c
                                                                   ,Warranty__c, FOB__c, Lead_Time__c, Quote_Name__c,Product_Name_Lookup2__c,Product_Name_Lookup2__r.Name,Product_Name_Lookup2__r.ProductCode, Extended_List_Price_Formula__c
                                                                   ,Product_Name_Lookup2__r.Description, Description__c,Discount__c,ListPrice__c,Quantity__c,Subtotal__c,Total_Price__c                                                                                                                                      
                                                                    from Quote_Line_Items__r)
                                                                    
                                                             From Quote_Line_Items__c Where Quote_Name__c = :qid order by Sort_Sequence_Number__c]);
                                                             
        return items;
        //return [Select Id,QuoteId,PricebookEntryId,Product2Id,Product2.Name,Description,Discount,ListPrice,Quantity,Subtotal,PricebookEntry.UnitPrice,UnitPrice,TotalPrice From QuoteLineItem Where QuoteId = :qid];
    }
    
    @RemoteAction
    public static List<PricebookEntry> searchProducts(String searchTerm, String pbID)
    {
        searchTerm += '%';
        return [Select Id,Name,UnitPrice,IsActive,Pricebook2Id,Product2Id, Product2.Name, Product2.productCode, Product2.Category_ID__c, Product2.Family   
                From PricebookEntry Where (Name Like :searchTerm or Product2.productCode Like :searchTerm or Product2.SKU__c like :searchTerm) And IsActive = true And Pricebook2Id = :pbID];
    }

    public class MissingArgumentException extends Exception {

    }

    @RemoteAction
    public static List<PricebookEntryWithQty> searchProductsWithQty(String searchTerm, String pbID)
    {

        System.debug('#### Price Book Id: ' + pbID);

        if (string.isBlank(pbID)) {
            throw new MissingArgumentException('Price Book not specified.');
        }

        searchTerm += '%';
        List<PricebookEntryWithQty> pbeQtyList = new List<PricebookEntryWithQty>(); 
        List<PricebookEntry> pbeList = [Select Id,Name,UnitPrice,IsActive,Pricebook2Id,Product2Id, Product2.Designation__c, Product2.Category_ID__c, Product2.Name, Product2.productCode, Product2.Family   
                From PricebookEntry Where (Name Like :searchTerm or Product2.productCode Like :searchTerm) And IsActive = true And Pricebook2Id = :pbID LIMIT 50];
        for(PricebookEntry pbe : pbeList){
            PricebookEntryWithQty pbeQty = new PricebookEntryWithQty();
            pbeQty.pbe = pbe;
            pbeQtyList.add(pbeQty);
        }
        return pbeQtyList;
    }
    
    @RemoteAction
    public static Decimal addProduct(String qid, String pbeID, String qty)
    {
        Decimal grandTotal;
        if(!String.isBlank(qid) && !String.isBlank(pbeID))
        {
            PricebookEntry objPBE = [Select UnitPrice,Pricebook2Id,Product2Id From PricebookEntry Where IsActive = true And Id = :pbeID Limit 1];
            Quote_Line_Items__c qli = new Quote_Line_Items__c();
            qli.Quote_Name__c = qid;
            qli.Product_Name_Lookup2__c = objPBE.Product2Id;
            //qli.PricebookEntryId = pbeID;
            qli.Unit_List_Price__c = objPBE.UnitPrice;
            qli.Quantity__c = Decimal.valueOf(qty);
            insert qli;
            Quote__c objQuote = [Select Grand_Total__c From Quote__c Where Id = :qid Limit 1];
            grandTotal = objQuote.Grand_Total__c;
        }
        return grandTotal;
    }
    
    @RemoteAction
    public static Decimal removeItem(String quoteID, String qliID)
    {
        Decimal grandTotal;
        if(!String.isBlank(qliID))
        {
            Quote_Line_Items__c qli = [Select Id From Quote_Line_Items__c Where Id = :qliID Limit 1];
            delete qli;
            Quote__c objQuote = [Select Grand_Total__c From Quote__c Where Id = :quoteID Limit 1];
            grandTotal = objQuote.Grand_Total__c;
        }
        return grandTotal;
    }
    
    @RemoteAction
    public static Decimal updateItems(String quoteID, List<Quote_Line_Items__c> items)
    {
        Decimal grandTotal;
        if(!items.isEmpty())
        {
            update items;
            Quote__c objQuote = [Select Grand_Total__c From Quote__c Where Id = :quoteID Limit 1];
            grandTotal = objQuote.Grand_Total__c;
        }
        return grandTotal;
    }
    
     // Modify Sort Sequence Number base on Drag & Drop by user
    public void UpdateSortSeqNumber(){
        try{
            // Initalize list
            List<Quote_Line_Items__c> lstQuoteLIUpdate = new List<Quote_Line_Items__c>();
            Quote_Line_Items__c objQLI;
            system.debug('@@@@@@@@'+strSortSequenceOrder);
            JSONParser parser = JSON.createParser(strSortSequenceOrder);
            while (parser.nextToken() != null) {
                 if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                     String qliRecId = parser.getText();
                     objQLI = new Quote_Line_Items__c(id=qliRecId);
                     parser.nextToken();
                     
                     Decimal decSortSeqNum = decimal.valueOf(parser.getText());
                     objQLI.Sort_Sequence_Number__c = decSortSeqNum;
                     lstQuoteLIUpdate.add(objQLI);
                 }
            }
            
            if(!lstQuoteLIUpdate.isEmpty()){
                // update Quote line items
                update lstQuoteLIUpdate;
            }
        }catch (Exception ex){
            system.debug('Exception ex:- ' + ex.getMessage());
        }
        
    }
    
    
    public class PricebookEntryWithQty{
        public PricebookEntry pbe {get; set;}
        public Integer qty {get; set;}
    }
}