public without sharing class CS_ReportService {

  public static Date retrieveLatestSalesDataDate(String groupQualifier) {
    

    Date reportDate = null;

    List<Id> userIds = new List<Id>();
    

    if ( 'mine'.equals(groupQualifier) ) {
      // just mine
      
      userIds.add( UserInfo.getUserId() );

    } else if(groupQualifier == null){
      
      list<User> lstUsers = CS_ARTerritoryService.retrieveUsersInMyTerritory();
      if(lstUsers.size() > 0){
        for(User objUser : lstUsers){
          userIds.add(objUser.Id);
        }
      }
      
    }else{
      // default to my team
      
      userIds = CS_ARTerritoryService.retrieveUserIdsInMyTerritory(groupQualifier);
      
    }

    List<Sales__c> salesDates = [select Id, Current_Date__c from Sales__c where Agent__r.Id in :userIds and Current_Date__c <= TODAY order by Current_Date__c desc limit 1];
    for ( Sales__c sales : salesDates ){
      reportDate = sales.Current_Date__c;
    }

    return reportDate;
  }

  public static List<Map<String,Object>> retrieveCategoryReports(Date asOfDate, String groupQualifier, Boolean abbreviate) {
    
    
    system.debug('##--retrieveCategoryReports.asOfDate: '+ asOfDate + ': groupQualifier: ' +groupQualifier + '; abbreviate' + abbreviate);
    List<Map<String,Object>> categories = new List<Map<String,Object>>();
    
    date currentDateOfJune = Date.newInstance(2016, 7, 1);//create a date instance to get the quotas for previous 
    // year if its missing.
    List<Id> userIds = new List<Id>();
    if ( 'mine'.equals(groupQualifier) ) {
      // just mine
      
      userIds.add( UserInfo.getUserId() );

    } else {
      // default to my team
      
      userIds = CS_ARTerritoryService.retrieveUserIdsInMyTerritory(groupQualifier);
      
    }
    
    Map<string,Axis_Sales_Category__c> categorySettings = Axis_Sales_Category__c.getAll();
    Integer categoryCount = categorySettings.size();

    system.debug('##--retrieveCategoryReports.userIds: '+ userIds);

    AggregateResult[] groupedResults = [SELECT sum(Rep_H0Rev_MTD__c) mtd,sum(Rep_Quota_CurrMonth__c) mtdQuota, sum(Rep_H0Rev_YTD__c) ytd, 
        sum(Rep_Quota_CurrFY__c) ytdQuota, sum(Rep_H0Rev_PriorDay__c) priorDay, SalesDaysLeft__c ,Product__r.Name,Currency__c from Sales__c 
        where Agent__r.Id in :userIds and Current_Date__c =:asOfDate group by Product__r.Name, SalesDaysLeft__c, Currency__c
        order by Product__r.Name ];
    
    
    AggregateResult[] groupedResults2 = [SELECT sum(Rep_H0Rev_MTD__c) mtd,sum(Rep_Quota_CurrMonth__c) mtdQuota, sum(Rep_H0Rev_YTD__c) ytd, 
        sum(Rep_Quota_CurrFY__c) ytdQuota, sum(Rep_H0Rev_PriorDay__c) priorDay, SalesDaysLeft__c ,Product__r.Name,Currency__c from Sales__c 
        where Agent__r.Id in :userIds and Current_Date__c =:currentDateOfJune group by Product__r.Name, SalesDaysLeft__c, Currency__c
        order by Product__r.Name ];
        
        
    system.debug('##--retrieveCategoryReports.groupedResults: '+ groupedResults);
    system.debug('##--retrieveCategoryReports.groupedResults2: '+ groupedResults2);
    for ( AggregateResult ar : groupedResults ) {
      
      String name = (String)ar.get('Name');

      Axis_Sales_Category__c categorySetting = categorySettings.get(name);
      if ( categorySetting != null ) {

        if ( abbreviate ) {
          name = categorySetting.Abbreviation__c;
        }
        
        object yeartoDateQuota =  ar.get('ytdQuota');
        object monthtoDateQuota =  ar.get('mtdQuota');
        system.debug('##--yeartoDateQuota: '+ yeartoDateQuota);
        if(yeartoDateQuota == 0.0){
          
          for(AggregateResult objAgg : groupedResults2){
            
            if(ar.get('Name') == objAgg.get('Name') 
              &&  objAgg.get('ytdQuota') != 0.0){
              yeartoDateQuota = objAgg.get('ytdQuota');
              //continue;
            }
            
          }
          
        }
        
        if(monthtoDateQuota == 0.0){
          
          for(AggregateResult objAgg : groupedResults2){
            
            if(ar.get('Name') == objAgg.get('Name') 
                &&  objAgg.get('mtdQuota') != 0.0){
                  
              monthtoDateQuota = objAgg.get('mtdQuota');
              
              //continue;
            }
            
          }
          
        }
      
        categories.add(CS_ReportService.createCategoryReport(name, 
                                  ar.get('ytd'), 
                                  ar.get('mtd'), 
                                  ar.get('priorDay'), 
                                  ar.get('SalesDaysLeft__c'), 
                                  yeartoDateQuota,//ar.get('ytdQuota'), 
                                  monthtoDateQuota,//ar.get('mtdQuota'),
                                  ar.get('Currency__c'),
                                  categorySetting ) );
        
      }

        
    }
    system.debug('##--retrieveCategoryReports.categories: '+ categories);
    return categories;
  }



  public static Map<String,Object> createCategoryReport(Object name, 
                              Object ytd, 
                              Object mtd, 
                              Object priorDay, 
                              Object daysLeft, 
                              Object ytdQuota, 
                              Object mtdQuota, 
                              Object curr, 
                              Object settings) {
    Map<String,Object> categoryReport = new Map<String,Object>();
    categoryReport.put('name', name);
    categoryReport.put('ytdSales', ytd );
    categoryReport.put('mtdSales', mtd );
    categoryReport.put('priorDaySales', priorDay );
    categoryReport.put('salesDayLeftInMonth', daysLeft );
    categoryReport.put('ytdSalesQuota', ytdQuota );
    categoryReport.put('mtdSalesQuota', mtdQuota);
    categoryReport.put('currency',curr);
    categoryreport.put('settings', settings);
    return categoryReport;
  }
  

}