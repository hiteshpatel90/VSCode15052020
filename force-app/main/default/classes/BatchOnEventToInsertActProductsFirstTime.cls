/******************************************************************************************
** Ameriprise Project
*******************************************************************************************
** Class Name:BatchOnEventToInsertActProductsFirstTime 
** Description: This batch class is executed only once during the cutover to insert the activity Products records for the Events created b/w 1/1/2014 till the Products re-design is deployed
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
global class BatchOnEventToInsertActProductsFirstTime implements Database.Batchable<sObject>{
    global final String Query;
    global BatchOnEventToInsertActProductsFirstTime (String q){    
        this.query = q;
    }    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }    
    global void execute(Database.BatchableContext BC, List<Event> scope){    
        List<Event> EventList = new List<Event>();
        Map<Id,String> EventProductsMap = new Map<Id,String>();
        Map<Id,Event> EventMap = new Map<Id,Event>();
        Map<Id,List<String>> EventIdProductListMap = new Map<Id,List<String>>(); 
        Map<String,Id> ProductMap= new Map<String,Id>();
        List<String> productlist = new list<String>();
        Set<String> UnqiueProducts = new Set<String>();        
        for( Event e : scope){
            System.debug('e.Products_Discussed__c'+e.Products_Discussed__c);            
            if(e.Products_Discussed__c!=null && !e.Products_Discussed__c.equals('No Products Discussed')){
                EventProductsMap.put(e.id, e.products_discussed__c);
                EventMap.put(e.id,e);
                System.debug('e.Products_Discussed__c'+e.Products_Discussed__c);            
            }            
        }
        System.debug('EventProductsMapCreate'+EventProductsMap); 
        if(EventProductsMap!=null && EventProductsMap.size()>0 ){
            System.debug('entered the insert block ');            
            for(String i :EventProductsMap.keyset()){
            String combinedProducts = EventProductsMap.get(i);            
                if(combinedProducts !=null && combinedProducts.contains(';')){                
                    String [] ProductsListPerEvent=new String[combinedProducts.split(';').size()];
                    ProductsListPerEvent=combinedProducts.split(';');
                    EventIdProductListMap.put(i,ProductsListPerEvent);
                    UnqiueProducts.addall(ProductsListPerEvent);                
                }else if(combinedProducts !=null ){
                    System.debug('combinedProducts'+combinedProducts);
                    String [] ProductsListPerEvent=new String[] {combinedProducts};
                    System.debug('ProductsListPerEvent'+ProductsListPerEvent);
                    System.debug('ProductsListPerEvent after assignment'+ProductsListPerEvent);
                    EventIdProductListMap.put(i,ProductsListPerEvent);
                    UnqiueProducts.add(combinedProducts);
                    System.debug('EventIdProductListMap'+EventIdProductListMap);
                    System.debug('UnqiueProducts'+UnqiueProducts);                    
                }            
            }
            System.debug('EventIdProductListMap'+EventIdProductListMap);
            System.debug('UnqiueProducts'+UnqiueProducts);            
            List<Products__c> ProductObjList= [Select Id,Name,Fund_Short_Name__c  from Products__c where Fund_Short_Name__c in : UnqiueProducts];   
            for(Products__c p: ProductObjList){
                ProductMap.put(p.Fund_Short_Name__c,p.id);
            }            
            List<Activity_Products__c> apList= new List<Activity_Products__c >();
            for(Id i: EventIdProductListMap.keyset()){
                List<String>ProdList =EventIdProductListMap.get(i);
                for(String prod: ProdList){
                    Activity_Products__c apTemp= new Activity_Products__c();
                    aptemp.activityid__c=i;
                    aptemp.Is_Event__c=true;
                    aptemp.ActivityURL__c=URL.getSalesforceBaseUrl().toExternalForm()+'/'+i;
                    aptemp.ActivityId_ProductId_Combo_Key__c=i+'/'+ProductMap.get(prod);
                    aptemp.Products__c=ProductMap.get(prod);
                    aptemp.to_be_processed__c=true;
                    apList.add(aptemp);
                }            
            }
            //try{            
                if(apList!=null){            
                    list<DataBase.SaveResult> result_Lst=Database.insert(apList, false);
                }
           // }catch(Exception e){
           //     e.getmessage();//exceptions are thrown
           // }
        }
    }    
    global void finish(Database.BatchableContext BC){
    
    }
}