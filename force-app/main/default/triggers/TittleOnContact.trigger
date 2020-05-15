/**@@
# TRIGGER NAME         : TittleOnContact
# HELPER CLASS NAME    : TittleOnContact_Helper
# HANDLER CLASS NAME   : TittleOnContact_Handler
# DISCRIPTION       : THIS TRIGGER WILL POPULATE ALL THE RELATATED CONTACT'S TITTLES TO PARENT ACCOUNT

@@**/

Trigger TittleOnContact on Contact (before insert,before update,before delete , after insert,after update,after delete,after undelete) 
{
    // this is for overall the controll of the trigger by Custom setting
    Tsetting__c t = Tsetting__c.getinstance(userinfo.getUserId());
    if(t.Trigger_Allow__c)
    {
        if(trigger.isBefore)
        {
            system.assertEquals(1, 2);
        }
    }
}