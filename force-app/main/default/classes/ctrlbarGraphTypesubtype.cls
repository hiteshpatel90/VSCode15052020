public class ctrlbarGraphTypesubtype{  
    public List<barWedgeData> getBarchartData() {  
        List<barWedgeData> data = new List<barWedgeData>();

        List<AggregateResult> groupedResults = [SELECT Sub_Type__c st, Type typ, Count(id) FROM Case where Archieved__c = false and Recordtype.DeveloperName = 'Employee_Relations' and CreatedDate = THIS_YEAR GROUP BY ROLLUP(Type,Sub_Type__c)];
        barWedgeData objbarWedgeData;
        set<String> strCaseowName = new set<String>();
        boolean isAdd = false;
        
        set<String> sOwname = new set<String>();
        for (AggregateResult ar : groupedResults)  {
            if(sOwname.contains(string.valueOf(ar.get('typ'))) == false){
                objbarWedgeData = new barWedgeData();
                objbarWedgeData.caseType = string.valueOf(ar.get('typ'));
                sOwname.add(string.valueOf(ar.get('typ')));
            }            
            if(string.valueOf(ar.get('typ')) !=null){
                if(string.valueOf(ar.get('st')) != null){
                    if(string.valueOf(ar.get('st')) == 'Mech Sub type1'){
                        objbarWedgeData.isMechSubtype1 = Integer.valueOf(ar.get('expr0'));
                    }
                    if(string.valueOf(ar.get('st')) == 'Mech Sub type2'){
                        objbarWedgeData.isMechSubtype2 = Integer.valueOf(ar.get('expr0'));
                    }
                    if(string.valueOf(ar.get('st')) == 'Elect Sub type1'){
                        objbarWedgeData.isElectSubtype1 = Integer.valueOf(ar.get('expr0'));
                    }
                    if(string.valueOf(ar.get('st')) == 'Elect Sub type2'){
                        objbarWedgeData.isElectSubtype2 = Integer.valueOf(ar.get('expr0'));
                    }
                    if(string.valueOf(ar.get('st')) == 'Other Sub type1'){
                        objbarWedgeData.isOtherSubtype1 = Integer.valueOf(ar.get('expr0'));
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
        public String caseType{ get; set; }   
        public Integer isMechSubtype1 { get; set; } 
        public Integer isMechSubtype2 { get; set; }  
        public Integer isElectSubtype1 { get; set; }  
        public Integer isElectSubtype2 { get; set; } 
        public Integer isOtherSubtype1 { get; set; } 
        public barWedgeData () {  
            isMechSubtype1 = 0;
            isMechSubtype2 = 0;
            isElectSubtype1 = 0;
            isElectSubtype2 = 0;
            isOtherSubtype1 = 0;
        }  
    }  
}