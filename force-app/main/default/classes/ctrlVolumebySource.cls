public with sharing class ctrlVolumebySource{    
    public List<PieWedgeData> getpieData(){  
    
     User u = [select id, UserRole.Name  from User where ID =: Userinfo.getuserid()];
        String strRoleContains;
        String strtempRoleContains;
        String stUserRolename =u.UserRole.Name;
        if(stUserRolename!=null && stUserRolename !=''){
            String[] arrUserRoleName= stUserRolename.split(' ');
            strRoleContains=arrUserRoleName[0];
            strtempRoleContains=strRoleContains + '%';
        }    
    
        List<PieWedgeData> data = new List<PieWedgeData>();
        List<Case> lstCase = new List<Case>();
        //List<AggregateResult> groupedResults = [SELECT Source_of_Case_Initiation__c  sc, Count(id) tot FROM Case  where Archieved__c = false and Recordtype.DeveloperName = 'Employee_Relations' and CreatedDate = THIS_YEAR GROUP BY Source_of_Case_Initiation__c];
        List<AggregateResult> groupedResults = [SELECT Source_of_Case_Initiation__c  sc, Count(id) tot FROM Case where Owner.userrole.name like: strtempRoleContains GROUP BY Source_of_Case_Initiation__c];
       
        PieWedgeData objPieWedgeData;
        for (AggregateResult ar : groupedResults){ 
            if(string.valueOf(ar.get('sc')) != null && integer.valueOf(ar.get('tot')) != null){          
                data.add(new PieWedgeData(string.valueOf(ar.get('sc')),integer.valueOf(ar.get('tot'))));            
            }
        }
        return data;  
    }  
    
    // Wrapper class  
    public class PieWedgeData{  
        public String name { get; set; }  
        public integer data { get; set; }  
       
        public PieWedgeData(String name, integer data) {  
            this.name = name;  
            this.data = data;  
        }  
    } 
}