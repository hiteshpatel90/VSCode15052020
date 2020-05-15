public with sharing class ctrlVolumeController{    
    public List<WrapperData> data {get;set;}    
    public ctrlVolumeController(){    
    
    User u = [select id, UserRole.Name  from User where ID =: Userinfo.getuserid()];
        String strRoleContains;
        String strtempRoleContains;
        String stUserRolename =u.UserRole.Name;
        if(stUserRolename!=null && stUserRolename !=''){
            String[] arrUserRoleName= stUserRolename.split(' ');
            strRoleContains=arrUserRoleName[0];
            strtempRoleContains=strRoleContains + '%';
        }    
        data = new List<WrapperData>();
        List<AggregateResult> groupedResults = [SELECT Status st, Count(id) tot  FROM Case where Owner.userrole.name like: strtempRoleContains GROUP BY Status];
        for (AggregateResult ar : groupedResults){        
            data.add(new WrapperData(string.valueOf(ar.get('st')),integer.valueOf(ar.get('tot'))));
              
        }    
    }
    //wrapper class
    
    public class WrapperData{    
        public String Status{ get; set; }  
        public integer intCount{ get; set; }    
        public WrapperData(String Status, integer intCount){  
            this.Status= Status;  
            this.intCount = intCount;  
        }
    }

}