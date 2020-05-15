public class Liveagent_Testpage_dynamicController{
    
    public List<LiveChatButton> LiveChatButtonList {get; set;}
    public string strOrganizationId {get; set;}
     
    public Liveagent_Testpage_dynamicController(){
    
        List<Organization> lstOrganization = [SELECT id from Organization];
        if(!lstOrganization.isEmpty()){
            strOrganizationId = lstOrganization[0].id;
            strOrganizationId = strOrganizationId.substring(0, 15);
        }
        
        // Fetch Button Id
        LiveChatButtonList = [SELECT id, developerName from LiveChatButton];
        
        List<LiveChatDeployment> LiveChatDeploymentList = [SELECT id, developerName from LiveChatDeployment];
        for(LiveChatDeployment lcd: LiveChatDeploymentList){
        
        }
    
    }
}