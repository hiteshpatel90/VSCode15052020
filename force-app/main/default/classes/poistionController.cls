global with sharing class poistionController {
 
      public Position__c pos{get;set;}
      public List<Position__c> title{get;set;}
      public List<Position__c> positions{get;set;}
 
      public poistionController() {
 
         pos = [select Max_Pay__c from Position__c where Name = 'Sr. Java Developer'];
      }
       /**
 
      * Method that creates the select option dynamically.
 
      **/
 
      public List<SelectOption> getOptions() {
 
          List<SelectOption> options = new List<SelectOption>();
          title = [select Position__c.Name from Position__c];
         //Creating an NULL option.
         options.add(new SelectOption('none','--Select--'));
         for( Position__c a :title ){
 
            options.add(new SelectOption(a.Name,a.Name));
         }
         return options;
      }
 
      /**
 
      * Remote action involved with Javascript remoting and is made global
 
      **/
 
      @RemoteAction
      global static Position__c[] getPositionDetails(String pos) {
          return [select Position__c.Name, Max_Pay__c, Min_Pay__c, Days_Open__c from Position__c WHERE                         Position__c.Name =: pos];
 
      }
 
}