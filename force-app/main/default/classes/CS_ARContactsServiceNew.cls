public class CS_ARContactsServiceNew {

    public static Account saveRelatedContact(Map<String,Object> accountMap) {
        Account c = null;
        /*String id = (String)accountMap.get('id');
        system.debug('##--saveAccount.id: '+ id);
        if ( id == null || id == '') {
            // new related contact

            c = new Account();
        } else {

            //c = [select FirstName,LastName,Email,Description, Phone,MobilePhone,MailingStreet, MailingState, MailingPostalCode, MailingCity, AccountId,Title from Contact where Id=:id];
            // LastName, FirstName, Title, Email, Phone
            c = [select Id, Name, Description, Phone,PersonEmail from Account where Id=:id];
        }
        
        c.FirstName = (String)accountMap.get('firstName');

        if ( accountMap.containsKey('lastName') ) {
            // only update if the map contains the key, last name is required
            c.LastName = (String)accountMap.get('lastName');
        }

        c.PersonEmail = (String)accountMap.get('email');
        c.Phone = (String)accountMap.get('phone');
        c.PersonMobilePhone = (String)accountMap.get('mobile');
        c.BillingStreet = (String)accountMap.get('street');
        c.BillingCity = (String)accountMap.get('city');
        c.BillingState = (String)accountMap.get('state');
        c.BillingCountry = 'United States';
        c.BillingPostalCode = (String)accountMap.get('zip');
        //c.AccountId = (String)accountMap.get('accountId');
        //c.Title = (String)accountMap.get('title');
        c.Description = (String)accountMap.get('notes');
        //c.ownerid = userinfo.getuserid();
        Id surgeonConRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Surgeon Contact').getRecordTypeId();

        c.RecordTypeId = surgeonConRecTypeId;
        upsert c;
        
        AccountShare objAccShare = new AccountShare();
        objAccShare.AccountId = c.id;
        objAccShare.AccountAccessLevel = 'Read';
        objAccShare.CaseAccessLevel = 'Read';
        objAccShare.ContactAccessLevel = 'Read';
        objAccShare.OpportunityAccessLevel = 'Read';
        objAccShare.UserOrGroupId = system.userinfo.getuserid();
        insert objAccShare;
        
        List<User> userList = [select id from User where Profile.Name = 'system administrator' and isActive = true and Email = 'swetha.penmethsa@contractor.arthrex.com' limit 1];
        system.runAs(userList[0]){
        List<Surgeon_Related_Contacts__c> lstSurgeonRelatedCon = new List<Surgeon_Related_Contacts__c>();
        Surgeon_Related_Contacts__c objSRC = new Surgeon_Related_Contacts__c();
        objSRC.Surgeon__c = (String)accountMap.get('accountId');
        objSRC.Surgeon_Contact__c = c.id;
        lstSurgeonRelatedCon.add(objSRC);
        insert lstSurgeonRelatedCon;
        }*/
        return c;
    }
}