////////////////////////////////////////////////////////////////////
//Type                   :  Test Class
//Name                   :  BatchExecmergeSubDeptPermissionSetsTest
//Company                :
//Created By             :  
//Created Date           :  05/27/2017
//Last Modified By       :  
//Last Modified Date     :  
//Description            :  This test class of "BatchExecmergeSubDeptPermissionSets".
/////////////////////////////////////////////////////////////////////
@istest
public class BatchExecmergeSubDeptPermissionSetsTest{
    Private Static testmethod void  myTestMethod(){
        Test.StartTest();
        
        List<Userlicense> lstuserlicense = [SELECT id, name from Userlicense where Name = 'Salesforce' LIMIT 1];
        // Create Rice All Users permission set
        PermissionSet objPS = new PermissionSet();
        objPS.Name = 'Rice_All_Users_Test';
        objPS.Label = 'Rice_All_Users_Test';
        objPS.LicenseId = lstuserlicense[0].id;                
        insert objPS;
        
        
        List<ObjectPermissions> lstObjectPermissions = new List<ObjectPermissions>();
        
        // Create Account Object permissions
        ObjectPermissions obPS = new ObjectPermissions();
        obPS.SobjectType = 'Account';
        obPS.PermissionsRead = true;
        obPS.ParentId = objPS.id;
        lstObjectPermissions.add(obPS);
        
        // Create Contact Object permissions
        obPS = new ObjectPermissions();
        obPS.SobjectType = 'Contact';
        obPS.PermissionsRead = true;
        obPS.ParentId = objPS.id;
        lstObjectPermissions.add(obPS);
        
        insert lstObjectPermissions;
        
        // Create Field permissions
        FieldPermissions fieldPS = new FieldPermissions();
        fieldPS.Field = 'User.Sub_Department__c';
        fieldPS.PermissionsRead = true;
        fieldPS.SobjectType = 'User';
        fieldPS.ParentId = objPS.id;                                                  
        insert fieldPS;
        
        // Create Apex Class/ Visualforce page permissions
        List<ApexClass> lstAC = [select id from ApexClass LIMIT 2];
        if(!lstAC.isEmpty()){
            SetupEntityAccess objSEA = new SetupEntityAccess();
            objSEA.ParentId = objPS.id;
            objSEA.SetupEntityId = lstAC[0].id;
            insert objSEA;
        }
        
        
        // Create Existing Permission sets
        PermissionSet objExistPS = new PermissionSet();
        objExistPS.Name = 'Test_PS_1';
        objExistPS.Label = 'Test_PS_1';
        objExistPS.LicenseId = lstuserlicense[0].id;                
        insert objExistPS;
        
        List<ObjectPermissions> lstObjectPermissionsExist = new List<ObjectPermissions>();
        // Create Account Object permissions
        ObjectPermissions obPSExist = new ObjectPermissions();
        obPSExist.SobjectType = 'Account';
        obPSExist.PermissionsRead = true;
        obPSExist.PermissionsCreate = true;
        obPSExist.PermissionsEdit = true;
        obPSExist.PermissionsDelete = true;
        obPSExist.PermissionsViewAllRecords = true;
        obPSExist.PermissionsModifyAllRecords = true;
        obPSExist.ParentId = objExistPS.id;
        lstObjectPermissionsExist.add(obPSExist);
        
        // Create Contact Object permissions
        obPSExist = new ObjectPermissions();
        obPSExist.SobjectType = 'Contact';
        obPSExist.PermissionsRead = true;
        obPSExist.PermissionsCreate = true;
        obPSExist.PermissionsEdit = true;
        obPSExist.PermissionsDelete = true;
        obPSExist.PermissionsViewAllRecords = true;
        obPSExist.PermissionsModifyAllRecords = true;
        obPSExist.ParentId = objExistPS.id;
        lstObjectPermissionsExist.add(obPSExist);                                               
        insert lstObjectPermissionsExist;
        
        // Create Field permissions
        FieldPermissions fieldPSExist = new FieldPermissions();
        fieldPSExist.Field = 'User.Sub_Department__c';
        fieldPSExist.PermissionsRead = true;
        fieldPSExist.PermissionsEdit = true;
        fieldPSExist.SobjectType = 'User';
        fieldPSExist.ParentId = objExistPS.id;                                                  
        insert fieldPSExist;
        
        
        // Create Apex Class/ Visualforce page permissions
        if(!lstAC.isEmpty() && lstAC.size() >= 2){
            SetupEntityAccess objSEA = new SetupEntityAccess();
            objSEA.ParentId = objExistPS.id;
            objSEA.SetupEntityId = lstAC[1].id;
            insert objSEA;
        }
        
        List<Permissionset> lstPS = [select id from Permissionset where id =: objExistPS.id];
        
        set<Id> sPermissionId = new set<Id>();
        for(Permissionset ps: lstPS){
            sPermissionId.add(ps.id);            
        }
        BatchExecmergeSubDeptPermissionSets batchApex = new BatchExecmergeSubDeptPermissionSets();
        Database.executeBatch(batchApex, 200); 
        
        Test.StopTest();
    }
    
