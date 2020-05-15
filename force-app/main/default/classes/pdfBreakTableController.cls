public class pdfBreakTableController{
    public boolean renderTable {get; set;}
    public List<Account> orderedMainOrgs {get; set;}
    public Map<Id, List<Account>> mainOrgToOrderedSubOrgs {get; set;}
    
    public Boolean renderCommitmentColumns {get;set;}
    public Map<Id, Boolean> displaySubtotals {get; set;}
    public Map<Id, List<String>> subtotals {get; set;}
    public Map<Id, Boolean> displayTotals {get; set;}
    public Map<Id, List<String>> totals {get; set;}
    public Boolean displayGrandTotals {get; set;}
    public List<String> grandTotals {get; set;}
    public Boolean multipleEndDates {get;set;}
    public List<Footnote__c> footnotes {get; set;}
    public Map<Id, List<Contact>> orgIdToInvestmentSummaryList {get; set;}
    public string baseURL {get; set;}
    public pdfBreakTableController(){
        renderTable = true;
        displayGrandTotals = true;
        mainOrgToOrderedSubOrgs = new Map<Id, List<Account>>();
        orgIdToInvestmentSummaryList = new Map<Id, List<Contact>>();
        
        List<Account> lstAccount =  [select id, Name, (select id, name from Contacts) from Account limit 1];
        orderedMainOrgs = new List<Account>();
        orderedMainOrgs.add(lstAccount[0]);
        displayTotals = new Map<Id, Boolean>();
        displayTotals.put(lstAccount[0].id, true);
        displayTotals.put(lstAccount[0].id, true);
        totals = new Map<Id, List<String>>();
        List<String> lstString = new List<String>{'v', 'v', 'v'};
        totals.put(lstAccount[0].id, lstString);
        
        //orderedMainOrgs.add(lstAccount[1]);
        
        for(Account acc: orderedMainOrgs){
        
            mainOrgToOrderedSubOrgs.put(acc.id, lstAccount);
            
        }
        
        for(Account acc: lstAccount){
            orgIdToInvestmentSummaryList.put(acc.id, acc.contacts);
            //orgIdToInvestmentSummaryList.get(acc.id).add(acc.contacts);
        }
        
    }
    
    public void updateReportingPeriod(){
    
    }
}