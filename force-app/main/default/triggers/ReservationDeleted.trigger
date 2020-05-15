trigger ReservationDeleted on Reservation__c (before delete) {
    
    Set<ID> deskids = new Set<ID>();
    //Build set of Ids for Stocks that you will need to update
    for (Reservation__c r : Trigger.old) {
        deskids.add(r.office_desk__c);
    }
    //Create a Map of parent stock records to act as an in-memory join to Stock
    Map<Id, Desk__c> mdesks = new Map<Id, Desk__c> ([Select Id, Status__c from Desk__c where Id in :deskids]);
    //now loop back over child distribution records and update parent stock records
    for (Reservation__c r : Trigger.old) {    
        //Check Stock was returned by SOQL
        if (mdesks.containskey(r.Office_Desk__c) ) {
            mdesks.get(r.Office_Desk__c).Status__c = 'Available';
        }
    }
    //finally, execute update of stock records
    try {
        update mdesks.values();
    } catch (Exception Ex) {
        system.debug(Ex);
    }
    
} //End Trigger