/**
* @File Name:   HOJ_PayloadOperation.cls
* @Description: Payload Operation Class
* @Author:      Fan Yang, fanxyang@deloitte.ca
* @Group:       Apex
* @Last Modified by:   Fan Yang
* @Last Modified time: 2017-09-07 16:53:02
* @Modification Log :
*-------------------------------------------------------------------------------------
* Ver       Date        Author           Modification
* 1.0       2017-05-13  Fan Yang         Created the file/class
* 2.0       2017-06-14  Fariba Taheri    Added Timeout
* 2.1       2017-06-16  Fan Yang         Added FormatURL
* 2.2       2017-09-07  Fan Yang         Added HttpHeaders
*/
public without sharing class HOJ_PayloadOperation{//without sharing is needed to query object/fields the user may not have access ex
        public Id Id{get; private set;}
        public Boolean Active{get; private set;}
        public String Certificate{get; private set;}
        public Integer Timeout{get; private set;}
        public String Name{get; private set;}
        public String URLBase{get; private set;}
        public String URLPath{get; private set;}
        public Boolean FormatURL{get; private set;}
        public String SourceId{get; set;}
        public String HttpMethod{get; private set;}
        public Map<String, String> HttpHeaders{get; private set;}
        private String headers{get;set;}
        private static Map<String, HOJ_PayloadOperation> Operations;

        static{
            Operations = new Map<String, HOJ_PayloadOperation>();
        }

        private HOJ_PayloadOperation(){}

        /**
        * @Name          getByName
        * @Description   Get Operation By Name
        * @Author        Fan Yang
        * @CreatedDate   2017-05-13
        * @Param         String name
        * @Return        HOJ_PayloadOperation
        */
        public static HOJ_PayloadOperation getByName(String name){
            if(String.isEmpty(name)){
                throw new HOJ_PayloadOperationException(
                    'Invalid input - unable to instantiate payload operation');
            }

            if(Operations.containsKey(name)){
                return Operations.get(name);
            }

            List<Payload_Operation__c> ops = [Select
                    Id, Active__c, Certificate_Name__c, Http_Timeout__c,
                    URL_Base__c, URL_Path__c, Http_Method__c, URL_Format__c,
                    Http_Headers__c
                    From Payload_Operation__c
                    Where Operation_Name__c = :name
                    Limit 1
            ];

            if(ops.size() == 1){
                HOJ_PayloadOperation operation = new HOJ_PayloadOperation();
                operation.Name = name;
                operation.Id = ops[0].Id;
                operation.Active = ops[0].Active__c;
                operation.Certificate = ops[0].Certificate_Name__c;
                operation.URLBase = String.isBlank(ops[0].URL_Base__c) ? '' : ops[0].URL_Base__c;
                operation.URLPath = String.isBlank(ops[0].URL_Path__c) ? '' : ops[0].URL_Path__c;
                operation.FormatURL = ops[0].URL_Format__c;
                operation.Timeout = Integer.valueof(ops[0].Http_Timeout__c);
                operation.HttpMethod = ops[0].Http_Method__c;
                operation.headers = ops[0].Http_Headers__c;

                try{
                    if(String.isNotBlank(operation.headers)){
                        operation.HttpHeaders = new Map<String, String>();
                        for(String l : operation.headers.split('\n')){
                            if(String.isNotBlank(l)){
                                String[] nameValues = l.trim().split(':');
                                operation.HttpHeaders.put(nameValues[0].trim(), nameValues[1].trim());
                            }
                        }
                    }
                }catch(Exception e){
                    throw new HOJ_PayloadOperationException('Corrupted Http Header values');
                }


                Operations.put(name, operation);
                return operation;
            }

            return null;
        }

        /**
        * @Name          getEndpoint
        * @Description   Get endpoint
        * @Author        Fan Yang
        * @CreatedDate   2017-06-16
        * @Param         List<String> endpointFormat
        * @Return        String
        */
        public String getEndpoint(List<String> endpointFormat){
            String endpoint = this.URLBase + this.URLPath;
            if(!endpoint.startsWith('callout:') && this.FormatURL && endpointFormat != null && !endpointFormat.isEmpty()){
                endpoint = String.format(endpoint, endpointFormat);
            }

            return endpoint;
        }

        public class HOJ_PayloadOperationException extends Exception{}

}