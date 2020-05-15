/******************************************************************************************
** Ameriprise Project
*******************************************************************************************
** Trigger Name: CallApproval
** Description: This Class is based on Contact object and is used to 
    Call Approval process for Contact creation/updation(with atleast mailing Address changed)
    This Class is only called  for all Non-System Administrator profile   
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



public  class CallApproval {

    //variable declarations to control recursion
    Public static boolean avoidRecurvise = False;
    Public static Recordtype r = [Select id,name from recordtype where name = 'New Contact' limit 1];
      /**
     ***Author: Pankaj  Mishra
     ***Description:This method will submit approval process on Contact record creation 
    **/ 
    public static void CallOnInsert(List<contact> ConList){
        system.debug('############');        
        for (Integer i = 0; i < ConList.size(); i++){  
        system.debug('############');                     
                 Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                  req.setComments('Submitted for approval. Please approve.');
                  req.setObjectId(ConList[i].Id);               
                // submit the approval request for processing
                 
                 try{
                    if((r.id == ConList[i].recordtypeid) ){
                         if(!Test.IsRunningTest()){Approval.ProcessResult result = Approval.process(req); 
                             
                         } 
                    }
                 }
                 catch(Exception e){ if(e.getMessage().contains('NO_APPLICABLE_PROCESS')){ ConList[i].addError('Record type should be New Contact');
                    
                       
                     }
                 } 
                                
        }//end of For loop
          avoidRecurvise =true;    //setting up recursion variable 
    }//End of CallOnInsert function
    
    
    /**
     ***Author: Pankaj  Mishra
     ***Description:This method will submit approval process on Contact record Updation 
    **/
     public static void CallOnUpdate(list<contact> ConList, list<contact>oldList){
     system.debug('###########'+ConList.size());          
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                for (Integer i = 0; i < ConList.size(); i++){
                    system.debug('###########'+ConList.size());
                  req = new Approval.ProcessSubmitRequest();
                  req.setComments('Submitted for approval. Please approve.');
                 
                  if(ConList[i].Approval_Entry__c =='YES' && conlist[i].Contact_Approval_Status__c  !=   'Submitted'){
                         
                        req.setObjectId(ConList[i].Id);
                     try{
                        if(!Test.IsRunningTest()){   Approval.ProcessResult result = Approval.process(req);  
                        } 
                 }
                     catch(Exception e){ if(e.getMessage().contains('NO_APPLICABLE_PROCESS')){ ConList[i].addError(e.getMessage());             
                         }
                     }      
                  }            
                          
                  
                }
          avoidRecurvise =true;    
    }//End of CallOnUpdate function
   
}//end of class