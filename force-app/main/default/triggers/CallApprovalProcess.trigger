/******************************************************************************************
** Ameriprise Project
*******************************************************************************************
** Trigger Name: CallApprovalProcess
** Description: This trigger is on Contact object and is used to 
    Call callApproval Class 
    callApproval class with further call Approval process for Contact creation/updation(with atleast mailing Address changed)
    This Trigger is only fired for all Non-System Administrator profile   
** Version: 1.0
** 
**-----------------------------------------------------------------------------------------
**Modification Log:
**----------------
**Developer                  Date          Version               Description
**-----------------------------------------------------------------------------------------
**Pankaj Mishra              17-Jun-2013        1.0               Created
**
**-----------------------------------------------------------------------------------------
**Review Log:
**----------------
**Reviewer                  Date           Version                Comments
**------------------------------------------------------------------------------------------
**              
********************************************************************************************/


trigger CallApprovalProcess on Contact (after insert, after update, before update) {
    
     Recordtype r = [Select id,name from recordtype where name = 'New Contact' limit 1];
     //Profile ProfileName = [select Name from profile where id = :userinfo.getProfileId()];
      Id proId =UserInfo.getProfileId();
      id usrid = userinfo.getuserid();          
      String psid = label.Approval_Permission_Set_Id;       
      List<PermissionSetAssignment> psconid = [Select AssigneeId from PermissionSetAssignment where PermissionSetId = :psid]; 
      Set<Id> conid = new Set<id>();      
      for(PermissionSetAssignment ps : psconid)
      {
          conid.add(ps.AssigneeId);       
      }  
       String  userProfile;
       try {
                Profile aProfile = [SELECT id, name from Profile WHERE id = :proId];
              userProfile = aProfile.name;
            } catch(Exception e) {   
                System.debug('aProfile is null');
            } 
        
      /** 
     ***Author: Pankaj  Mishra
     ***Description:This event will check if record is been created and the Profile of user is not is not equal to 'System Administrator' 
    **/ 
    if(Trigger.isinsert && !callApproval.avoidRecurvise){
        
        if(Test.IsRunningTest()){
            callApproval.CallOnInsert(Trigger.new);
        }
        
        else if(!label.Approval_Process_Profiles.contains(userProfile) && r.name == 'New Contact') {  

        callApproval.CallOnInsert(Trigger.new);     
            
        }// end of inner if         
    }// end of outer if
    
    /**
     ***Author: Pankaj  Mishra
     ***Description:This event will check if record is been updated and the Profile of user is not is not equal to 'System Administrator' and the Mailing Address field been modified.
    **/

    if(Trigger.isupdate && Trigger.isBefore)  
    {
        if(!label.Approval_Process_Profiles.contains(userProfile) && !conid.contains(usrid)) 
        {
            for(Contact c :trigger.new)
            {
                c.IsApprovalProcess__c = true;
            }
        }
        else
        {
            for(Contact c :trigger.new)
            {
                c.IsApprovalProcess__c = false;
            } 
        }           
    }  
    
    if(Trigger.isupdate && Trigger.isAfter){  
        
         if(Test.IsRunningTest()){
             callApproval.CallOnUpdate(Trigger.new, Trigger.old);  
        }
        
       else if(!label.Approval_Process_Profiles.contains(userProfile) && !conid.contains(usrid)) {  
       System.debug('Trigger.new'+Trigger.new);
       callApproval.CallOnUpdate(Trigger.new, Trigger.old);                           
        
       }// end of inner if         
    }// end of outer if
    
    }