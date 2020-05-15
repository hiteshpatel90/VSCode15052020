global class PermissionSetCreationScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        mergePermissionSets obj = new  mergePermissionSets();
        obj.createRiceALLUsersPS();
        
        if(Test.isRunningTest() == false){
            BatchExecmergeDepartmentPermissionSets batchApex = new BatchExecmergeDepartmentPermissionSets();
            Database.executeBatch(batchApex, 1); 
            
            BatchExecmergeSubDeptPermissionSets batchApex1 = new BatchExecmergeSubDeptPermissionSets();
            Database.executeBatch(batchApex1, 1);
        }
    }
}