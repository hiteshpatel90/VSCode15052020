public class KASummariesController{
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
    public Map<Id, List<wrapperorgIdToInvestmentSummary>> orgIdToInvestmentSummaryList {get; set;}
    public string baseURL {get; set;}
    public KASummariesController(){
        renderTable = true;
        displayGrandTotals = true;
        mainOrgToOrderedSubOrgs = new Map<Id, List<Account>>();
        orgIdToInvestmentSummaryList = new Map<Id, List<wrapperorgIdToInvestmentSummary>>();
        
        List<Account> lstAccount =  [select id, Name, (select id, name from Contacts) from Account limit 5];
        orderedMainOrgs = new List<Account>();
        orderedMainOrgs.add(lstAccount[0]);
        orderedMainOrgs.add(lstAccount[1]);
        orderedMainOrgs.add(lstAccount[2]);
        totals = new Map<Id, List<String>>();
        List<String> lstString = new List<String>{'v', 'v', 'v'};
        totals.put(lstAccount[0].id, lstString);
        totals.put(lstAccount[1].id, lstString);
        totals.put(lstAccount[2].id, lstString);
        
        
        footnotes = [select id, name, Format_Text__c from Footnote__c];
        for(Account acc: orderedMainOrgs){
        
            mainOrgToOrderedSubOrgs.put(acc.id, lstAccount);
            
        }
        
        List<wrapperorgIdToInvestmentSummary> lstWInvSummary;
        for(Account acc: lstAccount){
            lstWInvSummary = new List<wrapperorgIdToInvestmentSummary>();
            wrapperorgIdToInvestmentSummary objWInvSummary;
            for(Contact con: acc.contacts){
                objWInvSummary = new wrapperorgIdToInvestmentSummary();
                objWInvSummary.objContact = con;
                objWInvSummary.fundType = 'Non-Commitment';
                objWInvSummary.startingBalance = 0;
                lstWInvSummary.add(objWInvSummary);
            }
            orgIdToInvestmentSummaryList.put(acc.id, lstWInvSummary);
        }
    }
    
    public class wrapperorgIdToInvestmentSummary{
        public contact objContact {get; set;}
        public string fundType {get; set;}
        public string fundId {get; set;}
        public string fundCode {get; set;}
        public string periodStart {get; set;}
        public integer startingBalance {get; set;}
        public string contributions {get; set;}
        public string distributions {get; set;}
        public string gain {get; set;}
        public string capitalBalance {get; set;}
        public string unrealizedCarriedInterest {get; set;}
        public string netCapitalBalance {get; set;}
        public string periodEnd {get; set;}
    }
    
    public void updateReportingPeriod(){
    
    }
}