///////////////////////////////////////////////////////////////////
//Name                   : LiveAgent_Search_Case_ctrlTest
//Created by             : 
//Created date           : 06/06/2017
//Description            : This is test class for LiveAgent_Search_Case_ctrl class
/////////////////////////////////////////////////////////////////////
@IsTest
public class LiveAgent_Search_Case_ctrlTest {

    @testSetup static void testData(){
        
        Account objAcc = new Account();
        objAcc.Name = 'Test Accoun';
        insert objAcc;
        
        Contact objCon = new Contact();
        objCon.Firstname = 'Test first name';
        objCon.Lastname = 'Test last name';
        objCon.Email = 'test@test.com';
        objCon.AccountId = objAcc.Id;
        insert objCon;
        
        Case objCase = new Case();
        objCase.Subject = 'Test Case';
        objCase.AccountId = objAcc.Id;
        objCase.ContactId = objCon.Id;
        objCase.Live_Chat_Transcript_Chat_Key__c = '4444';
        insert objCase;
        
        CaseComment objCaseComment = new CaseComment();
        objCaseComment.Parentid = objCase.Id;
        objCaseComment.CommentBody = 'Test Case';
        insert objCaseComment;
        
        Attachment objAttachment = new Attachment();
        objAttachment.ParentId = objCase.id;
        objAttachment.Body = blob.valueOf('Test body');
        objAttachment.Name = 'Test Attachment';
        insert objAttachment;
        
    }
    
    static testMethod void testloadExistingCases(){
        LiveAgent_Search_Case_ctrl objLSC = new LiveAgent_Search_Case_ctrl();
        objLSC.locationId = '1234';
        objLSC.PersonEmail = 'test@test.com';
        objLSC.loadExistingCases();
    }
    
    static testMethod void testredirectToNewCase(){
        LiveAgent_Search_Case_ctrl objLSC = new LiveAgent_Search_Case_ctrl();
        objLSC.strSearchCase = '';
        objLSC.redirectToNewCase();
        
        objLSC.strSearchCase = 'T';
        objLSC.redirectToNewCase();
        
        objLSC.strSearchCase = 'Test Case';
        objLSC.redirectToNewCase();
    }
    
    static testMethod void testredirectToCaseDetailPage(){
        List<Case> caseList = [select id  from Case LIMIT 1];
        LiveAgent_Search_Case_ctrl objLSC = new LiveAgent_Search_Case_ctrl();
        objLSC.searchCaseId = caseList[0].id;
        objLSC.chatKeyId = '4444';
        objLSC.redirectToCaseDetailPage();
    }
    
    static testMethod void testcreateNewCase(){
        LiveAgent_Search_Case_ctrl objLSC = new LiveAgent_Search_Case_ctrl();
        objLSC.createNewCase();
    }
    
    static testMethod void testcloneCaseRecord(){
        List<Case> caseList = [select id  from Case LIMIT 1];
        
        LiveAgent_Search_Case_ctrl objLSC = new LiveAgent_Search_Case_ctrl();
        objLSC.cloneCaseRecord();
        objLSC.searchCaseId = caseList[0].id;
        objLSC.firstName = 'Test firstname';
        objLSC.lastname = 'Test lastname';
        objLSC.strDepartment = 'Test department';
        objLSC.cloneCaseRecord();
    }
}