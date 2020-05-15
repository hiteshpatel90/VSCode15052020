public class ctrlbarGraphCountry{  
    public List<barWedgeData> getBarchartData() {  
        List<barWedgeData> data = new List<barWedgeData>();

        List<AggregateResult> groupedResults = [SELECT Work_city__c wc, Country__c ctry, Count(id) FROM Case where Archieved__c = false and Recordtype.DeveloperName = 'Employee_Relations' and CreatedDate = THIS_YEAR GROUP BY ROLLUP(Country__c ,Work_city__c)];
        barWedgeData objbarWedgeData;
        set<String> strCaseowName = new set<String>();
        boolean isAdd = false;
        
        set<String> sOwname = new set<String>();
        for (AggregateResult ar : groupedResults)  {
            if(sOwname.contains(string.valueOf(ar.get('ctry'))) == false){
                objbarWedgeData = new barWedgeData();
                objbarWedgeData.Contry = string.valueOf(ar.get('ctry'));
                sOwname.add(string.valueOf(ar.get('ctry')));
            }            
            if(string.valueOf(ar.get('ctry')) !=null){
                if(string.valueOf(ar.get('wc')) != null){
                    if(string.valueOf(ar.get('wc')) == 'London'){
                        objbarWedgeData.isLondon = Integer.valueOf(ar.get('expr0'));
                    }
                    if(string.valueOf(ar.get('wc')) == 'New York'){
                        objbarWedgeData.isNewyork = Integer.valueOf(ar.get('expr0'));
                    }
                    if(string.valueOf(ar.get('wc')) == 'Jalisco'){
                        objbarWedgeData.isJalisco = Integer.valueOf(ar.get('expr0'));
                    }
                    if(string.valueOf(ar.get('wc')) == 'Bari'){
                        objbarWedgeData.isBari = Integer.valueOf(ar.get('expr0'));
                    }
                    if(string.valueOf(ar.get('wc')) == 'Granada'){
                        objbarWedgeData.isGranada = Integer.valueOf(ar.get('expr0'));
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
        public String Contry { get; set; }   
        public Integer isLondon { get; set; } 
        public Integer isNewyork { get; set; }  
        public Integer isJalisco { get; set; }  
        public Integer isBari { get; set; } 
        public Integer isGranada { get; set; } 
        public barWedgeData () {  
            isLondon = 0;
            isNewyork = 0;
            isJalisco = 0;
            isBari = 0;
            isGranada = 0;
        }  
    }  
}