/**
* @author       Dharma Penugonda
* @date         1/2/2018
* @description  Retrieve PingFed token either from Callout/ stored from PingFed object
* Uses ClientId and ClientSecret stored in "rcp_PingFedLogin__mdt" custom metadata to fetch token from PingFed against scopes passed
* Once token is fetched, it is saved in "rcp_PingFed__c" custom object along with its expiry time stamp and used for subsequent calls till its expiry
* <p> Test Class: RCP_PingFedTest
* <p>
* V1.0 -> 1/2/2018, Dharma Penugonda, HOJ-1825, Initial Commit
*/

public with sharing class RCP_PingFed {   
    
    /**
     * @param       String scopes corresponding to API being invoked
     * @return      PingFedToken (AccessToken, PingFed-records to upsert) if system-admin calls this method, else returns null
     * @description Check if "rcp_PingFed__c" custom object has active token, if yes retrieve else fetch new token
     * <p> If non-system-admin who cannot create create "rcp_PingFed__c" records call this method, returns null
     * <pre>RCP_PingFed.PingFedToken token = RCP_PingFed.Authenticate('prts.cop.prts.r prts.cop.prts.w');</pre>
     * after retrieving token from above call as shown below to the end of the transaction,
     * <pre>RCP_PingFed.managePingFedToken(token);</pre>
     * <p> Test Coverage: RCP_PingFedTest: test_authenticateToken1, test_authenticateToken2, authenticate_nonAdmin
     */    
    public static PingFedToken authenticate(String scopes) {
        PingFedToken token;
        
        //Return null if any user who has no permission to create rcp_PingFed__c invokes this method
        if(!Schema.sObjectType.rcp_PingFed__c.isCreateable()) return null;
        
        //check if there are any existing records for the scopes passed, If yes check expiry time stamp and return token
        String[] scope = scopes.split(' ');
        for(rcp_PingFed__c pf: [SELECT Id, Name, Expiry_DateTime__c, Token__c FROM rcp_PingFed__c WHERE Name IN :scope ORDER BY name ASC]) {
            if(!String.isBlank(pf.Token__c) && pf.Expiry_DateTime__c >= System.now()) {
                token = new pingFedToken(pf.Token__c, '');
                break;
            }
        }
        
        //If no records found above/ no active token exists, fetch new token
        if(NULL == token || String.isBlank(token.accessToken)) token = fetchNewToken(scopes);
        
        return token;
    }
    
    /**
     * @param       scopes scopes corresponding to API being invoked
     * @return      PingFedToken (AccessToken, PingFed-records to upsert) if system-admin calls this method, else returns null
     * @description fetch new PingFed accesstoken. This method should be called individually only when authenticate returns 401 status
     * <pre>RCP_PingFed.fetchNewToken('ctev.smsg.ctev.w ctev.smsg.ctev.r alev.altr.alev.w')</pre>
     * After retrieving token from above call as shown below to the end of the transaction,
     * <pre>RCP_PingFed.managePingFedToken(token);</pre> 
     * <p> Test Coverage: RCP_PingFedTest: test_fetchNewToken
     */     
    public static pingFedToken fetchNewToken(String scopes) {
        //Return null if any user who has no permission to create rcp_PingFed__c invokes this method
        if(!Schema.sObjectType.rcp_PingFed__c.isCreateable()) return null;
        
        String accessToken = '';
        String clientId_Fetch, clientSecret_Fetch;
        //Retrieve clientId and clientsecret from custom metadata
        for(rcp_PingFedLogin__mdt loginRecord: [SELECT Id, developername, clientid__c, clientsecret__c from rcp_PingFedLogin__mdt]) {
            if(loginRecord.developername == 'Fetch') {
                clientId_Fetch = loginRecord.clientid__c;
                clientSecret_Fetch = loginRecord.clientsecret__c;                
            }
        }
        if(String.isBlank(clientId_Fetch) || String.isBlank(clientSecret_Fetch)) {
            system.debug('clientid and secret missing in metadata');
            return null;
        }        
        
        //Callout to PingFed to fetch new token
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:PingFed?response_type=token&grant_type=client_credentials');
        request.setMethod('POST');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        String body = 'client_id='+clientId_Fetch;
        body += '&client_secret='+clientSecret_Fetch;
        body += '&scope='+EncodingUtil.urlEncode(scopes,'UTF-8'); 
        request.setBody(body);
        try{
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                PingFedFetch pf = (PingFedFetch) json.deserialize(response.getBody(), PingFedFetch.Class); 
                if(!String.isEmpty(pf.access_token) && pf.expires_in > 0 && !String.isEmpty(pf.token_type) && pf.token_type == 'Bearer') {
                    List<rcp_PingFed__c> pfRecords_upsert = new List<rcp_PingFed__c>();
                    for(String str : scopes.split(' ')) {
                        //this token is valid for 9.99 hours but we are expiring the token in 8.99 hours in salesforce
                        pfRecords_upsert.add(new rcp_PingFed__c(name = str, token__c = pf.access_token, Expiry_DateTime__c = system.now().addHours(-1).addSeconds(pf.expires_in)));
                    }
                    return new pingFedToken(pf.access_token, JSON.serialize(pfRecords_upsert));                                        
                }
            }
        } catch(Exception e) {
            system.debug('Exception Occured: '+e);
        }
        return null;
    }

    /**
     * @param PingFedToken token
     * @return void
     * @description check if there is valid JSON string of rcp_PingFed__c records to upsert, if yes upsert in future method.
     * This method should be called at the end of transaction each time authenticate/ fetchNewToken methods are called
     * <pre>RCP_PingFed.managePingFedToken(token)</pre>
     * <p> Test Coverage: RCP_PingFedTest: test_fetchNewToken
     */     
    public static void managePingFedToken(PingFedToken token) {
        if(NULL == token || String.isBlank(token.objJSON)) return;
        manageRecordsAsync(token.objJSON);
    }
    
    
    /**
     * @param objJSON       List<PingFed> records serialized in JSON
     * @return              void
     * @description         upsert PingFed records with newly fetched token and delete obsolete records
     * <p> Test Coverage: RCP_PingFedTest: fetchNewToken_S1, fetchNewToken_S2
     */
    @future
    private static void manageRecordsAsync(String objJSON) {
        List<rcp_PingFed__c> pfRecords_upsert = (List<rcp_PingFed__c>) JSON.deserialize(objJSON, List<rcp_PingFed__c>.Class);
        Schema.SObjectField f = rcp_PingFed__c.Fields.Name;
        if(!pfRecords_upsert.isEmpty()) {
            Database.upsertResult[] upsertResult = Database.upsert(pfRecords_upsert, f, false);
            system.debug('Upsert Result: '+upsertResult);            
        }
        
        //Delete obsolete/ expired PingFed records        
        List<rcp_PingFed__c> pfRecords_del = new List<rcp_PingFed__c>();
        for(rcp_PingFed__c pf : [SELECT Id, Name, Expiry_DateTime__c, Token__c FROM rcp_PingFed__c]) {
            if(String.isBlank(pf.Token__c) || pf.Expiry_DateTime__c < system.now()) pfRecords_del.add(pf);
        }
        if(!pfRecords_del.isEmpty()) {
            Database.DeleteResult[] deleteResult = Database.delete(pfRecords_del, false);
            system.debug('Delete Result: '+deleteResult);            
        }      
    }    
    
    /**
    * @description wrapper class to parse response of fetchnewtoken() call
    * <p>
    * V1.0 -> 1/2/2018, Dharma Penugonda, HOJ-1825, Initial Commit
    */    
    private Class PingFedFetch {
        String access_token {get;set;}
        String token_type {get;set;}
        Integer expires_in {get;set;}
    }
    
    /**
    * @description wrapper class for PingFed accessToken and JSON of PingFed records to upsert
    * <p>
    * V1.0 -> 1/2/2018, Dharma Penugonda, HOJ-1825, Initial Commit
    */    
    public class PingFedToken {
        public String accessToken{get;set;}
        public String objJSON{get;set;}
        pingFedToken(String accessToken, String objJSON) {
            this.objJSON = objJSON;
            this.accessToken = accessToken;
        }        
    }

}