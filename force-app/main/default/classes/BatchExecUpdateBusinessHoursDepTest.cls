////////////////////////////////////////////////////////////////////
//Type                   :  Test Class
//Name                   :  BatchExecUpdateBusinessHoursDepTest
//Company                :
//Created By             :  
//Created Date           :  12/10/2016
//Last Modified By       :  
//Last Modified Date     :  
//Description            :  This test class of "BatchExecUpdateBusinessHoursDepartment".
/////////////////////////////////////////////////////////////////////
@istest
public class BatchExecUpdateBusinessHoursDepTest{
    Private Static testmethod void  myTestMethod(){
        
        //create a test Lead
        Lead objLead = new Lead();     
        objLead.FirstName = 'Test Fname';
        objLead.LastName = 'Test Lname';
        objLead.Email = 'test@test.com';
        objLead.LeadSource = 'Live Chat';
        objLead.Company = 'ACME';
        insert objLead;      
        
        //create a Live Chat Visitor
        LiveChatVisitor objVisitor = new LiveChatVisitor();
        insert objVisitor;      
        
        String strChatButtonId;
        // Get existing 'B2C Sales Chat' business hour record
        List<LiveChatButton> lstLiveChatButtons = [SELECT id,DeveloperName from LiveChatButton where DeveloperName Like '%Sales%'];
        
        if(!lstLiveChatButtons.isEmpty()){
            strChatButtonId = lstLiveChatButtons[0].id;
        }
        
        //create a Live Chat Transcript
        LiveChatTranscript objLCT = new LiveChatTranscript();
        objLCT.LiveChatVisitorId = objVisitor.Id;
        objLCT.LeadId = objLead.Id;
        objLCT.Body = 'Test Chat';
        objLCT.LiveChatButtonId = strChatButtonId;
        objLCT.Requesttime = system.today();
        insert objLCT;
        
        Test.startTest();
        string strSOQL = 'SELECT id, LiveChatButtonId, Requesttime  from LiveChatTranscript';
        BatchExecUpdateBusinessHoursDepartment batchApex = new BatchExecUpdateBusinessHoursDepartment(strSOQL);
        Database.executeBatch(batchApex,200);  

        Test.stopTest();
    }    
}