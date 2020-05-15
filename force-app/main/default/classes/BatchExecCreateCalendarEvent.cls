///////////////////////////////////////////////////////////////////
//Name                   :  BatchExecCreateCalendarEvent 
//Created by             :  
/////////////////////////////////////////////////////////////////////

global class BatchExecCreateCalendarEvent implements Database.Batchable<sObject>,  Database.AllowsCallouts{
    global final String Query;
    global final set<Id> sEventId;
    global BatchExecCreateCalendarEvent(String q, set<Id> sEventIdParam){    
        this.query = q;
        this.sEventId = sEventIdParam;
    }    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }    
    
    global void execute(Database.BatchableContext BC, List<Event> lstEvent){
        set<Id> sEventId = new set<Id>();
        for(Event evt: lstEvent){
            sEventId.add(evt.Id);
        }
        createEventinGoogleCalendarFuture(sEventId);
    }
    
    public static void createEventinGoogleCalendarFuture(set<Id> sEventId){
        List<Event> eventlist = [SELECT id, Subject, WhoId, Who.Email FROM Event WHERE id IN: sEventId];
        set<Id> sWhoId = new set<Id>();
        for(Event evt: eventlist){
            sWhoId.add(evt.WhoId);
        }
        Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT id, Email FROM Contact WHERE id IN: sWhoId]);

        List<Event> lstEvent = [SELECT id, Subject, Who.Email FROM Event WHERE id IN: eventlist];
        
        List<GoogleCalenderInfo__c> googleCalendarInfo = GoogleCalenderInfo__c.getall().values();
        if(!googleCalendarInfo.isEmpty()){
            GoogleCalenderApi.doRefreshToken();
        }else{
            GoogleCalenderApi.doFetchAccessToken();
        }
        String accessToken = '';
        googleCalendarInfo = GoogleCalenderInfo__c.getall().values();
        if(!googleCalendarInfo.isEmpty()){
            accessToken = googleCalendarInfo[0].Access_Token__c;
        }
        String createEventEndPoint = 'https://www.googleapis.com/calendar/v3/calendars/'+ 'hitesh@infoglen.com' +'/events?sendNotifications=true';
                
        //try{
            for(Event evt: eventlist){
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
                    '"summary": "This is Test Event Using Calendar API ",'+
                    '"location": "B 24 Noida Sec 65"'+
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
                        ApexPages.addmessage(new ApexPages.message(
                            ApexPages.severity.CONFIRM,'Calendar Event Successfully  '+'\n'+' '+
                            HttpRes.getBody()));
                    }else{
                        String errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
                            +'Status '+HttpRes.getStatus()+' and Status Code '+HttpRes.getStatuscode();
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
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
    
    global void finish(Database.BatchableContext BC) {       
    }      
}