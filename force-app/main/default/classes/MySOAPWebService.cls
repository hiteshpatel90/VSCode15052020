global with sharing class MySOAPWebService {
    webservice static Account getRecord(String id) {
        Account objAcc = [SELECT id, Name FROM Account WHERE id = '0010H00002Xm8MA' LIMIT 1];
        return objAcc;
    }
}