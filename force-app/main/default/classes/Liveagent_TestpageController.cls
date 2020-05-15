public class Liveagent_TestpageController{


    public string strSalesUSChatbuttonId {get; set;}
    public string strSalesCandaChatbuttonId {get; set;}        
    public string strServiceUSChatbuttonId {get; set;}
    public string strServiceCandaChatbuttonId {get; set;}  
    public string strSMSCClaimsChatbuttonId {get; set;}
    public string strSMSCFinanceChatbuttonId {get; set;}  
    
    public string strSalesUSChatDeploymentId {get; set;}
    public string strSalesCanadaChatDeploymentId {get; set;}
    public string strServiceUSChatDeploymentId {get; set;}
    public string strServiceCanadaChatDeploymentId {get; set;}
    public string strSMSCClaimsChatDeploymentId {get; set;}
    public string strSMSCFinanceChatDeploymentId {get; set;}
    
    
    public string strOrganizationId {get; set;}

    public Liveagent_TestpageController(){
    
        List<Organization> lstOrganization = [SELECT id from Organization];
        if(!lstOrganization.isEmpty()){
            strOrganizationId = lstOrganization[0].id;
            strOrganizationId = strOrganizationId.substring(0, 15);
        }
        
        // Fetch Button Id
        List<LiveChatButton> LiveChatButtonList = [SELECT id, developerName from LiveChatButton];
        for(LiveChatButton lcb: LiveChatButtonList){
            // Sales US
            if(lcb.developerName == 'LiveChat_Sales_for_US'){
                strSalesUSChatbuttonId = lcb.id;
                strSalesUSChatbuttonId = strSalesUSChatbuttonId.substring(0, 15);
            }
            // Sales Canada
            if(lcb.developerName == 'LiveChat_Sales_for_CA'){
                strSalesCandaChatbuttonId = lcb.id;
                strSalesCandaChatbuttonId = strSalesCandaChatbuttonId.substring(0, 15);
            }
            
            // Service US
            if(lcb.developerName == 'LiveChat_Service_for_US'){
                strServiceUSChatbuttonId = lcb.id;
                strServiceUSChatbuttonId = strServiceUSChatbuttonId.substring(0, 15);
            }
            // Service Canada
            if(lcb.developerName == 'LiveChat_Service_for_CA'){
                strServiceCandaChatbuttonId = lcb.id;
                strServiceCandaChatbuttonId = strServiceCandaChatbuttonId.substring(0, 15);
            }
            
            // SMSC Claims
            if(lcb.developerName == 'LiveChat_SMSC_Claims'){
                strSMSCClaimsChatbuttonId = lcb.id;
                strSMSCClaimsChatbuttonId = strSMSCClaimsChatbuttonId.substring(0, 15);
            }
            // SMSC Finance
            if(lcb.developerName == 'LiveChat_SMSC_Finance'){
                strSMSCFinanceChatbuttonId = lcb.id;
                strSMSCFinanceChatbuttonId = strSMSCFinanceChatbuttonId.substring(0, 15);
            }
        }
        
        // Fetch Chat Deployment
        List<LiveChatDeployment> LiveChatDeploymentList = [SELECT id, developerName from LiveChatDeployment];
        for(LiveChatDeployment lcd: LiveChatDeploymentList){
            // Sales US
            if(lcd.developerName == 'Lenovo_com_LCsales_for_US'){                
                strSalesUSChatDeploymentId = lcd.id;
                strSalesUSChatDeploymentId = strSalesUSChatDeploymentId.substring(0, 15);
            }
            // Sales Canada
            if(lcd.developerName == 'Lenovo_com_LCsales_for_CA'){                
                strSalesCanadaChatDeploymentId = lcd.id;
                strSalesCanadaChatDeploymentId = strSalesCanadaChatDeploymentId.substring(0, 15);
            }
            
            // Service US
            if(lcd.developerName == 'Lenovo_com_LCservice_for_US'){                
                strServiceUSChatDeploymentId = lcd.id;
                strServiceUSChatDeploymentId = strServiceUSChatDeploymentId.substring(0, 15);
            }
            // Service Canada
            if(lcd.developerName == 'Lenovo_com_LCservice_for_CA'){                
                strServiceCanadaChatDeploymentId = lcd.id;
                strServiceCanadaChatDeploymentId = strServiceCanadaChatDeploymentId.substring(0, 15);
            }
            
            // SMSC Claims
            if(lcd.developerName == 'Lenovo_com_LCclaims_for_SMSC'){                
                strSMSCClaimsChatDeploymentId = lcd.id;
                strSMSCClaimsChatDeploymentId = strSMSCClaimsChatDeploymentId.substring(0, 15);
            }
            // SMSC Finance
            if(lcd.developerName == 'Lenovo_com_LCfinance_for_SMSC'){                
                strSMSCFinanceChatDeploymentId = lcd.id;
                strSMSCFinanceChatDeploymentId = strSMSCFinanceChatDeploymentId.substring(0, 15);
            }
            
        }

    
    }
}