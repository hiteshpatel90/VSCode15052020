public with Sharing class ctrlVolumeByType{  
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
        List<AggregateResult> groupedResults = [SELECT Type typ, Count(id) total FROM Case where Archieved__c = false and Recordtype.DeveloperName = 'Employee_Relations' and CreatedDate = THIS_YEAR and Owner.userrole.name like: strtempRoleContains GROUP BY Type];
        barWedgeData objbarWedgeData;
        set<String> strCaseowName = new set<String>();
        boolean isAdd = false;
        for (AggregateResult ar : groupedResults){
            if(string.valueOf(ar.get('typ')) !=null){           
                objbarWedgeData = new barWedgeData();
                objbarWedgeData.caseType = string.valueOf(ar.get('typ'));
                objbarWedgeData.isCountType = integer.valueOf(ar.get('total'));                            
                data.add(objbarWedgeData);                
            }            
         }
        return data;  
    }  
    
    // Wrapper class  
    public class barWedgeData {  
        public String caseType{ get; set; }   
        public Integer isCountType { get; set; }
        public barWedgeData () {  
            isCountType = 0;
            
        }  
    }  
}