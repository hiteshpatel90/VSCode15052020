public class ARPreferenceCardPDFController {



    public Contact objContact {get; set;}

    Public Practitioner_Procedure__c objPractitionerProc {get; set;}

    public List<Practitioner_Procedure_Products__c> productList {get; set;}

    public ARPreferenceCardPDFController(){

        List<User> userList = [select id, Contactid from user where id =: userinfo.getuserid()];

        String strContactId = userList[0].Contactid;

        

        //strContactId = '003i000000fwc5z';

        if(strContactId != null && strContactId != ''){

            objContact = [select id, Name, Phone from Contact where id =: strContactId];

        }

        objPractitionerProc = new Practitioner_Procedure__c(); 

        string ppId = apexpages.currentpage().getparameters().get('pid');

        List<Practitioner_Procedure__c> lstpp = [select Id,Practitioner__r.Name, Practitioner__r.Practice_Name__c, Practitioner__r.Distributor__c, Practitioner__r.Phone, Pref_Card_Name__c, Disposables__c, Equipment__c, Equipment_Notes__c, Medications__c,Position__c, Sutures__c,Procedure__r.Name  from Practitioner_Procedure__c where Id=:ppId];

        if(!lstpp.isEmpty()){

            objPractitionerProc = lstpp[0];

            if ( objPractitionerProc != null ) {

                productList = [select Id, Product__c, Product__r.Name,Product__r.Material_Number__c, Product__r.Description from Practitioner_Procedure_Products__c where Practitioner_Procedure_Products__c.Practitioner_Procedure__c=:objPractitionerProc.Id];

            }

        }
    }
}