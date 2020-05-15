global class BatchOnProducts implements Database.Batchable<sObject>{
    //Global variable declaration   
    global final String Query;// Variable to hold Query string    
    //Constructor          
    global BatchOnProducts(String q){
        this.query = q;
    }    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }    
    global void execute(Database.BatchableContext BC, List<Product2> prod){
        List<String> prodname = new List<String>();
        Map<String,id> pro = new Map<String,id>();        
        for(Product2 p : prod){
            prodname.add(p.name);
            pro.put(p.name,p.id);
        }        
        List<Products__c> proname = [Select id,Fund_Short_Name__c,Product2_ID__c from Products__c where Fund_Short_Name__c in :prodname];
        List<Products__c> updateprod = new List<Products__c>();        
        for (Products__c p : proname){
            if(pro.containsKey(p.Fund_Short_Name__c)){
                p.Product2_ID__c = pro.get(p.Fund_Short_Name__c);
                updateprod.add(p);
            }
        }
        update updateprod;
    }
    global void finish(Database.BatchableContext BC){
    
    }
}