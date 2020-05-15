Public class extTasklistview{
    Public List<Task> lstTask {get; set;}
    Public Map<Id, Account> mapAccount {get; set;}
    Public extTasklistview(apexpages.standardcontroller s){
        mapAccount = new Map<Id, Account>();
        set<Id> sWhoid = new set<Id>();
        
        lstTask = [select id, ActivityDate, Status, Subject, whoid, who.Name, what.Name from Task where status NOT IN ('Completed','Deferred','Not Applicable') and ownerid =: system.userinfo.getuserid()];
        for(Task tsk: lstTask){
           sWhoid.add(tsk.whoid); 
        }
        List<Contact> lstContact = [select id, Account.id, Account.Name from Contact where id in: sWhoid];
        for(Contact con: lstContact){
            Account objAcc = new Account(id=con.Account.id, Name = con.Account.Name);
            mapAccount.put(con.id, objAcc);
        }
        
        
    }
    public pagereference createNewTask(){
        pagereference pr = new pagereference('/00T/e?retURL=/home/home.jsp');
        return pr;
    }
}