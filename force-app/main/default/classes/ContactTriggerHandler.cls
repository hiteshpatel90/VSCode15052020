public class ContactTriggerHandler {
    
    public static void handleBeforeUpdate(List <Contact> newContacts, List <Contact> oldContacts) {
        
        Map<String, Contact> contactMap = new Map<String, Contact>();
        
        
        for (Contact contact : newContacts) {
    
                // Make sure another new contact isn't also a duplicate  
    
                if (contactMap.containsKey(contact.Email)) {
                    contact.Email.addError('Another new contact has the '
                                        + 'same email address.');
                } else {
                    contactMap.put(contact.Email, contact);
                }
                if (contactMap.containsKey(contact.Alternate_Email__c)) {
                    contact.Alternate_Email__c.addError('Another new contact has the '
                                        + 'same email address.');
                }else {
                    if (contact.Alternate_Email__c != null){
                        contactMap.put(contact.Alternate_Email__c, contact);
                    }
                }
        }
        
        String strMatchedRecords = '';
        List<Contact> lstExistingContact = [SELECT id, Name, Email FROM Contact WHERE Email IN :contactMap.KeySet()];
       
        for (Contact contact : [SELECT id, Email FROM Contact WHERE Email IN :contactMap.KeySet()]) {
            strMatchedRecords = '';
            Contact newContact = contactMap.get(contact.Email);
            for(Contact con: lstExistingContact){
                if (newContact.id != con.id){
                    strMatchedRecords += '<a href=\'/' + con.id + '\'>' + con.Name + '</a><br>';
                } 
            }
            if (newContact.id != contact.id){
                
                newContact.addError('A contact with this email or Alternate Email address already exists. Please find below suggestions.<br>' + strMatchedRecords, FALSE);
            }
        }
        for (Contact contact : [SELECT id, Alternate_Email__c FROM Contact WHERE  Alternate_Email__c IN :contactMap.KeySet()]) {
            strMatchedRecords = '';
            Contact newContact = contactMap.get(contact.Alternate_Email__c);
            for(Contact con: lstExistingContact){
                if (newContact.id != con.id){
                    strMatchedRecords += '<a href=\'/' + con.id + '\'>' + con.Name + '</a><br>';
                } 
            }
            if (newContact.id != contact.id){
                newContact.addError('A contact with this email or Alternate Email address already exists. Please find below suggestions.<br>' + strMatchedRecords, FALSE);
            }    
        }
    }
    
    public static void handleBeforeInsert(List <Contact> newContacts) {
        
        Map<String, Contact> contactMap = new Map<String, Contact>();
        
        for (Contact contact : newContacts) {
    
                // Make sure another new contact isn't also a duplicate  
    
                if (contactMap.containsKey(contact.Email)) {
                    contact.Email.addError('Another new contact has the '
                                        + 'same email address.');
                } else {
                    contactMap.put(contact.Email, contact);
                }
                if (contactMap.containsKey(contact.Alternate_Email__c)) {
                    contact.Alternate_Email__c.addError('Another new contact has the '
                                        + 'same email address.');
                }else {
                    if (contact.Alternate_Email__c != null){
                        contactMap.put(contact.Alternate_Email__c, contact);
                    }
                }
        }
        String strMatchedRecords = '';
        List<Contact> lstExistingContact = [SELECT id, Name, Email FROM Contact WHERE Email IN :contactMap.KeySet()];
        for(Contact con: lstExistingContact){
            strMatchedRecords += '<a href=\'/' + con.id + '\'>' + con.Name + '</a><br>';
            
        }
        strMatchedRecords = EncodingUtil.urlDecode(strMatchedRecords, 'UTF-8');
         
        for (Contact contact : [SELECT id, Name, Email FROM Contact 
                                WHERE Email IN :contactMap.KeySet()]) {
            Contact newContact = contactMap.get(contact.Email);
            
            newContact.addError('A contact with this email or Alternate Email address already exists. Please find below suggestions.<br>' + strMatchedRecords, FALSE);
        }
        for (Contact contact : [SELECT Alternate_Email__c FROM Contact 
                                WHERE  Alternate_Email__c IN :contactMap.KeySet()]) {
            Contact newContact = contactMap.get(contact.Alternate_Email__c);
            newContact.addError('A contact with this email or Alternate Email address already exists. Please find below suggestions.<br>' + strMatchedRecords, FALSE);
        }
        
    }

}