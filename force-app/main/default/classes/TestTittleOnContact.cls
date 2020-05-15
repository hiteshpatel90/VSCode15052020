@isTest
public class TestTittleOnContact {
    
    
    @testSetup static void setup()
    {
        Tsetting__c settings = Tsetting__c.getOrgDefaults();
        settings.Trigger_Allow__c = true;
        upsert settings;
        
        account a=new account();
        a.Name='TCS';
        
        insert a;
        contact c=new contact();
        c.lastname='Micheal';
        c.AccountId=a.id;
        insert c;
        
 
    }
    @isTest()
    public static void  show()
    {
        
        account acclist=[select id, (select id from contacts) from account where Name='TCS'];
        update acclist;

    }
    
}