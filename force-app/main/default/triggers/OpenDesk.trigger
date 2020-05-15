trigger OpenDesk on Reservation__c (after update) {
  //1. Create a set for related desk ids
    Set<ID> deskids = new Set<ID>();
    
    //2.  iterate through the reservations
    for (Reservation__c r : trigger.new) {
        //2.  If the reservation status is 'New'...
        if (r.Desk_Reserved__c == false) {
            //...add the jet ID to the set
            deskids.add(r.office_desk__c);
        }
    }
    
    //3.  use SOQL to query for the relevant desks
    List<Desk__c> desklist = [select id, status__c from Desk__c where id in :deskids];
    
    //4.  Iterate through the Desks
    for (desk__c d : desklist) {
        //4a.   set the status of each desk to 'Booked'
        d.status__c = 'Available';
        //update j;
    }
    //5.  Update the Desk records, with the booked status
    update desklist;
}