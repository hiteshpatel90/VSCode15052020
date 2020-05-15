trigger trgUpdateLeadandOpp on Contact (after update) {
    List<Lead> lstLeadUpdate = new List<Lead>();
    List<Opportunity> lstOppUpdate = new List<Opportunity>();
    
    List<Contact> lstContact = [select id, Phone, Email, (select id from opportunities), (select id from Leads__r) from contact where id =: trigger.newmap.keyset()];
    string strEmail = '';
    string strPhone = '';
    for(Contact con: lstContact){
        if(con.Email != null && con.Email != trigger.oldmap.get(con.id).Email){
            strEmail = con.Email;
        }
        if(con.Phone != null && con.Phone != trigger.oldmap.get(con.id).Phone){
            strPhone = con.Phone;
        }
        for(Lead ld: con.Leads__r){
            if(strEmail != null && strEmail != ''){
                ld.Email = strEmail;
            }
            if(strPhone != null && strPhone != ''){
                ld.Phone = strPhone;
            }
            lstLeadUpdate.add(ld);
        }
        /*for(Opportunity opp: con.opportunities){
        
        
        }*/
    }
    
    if(!lstLeadUpdate.isEmpty()){
        update lstLeadUpdate;
    }
    if(!lstOppUpdate.isEmpty()){
        update lstOppUpdate;
    }
}