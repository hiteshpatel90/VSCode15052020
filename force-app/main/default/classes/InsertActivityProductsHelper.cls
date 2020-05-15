public with sharing class InsertActivityProductsHelper { 
    /**
    ***Author: Divya
    ***Description: 
    **/
    public static void InsertActivityProductsForInsert(Map<Id,String> EventProductsMap, Map<Id,Event> EventMap){    
        Map<Id,List<String>> EventIdProductListMap = new Map<Id,List<String>>(); 
        Map<String,Id> ProductMap= new Map<String,Id>();
        List<String> productlist = new list<String>();
        Set<String> UnqiueProducts = new Set<String>();
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
        try{        
            if(apList!=null){        
                list<DataBase.SaveResult> result_Lst=Database.insert(apList, false);
            }
        }catch(Exception e){
            e.getmessage();//exceptions are thrown
        }    
    }
    
    public static void InsertActivityProductsForUpdate(Map<Id,String> EventProductsMap,Map<Id,Event> EventMap){    
        Map<Id,List<String>> EventIdProductListMap = new Map<Id,List<String>>(); 
        Map<String,Id> ProductMap= new Map<String,Id>();
        List<String> productlist = new list<String>();
        Set<String> UnqiueProducts = new Set<String>();
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
        List<Products__c> ProductObjList= [Select Id,Name from Products__c where name in : UnqiueProducts];   
        for(Products__c p: ProductObjList){
            ProductMap.put(p.name,p.id);
        }        
        List<Activity_Products__c> apList= new List<Activity_Products__c >();
        for(Id i: EventIdProductListMap.keyset()){
            List<String>ProdList =EventIdProductListMap.get(i);
            for(String prod: ProdList){
                Activity_Products__c apTemp= new Activity_Products__c();
                aptemp.activityid__c=i;
                aptemp.Is_Event__c=true;
                aptemp.ActivityId_ProductId_Combo_Key__c=i+'/'+ProductMap.get(prod);
                aptemp.ActivityURL__c=URL.getSalesforceBaseUrl().toExternalForm()+'/'+i;
                aptemp.Products__c=ProductMap.get(prod);
                aptemp.to_be_processed__c=true;                
                apList.add(aptemp);
            }        
        }
        try{        
            if(apList!=null){            
                list<DataBase.UpsertResult> result_Lst=Database.upsert(apList,Activity_Products__c.ActivityId_ProductId_Combo_Key__c, false);
            }
        }
        catch(Exception e){
            e.getmessage();//exceptions are thrown
        }    
    }    
    //for task insert
    public static void InsertActivityProductsForTaskInsert(Map<Id,String> TaskProductsMap, Map<Id,Task> TaskMap){    
        Map<Id,List<String>> TaskIdProductListMap = new Map<Id,List<String>>(); 
        Map<String,Id> ProductMap= new Map<String,Id>();
        List<String> productlist = new list<String>();
        Set<String> UnqiueProducts = new Set<String>();
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
    //for task update    
    public static void InsertActivityProductsForTaskUpdate(Map<Id,String> TaskProductsMap,Map<Id,Task> TaskMap){    
        Map<Id,List<String>> TaskIdProductListMap = new Map<Id,List<String>>(); 
        Map<String,Id> ProductMap= new Map<String,Id>();
        List<String> productlist = new list<String>();
        Set<String> UnqiueProducts = new Set<String>();
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
        List<Products__c> ProductObjList= [Select Id,Name from Products__c where name in : UnqiueProducts];   
        for(Products__c p: ProductObjList){
            ProductMap.put(p.name,p.id);
        }        
        List<Activity_Products__c> apList= new List<Activity_Products__c >();
        for(Id i: TaskIdProductListMap.keyset()){
            List<String>ProdList =TaskIdProductListMap.get(i);
            for(String prod: ProdList){
                Activity_Products__c apTemp= new Activity_Products__c();
                aptemp.activityid__c=i;
                aptemp.Is_Task__c=true;
                aptemp.ActivityId_ProductId_Combo_Key__c=i+'/'+ProductMap.get(prod);
                aptemp.ActivityURL__c=URL.getSalesforceBaseUrl().toExternalForm()+'/'+i;
                aptemp.Products__c=ProductMap.get(prod);
                aptemp.to_be_processed__c=true;                
            apList.add(aptemp);
            }
        }
        try{        
            if(apList!=null){            
                list<DataBase.UpsertResult> result_Lst=Database.upsert(apList,Activity_Products__c.ActivityId_ProductId_Combo_Key__c, false);
            }
        }
        catch(Exception e){
            e.getmessage();//exceptions are thrown
        }    
    }
}