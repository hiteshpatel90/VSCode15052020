////////////////////////////////////////////////////////////////////
//Type                   :  Test Class
//Name                   :  PermissionSetCreationSchedulerTest
//Company                :
//Created By             :  
//Created Date           :  05/27/2017
//Last Modified By       :  
//Last Modified Date     :  
//Description            :  This test class of "PermissionSetCreationScheduler".
/////////////////////////////////////////////////////////////////////
@istest
public class PermissionSetCreationSchedulerTest{
    Private Static testmethod void  myTestMethod(){
        Test.StartTest();
        
        PermissionSetCreationScheduler sh1 = new PermissionSetCreationScheduler();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test PermissionSetCreationScheduler', sch, sh1);
        
        Test.StopTest();
    }
}