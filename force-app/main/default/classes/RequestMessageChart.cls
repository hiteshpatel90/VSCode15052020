public class RequestMessageChart{
    public string values{get;set;}
    public List<Data> lstdata{get;set;}
    public integer CountID {get;set;}
    public integer intEmail {get;set;}
    public integer intPhone {get;set;}
    public integer intSMS {get;set;}
    public integer intPager {get;set;}
    public integer intFax {get;set;}
    public Boolean blnRecords{get;set;}
    public List<SelectOption> optionsFieldName {get;set;}
    public Map<String, Schema.SObjectType> mapGlobalDescribe {get;set;}
    public string strStandardObject {get;set;}
    Public String strToDate {get;set;}
    Public String strFromDate {get;set;}
    Public Date mydate{get;set;}
    Public Notification_Status__c objDate {get;set;}
    
    
    public RequestMessageChart(){
        objDate = new Notification_Status__c();
        lstdata = new List<Data>();
        blnRecords = false;
        values  = '';
        strToDate = '';
        strFromDate = '';
        integer CountID = 0;
        integer intEmail = 0;
        integer intPhone = 0;
        integer intSMS = 0;
        integer intPager = 0;
        integer intFax = 0;  
        GetSelectedObjectFields();      
    }
    
    public void callgetdata(){     
        lstdata = new List<Data>();  
        lstdata = getChartData();
        if(values != 'custom')
        {
            strToDate = '';   
            strFromDate = '';
        }
    }    
    
    public List<Data> getChartData() { 
        
        String dtFromDate;
        String dtToDate;
        string strsql = '';
        if(strFromDate != '') {         
            dtFromDate = String.valueof(date.newInstance(Integer.valueof(strFromDate.split('/')[2]),Integer.valueof(strFromDate.split('/')[0]),Integer.valueof(strFromDate.split('/')[1])));           
        }
        if(strToDate != ''){    
            dtToDate = String.valueof(date.newInstance(Integer.valueof(strToDate.split('/')[2]),Integer.valueof(strToDate.split('/')[0]),Integer.valueof(strToDate.split('/')[1])));            
        }

        system.debug('##########dtToDate' + dtToDate);
        system.debug('##########dtFromDate' + dtFromDate);
        
        LIST<AggregateResult> noOfSum = new LIST<AggregateResult> ();
        if(strStandardObject != null && strStandardObject != '--select--'){
            if(dtFromDate != null && dtToDate == null){
                system.debug('$$$$$$$ dtFromDate' + dtFromDate );
                strsql = 'SELECT count(id) IDC, SUM(Total_Emails__c) totalEmail,SUM(Total_Calls__c) TotalCalls,SUM(SMS__c) TotalSMS,SUM(Total_Pages__c) TotalPages,SUM(Total_Faxes__c) TotalFaxes from Notification_Status__c where day_only('+ strStandardObject+') >= '+ dtFromDate;                       
                
            }else if(dtToDate != null && dtFromDate == null){
                strsql = 'SELECT count(id) IDC, SUM(Total_Emails__c) totalEmail,SUM(Total_Calls__c) TotalCalls,SUM(SMS__c) TotalSMS,SUM(Total_Pages__c) TotalPages,SUM(Total_Faxes__c) TotalFaxes from Notification_Status__c where day_only('+ strStandardObject+') <= '+ dtToDate ; 
            }
            else if(dtToDate   != null && dtFromDate  != null){
                if(dtToDate >= dtFromDate){
                    system.debug('####---'+strsql);
                    strsql = 'SELECT count(id) IDC, SUM(Total_Emails__c) totalEmail,SUM(Total_Calls__c) TotalCalls,SUM(SMS__c) TotalSMS,SUM(Total_Pages__c) TotalPages,SUM(Total_Faxes__c) TotalFaxes from Notification_Status__c where day_only('+ strStandardObject +') >= '+ dtfromDate +' AND day_only('+ strStandardObject+') <= '+ dtToDate ;                
                    if(values != null){
                        //strsql += ' AND ' + values;
                        system.debug('####---'+strsql);                   
                    } 
                }
            
            }else{
                strsql = 'SELECT count(id) IDC, SUM(Total_Emails__c) totalEmail,SUM(Total_Calls__c) TotalCalls,SUM(SMS__c) TotalSMS,SUM(Total_Pages__c) TotalPages,SUM(Total_Faxes__c) TotalFaxes from Notification_Status__c ';
                system.debug('!!!!!!values' + values);
                if(values != null && values != 'custom' && values.contains('null') == false){
                    strsql += 'Where  ' + values;
                    system.debug('####---strsql'+strsql);                
                    system.debug('####---noOfSum '+noOfSum );
                } 
            }
        
            noOfSum = database.query(strsql); 
        }
        if(noOfSum.size() > 0){
           for(AggregateResult obj: noOfSum){      
                CountID = Integer.valueOf(obj.get('IDC'));
                
                intEmail = Integer.valueOf(obj.get('totalEmail'));
               
                intPhone = integer.valueOf(obj.get('TotalCalls'));
                
                intSMS = integer.valueOf(obj.get('TotalSMS')); 
                
                intPager = integer.valueOf(obj.get('TotalPages'));
                
                intFax = integer.valueOf(obj.get('TotalFaxes'));
                blnRecords = true;  
            }
        }
        if(CountID == 0){
           blnRecords = false; 
        }       
        List<Data> data = new List<Data>();
            data.add(new Data('Email', intEmail));
            data.add(new Data('Phone', intPhone));
            data.add(new Data('SMS', intSMS));
            data.add(new Data('Pager', intPager));
            data.add(new Data('Fax', intFax));
        return data;
    }
    
    public void GetSelectedObjectFields(){
        mapGlobalDescribe = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult schemaResult = mapGlobalDescribe.get('Notification_Status__c').getDescribe();
            string strName = schemaResult.getName();
            Schema.SObjectType objSchema = mapGlobalDescribe.get(strName);
            Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
            optionsFieldName = new List<SelectOption>();
            optionsFieldName.add(new Selectoption('','--Select--'));
            for (String fieldName: fieldMap.keySet()) { 
                 String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
    
                //It provides to get the object fields data type.
                Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
                if(fielddataType == Schema.DisplayType.DateTime){
                    if(fieldName != 'LastReferencedDate' && fieldName != 'LastViewedDate' && fieldName != 'SystemModStamp'){
                        optionsFieldName.add(new SelectOption(fieldName,fieldLabel));
                        optionsFieldName.sort();
                    }
                }
                
            }
    }
    
    public List<SelectOption> getItems() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','---None---'));
            options.add(new SelectOption('Custom','Custom'));
            options.add(new SelectOption(strStandardObject +'= THIS_FISCAL_YEAR','Current FY')); 
            options.add(new SelectOption(strStandardObject +'= LAST_FISCAL_YEAR','Previous FY'));
            options.add(new SelectOption(strStandardObject +'= LAST_N_FISCAL_YEARS:2','Previous 2 FY'));
            options.add(new SelectOption(strStandardObject +'= NEXT_FISCAL_YEAR','Next FY'));
            options.add(new SelectOption(strStandardObject +'= THIS_FISCAL_QUARTER','Current FQ'));
            options.add(new SelectOption(strStandardObject +'= NEXT_FISCAL_QUARTER','Next FQ'));
            options.add(new SelectOption(strStandardObject +'= LAST_FISCAL_QUARTER','Previous FQ'));
            options.add(new SelectOption(strStandardObject +'= THIS_YEAR','Current CY'));
            options.add(new SelectOption(strStandardObject +'= LAST_YEAR','Previous CY'));
            options.add(new SelectOption(strStandardObject +'= LAST_N_YEARS:2','Previous 2 CY'));
            options.add(new SelectOption(strStandardObject +'= NEXT_YEAR','Next CY'));
            options.add(new SelectOption(strStandardObject +'= THIS_QUARTER','Current CQ'));
            options.add(new SelectOption(strStandardObject +'= NEXT_QUARTER','Next CQ'));
            options.add(new SelectOption(strStandardObject +'= LAST_QUARTER','Previous CQ'));
            options.add(new SelectOption(strStandardObject +'= LAST_WEEK','Last Week'));
            options.add(new SelectOption(strStandardObject +'= THIS_WEEK','This Week'));
            options.add(new SelectOption(strStandardObject +'= NEXT_WEEK','Next Week'));
            options.add(new SelectOption(strStandardObject +'= YESTERDAY','Yesterday'));
            options.add(new SelectOption(strStandardObject +'= TODAY','Today'));
            options.add(new SelectOption(strStandardObject +'= TOMORROW','Tommorrow'));
            options.add(new SelectOption(strStandardObject +'= LAST_N_DAYS:7','Last 7 Days'));
            options.add(new SelectOption(strStandardObject +'= LAST_N_DAYS:30','Last 30 Days'));
            options.add(new SelectOption(strStandardObject +'= LAST_N_DAYS:60','Last 60 Days'));
            options.add(new SelectOption(strStandardObject +'= LAST_N_DAYS:90','Last 90 Days'));
            options.add(new SelectOption(strStandardObject +'= LAST_N_DAYS:120','Last 120 Days'));
            options.add(new SelectOption(strStandardObject +'= NEXT_N_DAYS:7','Next 7 days'));
            options.add(new SelectOption(strStandardObject +'= NEXT_N_DAYS:30','Next 30 days'));
            options.add(new SelectOption(strStandardObject +'= NEXT_N_DAYS:60','Next 60 days'));
            options.add(new SelectOption(strStandardObject +'= NEXT_N_DAYS:90','Next 90 days'));
            options.add(new SelectOption(strStandardObject +'= NEXT_N_DAYS:120','Next 120 days'));
            return options;
    }
   
    
    // Wrapper class
    public class Data {
        public String name { get; set; }
        public Integer data1 { get; set; }
        public Data(String name, Integer data1) {
            this.name = name;
            this.data1 = data1;
        }
    }
}