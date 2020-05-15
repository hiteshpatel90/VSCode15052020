/****************************************************************************
* Type               : Apex Trigger
* Name               : orderLineItemTrigger
* Created by         : Serge Kandukuri
* Created Date       : 26th Dec 2014
* Last Modified By   : Serge Kandukuri 4th Jan 2015
* Purpose            : Trigger for the Order_Line_Item__c sObject. 
                       This trigger is doing following functionality
                       1. Calculate RewardsPoints on Order Line Item
                          this is used to calculate Total Rewards Points in the Order Line Item (when shipping status is "Shipped") as per selected level and entered quantity
                       2. Calculate RewardsPoints On Contact
                          this is used to update total rewards points on contact (student) based on related order line items
                       3. Calculate Units On Order and Units Sold on Product
                          this is used to update Units Sold and Units On Order field values of Product based on related order line items
                            a. Units Sold = sum of Quantity of Order Line Items with "Shipped" status
                            b. Units On Order = sum of Quantity of Order Line Items with "Pending Shipment" status
****************************************************************************/
trigger orderLineItemTrigger on Order_Line_Item__c (before insert, before update, after insert, after update, after delete, after undelete) {
    // call Trigger Handler controller method
    orderLineItemTriggerHandler.oliTriggerHandlerMethod(trigger.new, trigger.old);
}// End of Trigger