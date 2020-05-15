/****************************************************************************
* Type               : Apex Class
* Name               : orderLineItemTriggerHandler
* Created by         : Serge Kandukuri
* Created Date       : 26th Dec 2014
* Last Modified By   : Serge Kandukuri 4th Jan 2015
* Purpose            : Trigger Handler class for the Order_Line_Item__c sObject. 
                       There are three methods in this trigger handler controller
                       1. "calculateRewardsPoints"
                          this method is used to calculate Total Rewards Points in the Order Line Item (when shipping status is "Shipped") as per selected level and entered quantity
                       2. "calculateRewardsPointsOnContact"
                          this method is used to update total rewards points on contact (student) based on related order line items
                       3. "calculatePUnitsSoldandOnOrder"
                          this method is used to update Units Sold and Units On Order field values of Product based on related order line items
                            a. Units Sold = sum of Quantity of Order Line Items with "Shipped" status
                            b. Units On Order = sum of Quantity of Order Line Items with "Pending Shipment" status
****************************************************************************/
public with sharing class orderLineItemTriggerHandler {
    // this is custom setting name to get the reward points for calucation
    public static final String CUSTOM_SETTING_NAME_CONSTANT = 'Rewards Points Values';
    public static void oliTriggerHandlerMethod(Order_Line_Item__c[] newOrderLineItems, Order_Line_Item__c[] oldOrderLineItems) {
        if(Trigger.isBefore){
            if(Trigger.isInsert || Trigger.isUpdate){
                // Rewards Points on Order Line Item
                calculateRewardsPoints(newOrderLineItems);
            }// End of IF Condition
        }// End of IF Condition
        if(Trigger.isAfter){
            // Total Rewards Points on Contact (student)
            calculateRewardsPointsOnContact(newOrderLineItems, oldOrderLineItems);
            
            // Update Product Units Sold and On Order
            calculatePUnitsSoldandOnOrder(newOrderLineItems, oldOrderLineItems);
        }// End of IF Condition
    }// End of the method - oliTriggerHandlerMethod
    
    // Rewards Points on Order Line Item
    public static void calculateRewardsPoints(Order_Line_Item__c[] newOrderLineItems){
        // static  get the rewards points values from custom setting
        Rewards_Points_Setting__c rPointsCS = Rewards_Points_Setting__c.getValues(CUSTOM_SETTING_NAME_CONSTANT);
        // define map to get point level value from custom setting 
        Map<String, Integer> mapRewardPoints = new Map<String, Integer>();
        if(rPointsCS != null){
            integer goldPoint   = 0;
            integer silverPoint = 0;
            integer bronzePoint = 0;
            if(rPointsCS.Gold_Reward_Point__c != null){
                goldPoint  = integer.valueOf(rPointsCS.Gold_Reward_Point__c);
            }// End of IF Condition
            if(rPointsCS.Silver_Reward_Point__c != null){
                silverPoint = integer.valueOf(rPointsCS.Silver_Reward_Point__c);
            }// End of IF Condition
            if(rPointsCS.Bronze_Reward_Point__c!= null){
                bronzePoint = integer.valueOf(rPointsCS.Bronze_Reward_Point__c);
            }// End of IF Condition
            mapRewardPoints.put('Gold', goldPoint  );
            mapRewardPoints.put('Silver', silverPoint );
            mapRewardPoints.put('Bronze', bronzePoint );
        }// End of IF Condition
        for(Order_Line_Item__c oli: newOrderLineItems){
            // check condition for order line item status is Shipped. and level and quantity  have some value
            oli.Rewards_Points__c = 0;
            if(!mapRewardPoints.isEmpty() && mapRewardPoints.containsKey(oli.Level__c)){
                if(oli.Shipping_Status__c == 'Shipped' && oli.Level__c != null && oli.Quantity__c != null){
                    oli.Rewards_Points__c = mapRewardPoints.get(oli.Level__c) * oli.Quantity__c;
                }// End of IF Condition
            }// End of IF Condition
        }
    }// End of the method - calculateRewardsPoints
    
    // Total Rewards Points on Contact (student)
    public static void calculateRewardsPointsOnContact(Order_Line_Item__c[] newOrderLineItems, Order_Line_Item__c[] oldOrderLineItems){
        set<Id> sContactId = new set<Id>();
        // Iterate  through the records to be inserted or updated   
        if(Trigger.isDelete == false){
            for(Order_Line_Item__c oli: newOrderLineItems){
                // condition to check student is exist in the order line item record
                if(oli.Student__c != null){
                    sContactId.add(oli.Student__c);
                }// End of IF Condition
            }// End of FOR loop
        }// End of IF Condition
        // Iterate  through the records to be deleted
        else if(Trigger.isDelete == true){   
            for(Order_Line_Item__c oli: oldOrderLineItems){              
                // condition to check student is exist in the order line item record
                if(oli.Student__c != null){
                    sContactId.add(oli.Student__c);
                }// End of IF Condition
            }// End of IF Condition
        }// End of IF Condition
        if(!sContactId.isEmpty()){
            try{
                // Instantiate the Contact map
                Map<Id, Contact> mapContact = new Map<Id, Contact>();
                for(Id con: sContactId){
                    Contact objContact = new Contact(id=con);
                    objContact.Rewards_Points__c = 0;                    
                    mapContact.Put(con, objContact);
                }// End of FOR loop        
                // Instantiate the contact list for update
                List<Contact> updateContactList = new List<Contact>();
                Contact objContact;
                if(!mapContact.isEmpty()){
                    for(AggregateResult ar: [SELECT Student__c, SUM(Rewards_Points__c) totalReward FROM Order_Line_Item__c WHERE Student__c in: sContactId GROUP BY Student__c]){
                        // add contact record to the list                        
                        objContact = new Contact(id=string.valueOf(ar.get('Student__c')));
                        if(mapContact.containsKey(objContact.id)){
                            objContact = mapContact.get(objContact.id);
                            objContact.Rewards_Points__c = Integer.valueOf(ar.get('totalReward'));
                        }                    
                        updateContactList.add(objContact);
                        mapContact.remove(objContact.id);
                    }// End of FOR loop
                    if(!mapContact.isEmpty() && updateContactList.isEmpty()){
                        updateContactList.addall(mapContact.values());
                    }// End of IF Condition
                    // update contact records
                    if(!updateContactList.isEmpty()){                                  
                        update updateContactList;
                    }// End of IF Condition
                }// End of IF Condition
            } catch(Exception ex){
                system.debug('Update of Contact ERROR : ' + ex.getMessage());       
            }// End of Try Catch
        }// End of IF Condition
    }// End of the method - calculateRewardsPointsOnContact
    
    // Product Units Sold and On Order
    public static void calculatePUnitsSoldandOnOrder(Order_Line_Item__c[] newOrderLineItems, Order_Line_Item__c[] oldOrderLineItems){
        set<Id> sProductId = new set<Id>();
        // Iterate  through the records to be inserted or updated        
        if(Trigger.isDelete == false){
            for(Order_Line_Item__c oli: newOrderLineItems){
                // condition to check Product is exist in the order line item record
                if(oli.Product__c != null){
                    sProductId.add(oli.Product__c);
                }// End of IF Condition
            }// End of FOR loop
        }// End of IF Condition
        // Iterate  through the records to be deleted
        else if(Trigger.isDelete == true){
            for(Order_Line_Item__c oli: oldOrderLineItems){
                // condition to check Product is exist in the order line item record
                if(oli.Product__c != null){
                    sProductId.add(oli.Product__c);
                }// End of IF Condition
            }// End of FOR loop
        }// End of IF Condition
        if(!sProductId.isEmpty()){
            try{
                // Instantiate the Product map
                Map<Id, Product2> allProductMap = new  Map<Id, Product2>();
                for(Id prodId: sProductId){
                    Product2 objProduct = new Product2(id=prodId);
                    objProduct.Units_Sold__c = 0;
                    objProduct.Units_On_Order__c = 0;
                    allProductMap.Put(objProduct.id, objProduct);
                }// End of FOR Loop
                // Instantiate the Product map
                Map<Id, Product2> productMap = new  Map<Id, Product2>();
                // Instantiate the contact list for update
                List<Product2> updataeProductUnitList = new List<Product2>();
                Product2 objProduct;
                // get the total number of Products that have shipped
                for(AggregateResult ar: [SELECT Product__c, SUM(Quantity__c) totalProductSold FROM Order_Line_Item__c WHERE Product__c IN: sProductId and Shipping_Status__c = 'Shipped' GROUP BY Product__c]){
                    // add product2 record to the list
                    objProduct = new Product2(id=string.valueOf(ar.get('Product__c')));
                    if(allProductMap.containsKey(objProduct.id)){
                        objProduct = allProductMap.get(objProduct.id);
                        objProduct.Units_Sold__c = Integer.valueOf(ar.get('totalProductSold'));
                        updataeProductUnitList.add(objProduct);
                        productMap.put(objProduct.id, objProduct);
                        allProductMap.remove(objProduct.id);                        
                    }// End of FOR Loop
                }// End of FOR Loop
                // get the total number of Products that have not shipped yet
                for(AggregateResult ar: [SELECT Product__c, SUM(Quantity__c) totalProductOnOrder FROM Order_Line_Item__c WHERE Product__c in: sProductId and Shipping_Status__c = 'Pending Shipment' GROUP BY Product__c]){ 
                    // add product2 record to the list   
                    objProduct = new Product2(id=string.valueOf(ar.get('Product__c')));
                    if(allProductMap.containsKey(objProduct.id)){
                        objProduct = allProductMap.get(objProduct.id);
                        // condition to check product2 record exist in the list or not
                        if(productMap.containsKey(objProduct.id)){                       
                            objProduct = productMap.get(objProduct.id);         
                            objProduct.Units_On_Order__c = Integer.valueOf(ar.get('totalProductOnOrder'));
                        }else{
                            objProduct.Units_On_Order__c = Integer.valueOf(ar.get('totalProductOnOrder'));
                            updataeProductUnitList.add(objProduct);          
                        }// End of IF Condition
                        allProductMap.remove(objProduct.id);
                    }// End of IF Condition
                }
                 if(!allProductMap.isEmpty() && updataeProductUnitList.isEmpty()){                    
                    updataeProductUnitList.addAll(allProductMap.values());                    
                }// End of IF Condition
                // update Product records
                if(!updataeProductUnitList.isEmpty()){                    
                    update updataeProductUnitList;                    
                }// End of IF Condition
            }catch(Exception ex){
                system.debug('Update of Product Units ERROR : ' + ex.getMessage());       
            }// End of Try Catch
        }// End of IF Condition
    }// End of the method - calculatePUnitsSoldandOnOrder
}// End of Class