@istest
public class trgPopulateMeetingTest{
    Private Static testmethod void trgPopulateMeetingTest(){
        
        Account objAcc = new Account();
        objAcc.Name = 'Test Account';
        insert objAcc;
        
        Medical_Event_vod__c objMeeting = new Medical_Event_vod__c();
        objMeeting.Account__c = objAcc.id;
        objMeeting.Name = 'Test Meeting';
        insert objMeeting;
        
        Event_Speaker_AZ__c objMeetingSpeaker = new Event_Speaker_AZ__c();
        objMeetingSpeaker.Medical_Event_AZ__c = objMeeting.id;
        objMeetingSpeaker.Account_AZ__c = objAcc.id;
        objMeetingSpeaker.Name = 'Test Meeting Speaker';
        insert objMeetingSpeaker;
        
        dsfs__DocuSign_Status__c objDSStatus = new dsfs__DocuSign_Status__c();
        objDSStatus.Meeting_Speaker__c = objMeetingSpeaker.id;
        
        insert objDSStatus;
    }
}