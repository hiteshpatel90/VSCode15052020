@isTest
public class CS_ARTerritoryMarkerBatch_Test {
    @TestSetup 
    static void setupData(){
        Id practitionerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Undefined').getRecordTypeId();
        Account acc =  new Account(
            Name = 'Test',
            //FirstName = 'FirstTest',
            //LastName = 'LastTestAcc1',
            RecordTypeId = practitionerRecordTypeId
        );
        //insert acc;
        
        Id agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        System.debug('####agencyRecordTypeId: ' + agencyRecordTypeId);
        Account acc1 =  new Account (Name = 'TestAcc1',
                                     RecordTypeId = agencyRecordTypeId);
        insert acc1;
        
        Id HCORecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Healthcare Organization - HCO').getRecordTypeId();
        System.debug('####HCORecordTypeId: ' + HCORecordTypeId);
        Account acc2 =  new Account (Name = 'TestAccHCO1',
                                     RecordTypeId = HCORecordTypeId);
        insert acc2;
        
        Contact con = new Contact(
            FirstName = 'ConTest1',
            LastName = 'LastName1',
            AccountId = acc1.Id,
            MailingCountryCode = 'US',
            Contact_Global_Division__c = 'TestContact_Global_Division__c',
            Contact_Region__c = 'TestContact_Region__c',
            Contact_Country_Code__c = 'TestContact_Country_Code__c',
            Contact_Distributor__c = 'TestContact_Distributor__c'
        );
        insert con;
        
    }
    
    static testMethod void testMethod1(){
        Contact con = [SELECT Id, Name FROM Contact LIMIT 1];
        
        //added by JJ
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        //system.debug('portalRole is ' + portalRole);
        
        //Create user
        Profile portalProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User user1 = new User(
            Username = System.now().millisecond() + 'test12345@test.com',
            //ContactId = con.Id,
            ProfileId = portalProfile.Id,
            UserRoleId = portalRole.Id,
            Alias = 'test123',
            Email = 'EAgnew@sportstekmedical.com',
            Customer_Number__c = '234 567',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Eric',
            LastName = 'Agnew',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert user1;
        
        System.runAs(user1){
            Territory2Model trrtyModel = new Territory2Model(
                Name='Test Model',
                developerName='TestDeveloperModel'
            );
            insert trrtyModel;
            
            Territory2Type trrtryType = [SELECT Id, DeveloperName FROM Territory2Type];
            
            Territory2 prntTrrty2 = new Territory2(
                Name='Arhtrex US & Canada',
                Territory2ModelId=trrtyModel.Id,
                developerName='TestParentDeveloper',
                Territory2TypeId=trrtryType.Id
            ); 
            insert prntTrrty2;
            
            Territory2 trrty2 = new Territory2(
                Name='Arhtrex US & Canada',
                Territory2ModelId=trrtyModel.Id,
                developerName='TestDeveloper',
                ParentTerritory2Id=prntTrrty2.Id,
                Territory2TypeId=trrtryType.Id
            ); 
            insert trrty2;
            
            Territory2 trrty3 = new Territory2(
                Name='Arhtrex US & Canada',
                Territory2ModelId=trrtyModel.Id,
                developerName='TestDeveloper3',
                ParentTerritory2Id=prntTrrty2.Id,
                Territory2TypeId=trrtryType.Id
            ); 
            insert trrty3;
            
            Account accnt = [SELECT Id, Name, RecordType.Name FROM Account where RecordType.Name = 'Healthcare Organization - HCO' LIMIT 1];
            System.debug('###accnt: '+accnt);
            
            ObjectTerritory2Association objTerrAssoc = new ObjectTerritory2Association(
                ObjectId=accnt.Id,
                Territory2Id=trrty2.Id,
                AssociationCause='Territory2Manual'
            );
            insert objTerrAssoc;
            
            
            
            
            Test.startTest();
            
            //Database.executeBatch(new CS_ARTerritoryMarkerBatch(),200);
            Test.stopTest();
        }
    }
    
    static testMethod void testMethod2(){
        Contact con = [SELECT Id, Name FROM Contact LIMIT 1];
        
        //added by JJ
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        //system.debug('portalRole is ' + portalRole);
        
        //Create user
        Profile portalProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User user1 = new User(
            Username = System.now().millisecond() + 'test12345@test.com',
            //ContactId = con.Id,
            ProfileId = portalProfile.Id,
            UserRoleId = portalRole.Id,
            Alias = 'test123',
            Email = 'EAgnew@sportstekmedical.com',
            Customer_Number__c = '234 567',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Eric',
            LastName = 'Agnew',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert user1;
        
        System.runAs(user1){
            Territory2Model trrtyModel = new Territory2Model(
                Name='Test Model',
                developerName='TestDeveloperModel'
            );
            insert trrtyModel;
            
            Territory2Type trrtryType = [SELECT Id, DeveloperName FROM Territory2Type];
            
            Territory2 prntTrrty2 = new Territory2(
                Name='ParentTer',
                Territory2ModelId=trrtyModel.Id,
                developerName='TestParentDeveloper',
                Territory2TypeId=trrtryType.Id
            ); 
            insert prntTrrty2;
            
            Territory2 trrty2 = new Territory2(
                Name='TerChild',
                Territory2ModelId=trrtyModel.Id,
                developerName='TestDeveloper',
                ParentTerritory2Id=prntTrrty2.Id,
                Territory2TypeId=trrtryType.Id
            ); 
            insert trrty2;
            
            Territory2 trrty3 = new Territory2(
                Name='TerChild2',
                Territory2ModelId=trrtyModel.Id,
                developerName='TestDeveloper3',
                ParentTerritory2Id=prntTrrty2.Id,
                Territory2TypeId=trrtryType.Id
            ); 
            insert trrty3;
            
            Territory2 trrty4 = new Territory2(
                Name='TerChild4',
                Territory2ModelId=trrtyModel.Id,
                developerName='TestDeveloper4',
                ParentTerritory2Id=prntTrrty2.Id,
                Territory2TypeId=trrtryType.Id
            ); 
            insert trrty4;
            
            Account accnt = [SELECT Id, Name, RecordType.Name FROM Account where RecordType.Name = 'Healthcare Organization - HCO' LIMIT 1];
            System.debug('###accnt: '+accnt);
            
            ObjectTerritory2Association objTerrAssoc = new ObjectTerritory2Association(
                ObjectId=accnt.Id,
                Territory2Id=trrty2.Id,
                AssociationCause='Territory2Manual'
            );
            insert objTerrAssoc;
            Test.startTest();
            
            //Database.executeBatch(new CS_ARTerritoryMarkerBatch(),200);
            
            //CS_ARTerritoryMarkerBatch sh1 = new CS_ARTerritoryMarkerBatch();
            String sch = '0 0 23 * * ?'; 
            //system.schedule('Test Territory Check', sch, sh1);
            
            Test.stopTest();
        }
    }
    
}