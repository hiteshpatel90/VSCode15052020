public with sharing class AxisUserInfo {

    public boolean currentUserCanPublishToAgencyMaster {get;set;}
    //Swetha P -4.4 Release --- role in the agency --export for list view
    public boolean currentUserCanExportListview {get;set;}
    
    public Boolean currentUserOIAccess{get;set;}
    
    public AxisUserInfo() {
        
        User me = [select Distributor__c, Name, ContactId,Contact.Name,Contact.Role_In_Agency__c, Calendar_Color__c from User where Id=:UserInfo.getUserId()];
        if ( me != null ) {

          AXIS_Report_Management__c publishSettings = AXIS_Report_Management__c.getValues(me.Contact.Role_In_Agency__c);
          if ( publishSettings != null && publishSettings.Publish_to_Calendar__c ) {
            currentUserCanPublishToAgencyMaster = true;
          } else {
            currentUserCanPublishToAgencyMaster = false;
          }
           //Swetha P -4.4 Release --- role in the agency --export for list view
          if ( publishSettings != null && publishSettings.Allow_List_View_Export__c && me.Contact.Role_In_Agency__c != null )  { 
            currentUserCanExportListview  = true;
          } else {
            currentUserCanExportListview = false;
          }
          
          //Added by Ansu release 4.4
          if( publishSettings != null && publishSettings.Allow_OI_Access__c)
            {
                currentUserOIAccess=true;
            }
            else
            {
                currentUserOIAccess=false;
            }
        }
    } 
}