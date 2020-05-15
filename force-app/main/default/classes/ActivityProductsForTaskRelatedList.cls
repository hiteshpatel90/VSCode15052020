public with sharing class ActivityProductsForTaskRelatedList{
    public Task e{get; set;}
    public List<Activity_Products__c> APList{get; set;}    
    public List<Products__c> ProductsCompleteList {get; set;}    
    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
    public ActivityProductsForTaskRelatedList(ApexPages.StandardController controller) {    
        //initialize the stanrdard controller
        this.controller = controller;
        this.e = (Task)controller.getRecord(); 
        Id eId= this.e.id;   
        APList= new List<Activity_Products__c>();        
        Set<Id> ProductList= new Set<Id>();        
        APList=[Select id, Products__c from activity_products__c where activityId__c =:e.id and is_task__c=true];
        for(Activity_Products__c a: APList){        
            ProductList.add(a.Products__c);
        }
        ProductsCompleteList = new List<Products__c>();
        if(ProductList.size()>0){
            ProductsCompleteList =[Select name, id, product_type__c,Fund_Short_Name__c, Morningstar_Category__c from products__c where id=:ProductList];        
        }
    }    
}