    Private Static testmethod void  myTestMethod1(){
        Test.StartTest();
        
        List<Userlicense> lstuserlicense = [SELECT id, name from Userlicense where Name = 'Salesforce' LIMIT 1];
        // Create Rice All Users permission set
        PermissionSet objPS = new PermissionSet();
        objPS.Name = 'Rice_All_Users_Test';
        objPS.Label = 'Rice_All_Users_Test';
        objPS.LicenseId = lstuserlicense[0].id;                
        insert objPS;
                
        // Create Existing Permission sets
        PermissionSet objExistPS = new PermissionSet();
        objExistPS.Name = 'Test_PS_1';
        objExistPS.Label = 'Test_PS_1';
        objExistPS.LicenseId = lstuserlicense[0].id;                
        insert objExistPS;
        
        List<ObjectPermissions> lstObjectPermissionsExist = new List<ObjectPermissions>();
        // Create Account Object permissions
        ObjectPermissions obPSExist = new ObjectPermissions();
        obPSExist.SobjectType = 'Account';
        obPSExist.PermissionsRead = true;
        obPSExist.PermissionsCreate = true;
        obPSExist.PermissionsEdit = true;
        obPSExist.PermissionsDelete = true;
        obPSExist.PermissionsViewAllRecords = true;
        obPSExist.PermissionsModifyAllRecords = true;
        obPSExist.ParentId = objExistPS.id;
        lstObjectPermissionsExist.add(obPSExist);
        
        // Create Contact Object permissions
        obPSExist = new ObjectPermissions();
        obPSExist.SobjectType = 'Contact';
        obPSExist.PermissionsRead = true;
        obPSExist.PermissionsCreate = true;
        obPSExist.PermissionsEdit = true;
        obPSExist.PermissionsDelete = true;
        obPSExist.PermissionsViewAllRecords = true;
        obPSExist.PermissionsModifyAllRecords = true;
        obPSExist.ParentId = objExistPS.id;   
        lstObjectPermissionsExist.add(obPSExist);                                               
        insert lstObjectPermissionsExist;
        
        // Create Field permissions
        FieldPermissions fieldPSExist = new FieldPermissions();
        fieldPSExist.Field = 'User.Sub_Department__c';
        fieldPSExist.PermissionsRead = true;
        fieldPSExist.PermissionsEdit = true;
        fieldPSExist.SobjectType = 'User';
        fieldPSExist.ParentId = objExistPS.id;                                                  
        insert fieldPSExist;
        
        
        // Create Apex Class/ Visualforce page permissions
        List<ApexClass> lstAC = [select id from ApexClass LIMIT 1];
        if(!lstAC.isEmpty()){
            SetupEntityAccess objSEA = new SetupEntityAccess();
            objSEA.ParentId = objExistPS.id;
            objSEA.SetupEntityId = lstAC[0].id;
            insert objSEA;
        }
        
        List<Permissionset> lstPS = [select id from Permissionset where id =: objExistPS.id];
        
        set<Id> sPermissionId = new set<Id>();
        for(Permissionset ps: lstPS){
            sPermissionId.add(ps.id);            
        }
        
        BatchExecmergeSubDeptPermissionSets batchApex = new BatchExecmergeSubDeptPermissionSets();
        Database.executeBatch(batchApex, 200);
        
        Test.StopTest();
    }
}