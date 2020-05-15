public with sharing class ActivityProductsForEventRelatedList{
    public Event e{get; set;}    
    public List<Activity_Products__c> APList{get; set;}
    public List<Products__c> ProductsCompleteList {get; set;}    
    //123 added an instance varaible for the standard controller 12345
    private ApexPages.StandardController controller {get; set;}
    public ActivityProductsForEventRelatedList(ApexPages.StandardController controller) {    
        //initialize the stanrdard controller CCC
        this.controller = controller;
        this.e = (Event)controller.getRecord();        
        Id eId= this.e.id;   
        APList= new List<Activity_Products__c>();
        Set<Id> ProductList= new Set<Id>();
        System.debug('eId'+ eId);
        System.debug('this.e.Id'+ this.e.Id);        
        APList=[Select id, Products__c from activity_products__c where activityId__c=:eId and is_event__c=true];        
        for(Activity_Products__c a: APList){
            ProductList.add(a.Products__c);
        }
        ProductsCompleteList = new List<Products__c>();
        if(ProductList.size()>0){
            ProductsCompleteList =[Select name, id, product_type__c,Fund_Short_Name__c, Morningstar_Category__c from products__c where id=:ProductList];
        }    
    }
}