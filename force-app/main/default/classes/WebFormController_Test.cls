////////////////////////////////////////////////////////////////////
//Type                   :  Test Class
//Name                   :  WebFormController
//Company                :
//Created By             :  
//Created Date           :  02/15/2018
//Last Modified By       :  
//Last Modified Date     :  
//Description            :  This test class of "WebFormController".
/////////////////////////////////////////////////////////////////////
@istest
public class WebFormController_Test{

    /**@@
    #DESCRIPTION     : Creating test records
    #Paramaters      : None
    @@**/
    @testSetup static void setup() {
        // Insert product record
        Product2 testProd = new Product2();
        testProd.Name = 'Test Product';
        testProd.ProductCode = 'TEST';
        testProd.IsActive = true;
        testProd.Description ='TestPTerm';        
        testProd.Family='Subscription';
        insert testProd;
        
        // Insert Account record
        Account accObj = new Account();
        accObj.Name = 'Test Acc';
        accObj.Type='Partner';
        accObj.Industry='TestSoftware';
        accObj.Website = 'www.acmetest.com';
        accObj.NumberOfEmployees =12;
        insert accObj; 
        
        // Insert Contact record
        Contact testContact = new Contact();
        testContact.FirstName='TestFName';
        testContact.LastName = 'Test Lastname';
        testContact.Email ='test@test.com';
        testContact.AccountId = accObj.id;
        testContact.Phone='1345678902';
        insert testContact;
                                    
        // Insert Case record
        Case objCase = new Case();
        objCase.Origin = 'Web';
        objCase.Status = 'New';
        objCase.Type = 'Test type';
        objCase.AccountId = accObj.id;
        objCase.ContactId = testContact.id;
        insert objCase;
        
        // Insert Question__c record
        Question__c objQue = new Question__c();
        objQue.Name = 'Test Question';
        objQue.Full_Question__c = 'TEST';
        insert objQue;
        
        // Insert Product_Question__c record
        Product_Question__c objPQ = new Product_Question__c();
        objPQ.Product__c = testProd.id;
        objPQ.Question__c = objQue.id;
        insert objPQ;
        
        //Insert Answer__c record
        Answer__c objAns = new Answer__c();
        objAns.Answer_text__c = 'Test Answer';
        objAns.Case__c = objCase.id;
        objAns.Product_Question__c = objPQ.id;
        insert objAns;
    }// End of Setup
    
    /**@@
    #DESCRIPTION     :  This test class method is covering methods of WebFormController
    #Paramaters      :  void
    @@**/
    Private Static testmethod void  myTestMethod(){
        Test.StartTest();
        
        // Call getProductFormQuestions
        WebFormController.getProductFormQuestions('Test Product');
        
        // Call insertCase
        List<Product2> lstProduct = [SELECT id FROM Product2 LIMIT 1];
        WebFormController.insertCase('Student', 'Test Primary Issue', 'Test Secondary Issue', lstProduct[0].id, 'Test Description', 'Test Subject', 'test@test.com');
        
        // Call insertAnswers
        List<Case> lstCase = [SELECT id FROM Case LIMIT 1];
        List<Question__c> lstQuestion = [SELECT id FROM Question__c LIMIT 1];
        Map<String, String> answerMap = new Map<String, String>();
        answerMap.Put(lstQuestion[0].id, 'Test Answer');
        WebFormController.insertAnswers(lstCase[0].id, answerMap);
        Test.StopTest();
        
    }// End of myTestMethod
}