/****************************************************************************
* Type               : Apex Class
* Name               : searchProductsController 
* Created by         : 
* Created Date       : 
* Last Modified By   : 
* Last Modified date : 18th Sept 2016
* Purpose            : This class is used to Search existing product.
                       - User can add those products in to their cart & abilitity to view their cart
                       - User can check his order history            
*******************************************************************************/
public class searchProductsController {
    public string strSearchProduct {get; set;}
    public List<productWithCategoryWrapper> lstProductWrapper{get; set;}
    Public List<productWithCategoryWrapper> lstSelectedProductWrapper {get; set;}
    Public List<orderWrapper> orderWrapperList {get; set;}
    public decimal decTotalPrice {get; set;}
    public string strAccName {get; set;}
    public Account objAccount {get; set;}
    
    // selection and filter 
    public list<String> AlphaList {get; set;}
    public String AlphaFilter {get; set;}
    public String SortFieldSave;
    String strProductSOQL;
    // Constructor
    public searchProductsController(){
        strSearchProduct = '';
        lstproductWrapper = new List<productWithCategoryWrapper>();
        
        strProductSOQL = 'select id, name, Available_Quantity__c, Unit_Price__c from Product2';
        string strOrderby = ' ORDER BY NAME ASC LIMIT 10000';
        string strSOQL = strProductSOQL + strOrderby;
        List<Product2> lstProduct = database.query(strSOQL);
        
        productWithCategoryWrapper objproductWCWrapper;
        objproductWCWrapper = new productWithCategoryWrapper();
        objproductWCWrapper.strProductCategoty = 'Test Category 1';
        productWrapper objproductWrapper;
        for(Product2 prd: lstProduct){
            objproductWrapper = new productWrapper();
            objproductWrapper.objProduct = prd;
            objproductWCWrapper.lstProduct.add(objproductWrapper);
        }
        lstproductWrapper.add(objproductWCWrapper);
        
        
        lstSelectedProductWrapper = new List<productWithCategoryWrapper>();
        loadOrderHistory();
        decTotalPrice = 0;
        
        // initialization alpha list
        AlphaList = new list<String> {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'Other', 'All'};
        SortFieldSave = SortField;
        
        // alpha filter, use page parameter or set default to all
        if (apexpages.currentpage().getparameters().get('alpha') == null) {
            AlphaFilter = 'All';
        } else {
            AlphaFilter = apexpages.currentpage().getparameters().get('alpha');
        }
        
        strAccName = '';
        if(apexpages.currentpage().getparameters().get('id') != null){
            string strAccId = apexpages.currentpage().getparameters().get('id');
            List<Account> accList = [select id, Name, Pharmacy_Name__c, License__c,Pharmacist_Name__c, Line_of_Credit__c, Balance__c from Account where id =: strAccId];
            if(!accList.isEmpty()){
                strAccName = accList[0].Name;
                objAccount = accList[0];
            }
        }
    }
    
    /***
    * ClearAccountSelectedSet - remove selected accounts and initialize counter
    ***/
    public PageReference ClearAll(){
        AlphaFilter = 'All';
        
        BuildQuery();
        return null;
    }
    
    /***
    * SortToggle - toggles the sorting of query from asc<-->desc
    ***/
    public void SortToggle() {
        SortDirection = SortDirection.equals('asc') ? 'desc NULLS LAST' : 'asc';
        // reset alpha filter and sort sequence when sorted field is changed
        if (SortFieldSave != SortField) {
            SortDirection = 'asc';
            AlphaFilter = 'All';
            SortFieldSave = SortField;
        }
        // run the query again
        BuildQuery();
    }
    
    /***
    * SortDirection - return sort direction. Default ascending(asc)
    ***/
    public String SortDirection {
        get { if (SortDirection == null) {  SortDirection = 'asc'; } return SortDirection;  }
        set;
    }
    
    /***
    * SortField - return sort by field. Default to Name
    ***/
    public String SortField {
        get { if (SortField == null) {SortField = 'Name'; } return SortField;  }
        set; 
    }
    
