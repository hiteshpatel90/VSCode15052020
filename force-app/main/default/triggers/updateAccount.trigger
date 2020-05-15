trigger updateAccount on Contact (after insert, after update) {
    
    Map<String, String> mp = new Map<String, String>();     
    Set<String> accId= mp.keySet();
    List<Account> newAcc=new List<Account>();
    
    for(Contact con: Trigger.New){
        mp.put(con.AccountId, con.description);
    }
   
   List<Account> accList=[select id, Description from Account where Id In :accId];
   for(Account a:accList){
       a.Description=mp.get(a.Id);
       newAcc.add(a);
   }
   
   update newAcc;
}