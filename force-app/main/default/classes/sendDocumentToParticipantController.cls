public with sharing class sendDocumentToParticipantController {
    public sendDocumentToParticipantController() {
        
    }
    @AuraEnabled(cacheable=true)
    public static void sendSignRequestToParticipant(String strResearchId) {
        system.System.debug('$$$$$$$$$$$$$$$');
        system.System.debug('$$$$$$$$$$$$$$$'+strResearchId);
    }
}