    // Function used to load Order History
    public void loadOrderHistory(){
        List<Order> orderList = new List<Order>();
        // Get existing Orders
        orderList = [select id, Name, (select id, Fulfillment_Date__c, UnitPrice, Quantity, Pricebookentry.Product2Id, Pricebookentry.Product2.Name, Shipping_Status__c from OrderItems) from Order];
        
        // Fill existing orders in to list
        orderWrapperList = new List<orderWrapper>();
        orderWrapper objorderWrapper;
        for(Order ord: orderList){
            for(OrderItem oli: ord.OrderItems){
                objorderWrapper = new orderWrapper();
                objorderWrapper.strProdId = oli.Pricebookentry.Product2Id;
                objorderWrapper.strProdTitle = oli.Pricebookentry.Product2.Name;
                objorderWrapper.decQuantity = oli.Quantity;
                objorderWrapper.decPrice = oli.UnitPrice;
                objorderWrapper.fulfillmentDate = oli.Fulfillment_Date__c;
                objorderWrapper.strStatus = oli.Shipping_Status__c;
                orderWrapperList.add(objorderWrapper);
            }
        }
    }
    
    // Function used to Search existing poroduct
    public void searchProduct(){
        lstproductWrapper = new List<productWithCategoryWrapper>();
        string strTempSearcPrd = '%' + strSearchProduct + '%';
        // Get existing products based on user input
        List<Product2> lstProduct = [select id, name, Available_Quantity__c, Unit_Price__c from Product2 where name like: strTempSearcPrd];
        productWithCategoryWrapper objproductWCWrapper;
        objproductWCWrapper = new productWithCategoryWrapper();
        objproductWCWrapper.strProductCategoty = 'Test Category 1';
        productWrapper objproductWrapper;
        for(Product2 prd: lstProduct){
            objproductWrapper = new productWrapper();
            objproductWrapper.objProduct = prd;
            objproductWCWrapper.lstProduct.add(objproductWrapper);
            
        }
        lstproductWrapper.add(objproductWCWrapper);
    }
    
    // Function used to add Selected product in to Cart
    public void addToCart(){
        Integer intRowIndex = integer.valueOf(apexpages.currentpage().getparameters().get('rowIndex'));
        Integer intCatIndex = integer.valueOf(apexpages.currentpage().getparameters().get('catIndex'));
        Boolean blnProductAdded = false;
        if(intRowIndex != null && intCatIndex != null){
            if(lstSelectedProductWrapper.size() > 0 && lstSelectedProductWrapper.size() >= intCatIndex){
                productWrapper objproductWrapper = new productWrapper();
                objproductWrapper = lstproductWrapper[intCatIndex].lstProduct[intRowIndex];
                  
                for(Integer i = 0; i < lstSelectedProductWrapper.size(); i++){
                    for(Integer j = 0; j < lstSelectedProductWrapper[i].lstSelProduct.size(); j++){
                        if(lstSelectedProductWrapper[i].lstSelProduct[j].objProduct.id == lstproductWrapper[intCatIndex].lstProduct[intRowIndex].objProduct.id){
                            lstSelectedProductWrapper[i].lstSelProduct[j] = lstproductWrapper[intCatIndex].lstProduct[intRowIndex];
                            lstSelectedProductWrapper[i].lstSelProduct[j].isAddedtoCart = true;
                            blnProductAdded = true;
                        }
                    }
                }
                if(blnProductAdded == false){
                    objproductWrapper.isAddedtoCart = true;
                    lstSelectedProductWrapper[intCatIndex].lstSelProduct.add(objproductWrapper);
                }
            }else{
                productWithCategoryWrapper objproductWCWrapper = new productWithCategoryWrapper();
                objproductWCWrapper = lstproductWrapper[intCatIndex];
                
                productWrapper objproductWrapper = new productWrapper();
                objproductWrapper = objproductWCWrapper.lstProduct[intRowIndex];
                objproductWrapper.isAddedtoCart = true;
                objproductWCWrapper.lstSelProduct.add(objproductWrapper);
                
                lstSelectedProductWrapper.add(objproductWCWrapper);
            }
        }
        
        decTotalPrice = 0;
        for(productWithCategoryWrapper pwc: lstSelectedProductWrapper){
            for(productWrapper pw: pwc.lstSelProduct){
                if(pw.isAddedtoCart == true && pw.objProduct.Unit_Price__c != null && pw.decQuantity != null){
                    decTotalPrice += pw.objProduct.Unit_Price__c * pw.decQuantity;
                }
            }
        }
        system.debug('@@@@'+lstSelectedProductWrapper);
    }
    
