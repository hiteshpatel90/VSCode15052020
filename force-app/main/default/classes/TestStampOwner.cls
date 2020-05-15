@isTest
private class TestStampOwner {
    static testMethod void TestUserInsert(){
        User findadmin = [SELECT id, name, profileid FROM User WHERE Profile.Name ='System Administrator' AND IsActive=true LIMIT 1 ];
        Profile objProfile = [SELECT id FROM Profile WHERE name = 'Standard User' LIMIT 1];
        userrole objuserrole  = [SELECT id FROM userrole WHERE name='NAM Regional Sales Rep - Central' LIMIT 1];
        User u = new User(FirstName='Test',LastName='User',ProfileId = objProfile.Id, LocaleSidKey='eu',LanguageLocaleKey='en_us', Email='tharris@hidglobal.com',Alias='TestUser',Username='tharris@hidglobal.com.TestUser',CommunityNickname='TestUser',EmailEncodingKey='ISO-8859-1', UserRoleId=objuserrole.id,TimeZoneSidKey='Europe/Amsterdam');
        System.runAs(findadmin){
            insert u;
        }
        
        Lead l = new Lead(Company='Test Company',LastName='TestLead',Ownerid=u.id,Status='New',LeadSource='Banner', Role__c='Partner', Areas_of_Interest__c='Animal ID');
        insert l;
        
        List<Lead> le = new List<Lead>();        
        for(Integer i=0; i <= 250; i++){
            String cn = 'Test' + String.valueOf(i);
            String ln = 'test company' + String.valueOf(i);
            le.add(new Lead(Company=cn,LastName=ln,Ownerid=u.id,Status='New',LeadSource='Banner', Role__c='Partner', Areas_of_Interest__c='Animal ID'));
            system.debug(le);
        }
        insert le;
        system.debug(le);
        
        Task t = new Task(WhoId = l.id, Status='Completed',Ownerid=u.id,Priority='Normal', Type='Call', Subject='Test' ); 
        insert t;
        
        system.assertEquals(l.First_Touch__c, t.CreatedDate);
        system.assertEquals(l.ownerid, t.ownerid);
    }    
}