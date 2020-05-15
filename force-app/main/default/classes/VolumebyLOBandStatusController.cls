public class VolumebyLOBandStatusController{  
    public List<barWedgeData> getBarchartData() {  
        List<barWedgeData> data = new List<barWedgeData>();

        List<AggregateResult> groupedResults = [SELECT status st, LOB_Name__r.Name lob, Count(id) FROM Case where Archieved__c = false and Recordtype.DeveloperName = 'Employee_Relations' and CreatedDate = THIS_YEAR GROUP BY ROLLUP(LOB_Name__r.Name,Status)];
        barWedgeData objbarWedgeData;
        set<String> strCaseowName = new set<String>();
        boolean isAdd = false;
        
        set<String> sOwname = new set<String>();
        for (AggregateResult ar : groupedResults)  {
            if(sOwname.contains(string.valueOf(ar.get('lob'))) == false){
                objbarWedgeData = new barWedgeData();
                objbarWedgeData.caseOwner = string.valueOf(ar.get('lob'));
                sOwname.add(string.valueOf(ar.get('lob')));
            }            
            if(string.valueOf(ar.get('lob')) !=null){
                if(string.valueOf(ar.get('st')) != null){
                    if(string.valueOf(ar.get('st')) == 'New'){
                        objbarWedgeData.isStatusNew = Integer.valueOf(ar.get('expr0'));
                    }
                    if(string.valueOf(ar.get('st')) == 'Working'){
                        objbarWedgeData.isStatusWorking = Integer.valueOf(ar.get('expr0'));
                    }
                    if(string.valueOf(ar.get('st')) == 'Escalated'){
                        objbarWedgeData.isStatusEscalated = Integer.valueOf(ar.get('expr0'));
                    }
                    if(string.valueOf(ar.get('st')) == 'Closed'){
                        objbarWedgeData.isStatusClosed = Integer.valueOf(ar.get('expr0'));
                    }
                }else{
                    data.add(objbarWedgeData);               
                }
            }
            
         }
        return data;  
    }  
    
    // Wrapper class  
    public class barWedgeData {  
        public String caseOwner { get; set; }   
        public Integer isStatusNew { get; set; } 
        public Integer isStatusWorking { get; set; }  
        public Integer isStatusEscalated { get; set; }  
        public Integer isStatusClosed { get; set; }    
        public barWedgeData () {  
            isStatusNew = 0;
            isStatusWorking = 0;
            isStatusEscalated = 0;
            isStatusClosed = 0;
            
        }  
    }  
}