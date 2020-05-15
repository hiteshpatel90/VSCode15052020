public with sharing class CS_ARTasksCC {
    
    //Swetha Penmethsa -- Release 4.4 -- export list view   
    public boolean currentUserCanExportListview {get;set;}
    public CS_ARTasksCC(){
        AxisUserInfo axisUserInfo = new AxisUserInfo();
        currentUserCanExportListview = true;
        if ( axisUserInfo.currentUserCanExportListview ) {
            currentUserCanExportListview = true;
        }
    }
    //Swetha Penmethsa -- Release 4.4 -- export list view   
    
    public String getCurrentUserTimeZone(){
        return UserInfo.getTimeZone().getID();
    }   //  end of getCurrentUserTimeZone

    @RemoteAction
    public static list<CS_ARTasksService.CS_ARTaskWrapper> retrieveAllTasks(){
        return CS_ARTasksService.retrieveTasks();
    }// end of retrieveTaskDetails
      
    @RemoteAction
    public static boolean checkIfOwnerAndSurgeonTerritory(Id caseId, string ownerId){
        
        CS_ARTasksService.CS_ARTaskWrapper wrapper = CS_ARTasksService.getTaskDetail(caseId);
        return CS_ARTasksService.c_CheckIfOwnerAndAccountTerritory(wrapper.surgeonId, ownerId);
    }
    
    @RemoteAction
    public static void createCaseForSurgeonNotInSameTerritoryAsOwner(String ticketId, string surgeonName, string ticketOwnerName, string surgeonId) {
        CS_ARTasksService.createCaseForSurgeonNotInSameTerritoryAsOwner(ticketId, surgeonName, ticketOwnerName, surgeonId);
    }

    @RemoteAction
    public static CS_ARTasksService.CS_ARTaskWrapper getTaskDetail(String taskId) {
        return CS_ARTasksService.getTaskDetail(taskId);        

    }

    @RemoteAction
    public static CS_ARTasksService.CS_ARTaskWrapper updateTaskStatus(String taskId, String status) {
        return CS_ARTasksService.updateTaskStatus(taskId, status);        
    }

    @RemoteAction
    public static CS_ARTasksService.CS_ARTaskWrapper saveTask(String taskType, List<String> relatedToWhatIds, List<String> relatedToWhoIds, Map<String,String> taskDetails) {
        system.debug('##--CS_ARTasksCC.saveTask.relatedToWhoIds: '+ relatedToWhoIds);
        return CS_ARTasksService.saveTask(taskType, relatedToWhatIds, relatedToWhoIds, taskDetails);

    }    


    // end added by chad

}