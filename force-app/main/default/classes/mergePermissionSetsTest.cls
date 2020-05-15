////////////////////////////////////////////////////////////////////
//Type                   :  Test Class
//Name                   :  mergePermissionSetsTest
//Company                :
//Created By             :  
//Created Date           :  05/27/2017
//Last Modified By       :  
//Last Modified Date     :  
//Description            :  This test class of "mergePermissionSets".
/////////////////////////////////////////////////////////////////////
@istest
public class mergePermissionSetsTest{
    Private Static testmethod void  myTestMethod(){
        Test.StartTest();
        
        mergePermissionSets objMP = new mergePermissionSets();      
        objMP.createRiceALLUsersPS();        
        Test.StopTest();
    }
    
    Private Static testmethod void  myTestMethod1(){
        Test.StartTest();
        
        mergePermissionSets objMP = new mergePermissionSets();      
        objMP.createDepartmentPS();
        Test.StopTest();
    }
    
    Private Static testmethod void  myTestMethod2(){
        Test.StartTest();
        
        mergePermissionSets objMP = new mergePermissionSets();      
        objMP.createSubDepartmentPS();
        
        Test.StopTest();
    }
}