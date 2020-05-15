/*
Apex Class : accountReportController
Purpose :  Dispaly list of account records as a report
Createddate : 09/11/2018
*/
public class accountReportController{

    public List<Account> lstAccount {get; set;}
    /*
    Description : Dispaly list of account records as a report
    Constructor
    */
    public accountReportController(){
        lstAccount = [SELECT id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, NumberOfEmployees FROM Account];
    }
    
    @remoteAction
    public static List<Account> fetchAccounts(){
        List<Account> lstAccount = [SELECT id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, NumberOfEmployees FROM Account];
        return lstAccount;
    }
    
    @AuraEnabled
    public static List<Account> filterAccountByName(String strSearchText) {
        if(strSearchText != null && strSearchText != ''){
        String strTempSearch = '%' + strSearchText + '%';
            return [Select id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, NumberOfEmployees from Account WHERE Name LIKE :strTempSearch LIMIT 10];
        }else{
            return [Select id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, NumberOfEmployees from Account LIMIT 10];
        
        }
    }

}