    // Function used to remove existing product from Cart
    public void removeProducts(){
        Integer intRowIndex = integer.valueOf(apexpages.currentpage().getparameters().get('rowIndex'));
        Integer intCatIndex = integer.valueOf(apexpages.currentpage().getparameters().get('catIndex'));
        if(intRowIndex != null && intCatIndex != null){
            lstSelectedProductWrapper[intCatIndex].lstSelProduct.remove(intRowIndex);
            lstproductWrapper[intCatIndex].lstProduct[intRowIndex].isAddedtoCart = false;
            lstproductWrapper[intCatIndex].lstProduct[intRowIndex].decQuantity = 0;
        }
        
        decTotalPrice = 0;
        for(productWithCategoryWrapper pwc: lstSelectedProductWrapper){
            for(productWrapper pw: pwc.lstSelProduct){
                if(pw.isAddedtoCart == true && pw.objProduct.Unit_Price__c != null && pw.decQuantity != null){
                    decTotalPrice += pw.objProduct.Unit_Price__c * pw.decQuantity;
                }
            }
        }
    }
    
    /***
    * BuildQuery - build query command for list selection change
    ***/
    public void BuildQuery() {
        String QueryWhere = '';
        if (AlphaFilter == null || AlphaFilter.trim().length() == 0) {
            AlphaFilter = 'All';
        }
        
        if (AlphaFilter == 'Other') {
            QueryWhere = BuildWhere(QueryWhere, '(' + String.escapeSingleQuotes(SortField) + ' < \'A\' OR ' + 
                                    String.escapeSingleQuotes(SortField) + ' > \'Z\') AND (NOT ' + 
                                    String.escapeSingleQuotes(SortField) + ' LIKE \'Z%\') ');
        } else if (AlphaFilter != 'All') {
            QueryWhere = BuildWhere(QueryWhere, '(' + String.escapeSingleQuotes(SortField) + ' LIKE \'' + String.escapeSingleQuotes(AlphaFilter) + '%\')' );
        }
        
        string strSOQL = strProductSOQL + QueryWhere + ' ORDER BY  ' + String.escapeSingleQuotes(SortField) + ' ' + String.escapeSingleQuotes(SortDirection) + ' LIMIT 10000';
        system.debug('@@@@@@@@@@@'+strSOQL);
        List<Product2> lstProduct = database.query(strSOQL);
        
        Integer intCatIndex = integer.valueOf(apexpages.currentpage().getparameters().get('catIndex'));
        if(intCatIndex >= 0){
            lstproductWrapper[intCatIndex].lstProduct = new List<productWrapper>();
            productWrapper objproductWrapper;
            for(Product2 prd: lstProduct){
                objproductWrapper = new productWrapper();
                objproductWrapper.objProduct = prd;
                lstproductWrapper[intCatIndex].lstProduct.add(objproductWrapper);
            }
        }
        
    }
    
    /***
    * BuildWhere - build soql string for where criteria 
    ***/
    public String BuildWhere(String QW, String Cond) {
        if (QW == '') {
            return ' WHERE ' + Cond;
        } else {
            return QW + ' AND ' + Cond;
        }
    }
    
    
    // Function used to redirect user to Order History page
    public pagereference gotoOrderHistoryPage(){
        pagereference pr = new pagereference('/apex/orderHistory');
        //pr.setRedirect(true);
        return pr;
    }
    
    // Function used to redirect user to Search Product page
    public pagereference gotoSearchProductPage(){
        pagereference pr = new pagereference('/apex/searchProducts');
        //pr.setRedirect(true);
        return pr;
    }
    
    // Function used to redirect user to View Cart page
    public pagereference gotoViewCartPage(){
        pagereference pr = new pagereference('/apex/viewCartPage');
        //pr.setRedirect(true);
        return pr;
    }
    
    // Wrapper class for Product Category and Product
    public class productWithCategoryWrapper{
        public string strProductCategoty {get; set;}
        
        public List<productWrapper> lstProduct {get; set;}
        public List<productWrapper> lstSelProduct {get; set;}
        public productWithCategoryWrapper(){
            lstProduct = new List<productWrapper>();
            lstSelProduct = new List<productWrapper>();
        }
    }
    
    // Wrapper class for Product
    public class productWrapper{
        public Product2 objProduct {get; set;}
        public Decimal decQuantity {get; set;}
        public boolean isAddedtoCart {get; set;}
    }
    
    // Wrapper class for Orders
    public class orderWrapper{
        public string strProdId {get; set;}
        public string strProdTitle {get; set;}
        public Decimal decQuantity {get; set;}
        public Decimal decPrice {get; set;}
        public date fulfillmentDate {get; set;}
        public string strStatus {get; set;}
        
    }
}