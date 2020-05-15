public with sharing class ctrlVolumeByLastIssuedOutcomeLastMonth{    
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
        List<AggregateResult> groupedResults = [SELECT Last_Issued_Outcome__c  lo, Count(id) tot FROM Case where Owner.userrole.name like: strtempRoleContains GROUP BY Last_Issued_Outcome__c ];
        //List<AggregateResult> groupedResults = [SELECT Last_Issued_Outcome__c  lo, Count(id) tot FROM Case where CreatedDate = LAST_MONTH and Status ='Closed' GROUP BY Last_Issued_Outcome__c];
       
        PieWedgeData objPieWedgeData;
        for (AggregateResult ar : groupedResults){ 
            if(string.valueOf(ar.get('lo')) != null && integer.valueOf(ar.get('tot')) !=null){          
                data.add(new PieWedgeData(string.valueOf(ar.get('lo')),integer.valueOf(ar.get('tot'))));            
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