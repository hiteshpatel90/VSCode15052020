public class ctrlVolumebyOwnerLastmonth{  
    public List<barWedgeData> getBarchartData() {  
        List<barWedgeData> data = new List<barWedgeData>();
        
        User u = [select id, UserRole.Name  from User where ID =: Userinfo.getuserid()];
        String strRoleContains;
        String strtempRoleContains;
        String stUserRolename =u.UserRole.Name;
        if(stUserRolename!=null && stUserRolename !=''){
            String[] arrUserRoleName= stUserRolename.split(' ');
            strRoleContains=arrUserRoleName[0];
            strtempRoleContains=strRoleContains + '%';
        }    
        List<AggregateResult> groupedResults = [SELECT Owner.Name owd, Count(id) total FROM Case where Owner.userrole.name like: strtempRoleContains and Archieved__c = false and Recordtype.DeveloperName = 'Employee_Relations' GROUP BY Owner.Name];
        //List<AggregateResult> groupedResults = [SELECT Owner.Name owd, Count(id) total FROM Case where  Owner.userrole.name like: strtempRoleContains and Archieved__c = false and Recordtype.DeveloperName = 'Employee_Relations' and CreatedDate = LAST_MONTH GROUP BY Owner.Name];
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