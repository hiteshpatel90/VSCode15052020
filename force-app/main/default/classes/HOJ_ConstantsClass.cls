/**
* @File Name:   HOJ_ConstantsClass.cls
* @Description:   
* @Author:      Dipak Sonawane, dsonawane@deloitte.com
* @Group:       Apex
* @Last Modified by:   Kejia Hu
* @Last Modified time: 2018-01-15 07:40:03
* @Modification Log :
*-------------------------------------------------------------------------------------
* Ver       Date        Author      Modification
* 1.0       2017-11-22  Dipak Sonawane    Created the file/class
*/
public class HOJ_ConstantsClass {

    public static final String GRANT_TYPE = 'grant_type';
    public static final String GRANT_TYPE_PASSWORD = 'password';

    public static final String CLIENT_ID = 'client_id';
    public static final String CLIENT_ID_VALUE = '3MVG9szVa2RxsqBaWTdl1FL.6_dzE1RXXLPVXXF9pScVXP.yPSoXfrxK0bZb4sk60AJxcC.AlTcvrCVS3bFUt';

    public static final String CLIENT_SECRET = 'client_secret';
    public static final String CLIENT_SECRET_VALUE= '1379260038873173341';

    public static final String USERNAMEE= '';
    public static final String PASSWORDD= '';    

    public static final String REQUEST_SCOPE = 'scope';
    public static final String CONTENT_TYPE = 'Content-Type';
    public static final String CONTENT_TYPE_APP_URLENCODED = 'application/x-www-form-urlencoded';
    public static final String TOKEN_END_POINT_URL= '';

    public static final String PAYMENT_ENDPOINT = '';    
    public static final String HTTP_METHOD_TYPE_GET = 'GET';    
    public static final String HTTP_METHOD_TYPE_POST = 'POST';
    public static final String ACCESS_TOKEN = 'access_token';
    public static final String TOKEN_TYPE = 'token_type';
    public static final String EXPIRES_IN = 'expires_in';
    public static final String RESPONSE_SCOPE = 'scope';    
    public static final String EQUALS= '=';   
    public static final String DOT= '.';                    
    public static final String AMPERSAND= '&';  

    public static final string AUTHORIZATION = 'Authorization';
    public static String accessToken='';
    public static String ACCOUNTREST_END_POINT_URL= '';        
    public static String ACCOUNT_RT_INDIVIDUAL='Individual';
    public static String SOBJECT_ACCOUNT='Account';
    public static final String SOBJECT_APPLICANT='HOJ_Applicant__c';
                    
    public static final String PARAM_LOAN_ASSET_PURCHASE_AMT='loanAssetPurchaseAmt';                
    public static final String PARAM_DOWN_PAYMENT_AMT='downPaymentAmt';
    public static final String PARAM_REAL_ESTATE_TERRITORY='realEstateTerritory';
    public static final String PARAM_APPLICATION_LOAN_AMT='applicationLoanAmt';
    public static final String PARAM_LOAN_VALUE_RATE='loanToValueRate';                
    public static final String PARAM_PAYMENT_TIME_PERIOD_VAL='paymentTimePeriodVal';
    public static final String PARAM_AMORTIZATION_TIME_PERIOD='amortizationTimePeriod';
    public static final String PARAM_MORTGAGE_CLOSING_DATE='mortgageClosingtDt';
    public static final String PARAM_CUSTOMER_RATE='customerRate';
    public static final String PARAM_CUST_RATE_FEATURE_ID='rateFeatureId';
    public static final String PARAM_CUST_RATE_TYPE_VAL='rateTypeVal';
    public static final String PARAM_CUST_TERM_TYPE_VAL='termTypeVal';
    public static final String PARAM_CUST_TERM_PERIOD_MONTH_COUNT='termPeriodMonthCnt';
    public static final String PARAM_CUST_CUSTOMER_RATE='customerRate';
    public static final String PARAM_APPLICANT='applicant';
    public static final String PARAM_APP_KEY='key';
    public static final String PARAM_APP_AGE_COUNT='applicantAgeCnt';
    public static final String PARAM_APP_TERRITORY='territory';
    public static final String PARAM_APP_CREDIT_PROTECTION='creditProtectionCoverageVal';                  
    public static final String PAYLOAD_OPERATION_1='PAYMENT_API_GET_New';
    public static final String PAYLOAD_OPERATION_INTERIM_API='INTERIM_API_POST';
    public static final String PAYLOAD_OPERATION_FULL_DECISION_API='FULL_DECISION_API_POST';
    public static final String PAYLOAD_OPERATION_LTV='LTV';
    
    public static final String  INVALID_DATE_FORMAT='Please provide date of birth in the correct format';
    public static final String  INVALID_DATE ='Please provide a valid date of birth';   
    public static final String UNBOOK_PAYLOAD_OPERATION='InvokeUnBookRateEndPoint'; // Used by HOJ-1605 - UnbookRateAPI Service
    public static final String ERROR_SERVERSTATUSCODE = 'serverStatusCode';
    
    public static final String CONSTANT_CONDO = 'Condo';
    public static final String CONSTANT_CONDOMINIUM = 'Condominium';    
    public static final String CONSTANT_DETACHED = 'Detached';  
    public static final String CONSTANT_FIXED = 'Fixed';    
    public static final String CONSTANT_OPEN = 'Open';  
    public static final String CONSTANT_CLOSED = 'Closed';  
    public static final String CONSTANT_VARIABLE = 'Variable';
    public static final String CONSTANT_VIRM = 'VIRM';
    public static final String CONSTANT_YEAR = 'year';
    public static final String CONSTANT_YEARS = 'years';
    public static final String CONSTANT_MONTH = 'month';
    public static final String CONSTANT_MONTHS = 'months';
    public static final String CONSTANT_ORIGIN_WEB = 'Web'; 

    public static final Map<String, String> JSON_HEAD = new Map<String,String>{
                        'Accept' => 'application/json'
                        , 'Content-Type' => 'application/json'
                        , 'Authorization' => 'Bearer an_actual_token_here'
                    };      

    public static String getSegmentCode(String segmentName){   //Added as part of HOJ-4354
        List<SegmentID__mdt> sg = [select MasterLabel, DeveloperName, SegmentCode_del__c from SegmentID__mdt];
        Map<String, String> sgMap = new Map<String, String>();
        for(SegmentID__mdt s: sg){
            sgMap.put(s.DeveloperName.toUpperCase(), s.SegmentCode_del__c);
        }
        return sgMap.get(segmentName.toUpperCase());
    }                   
}