/*
* @File Name:           HOJ_Exception.cls
* @Description:         Exception class for used by HOJ_*
* @Author:              Ferry Cendra, ferry.cendra@stratus360.com
* @Group:               Apex
* @Modification Log:
*-------------------------------------------------------------------------------------------------------
* Ver       Date        Author          User Stories            Modification
* 1.0       2017-12-15  Ferry Cendra    HOJ-1735
*/

public class HOJ_Exception extends Exception {
    public static void LogException(Exception eE, String sMethod) {
        InsertOperationLog(eE, null, null, sMethod, null, 'Failure');
    }

    public static void LogException(Exception eE, String sRequest, String sResponse, String sMethod, String sEndPoint, String sStatus) {
        InsertOperationLog(eE, sRequest, sResponse, sMethod, sEndPoint, sStatus);
    }
    
    public static void InsertOperationLog(Exception eE, String sRequest, String sResponse, String sMethod, String sEndPoint, String sStatus) {
        Payload_Log__c oPL = new Payload_Log__c();

        if(eE != null) {
            oPL.Description__c = eE.getMessage() + ', Line#: ' + eE.getLineNumber();
            oPL.Exception_Stack_Trace__c = eE.getStackTraceString();
            oPL.Exception_Type__c = (eE.getTypeName() == 'HOJ_Exception') ? String.valueOf(eE.getCause()) : eE.getTypeName();
        }

        oPL.Incoming_Payload__c = sResponse;
        //oPL.Operation_Method__c = 'SOAP';
        oPL.Operation_Name__c = sMethod;
        oPL.Outgoing_Payload__c = sRequest;
        oPL.Remote_Endpoint__c = sEndPoint;
        oPL.Source_Id__c = UserInfo.getUserId();
        oPL.Status__c = sStatus;

        insert oPL;
    }
}