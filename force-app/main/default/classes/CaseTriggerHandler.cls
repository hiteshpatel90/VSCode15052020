public class CaseTriggerHandler{
    public void execute(Map<Id, Case> history, Case[] current) {
        if(Trigger.isBefore && Trigger.isInsert){
            assignAndUpdateCase(current);
        }
    }
    
     public void assignAndUpdateCase(List<Case> current) {
         system.debug('#########');
         List<Case> caseListUpdate = new List<Case>();
         List<Group> QueueList = [select Id from Group where Name = 'Dispatch' and Type = 'Queue'];
         string strDispatchQueueId = '';
         if(!QueueList.isEmpty()){
             strDispatchQueueId = QueueList[0].id;
         }
         
         Case objCase;
         for(Case cs: current){
             system.debug('#########'+cs.Origin);
             if(cs.Origin == 'Email'){
                 cs.Status = 'Dispatch';
                 if(strDispatchQueueId != ''){
                     cs.ownerid = strDispatchQueueId;
                 }
                 caseListUpdate.add(objCase);
             }
         }
         
     }
}