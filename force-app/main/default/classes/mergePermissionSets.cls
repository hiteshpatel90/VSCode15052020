public class mergePermissionSets{
    
    public integer intTotalUsers {get; set;}
    public mergePermissionSets(){
        // Total Users = 555 -- intTotalUsers
        intTotalUsers = 0;
        intTotalUsers = [select id from User where UserType = 'Standard' and isActive = true and  profile.UserLicenseId = '10050000000IuuOAAS' and EmployeeNumber != ''].size();
    
    }
    
    // This method is used to create RICE ALL Users Permission Set
    public void createRiceALLUsersPS(){
       
        List<PermissionSet> lstALLUsersPS = [SELECT id from PermissionSet WHERE Name = 'Rice_All_Users' LIMIT 1];
        PermissionSet objPS = new PermissionSet();
        if(!lstALLUsersPS.isEmpty()){
            objPS = new PermissionSet(id=lstALLUsersPS[0].id);            
        }else{
            List<Userlicense> lstuserlicense = [SELECT id, name from Userlicense where Name = 'Salesforce' LIMIT 1];
            if(!lstuserlicense.isEmpty()){
                objPS = new PermissionSet();
                objPS.Name = 'Rice_All_Users';
                objPS.Label = 'Rice_All_Users';
                objPS.LicenseId = lstuserlicense[0].id;                
                insert objPS;
            }
        }
        
        // 60% of 555 = 333
        Integer intSixtyPercent = 0;
        if(intTotalUsers > 0){
            intSixtyPercent = (60*intTotalUsers)/100;
        }
        
        set<Id> sPermissionId = new set<Id>();
        List<AggregateResult> lstAggregateResult = [SELECT count(AssigneeId) totalUsers, PermissionSetId psId, PermissionSet.Name psName from PermissionsetAssignment group by PermissionSetId, PermissionSet.Name];
        
        Map<Id, String> mapPS = new Map<Id, String>();        
        for(AggregateResult agr: lstAggregateResult){
            if(integer.valueOf(agr.get('totalUsers')) >= intSixtyPercent){
                sPermissionId.add(string.valueOf(agr.get('psId')));
                
                mapPS.Put(string.valueOf(agr.get('psId')), string.valueOf(agr.get('psName')));
            }
        }
        
        string strSOQL = 'SELECT id, name from PermissionSet WHERE id in: sPermissionId';
        BatchExecmergePermissionSets batchApex = new BatchExecmergePermissionSets(objPS.id, sPermissionId);
        Database.executeBatch(batchApex, 200);   
                
    }
    
    // This method is used to create Department Permission Set
    public void createDepartmentPS(){
        if(Test.isRunningTest() == false){
            BatchExecmergeDepartmentPermissionSets batchApex = new BatchExecmergeDepartmentPermissionSets();
            Database.executeBatch(batchApex, 1); 
        }
    }
    
    // This method is used to create Sub-Department Permission Set
    public void createSubDepartmentPS(){
        if(Test.isRunningTest() == false){
            BatchExecmergeSubDeptPermissionSets batchApex = new BatchExecmergeSubDeptPermissionSets();
            Database.executeBatch(batchApex, 1);
        }
    }
    
}