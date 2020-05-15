/**@@
#APEX CLASS NAME       :   MBW_DIR_CheckTest
#DESCRIPTION           :   This is test class for MBW_DIR_Check (Apex Trigger)
@@**/
@IsTest
public class MBW_DIR_CheckTest{
    
    /**@@
    #DESCRIPTION     : Creating test records
    #Paramaters      : None
    @@**/
    @testSetup static void setup() {
               
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId !=null AND isActive = true LIMIT 1];
        
        System.runAs(admin) {
            // Create a test account record
            Account testAcct = new Account (Name = 'My Test Account');
            insert testAcct;
            
            Pricebook2 pb = new Pricebook2(Name = 'MBW Standard Cost Codes', IsActive = true);
            insert pb;

            Product2 prod1 = new Product2(Name = 'Concrete Polish', ProductCode = '9', IsActive = true);
            insert prod1;

            Product2 prod2 = new Product2(Name = 'Warranty - Concrete Polish', ProductCode = '59', IsActive = true);
            insert prod2;

            PricebookEntry spbe1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod1.Id, UnitPrice = 1);
            insert spbe1;

            PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod1.Id, UnitPrice = 1, IsActive = true);
            insert pbe1;

            PricebookEntry spbe2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod2.Id, UnitPrice = 1);
            insert spbe2;

            PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod2.Id, UnitPrice = 1, IsActive = true);
            insert pbe2;

            Account acc = new Account(Name = 'Test Acc');
            insert acc;

            // Create a test job record            
            job_site__c job = new Job_Site__c(Name = 'Test Job', Department__c = '100-Anaheim', Job_Status__c = '1 - Bid', General_Contractor__c = testAcct.Id);
            insert job;
            
            // Create a test opportunity record
            Opportunity oppt = new Opportunity();
            oppt.Name ='New Test Opp';
            oppt.AccountID = testAcct.ID;
            oppt.StageName = 'Prospecting';
            oppt.Amount = 100;
            oppt.CloseDate = System.today();
            oppt.DIR_Attached__c = false;
            oppt.Job__c = job.id;
            insert oppt;
        }
    }// END OF METHOD - setup
    
    /**@@
    #DESCRIPTION     : This is a test method used to Cover trigger code
    #Paramaters      : None
    @@**/
    public static testMethod void unitMethod1(){
        // Fetch existin Opportunity record
        Opportunity objOpp = [SELECT id FROM Opportunity LIMIT 1];
        
        // create test Attachment record
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Test Attachment DIR';
        objAttachment.ParentId = objOpp.id;
        objAttachment.Body = blob.valueOf('test');
        insert objAttachment;
        
        // create Attachment record
        delete objAttachment;
    }// END OF METHOD - unitMethod1
    
}