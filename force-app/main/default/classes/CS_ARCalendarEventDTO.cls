// Data Transfer Object for moving Case__c object to/from the calendar on the front-end
// - Chad Armstrong
global class CS_ARCalendarEventDTO {

    public String url {get;set;}
    public String ownerId {get;set;}
    public String ownerProviderTerritory {get;set;}
    public String ownerProviderTerritoryId {get;set;}
    public String ownerProviderParentTerritoryId {get;set;}
    public String ownerTitle {get;set;}
    public String practitionerId {get;set;}
    public String providerId {get;set;}
    public String startDate {get;set;}
    public String endDate {get;set;}
    public String providerAddress {get;set;}

    public String title {get;set;}
    public String description {get;set;}
    public String practitioner {get;set;}
    public String procedure {get;set;}
    public String provider {get;set;}
    public String status {get;set;}
    public list<Case_Pref_Card__c> lstCasePrefCards {get;set;}
    public list<CaseParticipant__c> lstCaseParticipants {get;set;}
    public list<Case_Procedure__c> lstCaseProcedures {get;set;}
    public list<Case_Procedure__c> lstCaseSurgicalTechniques {get;set;}
    public list<Opportunity_Case__c> lstOpportunityCases {get;set;}
    

    /*
    public String providerStreet {get;set;}
    public String providerCity {get;set;}
    public String providerState {get;set;}
    public String providerZip {get;set;}
    public String providerCountry {get;set;}
    */

    public double providerLatitude {get;set;}
    public double providerLongitude {get;set;}
    public String providerTerritory {get;set;}
    public String providerTerritoryId {get;set;}
    public String providerParentTerritoryId {get;set;}
    public String owner {get;set;}
    //public set<string> attendees {get;set;}

    public List<Map<String,String>> participants {get;set;}
    // public List<Map<String,String>> products {get;set;}

    public CS_ARCalendarEventDTO() {
        participants = new List<Map<String,String>>();
        lstCaseProcedures = new list<Case_Procedure__c>();
        lstOpportunityCases = new list<Opportunity_Case__c>();
        lstCaseSurgicalTechniques = new list<Case_Procedure__c>();
        lstCasePrefCards = new list<Case_Pref_Card__c> ();
        // products = new List<Map<String,String>>();       
    }


    public static CS_ARCalendarEventDTO buildFromCase(Case__c eventCase) {
        
        CS_ARCalendarEventDTO event = new CS_ARCalendarEventDTO();
        
        event.url = eventCase.Id;
        event.ownerId = eventCase.OwnerId;
        event.ownerTitle = eventCase.Owner.Title;
        event.providerId = eventCase.Health_Care_Provider__c;
        event.practitionerId = eventCase.Practitioner__c;
        event.startDate = String.valueOf(eventCase.Event_Start_Date__c);
        event.endDate = String.valueOf(eventCase.Event_End_Date__c);
        event.description = eventCase.Description__c;

        event.status = eventCase.Status__c;
        
        event.practitioner = eventCase.Practitioner__r.Name;
        
        //Yan: per enhancement to the title format
        //Dr. Last Name
        //Hospital Account
        //Procedure - Technique
        event.procedure = eventCase.Procedure_Names_Placeholder__c;
        event.provider = eventCase.Health_Care_Provider__r.Name;
        
        /*if(eventCase.Practitioner__r.LastName != null)
            event.title = 'Dr. ' +  eventCase.Practitioner__r.LastName;
        else
            event.title = '';   
        
        if(event.provider != null){

            event.title += '\n' + event.provider;
        }*/

        if(event.procedure != null){
            event.title += '\n' + event.procedure;
        }

        event.providerLatitude = eventCase.Health_Care_Provider__r.BillingLatitude;
        event.providerLongitude = eventCase.Health_Care_Provider__r.BillingLongitude;
        
        event.providerAddress = eventCase.Health_Care_Provider__r.BillingStreet + '<br/>' + 
                                eventCase.Health_Care_Provider__r.BillingCity + ', ' +
                                eventCase.Health_Care_Provider__r.BillingState + ', '+
                                eventCase.Health_Care_Provider__r.BillingCountry + ', ' +
                                eventCase.Health_Care_Provider__r.BillingPostalCode; 
        event.owner = eventCase.Owner.Name;
        
        //List<CaseParticipant__c> caseParticipants = [select Participant__r.Id, Participant__r.Name, Participant__r.Title from CaseParticipant__c where Case__c =:eventCase.Id];
        //system.debug('##--caseParticipants: '+ caseParticipants);
        if ( eventCase.Case_Participants__r.size() > 0) {
            for ( CaseParticipant__c  caseparticipant: eventCase.Case_Participants__r ) {
                Map<String,String> participant = new Map<String,String>();
                participant.put('Id',caseParticipant.Participant__r.Id);
                participant.put('Name',caseParticipant.Participant__r.Name);
                participant.put('Title',caseParticipant.Participant__r.Title);
                event.participants.add(participant);
                //event.attendees.add(caseParticipant.Participant__r.Name);
                    
            }
        }
        
        if(eventCase.Case_Pref_Cards__r.size() > 0){
            
            for(Case_Pref_Card__c objPrefCard :eventCase.Case_Pref_Cards__r){
                event.lstCasePrefCards.add(objPrefCard);
            }
            
        }
        
        if(eventCase.Case_Procedures__r.size() > 0){
            //event.lstCaseProcedures = new list<Case_Procedure__c>();
            //event.lstCaseSurgicalTechniques = new list<Case_Procedure__c>();
            for(Case_Procedure__c objCaseProd : eventCase.Case_Procedures__r){
                
                system.debug('##--procedure taxongroup: '+ objCaseProd.Procedure__r.TaxonGroupId__c);
                if(objCaseProd.Procedure__r.TaxonGroupId__c == 'procedure'){
                    event.lstCaseProcedures.add(objCaseProd);
                }else if(objCaseProd.Procedure__r.TaxonGroupId__c == 'surgical_technique'){
                    event.lstCaseSurgicalTechniques.add(objCaseProd);
                }
                
            }// end of for-each
        }
        
        if(eventCase.Opportunity_Cases__r.size() > 0){
            //event.lstOpportunityCases = new list<Opportunity_Case__c>();
            for(Opportunity_Case__c objCaseProd : eventCase.Opportunity_Cases__r){
                event.lstOpportunityCases.add(objCaseProd);
            }// end of for-each
        }
        system.debug('##--event.participants: '+ event.participants);
        return event;
    }

    public static String getCaseBuildSoql() {

        String soql = 'select Id, OwnerId, Owner.Title, Health_Care_Provider__c, Practitioner__c, Health_Care_Provider__r.Id, ';
        
        soql += ' Status__c,Procedure_Names_Placeholder__c, Event_Start_Date__c, Event_End_Date__c, Practitioner__r.Name, ';
        soql += ' Health_Care_Provider__r.Name, Health_Care_Provider__r.BillingStreet, Health_Care_Provider__r.BillingState, ';
        soql += ' (select Participant__r.Id, Participant__r.Name, Participant__r.Title FROM Case_Participants__r), ';
        soql += ' (select Case__c, Procedure__c, Procedure__r.Name, Procedure__r.TaxonGroupId__c FROM Case_Procedures__r), ';
        soql += ' (select Case__c, Opportunity__c, Opportunity__r.Name, Opportunity__r.Type, ';
        soql += '  Opportunity__r.Potential_Revenue_per_Case__c, Opportunity__r.CloseDate FROM Opportunity_Cases__r), ';
        soql += ' (select Id, Case__c, Practitioner_Procedure__c, Practitioner_Procedure__r.Pref_Card_Name__c, Practitioner_Procedure__r.Procedure__r.Name FROM Case_Pref_Cards__r), ';
        soql += ' Health_Care_Provider__r.BillingCity, Health_Care_Provider__r.BillingCountry, ';
        soql += ' Health_Care_Provider__r.BillingPostalCode, Health_Care_Provider__r.BillingLatitude, ';
        soql += ' Health_Care_Provider__r.BillingLongitude, Owner.Name,Description__c from Case__c ';

        return soql;
    }


}