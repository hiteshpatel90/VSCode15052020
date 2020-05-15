public class extExportAccountwithOracle {
    Public List<AggregateResult> lstAggAccount {get; set;}
    public extExportAccountwithOracle(ApexPages.StandardController controller) {
        lstAggAccount = [select count(id) total, Oracle_Customer_Number__c orcleNum from Account where Oracle_Customer_Number__c != null group by Oracle_Customer_Number__c];
    }
}