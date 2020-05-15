@IsTest
public class AxisUserInfo_Test {
    @testSetup
    static void dataSetup() {
        
        Account agencyAccount = DataFactoryAccount.createAgencyAccount('Test Agency Account');
        insert agencyAccount;
        
        Contact portalUserContact = DataFactoryContact.createContacts('PortalContact');
        portalUserContact.AccountId = agencyAccount.Id;
        portalUserContact.Role_In_Agency__c = 'None';
        insert portalUserContact;
        
        AXIS_Report_Management__c objARM = new AXIS_Report_Management__c();
        objARM.Name = 'None';
        objARM.Allow_List_View_Export__c = true;
        objARM.Allow_OI_Access__c = true;
        objARM.Publish_to_Calendar__c = true;
        insert objARM;
        
    }
    
    static testmethod void AixsUserInfoContructorTest() {
        
        Contact portalUserContact = [SELECT id, Role_In_Agency__c FROM Contact LIMIT 1];
        AXIS_Report_Management__c objARM = AXIS_Report_Management__c.getValues(portalUserContact.Role_In_Agency__c);
        Test.startTest();
        ClsStaticVariables.DoNotSetPortalUserAsContactOwner = true;
        User portalUser = DataFactoryUser.preparePortalUser();
        portalUser.customer_number__c = 'ArthTest001';
        portalUser.ContactId = portalUserContact.Id;
        insert portalUser;
        Test.stopTest();
       
        
        system.runAs(portalUser){
             
            AxisUserInfo axisUserInfo = new AxisUserInfo();
            system.assertNotEquals(null, axisUserInfo);
            
            objARM.Publish_to_Calendar__c = false;
            update objARM;
            axisUserInfo = new AxisUserInfo();
            
            objARM.Allow_OI_Access__c = false;
            update objARM;
            axisUserInfo = new AxisUserInfo();
        }
    }
}