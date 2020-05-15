trigger TriggerOnEventToInsertActivityProducts on Event (After Insert, before Update) {
    List<Event> EventListOnCreate = new List<Event>();
    List<Event> EventListOnUpdate = new List<Event>();
    Map<Id,String> EventProductsMapCreate = new Map<Id,String>();
    Map<Id,String> EventProductsMapUpdate = new Map<Id,String>();
    Map<Id,Event> EventMapCreate = new Map<Id,Event>();
    Map<Id,Event> EventMapUpdate = new Map<Id,Event>();
    
    if(Trigger.isAfter && Trigger.isInsert){
        for( Event e : Trigger.new){
            System.debug('e.Products_Discussed__c'+e.Products_Discussed__c);            
            if(e.Products_Discussed__c!=null && !e.Products_Discussed__c.equals('No Products Discussed')){
                //  EventListOnCreate.add(e);
                EventProductsMapCreate.put(e.id, e.products_discussed__c);
                EventMapCreate.put(e.id,e);
                System.debug('e.Products_Discussed__c'+e.Products_Discussed__c);
            }
            System.debug('EventProductsMapCreate'+EventProductsMapCreate); 
        }
        if(EventProductsMapCreate!=null && EventProductsMapCreate.size()>0 ){
            System.debug('entered the insert block ');
            InsertActivityProductsHelper.InsertActivityProductsForInsert(EventProductsMapCreate,EventMapCreate);
        }    
    }    
    if(Trigger.isBefore && Trigger.isUpdate){
        for( Event e : Trigger.new){        
            if(trigger.newmap!=null && trigger.oldmap!=null && trigger.newmap.get(e.id).Products_Discussed__c!=null &&  trigger.oldmap.get(e.id).Products_Discussed__c!=null &&  trigger.newmap.get(e.id).Products_Discussed__c!= trigger.oldmap.get(e.id).Products_Discussed__c && !trigger.newmap.get(e.id).Products_Discussed__c.equals('No Products Discussed')){
                //  EventListOnUpdate.add(e);
                EventProductsMapUpdate.put(e.id, e.products_discussed__c);
                EventMapUpdate.put(e.id,e);
            }        
        }        
        if(EventProductsMapUpdate!=null && EventProductsMapUpdate.size()>0 ){
            System.debug('entered the update block ');
            InsertActivityProductsHelper.InsertActivityProductsForUpdate(EventProductsMapUpdate,EventMapUpdate);        
        }    
    }
}