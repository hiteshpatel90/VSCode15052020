/*
Apex Class : old_createContactController
Purpose :  create or update cotact record from Community
Createddate : 09/11/2018
*/
public class old_createContactController{
    /*
    Description : This method is used to create or update cotact record from Community
    Parameter   : Firstname, Lastname, Email, Phone of Contact
    Return type : Id of Contact record
    */
    @AuraEnabled 
    Public Static String saveContactRecord(String strFirstName,  String strLastName, String strEmail, String strPhone){
        try{
            Boolean isContactExist = false;
            List<Contact> lstCon = new List<Contact>();
            if(strEmail != '' && strEmail != null){
                lstCon = [SELECT id FROM Contact WHERE Email =: strEmail];
                if(!lstCon.isEmpty()){
                    isContactExist = true;
                }
            }
            if(isContactExist == true){                
                contact updateObjCon = lstCon[0];
                updateObjCon.FirstName = strFirstName;
                updateObjCon.LastName = strLastName;
                updateObjCon.Phone = strPhone;
                update updateObjCon;
                return updateObjCon.id;                
            }else{             
                Contact objCon = new Contact();
                objCon.FirstName = strFirstName;
                objCon.LastName = strLastName;
                objCon.Email = strEmail;
                objCon.Phone = strPhone;
                insert objCon;
                return objCon.id;                   
            }// End of If
            
        }catch (Exception ex){
            return null;
        }        
    }// End of Method - saveContactRecord
}// End of Class