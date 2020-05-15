public class ctrlVolumeByCaseOpenLastMonth{    
    public List<PieWedgeData> getpieData(){  
        List<PieWedgeData> data = new List<PieWedgeData>();
        List<Case> lstCase = new List<Case>();
       // List<AggregateResult> groupedResults = [SELECT Source_of_Case_Initiation__c  sc, Count(id) tot FROM Case  where Archieved__c = false and Recordtype.DeveloperName = 'Employee_Relations' and CreatedDate = THIS_YEAR GROUP BY Source_of_Case_Initiation__c];
        List<AggregateResult> groupedResults = [SELECT Last_Issued_Outcome__c  lo, Count(id) tot FROM Case where CreatedDate = LAST_MONTH and Status !='Closed' GROUP BY Last_Issued_Outcome__c];
       
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