/**
* @File Name: HOJ_CalculatePaymentHandler.cls
* @Description: 
* @Author:    Dipak Sonawane, dsonawane@deloitte.com
* @Group:     Apex
* @Last Modified by:   Dipak Sonawane
* @Last Modified time: 2017-12-13 17:15:36
* @Modification Log :
*-------------------------------------------------------------------------------------
* Ver       Date        Author      Modification
* 1.0       2017-11-22  Dipak Sonawane    Created the file/class */

global class HOJ_CalculatePaymentHandler {
    public static String calculateBorrowerAge(String dob){
        string sAge;
        try{
        if(dob!='' && dob!=null && !String.isBlank(dob)){
        date inputBirthDate= date.ValueOf(dob);
        integer totalDaysCount= inputBirthDate.daysBetween(Date.Today());
        integer age = Integer.valueOf(totalDaysCount/365);
        if(age>=1){
            sAge = String.valueOf(age); 
        }
        else{    
            sAge= HOJ_ConstantsClass.INVALID_DATE;
            }  
        }
            else{
             sAge= HOJ_ConstantsClass.INVALID_DATE;
            }  
        }
        Catch(Exception exp){
            sAge  = HOJ_ConstantsClass.INVALID_DATE_FORMAT;
        } 
        return sAge;
    }  
    
    /**
    * @Name          calculateClosingDate
    * @Description   Method to return closing date.
    * @Author        Dipak Sonawane
    * @CreatedDate   2017-11-14
    * @Param         HOJ_MortgageData md
    * @Return        HOJ_MortgageApplication
    */
    public static Date calculateClosingDate(Date setDate){
        Datetime nextStart, dt;    
        integer daysCount = Integer.valueof(Label.Closing_Date_Day_Count.trim());
        Time myTime = Time.newInstance(60,60, 60, 60);
        nextStart = DateTime.newInstance(setDate, myTime);
        // Get the default business hours
        if(setDate!=null ){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        nextStart= nextStart+daysCount;
        dt = BusinessHours.nextStartDate(bh.id,nextStart);
        }
        Date returnDate= date.newinstance(dt.year(), dt.month(), dt.day());
        return returnDate;    
    }     

    /**
    * @Name          calculateNextBusinessDay
    * @Description
    * @Author        Lap Thanh Ngo
    * @CreatedDate   2017-12-08
    * @Param         Date setDate
    * @Return        Date
    */
    public static Date calculateNextBusinessDay(Date setDate){
        Datetime nextStart, dt;    
        Time myTime = Time.newInstance(60,60, 60, 60);
        nextStart = DateTime.newInstance(setDate, myTime);
        
        // Get the default business hours
        if(setDate!=null ){
            BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        
            dt = BusinessHours.nextStartDate(bh.id,nextStart);        
        }
        Date returnDate= date.newinstance(dt.year(), dt.month(), dt.day());

        return returnDate;    
    }   
}