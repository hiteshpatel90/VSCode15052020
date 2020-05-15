/******************************************************************************************
** Ameriprise Project
*******************************************************************************************
** Class Name:BatchOnTaskToInsertActProductsFirstTime 
** Description: This batch class is executed only once during the cutover to insert the activity Products records for the Tasks created b/w 1/1/2014 till the Products re-design is deployed
** Version: 1.0
** 
**-----------------------------------------------------------------------------------------
**Modification Log:
**----------------
**Developer                  Date          Version               Description
**-----------------------------------------------------------------------------------------
**Divyashree M             30-Dec-2013         1.0                   Created
**-----------------------------------------------------------------------------------------
**Review Log:
**----------------
**Reviewer                  Date           Version                Comments
**------------------------------------------------------------------------------------------
**              
********************************************************************************************/
global class BatchOnTaskToInsertActProductsFirstTime implements Database.Batchable<sObject>{
    global final String Query;    
    global BatchOnTaskToInsertActProductsFirstTime (String q){    
        this.query = q;
    }    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }    
    global void execute(Database.BatchableContext BC, List<Task> scope){
        List<Task> TaskList = new List<Task>();
        Map<Id,String> TaskProductsMap = new Map<Id,String>();
        Map<Id,Task> TaskMap = new Map<Id,Task>();
        Map<Id,List<String>> TaskIdProductListMap = new Map<Id,List<String>>(); 
        Map<String,Id> ProductMap= new Map<String,Id>();
        List<String> productlist = new list<String>();
        Set<String> UnqiueProducts = new Set<String>();        
        for( Task e : scope){
            System.debug('e.Products_Discussed__c'+e.Products_Discussed__c);            
            if(e.Products_Discussed__c!=null && !e.Products_Discussed__c.equals('No Products Discussed')){
                TaskProductsMap.put(e.id, e.products_discussed__c);
                TaskMap.put(e.id,e);
                System.debug('e.Products_Discussed__c'+e.Products_Discussed__c);            
            }        
        }
        System.debug('TaskProductsMapCreate'+TaskProductsMap); 
        if(TaskProductsMap!=null && TaskProductsMap.size()>0 ){
            System.debug('entered the insert block ');            
            for(String i :TaskProductsMap.keyset()){
                String combinedProducts = TaskProductsMap.get(i);                
                if(combinedProducts !=null && combinedProducts.contains(';')){                
                    String [] ProductsListPerTask=new String[combinedProducts.split(';').size()];
                    ProductsListPerTask=combinedProducts.split(';');
                    TaskIdProductListMap.put(i,ProductsListPerTask);
                    UnqiueProducts.addall(ProductsListPerTask);                
                }else if(combinedProducts !=null ){
                    System.debug('combinedProducts'+combinedProducts);
                    String [] ProductsListPerTask=new String[] {combinedProducts};
                    System.debug('ProductsListPerTask'+ProductsListPerTask);
                    System.debug('ProductsListPerTask after assignment'+ProductsListPerTask);
                    TaskIdProductListMap.put(i,ProductsListPerTask);
                    UnqiueProducts.add(combinedProducts);
                    System.debug('TaskIdProductListMap'+TaskIdProductListMap);
                    System.debug('UnqiueProducts'+UnqiueProducts);                    
                }                
            }
            System.debug('TaskIdProductListMap'+TaskIdProductListMap);
            System.debug('UnqiueProducts'+UnqiueProducts);            
            List<Products__c> ProductObjList= [Select Id,Name,Fund_Short_Name__c  from Products__c where Fund_Short_Name__c in : UnqiueProducts];   
            for(Products__c p: ProductObjList){
                ProductMap.put(p.Fund_Short_Name__c,p.id);
            }            
            List<Activity_Products__c> apList= new List<Activity_Products__c >();
            for(Id i: TaskIdProductListMap.keyset()){
                List<String>ProdList =TaskIdProductListMap.get(i);
                for(String prod: ProdList){
                    Activity_Products__c apTemp= new Activity_Products__c();
                    aptemp.activityid__c=i;
                    aptemp.Is_Task__c=true;
                    aptemp.ActivityURL__c=URL.getSalesforceBaseUrl().toExternalForm()+'/'+i;
                    aptemp.ActivityId_ProductId_Combo_Key__c=i+'/'+ProductMap.get(prod);
                    aptemp.Products__c=ProductMap.get(prod);
                    aptemp.to_be_processed__c=true;
                    apList.add(aptemp);
                }            
            }
            try{            
                if(apList!=null){                
                    list<DataBase.SaveResult> result_Lst=Database.insert(apList, false);
                }
            }
            catch(Exception e){
                e.getmessage();//exceptions are thrown
            }
        }
    }    
    global void finish(Database.BatchableContext BC){
    
    }
}