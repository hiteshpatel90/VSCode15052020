/**@@
#TRIGGER NAME        :    EventTrigger
#HANDLER CLASS NAME  :    Trigger_Event_Handler
#HELPER CLASS NAME   :    Trigger_Event_Helper
#TEST CLASS          :    EventTriggerTest
#DESCRIPTION         :    This Helper class will handles all the trigger events and handling the appropriate logic.   
@@**/
public class Trigger_Event_Helper {
    
    /**@@
    #DESCRIPTION   : Sync Event with Google Calendar
    #Paramaters    : trigger.new,trigger.oldMap
    @@**/
    public static void createEventinGoogleCalendar(List<Event> eventlist){
        set<Id> sEventId = new set<Id>();
        
        for(Event evt: eventlist){
            sEventId.add(evt.Id);
        }
       
        createEventinGoogleCalendarFuture(sEventId);
    }
    /**@@
    #DESCRIPTION   : Sync Event with Google Calendar
    #Paramaters    : set<Id> sEventId
    @@**/
    @future(callout=true)
    public static void createEventinGoogleCalendarFuture(set<Id> sEventId){
        
        List<Event> eventlist = [SELECT id, Subject, WhoId, Who.Email FROM Event WHERE id IN: sEventId];
        set<Id> sWhoId = new set<Id>();
        for(Event evt: eventlist){
            sWhoId.add(evt.WhoId);
        }
        Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT id, Email FROM Contact WHERE id IN: sWhoId]);

        List<Event> lstEvent = [SELECT id, Subject, Who.Email, StartDateTime, EndDateTime, Location FROM Event WHERE id IN: eventlist];
        
        
        List<GoogleCalenderInfo__c> googleCalendarInfo = GoogleCalenderInfo__c.getall().values();
        
        String accessToken = '';
        googleCalendarInfo = GoogleCalenderInfo__c.getall().values();
        if(!googleCalendarInfo.isEmpty()){
            accessToken = googleCalendarInfo[0].Access_Token__c;
        }
        String createEventEndPoint = 'https://www.googleapis.com/calendar/v3/calendars/'+ 'hitesh@infoglen.com' +'/events?sendNotifications=true';
                
        //try{
            for(Event evt: lstEvent){
                 //system.assertEquals(mapContacts.get(evt.WhoId).Email, 'pp');
                String createEventBody =  '{' +
                    '"attendees": ['+
                    '{'+
                    '"email": "' + mapContacts.get(evt.WhoId).Email + '"}'+ 
                    '],'+
                    '"attachments": ['+
                    '{'+
                    '"fileUrl": ""'+
                    '}'+
                    '],'+
                    '"end": {'+
                    '"dateTime": "2019-02-01T03:30:00-07:00"'+
                    '},'+
                    '"reminders": {'+
                    '"useDefault": true'+
                    '},'+
                    '"start": {'+
                    '"dateTime": "2019-02-01T03:30:00-06:00"'+
                    '},'+
                    '"summary": " ' + evt.Subject + ' ",'+
                    '"location": "' + evt.Location + '"'+
                    '}';
                System.debug('#### createEventBody  '+createEventBody );
                Http http = new Http();
                HttpRequest httpReq = new HttpRequest();
                HttpResponse HttpRes = new HttpResponse();
                
                httpReq.setEndpoint(createEventEndPoint);
                httpReq.setMethod('POST');
                httpReq.setBody(createEventBody );
                httpReq.setHeader('Content-Type', 'application/json');
                httpReq.setHeader('Authorization','Bearer '+accessToken);
                try{
                    HttpRes = http.send(httpReq);
                    if(HttpRes.getStatusCode() == 200){
                        system.debug('Calendar Event Successfully');
                    }else{
                        String errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
                            +'Status '+HttpRes.getStatus()+' and Status Code '+HttpRes.getStatuscode();
                        system.debug('Exception is - '+errorMessage );
                    }
                }catch(System.Exception e){
                    System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
                }
            }
        /*} //End of try block
        catch(Exception e){
            system.debug('Exception is===>'+e.getMessage());
        }//End of catch
        */
    }//End of Method
}