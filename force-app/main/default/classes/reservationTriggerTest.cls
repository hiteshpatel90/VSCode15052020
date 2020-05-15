/****************************************************************************
* Type               : Apex Class
* Name               : reservationTriggerTest
* Modified by        : Hitesh Patel
* Modified Date      : 5th June 2015
* Last Modified By   : Hitesh Patel 5th June 2015
* Purpose            : This is the test class for reservationTrigger
****************************************************************************/
@istest
public class reservationTriggerTest{
    Private Static testmethod void TestAccountDupController(){
        Desk__c objDesk = new Desk__c();
        objDesk.Desk_Number__c = 'NYC - 01';
        objDesk.Office__c = 'New York City';
        objDesk.Status__c = 'Available';
        insert objDesk;
        
        Desk__c objDesk1 = new Desk__c();
        objDesk1.Desk_Number__c = 'NYC - 02';
        objDesk1.Office__c = 'New York City';
        objDesk1.Status__c = 'Available';
        insert objDesk1;
        
        Reservation__c objReservation = new Reservation__c();
        objReservation.Start_Date__c = system.today();
        objReservation.End_Date__c = system.today().adddays(2);
        objReservation.Office_Desk__c = objDesk.id;
        objReservation.Reserve_Desk__c = true;
        insert objReservation;
        
        Reservation__c objReservation1 = new Reservation__c();
        objReservation1.Start_Date__c = system.today().adddays(3);
        objReservation1.End_Date__c = system.today().adddays(4);
        objReservation1.Office_Desk__c = objDesk1.id;
        objReservation1.Reserve_Desk__c = true;
        insert objReservation1;
        
        objReservation1.Reserve_Desk__c = false;
        update objReservation1;
        
        resmanagerController objresMController = new resmanagerController();
        objresMController.searchReservation();
        
        objresMController.objReservation.Start_Date__c = system.today().adddays(5);
        objresMController.objReservation.End_Date__c = system.today().adddays(25);
        objresMController.objDesk.Office__c = 'New York City';
        objresMController.searchReservation();
        
        objresMController.objReservation.Start_Date__c = system.today().adddays(5);
        objresMController.objReservation.End_Date__c = system.today().adddays(4);
        objresMController.objDesk.Office__c = 'New York City';
        objresMController.searchReservation();
        
        objresMController.objReservation.Start_Date__c = system.today().adddays(5);
        objresMController.objReservation.End_Date__c = system.today().adddays(6);
        objresMController.objDesk.Office__c = 'New York City';
        objresMController.searchReservation();
        
        objresMController.objReservationNew.Start_Date__c = system.today().adddays(20);
        objresMController.createNewReservation();
        
        objresMController.objReservationNew.Start_Date__c = system.today();
        objresMController.objReservationNew.End_Date__c = system.today().adddays(15);
        objresMController.createNewReservation();
        
        delete objReservation;
    }
}