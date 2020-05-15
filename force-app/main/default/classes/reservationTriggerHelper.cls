/****************************************************************************
* Type               : Apex Class
* Name               : reservationTriggerHelper
* Created by         : Hitesh Patel
* Created Date       : 5th August 2015
* Last Modified By   : Hitesh Patel 5th June 2015
* Purpose            : This controller is helper class of reservationTrigger
****************************************************************************/
Public class reservationTriggerHelper{ 
    public void handleTriggerMethods(List<Reservation__c> lstReservationNew, Map<Id, Reservation__c> mapReservationOld){
        if(Trigger.isBefore){
            if(Trigger.isDelete){
                // Make reservation available if someone have deleted.
                reservationTriggerHandler.makereservationAvailable(lstReservationNew, mapReservationOld);
            }
        }
        if(Trigger.isAfter){
            if(Trigger.isInsert || Trigger.isUpdate){
                // Make reservation to booked if someone have created or updated
                reservationTriggerHandler.makereservationBooked(lstReservationNew);
            }
        }
    }

}