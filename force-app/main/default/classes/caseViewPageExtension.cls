public class caseViewPageExtension {
    public Case objCase {get; set;}
    public caseViewPageExtension(ApexPages.StandardController controller) {
        String strCaseId = apexpages.currentpage().getparameters().get('id');
        objCase = [select id, Accountid, Account.Name from Case where id =: strCaseId];
    }

}