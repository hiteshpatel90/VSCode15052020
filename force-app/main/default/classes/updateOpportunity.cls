global class updateOpportunity{
    webservice static Id makeContact(String oppId, String strNote) {
        Opportunity opp = new Opportunity(id=oppId);
        opp.Description = strNote;
        update opp;
        return opp.id;
    }
}