public with sharing class ctrlvolumebyCountry{  
    public List<barWedgeData> getBarchartData() {  
    
      User u = [select id, UserRole.Name  from User where ID =: Userinfo.getuserid()];
        String strRoleContains;
        String strtempRoleContains;
        String stUserRolename =u.UserRole.Name;
        if(stUserRolename!=null && stUserRolename !=''){
            String[] arrUserRoleName= stUserRolename.split(' ');
            strRoleContains=arrUserRoleName[0];
            strtempRoleContains=strRoleContains + '%';
        }    
    
        List<barWedgeData> data = new List<barWedgeData>();

        List<AggregateResult> groupedResults = [SELECT Country__c ctry, Count(id) total FROM Case where Archieved__c = false and Recordtype.DeveloperName = 'Employee_Relations' and CreatedDate = THIS_YEAR and Owner.userrole.name like: strtempRoleContains GROUP  BY Country__c];
        barWedgeData objbarWedgeData;
         for (AggregateResult ar : groupedResults)  {
                       
            if(string.valueOf(ar.get('ctry')) !=null){
                objbarWedgeData = new barWedgeData();
                objbarWedgeData.Contry = string.valueOf(ar.get('ctry'));
                objbarWedgeData.intTotalcase = integer.valueOf(ar.get('total'));
                objbarWedgeData.Percentage= 100;
                data.add(objbarWedgeData);
            }
            
         }
        return data;  
    }  
    
    // Wrapper class  
    public class barWedgeData {  
        public String Contry { get; set; }   
        public Integer intTotalcase { get; set; } 
        public Integer Percentage{ get; set; } 
        
        public barWedgeData () {  
            intTotalcase = 0;
            
        }  
    }  
}