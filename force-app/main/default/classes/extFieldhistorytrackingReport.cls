public with sharing class extFieldhistorytrackingReport{
    public List<Field_History__c> lstFieldHistory {get; set;}
    public string strSelFilterOption {get; set;}
    public extFieldhistorytrackingReport(apexpages.standardcontroller stdCon){
        lstFieldHistory = [select id, Edit_Date__c, Record_Id__c, User__c,User__r.Name, Field_Event__c, New_Value__c, Old_Value__c, sObject_Name__c from Field_History__c where Tracking_Status__c = 'Archived' order by Createddate LIMIT 10000];
    }
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                size = 3;
                string queryString = 'select id, Edit_Date__c, Record_Id__c, User__c,User__r.Name, Field_Event__c, New_Value__c, Old_Value__c, sObject_Name__c from Field_History__c ';
                if(strSelFilterOption == 'Show archived data'){
                    queryString += ' where Tracking_Status__c = \'Archived\'';
                }else if(strSelFilterOption == 'Hide archived data'){
                    queryString += ' where Tracking_Status__c != \'Archived\'';
                }
                queryString += ' order by Createddate LIMIT 10000';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                //noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
     
    Public List<Field_History__c> getFieldHistories(){
        List<Field_History__c> accList = new List<Field_History__c>();
        for(Field_History__c a : (List<Field_History__c>)setCon.getRecords()){
            Schema.DescribeSobjectResult sObjecttype = Schema.getGlobalDescribe().get(a.sObject_Name__c).getDescribe();
            if (sObjecttype.isAccessible()){
                Schema.DescribeFieldResult field = sObjecttype.fields.getMap().get(a.Field_Event__c).getDescribe();
                if(field.isAccessible()){
                    accList.add(a);
                }
            }
            
        }
        noOfRecords = accList.size();
        return accList;
    }
     
    public pageReference refresh() {
        setCon = null;
        getFieldHistories();
        setCon.setPageNumber(1);
        return null;
    }
     
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
  
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
  
    public void first() {
        setCon.first();
    }
  
    public void last() {
        setCon.last();
    }
  
    public void previous() {
        setCon.previous();
    }
  
    public void next() {
        setCon.next();
    }
    
    public List<SelectOption> getFilterOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None --'));
        options.add(new SelectOption('Show archived data','Show archived data'));
        options.add(new SelectOption('Hide archived data','Hide archived data'));
        return options;
    }
    
    public pagereference exportFieldTracking(){
        pagereference pr = new pagereference('/apex/exportFieldTracking');
        return pr;
    }
}