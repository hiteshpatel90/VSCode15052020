/****************************************************************************
* Type               : Apex Trigger
* Name               : reservationTrigger
* Created by         : Hitesh Patel
* Created Date       : 5th August 2015
* Last Modified By   : Hitesh Patel 5th June 2015
* Purpose            : This controller is used to reserve desk on Particular time at Particular office. 
****************************************************************************/
trigger reservationTrigger on Reservation__c (after insert, after update, before delete) {
    reservationTriggerHelper objResTriggerHelper = new reservationTriggerHelper();
    objResTriggerHelper.handleTriggerMethods(trigger.new, trigger.oldmap);
}