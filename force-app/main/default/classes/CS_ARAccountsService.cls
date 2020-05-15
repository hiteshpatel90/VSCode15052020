public with sharing class CS_ARAccountsService {
    
    public static list<CS_ARAccountWrapper> retrieveProviders(){
     list<CS_ARAccountWrapper> lstCS_ARAccountWrapper=new list<CS_ARAccountWrapper>();
     List<Account> lstproviders=CS_ARSearch.searchProvidersInMyTeamTerritory('');
     List<ObjectTerritory2Association> lsterritoryforProvider=new List<ObjectTerritory2Association>();
     List<Id> lstproviderIds=new List<Id>();
     Map<Id,String> accountToTerritoryMap=new Map<Id,String>();
     for(Account provider:lstproviders)
     {
         lstproviderIds.add(provider.Id);
     }
     if(!lstproviders.isEmpty() && lstproviders!=null)
     {
         lsterritoryforProvider=CS_ARAccountsService.retrieveTerritoryForProviders(lstproviderIds);
         
         for(ObjectTerritory2Association oTA:lsterritoryforProvider)
         {
             if(accountToTerritoryMap.keyset().contains(oTA.ObjectId))
             {
                 String existingterrList=accountToTerritoryMap.get(oTA.ObjectId);
                 String newterrList=existingterrList+','+oTA.Territory2.Name;
                 accountToTerritoryMap.put(oTA.ObjectId,newterrList);
             }
             else
             {
                 String newterrList=oTA.Territory2.Name;
                 accountToTerritoryMap.put(oTA.ObjectId,newterrList);
             }    
         }
     }
     for(Account provider:lstproviders)
     {         
         String territory;
         if(accountToTerritoryMap.keyset().contains(provider.Id))
         {
          territory=accountToTerritoryMap.get(provider.Id);
         }
         
         lstCS_ARAccountWrapper.add(new CS_ARAccountWrapper(provider,territory)); 
     }
      //   list<CS_ARAccountWrapper> lstCS_ARAccountWrapper=new 
     //   return lstCS_ARAccountWrapper;
     return lstCS_ARAccountWrapper;
    }
    
     public static List<ObjectTerritory2Association> retrieveTerritoryForProviders(List<Id> accountIdList) {
        
        
         List<ObjectTerritory2Association> assocs= [SELECT ObjectId, Territory2Id, Territory2.Name, Territory2.ParentTerritory2Id FROM ObjectTerritory2Association where ObjectId in: accountIdList];
         
         System.debug('assocs--'+ assocs);

         return assocs;
    } 
    
    public static List<Opportunity> retrieveOpportunitiesByAccountId(String accountId) {
        
        
         List<Opportunity> lstOpportunities= [SELECT Name,Type FROM Opportunity where Account.Id=:accountId];
         
         System.debug('lstOpportunities--'+ lstOpportunities);

         return lstOpportunities;
    } 
    
    public static list<AccountWrapper> retrieveAccountActivity(string activityType, 
                                                                       Id accountId){
        
        list<CS_AccountActivityWrapper> lstCS_AccountActivityWrapper = new list<CS_AccountActivityWrapper>();
        list<AccountWrapper> lstSortedAccountWrapper= new list<AccountWrapper>();
        
        for(Account objAcc :[SELECT Id, 
                                    (SELECT Id, IsDeleted, AccountId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue // fetching history
                                        FROM Histories WHERE Field != 'accountMerged' order by CreatedDate), // updated by srinivas sattoor on 10.23.2017. There is no api name for 'accountMerged' 
                                        
                                    (SELECT Id, CreatedDate, Body, CreatedBy.Name , LastModifiedDate FROM Notes order by LastModifiedDate), //fetching logs
                                    
                                    (SELECT Id, Name, Type, StageName, CreatedDate, CreatedBy.Name, CloseDate FROM Opportunities order by CloseDate DESC) //fetching oppteammembers
                                    //(SELECT Id, CreatedDate, Contact.Name, CreatedBy.Name, IsPrimary FROM OpportunityContactRoles order by CreatedDate), // fetching opportunityContactRoles
                                    //(SELECT Id, CreatedDate, CreatedBy.Name, deleted_by__c, deleted_by__r.Name, Lastmodifieddate, Contact__r.Name FROM Key_Contacts_Opportunity_logs__r order by CreatedDate asc) // fetching deleted opportunityContactRoles
                                    FROM Account WHERE Id = : accountId]){
            
            // adding account history   
            
            if(activityType == 'All Activities' || activityType == 'Log'){                  
                for(AccountHistory objAccHistory :objAcc.Histories){
                    string wrapperNotes ='';
                    
                    if(CS_AROpportunityService.checkIfFieldValueIsId(string.valueof(objAccHistory.NewValue))){
                        continue;
                    }
                    if(CS_AROpportunityService.retrieveFieldName('Account', objAccHistory.Field) == 'Created'){
                        wrapperNotes =  CS_AROpportunityService.retrieveFieldName('Account', objAccHistory.Field) ;
                    }else if(objAccHistory.NewValue != null){
                        wrapperNotes =  'Changed ' + CS_AROpportunityService.retrieveFieldName('Account', objAccHistory.Field);
                        if(objAccHistory.OldValue != null){
                            wrapperNotes += ' from ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccHistory.OldValue));
                            
                        }
                        system.debug('##--wrapperNotes1: '+ wrapperNotes);
                        wrapperNotes += ' to ';
                        wrapperNotes += objAccHistory.NewValue == null?'':CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccHistory.NewValue));
                        system.debug('##--wrapperNotes2: '+ wrapperNotes);
                    
                    }else if(objAccHistory.NewValue == null){
                        
                        wrapperNotes = 'Deleted ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccHistory.OldValue)) + ' in ' + CS_AROpportunityService.retrieveFieldName('Account', objAccHistory.Field);
                        
                    }
                    CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objAccHistory.Id,objAccHistory.CreatedBy.Name,objAccHistory.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG');        
                       lstCS_AccountActivityWrapper.add(objWrapper);   
                    
                }// end of for -each history
                
                
                /*for(Affiliation__c objAccSurgeon : [SELECT Id, Account_hcp__c, Account_p__r.Name,isDeleted, Lastmodifieddate, LastModifiedBy.Name,
                                                                (SELECT Id, ParentId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue FROM Histories order by CreatedDate)
                                                        FROM Affiliation__c WHERE Account_hcp__c= :accountId ALL ROWS]){
                    if(objAccSurgeon.Histories.size() > 0){                                 
                        for(Affiliation__History objAccSurgFieldHistory :objAccSurgeon.Histories){
                            lstCS_AccountActivityWrapper.add(createAccSurgeonHistoryWrapper(objAccSurgFieldHistory , objAccSurgeon));  
                          
       
                        }
                    }
                    if(objAccSurgeon.isDeleted){
                        String strNote = objAccSurgeon.LastModifiedBy.Name + ' deleted ' + objAccSurgeon.Account_p__r.Name;
                        CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objAccSurgeon.Lastmodifieddate, strNote, 'LOG');
                        lstCS_AccountActivityWrapper.add(objWrapper);
                    }
                    
                }*/// end of for-each Affiliation__c 
                
                /*for(Case__c objAccCase: [SELECT Id, Health_Care_Provider__c , Name,
                                                                (SELECT Id, ParentId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue FROM Histories order by CreatedDate)
                                                        FROM Case__c WHERE Health_Care_Provider__c = :accountId ALL ROWS]){
                    if(objAccCase.Histories.size() > 0){                                    
                        for(Case__History objAccCaseHistory :objAccCase.Histories){
                            lstCS_AccountActivityWrapper.add(createAccCaseHistoryWrapper(objAccCaseHistory , objAccCase));  
                        }
                    }
                    
                }// end of for-each Opportunity_Case__c
                
               for(Opportunity objAccOpp: [SELECT Id , Name,
                                                                (SELECT Id, IsDeleted, OpportunityId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue FROM Histories order by CreatedDate)
                                                        FROM Opportunity WHERE Account.Id = :accountId ALL ROWS]){
                    if(objAccOpp.Histories.size() > 0){                                    
                        for(OpportunityFieldHistory objAccOppHistory :objAccOpp.Histories){
                             string wrapperNotes ='';
                    
                    if(CS_AROpportunityService.checkIfFieldValueIsId(string.valueof(objAccOppHistory.NewValue))){
                        continue;
                    }
                     if(CS_AROpportunityService.retrieveFieldName('Opportunity', objAccOppHistory.Field) == 'Created'){
                       
                    }
                     else if(objAccOppHistory.NewValue != null){
                        wrapperNotes = ' Changed Opportunity '+objAccOpp.Name+' '+ CS_AROpportunityService.retrieveFieldName('Opportunity', objAccOppHistory.Field);
                        if(objAccOppHistory.OldValue != null){
                            wrapperNotes += ' from ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccOppHistory.OldValue));
                            
                        }
                        system.debug('##--wrapperNotes1: '+ wrapperNotes);
                        wrapperNotes += ' to ';
                        wrapperNotes += objAccOppHistory.NewValue == null?'':CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccOppHistory.NewValue));
                        system.debug('##--wrapperNotes2: '+ wrapperNotes);
                    
                    }else if(objAccOppHistory.NewValue == null){
                        
                        wrapperNotes = 'Deleted ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccOppHistory.OldValue)) + ' in ' + CS_AROpportunityService.retrieveFieldName('Opportunity', objAccOppHistory.Field);
                        
                    }
                    CS_AccountActivityWrapper  objWrapper = new CS_AccountActivityWrapper (objAccOppHistory.Id,objAccOppHistory.CreatedBy.Name,objAccOppHistory.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG');        
                       lstCS_AccountActivityWrapper.add(objWrapper);    
                        }
                    }
                    
                }*/// end of for-each Opportunity_Case__c
     
              
            } 
            
            //adding surgical cases
            if(activityType == 'All Activities' || activityType == 'Event') {

                for (Event e : CS_EventsService.getEventActivityForAccount(accountId) ) {

                    String note = e.Type;
                    if ( e.Location != null ) { note+=' - '+e.Location; }
                    if ( e.Subject != null ) { note += '\n'+e.Subject; }
                    

                    CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(e.Id,e.CreatedBy.Name,e.StartDateTime,
                                                                                             note,
                                                                                             'EVENT', '');      
                    lstCS_AccountActivityWrapper.add(objWrapper); 
                }

            }
            
            if(activityType == 'All Activities' || activityType == 'Note'){
                for(Note objNote : objAcc.Notes){
                    
                    CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objNote.id,objNote.CreatedBy.Name,objNote.LastModifiedDate,
                                                                                             (objNote.Body).trim(),
                                                                                             'NOTE');       
                        lstCS_AccountActivityWrapper.add(objWrapper);   
                    
                }
            }
            
            if(activityType == 'All Activities' || activityType == 'Task'){
                system.debug('##--retrieveAccountActivity.accountId: '+ accountId);
                List<Task> tasks = CS_ARTasksService.retrieveSFTasksByAssociatedId(accountId);
                system.debug('##--retrieveAccountActivity.tasks: '+ tasks);
                for(Task objTask : tasks){

                    // added status, priority, subject - Chad for  4.1
                    CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objTask.Id,objTask.CreatedBy.Name,objTask.ActivityDate,
                                                                                             objTask.Description,
                                                                                             objTask.Priority,
                                                                                             objTask.Status,
                                                                                             objTask.Subject,
                                                                                             'TASK');       
                        lstCS_AccountActivityWrapper.add(objWrapper);
                    
                }
            }
            
            if(activityType == 'All Activities' || activityType == 'Opportunity'){
                for(Opportunity objOpp : objAcc.Opportunities){
                    CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objOpp.Id,objOpp.CreatedBy.Name,objOpp.CloseDate,
                                                                                             objOpp.Name,
                                                                                             'OPPORTUNITY',objOpp.StageName);       
                        lstCS_AccountActivityWrapper.add(objWrapper);
                    
                }
            }
            
        }
        
        for(CS_AccountActivityWrapper objWrapper : lstCS_AccountActivityWrapper ){
            
            lstSortedAccountWrapper.add(new AccountWrapper(objWrapper));
        }
        lstSortedAccountWrapper.sort();
        System.debug('lstSortedAccountWrapper===='+lstSortedAccountWrapper);
        return lstSortedAccountWrapper;
    
    }// end of retrieveAccountFieldHistory 
     public static CS_AccountActivityWrapper createAccCaseHistoryWrapper(Case__History objAccCaseFieldHistory, 
                                                                          Case__c objAccCase){
        
        string wrapperNotes ='';
        if(CS_AROpportunityService.retrieveFieldName('Case__c', objAccCaseFieldHistory.Field) == 'Created'){
            wrapperNotes =  'Case added'; //objOppCase.Case__r.Name;
        }else{
            wrapperNotes =  ' Changed Case ' + CS_AROpportunityService.retrieveFieldName('Case__c', objAccCaseFieldHistory.Field);
            if(objAccCaseFieldHistory.OldValue != null){
                wrapperNotes += ' from ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccCaseFieldHistory.OldValue));
                
            }
            system.debug('##--wrapperNotes1: '+ wrapperNotes);
            wrapperNotes += ' to ';
            wrapperNotes += objAccCaseFieldHistory.NewValue == null?'':CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccCaseFieldHistory.NewValue));
            system.debug('##--wrapperNotes2: '+ wrapperNotes);
        
        }
        CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper (objAccCaseFieldHistory.Id,objAccCaseFieldHistory.CreatedBy.Name,objAccCaseFieldHistory.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG'); 
       return objWrapper;
        
    }// end of createAccCaseHistoryWrapper
    
    
     /*public static CS_AccountActivityWrapper createAccSurgeonHistoryWrapper(Affiliation__History objAccSurgFieldHistory , 
                                                                          Affiliation__c objAccSurgeon){
        
        string wrapperNotes ='';
        if(CS_AROpportunityService.retrieveFieldName('Account_p__c', objAccSurgFieldHistory.Field) == 'Created'){
            wrapperNotes = objAccSurgFieldHistory.CreatedBy.Name + ' added ' + objAccSurgeon.Account_p__r.Name;
        }else{
            wrapperNotes = objAccSurgFieldHistory.CreatedBy.Name + ' changed ' + CS_AROpportunityService.retrieveFieldName('Account_p__c', objAccSurgFieldHistory.Field);
            if(objAccSurgFieldHistory.OldValue != null){
                wrapperNotes += ' from ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccSurgFieldHistory.OldValue));
                
            }
            system.debug('##--wrapperNotes1: '+ wrapperNotes);
            wrapperNotes += ' to ';
            wrapperNotes += objAccSurgFieldHistory.NewValue == null?'':CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccSurgFieldHistory.NewValue));
            system.debug('##--wrapperNotes2: '+ wrapperNotes);
        
        }
        CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objAccSurgFieldHistory.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG'); 
       return objWrapper;
        
    }*/// end of createAccSurgeonHistoryWrapper
      public static void createNote(string accountId, string noteBody){
        
        Note accountNote = new Note(ParentId = accountId,
                                        Title = 'Account Note',
                                        Body = noteBody);
        insert accountNote ;
    }// end of createNote
      public static void updateNote(string noteId,string note){
            
            Note accountNote = [Select Id,Body from Note where Id=:noteId limit 1];
            accountNote.body=note;
            update accountNote ;
        }// end of createNote
        
     public static void deleteNote(string noteId){
            
            Note accountNote = [Select Id,Body from Note where Id=:noteId limit 1];            
            delete accountNote ;
     }//    
    
     public class CS_AccountActivityWrapper{
        
        public datetime logDate {get;set;}
        public string notes {get;set;}
        public string activityType {get;set;}
        public string logOwner{get;set;}
        public string recId{get;set;}
        public string stage{get;set;}

        // fields added by chad for 4.1
        public string status1 {get;set;}
        public string priority {get;set;}
        public string subject {get;set;}
        
        public CS_AccountActivityWrapper(string p_Id,string p_owner,datetime p_logDate,
                                        string p_notes,
                                         string p_activityType){
            
            recId=p_Id;
            logOwner = p_owner;
            logDate = p_logDate;
            notes = p_notes;
            activityType = p_activityType; 
        }
        public CS_AccountActivityWrapper(string p_Id,string p_owner,datetime p_logDate,
                                        string p_notes,
                                         string p_activityType,
                                         string p_stage){
            
            recId=p_Id;
            logOwner = p_owner;
            logDate = p_logDate;
            notes = p_notes;
            activityType = p_activityType;
            stage = p_stage;
             
        }

        // constructor added by chad for 4.1
        public CS_AccountActivityWrapper(string p_Id,string p_owner,datetime p_logDate,
                                        string p_notes,
                                        string p_status,
                                        string p_priority,
                                        string p_subj,
                                        string p_activityType){
            
            recId=p_Id;
            logOwner = p_owner;
            logDate = p_logDate;
            notes = p_subj; //updated by srinivas sattoor on 10.23.2017. This is the field thats being populated on activity UI //p_notes;
            activityType = p_activityType;
            status1= p_status;
            subject = p_subj;
            priority= p_priority;
            
        }
        
    }// end of CS_AccountActivityWrapper
            
    public class CS_ARAccountWrapper{
    
    public string id {get;set;}
    public string AccountNumber {get;set;}
    public string Name{get;set;}
    public string SAPName {get;set;}
    public string BillingCity{get;set;}
    public string BillingState{get;set;}
    public string Phone{get;set;}
    public string Team {get;set;}
    
    public CS_ARAccountWrapper(Account provider,String territory){
      
      id = provider.Id;
      AccountNumber = provider.Customer_Number__c ;
      Name = provider.Preferred_Name__c;
      SAPName =provider.Name;
      BillingCity =provider.BillingCity;
      BillingState= provider.BillingState;
      Phone= provider.Phone;
      Team = territory;
      
    }// end of CS_ARAccountWrapper    
  }// end of CS_ARAccountWrapper
  public class AccountWrapper implements Comparable {

        public CS_AccountActivityWrapper acc;
        
        // Constructor
        public AccountWrapper (CS_AccountActivityWrapper ac) {
            acc = ac;
        }
        
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            AccountWrapper compareToAcc = (AccountWrapper )compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (acc.logDate < compareToAcc.acc.logDate) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (acc.logDate > compareToAcc.acc.logDate) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            else if(acc.logDate==null){
                returnValue = 1;
            }
            return returnValue;       
        }
    }
    
   public static List<Account_Inventory__c> retrieveAccountInventory(String accId) {
        return [select Account__c, Product__r.Id,Product__r.Name, Product__r.Material_Number__c,Product__r.Material_Group_Number__c,Product__r.Material_Group_Type__c,Quantity__c,Serial_Number__c,High_Par__c,Low_Par__c,Account__r.Biologics__c,Account__r.Disposables__c,Account__r.Equipment_Notes__c,Account__r.Sutures__c,Account__r.Equipment__c,Account__r.Name from Account_Inventory__c where Account__c=:accId ];
    }
    
   public static list<Account_Inventory__c> csaveAccountInventory(String id, 
                                                                    String disposables,
                                                                    String equipment,
                                                                    String equipmentNotes, 
                                                                    String medications,
                                                                    String sutures,
                                                                    List<Account_Inventory__c> productList) { 
        
        Set<Account_Inventory__c> productIds = new Set<Account_Inventory__c>(productList);
        list<Account_Inventory__c> lstinsertAccountInventory = new list<Account_Inventory__c>();
        
        Account acc = null;
        if ( id != null ) {
            acc = [select Id,Name,Disposables__c, Equipment__c, Equipment_Notes__c, Biologics__c, Sutures__c  from Account where Id=:id];
        } else {
            return null; 
        }
        
        
        
        acc.Disposables__c =disposables;
        acc.Equipment__c=equipment;
        acc.Biologics__c=medications;
        acc.Sutures__c  =sutures;
        acc.Equipment_Notes__c=equipmentNotes;
        
        System.debug('notes acc'+acc);
        if ( id != null ) {
            update acc;
        } 
        
        
        // products mapped to this practioner procedure
        Set<Account_Inventory__c> invProductList = new Set<Account_Inventory__c>([select Id,Product__c from Account_Inventory__c where Account_Inventory__c.Account__c=:acc.Id]);
        list<Account_Inventory__c> lstAccountInventory = new list<Account_Inventory__c>();
        if ( invProductList  == null ) { 
            invProductList  = new Set<Account_Inventory__c>(); 
        }
        system.debug('productList ~~~'+productList );
        // Step 1-2 remove all existing products, will replace them with what is coming in
        for ( Account_Inventory__c existingProduct : invProductList ) {
            //delete existingProduct;
            lstAccountInventory.add(existingProduct);
        }
        
        if(lstAccountInventory.size() > 0){
            deleteAccountInventory d_deleteAccountInventory = new deleteAccountInventory();
            d_deleteAccountInventory.c_deleteAccountInventory(lstAccountInventory);
        }
        system.debug('productIds ~~~'+productIds );
              
        // Step 2-2. add products in productIds 
        for(Account_Inventory__c  objAccInv :productIds ){
            
            Account_Inventory__c AccInv = new Account_Inventory__c();
                AccInv.account__c= acc.Id;
                
                lstinsertAccountInventory.add(AccInv);
        }
        
        system.debug('lstinsertAccountInventory~~~'+lstinsertAccountInventory);
        if(lstinsertAccountInventory.size() > 0){
            insert lstinsertAccountInventory;
        }
        
        return lstinsertAccountInventory;
        //return [select Id,Pref_Card_Name__c,Disposables__c, Equipment__c, Equipment_Notes__c, Medications__c,Position__c, Sutures__c,Procedure__r.Name  from Practitioner_Procedure__c where Id=:pp.Id];

    }
    
    public without sharing class deleteAccountInventory{
        
        public void c_deleteAccountInventory(list<Account_Inventory__c> lstAccountInventory){
            
            delete lstAccountInventory;
         system.debug('dellstAccountInventory~~~'+lstAccountInventory);   
        }// end of c_deletePractitionerProcProds
        
    }// end of deletePractitionerProcProds
     
    public static List<Account> searchSurgeonsInMyTeamTerritory(String q) {
        List<Account> foundSurgeons = new List<Account>();
        
        // qualify the search so it only covers surgeons in the caller's territory
         List<Id> surgInTerritoryIds = CS_ARTerritoryService.retrieveSurgeonsInMyTeamTerritory();
        
        if ( q == null || q.length() == 0 ) {
            
            // if there's an empty search just return all the surgeons in the user's territory
             foundSurgeons = [select Id,Name,Profile_Picture__c, Email__c, Provider__r.Id, Provider__r.Name,Phone from Account where Id in :surgInTerritoryIds order by Name Asc];
            

        } else {
            
            // sosl


            String objectName = 'Account';
            List<String> fieldNames = new List<String> { 'Id','Name','Gender__c','Native_Language__c', 
                'Practice_Name__c', 'Profile_Picture__c','Email__c','Provider__r.Id',
                'Provider__r.Name',
                'Internship__c', 'Certifications__c', 
                'Awards__c','Professional_Societies__c','Sport_Interests__c', 'Residencies__c','Fellowships__c'   };
            String filterClause = ' Id in (\''+String.join(surgInTerritoryIds,'\',\'')+'\') ';
            String orderBy = 'Name Asc';
            Integer recordLimit = 25;
            List<SObject> results = CS_ARSearch.searchRecords(q, objectName, fieldNames, filterClause, orderBy, recordLimit);
            for ( SObject obj : results ) {
                foundSurgeons.add( (Account) obj );
            }


        }
        return foundSurgeons;
        
    }
    
    /*Code modified by Ansu on 16/6/2017 
      Release-4.1
      Purpose-Retrieves all surgeons related to an HCO Account    
    */
    public static List<CS_SurgeonAffiliationWrapper> retrieveSurgeonAffiliationsByAccount(String accountId) {
        cls_RetrieveSurgeonAffiliationsByAccount surgeonAffiliations= new cls_RetrieveSurgeonAffiliationsByAccount ();
        List<Affiliation__c> lstSurgeonAffiliations=surgeonAffiliations.retrieveAllSurgeonAffiliationsByAccount(accountId);
        List<Account> practitionersInMyTeam = CS_ARSearch.searchSurgeonsInMyTeamTerritory('');
        Set<Id> practitionersIdSet = new Set<Id>((new Map<Id,SObject>(practitionersInMyTeam )).keySet());
        List<CS_SurgeonAffiliationWrapper > lstSurgeonAffilitaionWrapper=new List<CS_SurgeonAffiliationWrapper >();
        Map<Id,String> practitionerToTeamMap=new Map<Id,String>();
        CS_ARAccountsService.cls_RetrieveTerritoryForPractitioners cls_terrPrac= new CS_ARAccountsService.cls_RetrieveTerritoryForPractitioners() ;
        practitionerToTeamMap=cls_terrPrac.retrieveTerritoryForPractitioners(lstSurgeonAffiliations);
        
 
        for(Affiliation__c surgeonAff:lstSurgeonAffiliations )
            {
                if(practitionersIdSet.contains(surgeonAff.Account_p__c))
                {
                    String team='';
                    if(practitionerToTeamMap.keySet().contains(surgeonAff.Account_p__c))
                    {
                        team=practitionerToTeamMap.get(surgeonAff.Account_p__c);
                    }
                    CS_SurgeonAffiliationWrapper objWrapper = new CS_SurgeonAffiliationWrapper(surgeonAff,true,team);
                    lstSurgeonAffilitaionWrapper.add(objWrapper);
                }
                else
                {
                    String team='';
                    if(practitionerToTeamMap.keySet().contains(surgeonAff.Account_p__c))
                    {
                        team=practitionerToTeamMap.get(surgeonAff.Account_p__c);
                    }
                    CS_SurgeonAffiliationWrapper objWrapper = new CS_SurgeonAffiliationWrapper(surgeonAff,false,team);
                    lstSurgeonAffilitaionWrapper.add(objWrapper);
                }
                
            }
        System.debug('Surgeon Affiliation wrapper --'+ lstSurgeonAffilitaionWrapper);
        return lstSurgeonAffilitaionWrapper;
    }
    
     public class CS_OpportunityActivityWrapper{
        
        public datetime logDate {get;set;}
        public string notes {get;set;}
        public string activityType {get;set;}
        
        public CS_OpportunityActivityWrapper(datetime p_logDate,
                                        string p_notes,
                                         string p_activityType){
            
            logDate = p_logDate;
            notes = p_notes;
            activityType = p_activityType; 
        }
    }// end of CS_OpportunityActivityWrapper
    
    public class OpportunityWrapper implements Comparable {

        public CS_OpportunityActivityWrapper oppy;
        
        // Constructor
        public OpportunityWrapper(CS_OpportunityActivityWrapper op) {
            oppy = op;
        }
        
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            OpportunityWrapper compareToOppy = (OpportunityWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (oppy.logDate < compareToOppy.oppy.logDate) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (oppy.logDate > compareToOppy.oppy.logDate) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }   
    public class CS_SurgeonAffiliationWrapper{
        
        public Affiliation__c surgeonAffiliation {get;set;}
        public boolean editable {get;set;}
        public String team {get;set;}
        
        public CS_SurgeonAffiliationWrapper(Affiliation__c p_affiliation,
                                        boolean p_editable,String p_team){
            
            surgeonAffiliation = p_affiliation;
            editable = p_editable;
            team = p_team;
             
        }
    }// end of CS_OpportunityActivityWrapper 
    
        //Code added by Ansu for getting Surgeon Affiliations to an account in release 2.2. 
    //Code modified and moved from CS_ARContactService by Ansu release 3.2 to include all surgeons affiliated with an account 
    public without sharing class cls_RetrieveSurgeonAffiliationsByAccount {  
        public List<Affiliation__c> retrieveAllSurgeonAffiliationsByAccount(String accountId) {
            List<Affiliation__c> lstAffiliations= [SELECT Id, Name, Full_Name__c, Account_p__r.Name, Surgeon_Designation__c, Surgeon_Phone__c,Surgeon_Type__c, Person_Email__c,Account_p__r.Id,Account_p__c,Account_p__r.Phone,Account_p__r.Practice_Name__c FROM Affiliation__c where Account_hcp__r.Id=:accountId ORDER BY Name desc];
             
            if ( lstAffiliations== null || lstAffiliations.size() == 0 ) { 
                lstAffiliations= new List<Affiliation__c>(); 
            }
            System.debug('All Surgeon Affiliation--'+ lstAffiliations);
            
            return lstAffiliations;
        }
      }
     
    public without sharing class cls_RetrieveTerritoryForPractitioners { 
         public Map<Id,String> retrieveTerritoryForPractitioners(List<Affiliation__c> lstAffiliation) {
        
             Map<Id,String> practitionerToTeamMap=new Map<Id,String>();
             Set<Id> practitionerIdSet = new Set<Id>();
             for(Affiliation__c  af:lstAffiliation  )
             {
              practitionerIdSet.add(af.Account_p__r.Id);          
             }
             System.debug('practitionerIdSet --'+ practitionerIdSet );
             List<ObjectTerritory2Association> assocs= [SELECT ObjectId, Territory2Id, Territory2.Name, Territory2.ParentTerritory2Id FROM ObjectTerritory2Association where ObjectId in: practitionerIdSet ];
             
             if( assocs.size() > 0 ){
                                   
                     for ( ObjectTerritory2Association oT2A:assocs) {
                         String terrString='';
                         for ( ObjectTerritory2Association oT2A2:assocs) {
                         if(oT2A.ObjectId==oT2A2.ObjectId)
                              terrString+= ', ' + oT2A2.Territory2.Name; 
                                        
                         }
                         practitionerToTeamMap.put(oT2A.ObjectId,terrString.substring(1)); 
                      }
                     System.debug('practitionerToTeamMap----------------'+practitionerToTeamMap)    ;               
                
            }          
            //System.debug('practitionerToTeamMap--'+ practitionerToTeamMap);
    
             return practitionerToTeamMap;
         } 
    }   
    
        
}