Global class ProductSelectorInlineController
{
    // Constructor
    public ProductSelectorInlineController() {
        executeOnLoad();        
    }
    
    // This fuction executes on visualforce page load
    public void executeOnLoad(){
        isEditQLIbuttonDisplay = false;
        string isInline = ApexPages.currentPage().getParameters().get('inline');
        tableHeight = '600px';
        // condition to identify user is on inline page or not
        if(isInline == '1'){
            isEditQLIbuttonDisplay = true;
            tableHeight = '200px';
        }
        if( Apexpages.currentPage().getUrl().contains('QuoteGridPage')){
            isEditQLIbuttonDisplay = true;
        }
        // Get quote record id
        quoteID = ApexPages.currentPage().getParameters().get('Id');
        System.debug('quoteID: ' + quoteID);
        if(!String.isBlank(quoteID))
        {
            objQuote = [Select Id, Name,Agreement__c, Grand_Total__c, status__c, Opportunity_Name__r.Pricebook2Id, Price_Book__c From Quote__c Where Id = :quoteID Limit 1];
        }    
    }
    
    // Used to store quote record id
    public String quoteID {get;set;}
    public Quote__c objQuote {get;set;}
    public List<Quote_Line_Items__c> quoteLineItemsList {get;set;}
    public String quoteLineIdToRemove {get; set;}
    // New variable to identify user is on inline page or not
    public boolean isEditQLIbuttonDisplay {get; set;}
    public string tableHeight {get; set;}
    
    // Constructor
    public ProductSelectorInlineController(ApexPages.StandardController stdCtrl){        
        executeOnLoad();      
    }
    
    // This function used to display quote line item records in to visualforce page
    @RemoteAction
    global static List<Quote_Line_Items__c> fetchItems(String qid){
        // added QuoteLineItem fields in to SOQL query to display it on list
        List<Quote_Line_Items__c> items = new List<Quote_Line_Items__c>([Select Id, Sort_Sequence_Number__c, ACEWeb_Selector__r.Product_Name_Lookup2__r.ProductCode, Line_Item_Number__c, Selection_Box__c,Internal_generated_line_number__c,ACEWeb_Selector__c
                                                                   ,Icon_to_access_detail_view_of_product__c,Icon_to_edit_configuration__c
                                                                   ,Group_Number__c,Order_Quantity__c,Unit_of_Measure__c,Designation__c,Price_Discount_Category__c
                                                                   ,Shipping_location__c,Unit_List_Price__c,Extended_list_Price__c,Purchaser_Profile_Multiplier__c
                                                                   ,Customer_Profile_Multiplier__c,Normal_Net_Multiplier__c,Extended_Net_Multiplier__c,Normal_Net_Extended_Price__c
                                                                   ,Product_Name_Lookup2__r.product_category__r.Name,Price_Determination__c, System_Recommended_Fix__c, Requested_Sell_Net_Multiplier__c
                                                                   ,Fix_Requested_Price__c, Proposed_Sell_Net_Multiplier__c, Proposed_Extended_Price__c, Authorized_Selling_Net_Multiplier__c
                                                                   ,Warranty__c, FOB__c, Lead_Time__c, Quote_Name__c,Product_Name_Lookup2__c,Product_Name_Lookup2__r.Name,Product_Name_Lookup2__r.ProductCode
                                                                   ,Product_Name_Lookup2__r.Description, Description__c,Discount__c,ListPrice__c,Quantity__c,Subtotal__c,Total_Price__c,
                                                                  
                                                                   (select Id, Sort_Sequence_Number__c, ACEWeb_Selector__r.Product_Name_Lookup2__r.ProductCode, Line_Item_Number__c, Selection_Box__c,Internal_generated_line_number__c,ACEWeb_Selector__c
                                                                   ,Icon_to_access_detail_view_of_product__c,Icon_to_edit_configuration__c
                                                                   ,Group_Number__c,Order_Quantity__c,Unit_of_Measure__c,Designation__c,Price_Discount_Category__c
                                                                   ,Shipping_location__c,Unit_List_Price__c,Extended_list_Price__c,Purchaser_Profile_Multiplier__c
                                                                   ,Customer_Profile_Multiplier__c,Normal_Net_Multiplier__c,Extended_Net_Multiplier__c,Normal_Net_Extended_Price__c
                                                                   ,Product_Name_Lookup2__r.product_category__r.Name,Price_Determination__c, System_Recommended_Fix__c, Requested_Sell_Net_Multiplier__c
                                                                   ,Fix_Requested_Price__c, Proposed_Sell_Net_Multiplier__c, Proposed_Extended_Price__c, Authorized_Selling_Net_Multiplier__c
                                                                   ,Warranty__c, FOB__c, Lead_Time__c, Quote_Name__c,Product_Name_Lookup2__c,Product_Name_Lookup2__r.Name,Product_Name_Lookup2__r.ProductCode
                                                                   ,Product_Name_Lookup2__r.Description, Description__c,Discount__c,ListPrice__c,Quantity__c,Subtotal__c,Total_Price__c                                                                                                                                      
                                                                    from Quote_Line_Items__r)
                                                                    
                                                             From Quote_Line_Items__c Where Quote_Name__c = :qid order by Sort_Sequence_Number__c]);

        return items;
        
        //return [Select Id,Quote_Name__c,PricebookEntryId,Product2Id,Product_Name_Lookup2__r.Name,Description__c,Discount__c,ListPrice,Quantity__c,Subtotal,PricebookEntry.UnitPrice,UnitPrice,TotalPrice From QuoteLineItem Where Quote_Name__c = :qid];
    }

    @RemoteAction
    global static Quote_Line_Items__c addItem(String quoteId, PricebookEntry pbe, String quantity) {

        system.debug('#### quoteId: ' + quoteId);
        system.debug('#### pbe: ' + pbe);
        system.debug('#### quantity: ' + quantity);

        Decimal grandTotal;
        if(pbe != null && !String.isBlank(quantity)) {
            PricebookEntry objPBE = pbe;
            Quote_Line_Items__c qli = new Quote_Line_Items__c();
            qli.Quote_Name__c = quoteId;
            qli.Product_Name_Lookup2__c = objPBE.Product2Id;
            //qli.PricebookEntryId = pbeID;
            qli.Unit_List_Price__c = objPBE.UnitPrice;
            qli.Quantity__c = Decimal.valueOf(quantity);
            insert qli;
            //Quote__c objQuote = [Select Grand_Total__c From Quote__c Where Id = :qid Limit 1];
            //grandTotal = objQuote.Grand_Total__c;

            List<Quote_Line_Items__c> items = new List<Quote_Line_Items__c>([Select Id, Sort_Sequence_Number__c, ACEWeb_Selector__r.Product_Name_Lookup2__r.ProductCode, Line_Item_Number__c, Selection_Box__c,Internal_generated_line_number__c,ACEWeb_Selector__c
                    ,Icon_to_access_detail_view_of_product__c,Icon_to_edit_configuration__c
                    ,Group_Number__c,Order_Quantity__c,Unit_of_Measure__c,Designation__c,Price_Discount_Category__c
                    ,Shipping_location__c,Unit_List_Price__c,Extended_list_Price__c,Purchaser_Profile_Multiplier__c
                    ,Customer_Profile_Multiplier__c,Normal_Net_Multiplier__c,Extended_Net_Multiplier__c,Normal_Net_Extended_Price__c
                    ,Product_Name_Lookup2__r.product_category__r.Name,Price_Determination__c, System_Recommended_Fix__c, Requested_Sell_Net_Multiplier__c
                    ,Fix_Requested_Price__c, Proposed_Sell_Net_Multiplier__c, Proposed_Extended_Price__c, Authorized_Selling_Net_Multiplier__c
                    ,Warranty__c, FOB__c, Lead_Time__c, Quote_Name__c,Product_Name_Lookup2__c,Product_Name_Lookup2__r.Name,Product_Name_Lookup2__r.ProductCode
                    ,Product_Name_Lookup2__r.Description, Description__c,Discount__c,ListPrice__c,Quantity__c,Subtotal__c,Total_Price__c,

            (select Id, Sort_Sequence_Number__c, ACEWeb_Selector__r.Product_Name_Lookup2__r.ProductCode, Line_Item_Number__c, Selection_Box__c,Internal_generated_line_number__c,ACEWeb_Selector__c
                    ,Icon_to_access_detail_view_of_product__c,Icon_to_edit_configuration__c
                    ,Group_Number__c,Order_Quantity__c,Unit_of_Measure__c,Designation__c,Price_Discount_Category__c
                    ,Shipping_location__c,Unit_List_Price__c,Extended_list_Price__c,Purchaser_Profile_Multiplier__c
                    ,Customer_Profile_Multiplier__c,Normal_Net_Multiplier__c,Extended_Net_Multiplier__c,Normal_Net_Extended_Price__c
                    ,Product_Name_Lookup2__r.product_category__r.Name,Price_Determination__c, System_Recommended_Fix__c, Requested_Sell_Net_Multiplier__c
                    ,Fix_Requested_Price__c, Proposed_Sell_Net_Multiplier__c, Proposed_Extended_Price__c, Authorized_Selling_Net_Multiplier__c
                    ,Warranty__c, FOB__c, Lead_Time__c, Quote_Name__c,Product_Name_Lookup2__c,Product_Name_Lookup2__r.Name,Product_Name_Lookup2__r.ProductCode
                    ,Product_Name_Lookup2__r.Description, Description__c,Discount__c,ListPrice__c,Quantity__c,Subtotal__c,Total_Price__c
            from Quote_Line_Items__r)

            From Quote_Line_Items__c Where Quote_Name__c = :quoteId AND Id = :qli.id order by Sort_Sequence_Number__c]);

            return items[0];
        }
        //return grandTotal;
        return null;
    }
    
    // This function is used to remove/delete selected quote line items
    // Added logic to remove multiple quote line items as per user selection - Serge Kandukuri 
    @RemoteAction
    global static Decimal removeItem(String quoteID, String qliID)
    {
        System.debug('### quoteId: ' + quoteID);
        System.debug('### qliID: ' + qliID);
        Decimal grandTotal;
        if(!String.isBlank(qliID))
        {
            // Get Selected Quote Line Items for delete
            set<String> sQLIId = new set<String>();
            string[] arrQLIId = qliID.split(',');
            for(String str: arrQLIId){
                sQLIId.add(str);
            }
            
            List<Quote_Line_Items__c> qliList = [Select Id From Quote_Line_Items__c Where Id IN: sQLIId];
            delete qliList;
           
            Quote__c objQuote = [Select GrandTotal__c From Quote__c Where Id = :quoteID Limit 1];
            grandTotal = objQuote.GrandTotal__c;
        }
        return grandTotal;
    }

    @RemoteAction
    global static List<PricebookEntryWithQty> searchProductsWithQty(String searchTerm, String pbID)
    {

        System.debug('#### Price Book Id: ' + pbID);

        if (string.isBlank(pbID)) {
            throw new MissingArgumentException('Price Book not specified.');
        }

        searchTerm = '%' + searchTerm + '%';
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

    global class MissingArgumentException extends Exception {

    }

    global class PricebookEntryWithQty{
        global PricebookEntry pbe {get; set;}
        global Integer qty {get; set;}
    }

    public string strSortSequenceOrder {get; set;}
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
    
    // Added new function to redirect to Quote
    public pagereference QuotePageRedirect(){
        UpdateSortSeqNumber();
               
        // pagereference pr = new pagereference('/apex/QuoteGridPage?id=' + quoteID );
        pagereference pr = new pagereference('/' + quoteID ); // Updated by Serge Kandukuri :- 09/22/2016
        return pr;
    }
}