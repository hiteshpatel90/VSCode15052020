/***********************************************************************************
* Name: ErrorLogger
* Created by: Hitesh Patel
* Description: This apex class is used to create log in Error log object
************************************************************************************/
public with sharing class ErrorLogger{
    public static List<Error_Log__c> errorLogs{
        get{
            if( errorLogs == NULL ){
                errorLogs = new List<Error_Log__c>();
            }
        return errorLogs;
        }
        set;
    }
    
    public static Error_Logger_Notification__c notifyRecord;
    
    public void log( Exception anException, Set<Id> errorSObjectIds, String customMessage ){
        String sObjectIdsFlattened = String.join( new List<Id>( errorSObjectIds ), ',' );
        log( anException, sObjectIdsFlattened, customMessage );
    }
    
    public void log( Exception anException, String errorSObjectId, String customMessage ){
        String exceptionType = anException.getTypeName();
        String errorMessage = ( customMessage == NULL ) ? '' : customMessage;
        String description =  errorMessage + ' ' + anException.getMessage();
        String stackTrace = anException.getStackTraceString();
        log( errorSObjectId, exceptionType, description, stackTrace );
    }
    
    public void log( String errorSObjectId, String exceptionType, String description, String stackTrace ){
        Error_Log__c newErrorLog = new Error_Log__c();
        newErrorLog.SObject_Id__c = errorSObjectId;
        newErrorLog.Exception_Type__c = exceptionType;
        newErrorLog.Description__c = ' LOG ERROR: ' + description;
        if(description != null){ 
            if(description.length() > 255)   
                newErrorLog.Description_Short__c = description.substring(0,255);
            else
                newErrorLog.Description_Short__c = description;  
        }
        newErrorLog.Stack_Trace__c = stackTrace;
        errorLogs.add( newErrorLog );
        System.debug('In ErrorLogger/log id: ' + errorSObjectId + ' exception type: ' + exceptionType + ' description '  + description);
        insert errorLogs;
    }
    
    public void flush(){
        if( !errorLogs.isEmpty() ){
            Boolean doNotify = false;
            if(System.Test.isRunningTest())
                doNotify = true;
            else{   
                notifyRecord = Error_Logger_Notification__c.getInstance('Notify Data Record');
                doNotify = notifyRecord.Notify__c;
            } 
            List<Database.SaveResult> saveResults = Database.insert( errorLogs, false );
            for( Database.SaveResult aSR : saveResults ){
                if( !aSR.isSuccess() ){
                    doNotify = true;
                    break;
                }
            }
            
            errorLogs.clear();
        }
    
    }
    
   
}