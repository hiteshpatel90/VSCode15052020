/****************************************************************************
* Type               : Apex Class
* Name               : reservationTriggerHandler
* Created by         : Hitesh Patel
* Created Date       : 5th August 2015
* Last Modified By   : Hitesh Patel 5th June 2015
* Purpose            : This controller is handler class of reservationTrigger
****************************************************************************/
Public class reservationTriggerHandler{ 
    public static void makereservationAvailable(List<Reservation__c> lstReservationNew, Map<Id, Reservation__c> mapReservationOld){
        Set<ID> deskids = new Set<ID>();
        //Build set of Ids for Stocks that you will need to update
        for (Reservation__c r : mapReservationOld.values()) {
            deskids.add(r.office_desk__c);
        }
        //Create a Map of parent stock records to act as an in-memory join to Stock
        Map<Id, Desk__c> mdesks = new Map<Id, Desk__c> ([Select Id, Status__c from Desk__c where Id in :deskids]);
        //now loop back over child distribution records and update parent stock records
        for (Reservation__c r : mapReservationOld.values()) {    
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
    }
    public static void makereservationBooked(List<Reservation__c> lstReservationNew){
        // Create a set for related desk ids
        Set<ID> deskids = new Set<ID>();
        // Create a set for related desk ids
        Set<ID> deskidsAvail = new Set<ID>();        
        // iterate through the reservations
        for (Reservation__c r : lstReservationNew) {
            // If the reservation status is 'New'...
            if (r.Desk_Reserved__c == true) {
                //...add the ID to the set
                deskids.add(r.office_desk__c);
            }
            if (r.Desk_Reserved__c == false) {
                //...add the ID to the set
                deskidsAvail.add(r.office_desk__c);
            }
        }
        if(!deskids.isEmpty()){    
            // use SOQL to query for the relevant desks
            List<Desk__c> desklist = [select id, status__c from Desk__c where id in :deskids];
            if(!deskids.isEmpty()){        
                // Iterate through the Desks
                for (desk__c d : desklist) {
                    // set the status of each desk to 'Booked'
                    d.status__c = 'Booked';
                }            
                // Update the Desk records, with the booked status
                update desklist;
            }
        }        
        if(!deskidsAvail.isEmpty()){    
            // use SOQL to query for the relevant desks
            List<Desk__c> desklist = [select id, status__c from Desk__c where id in :deskidsAvail];
            if(!deskidsAvail.isEmpty()){        
                // Iterate through the Desks
                for (desk__c d : desklist) {
                    // set the status of each desk to 'Booked'
                    d.status__c = 'Available';
                }            
                // Update the Desk records, with the booked status
                update desklist;
            }
        }
    }
}