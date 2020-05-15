public with sharing class ctrlVolumebyLOB{  
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

      List<AggregateResult> groupedResults = [SELECT Employee_LOB_static__c lob, Count(id) Total FROM Case where Archieved__c= false and Recordtype.DeveloperName = 'Employee_Relations' and CreatedDate = THIS_YEAR and Owner.userrole.name like: strtempRoleContains GROUP BY ROLLUP(Employee_LOB_static__c)];
       barWedgeData objbarWedgeData;
       map<String, Integer> mapCaseowName = new map<String, Integer>();
       for (AggregateResult ar : groupedResults)  {
           if(string.valueOf(ar.get('lob')) !=null){
               //if(mapCaseowName.containskey(string.valueOf(ar.get('lob'))) == false){
                   mapCaseowName.put(string.valueOf(ar.get('lob')), integer.valueOf(ar.get('total')));
                   objbarWedgeData = new barWedgeData();
                   objbarWedgeData.caseOwner = string.valueOf(ar.get('lob'));
                   objbarWedgeData.isTotalcase = integer.valueOf(ar.get('total'));
                   data.add(objbarWedgeData); 
                      
           }            
        }
       return data;  
   }  
   
   // Wrapper class  
   public class barWedgeData {  
       public String caseOwner { get; set; }
       public Integer isTotalcase { get; set; }         
       public barWedgeData () {  
           isTotalcase = 0;            
       }  
   }  
}