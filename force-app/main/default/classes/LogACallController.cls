public class LogACallController{
    // Create a new Task record with salesforce
    @AuraEnabled
    public static void saveTask(Task task){
        insert new Task(
                    Subject = task.Subject,
                    //Type = task.Type,
                    ActivityDate = task.ActivityDate,
                    Description = task.Description,
                    Status = 'Open');
                    
    }
}