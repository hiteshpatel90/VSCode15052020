public with Sharing class ctrlVolumebyOwner{  
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

        List<AggregateResult> groupedResults = [SELECT Owner.Name owd, Count(id) total FROM Case where Archieved__c = false and Recordtype.DeveloperName = 'Employee_Relations' and CreatedDate = THIS_YEAR and Owner.userrole.name like: strtempRoleContains GROUP BY Owner.Name ];
        
        barWedgeData objbarWedgeData;
  
        for (AggregateResult ar : groupedResults)  {                       
            if(string.valueOf(ar.get('owd')) !=null){
                objbarWedgeData = new barWedgeData();
                objbarWedgeData.caseOwner = string.valueOf(ar.get('owd'));
                objbarWedgeData.intTotalCase = integer.valueOf(ar.get('total'));
                data.add(objbarWedgeData);               
            }
         }
        return data;  
    }  
    
    // Wrapper class  
    public class barWedgeData {  
        public String caseOwner { get; set; }   
        public Integer intTotalCase { get; set; }        
        public barWedgeData () {  
            intTotalCase = 0;
        }  
    }  
}