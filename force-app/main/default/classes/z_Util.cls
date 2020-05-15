public with sharing class z_Util {
    
    static public void log(String str) {
        System.debug(logginglevel.INFO, str);
    }
    
    // Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
    static public String convertToStringForScheduler(Datetime dt) {
        return dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ' + '?' + ' ' + dt.year();
    }
    
    static public Id executeBatchableMetadataDump1(boolean executeDump2) {
        prepareMetadataDump();
        // scope must be 1 because of governer limit
        return Database.executeBatch(new z_BatchableMetadataDump1(executeDump2), 1);
    }   

    static public id executeBatchableMetadataDump2(boolean executeDump3) {
        // scope must be 10 because of governer limit       
        return Database.executeBatch(new z_BatchableMetadataDump2(executeDump3), 10);
    }

    static public id executeBatchableMetadataDump3() {
        // scope must be 10 because of governer limit       
        return Database.executeBatch(new z_BatchableMetadataDump3(), 100);
    }
    
    static public void cleanData1() {       
        List<SObject> objs = [Select id from z_SchemaTemp__c limit 10000];
        if(objs.size() == 0)
            return;

        delete objs;
    }   
    
    static public void cleanData2() {
        List<SObject> objs = [Select id from z_SObjectDescription__c limit 10000];
        if(objs.size() == 0)
            return;

        delete objs;
    }   

    
    static public void prepareMetadataDump() {
        cleanData1();
        cleanData2();

        List<z_MetaDumpSetting__c> settings = [Select id, name__c From z_MetaDumpSetting__c limit 10000];

        List<z_SchemaTemp__c> records = new List<z_SchemaTemp__c>();        
        for(z_MetaDumpSetting__c setting : [Select id, name__c From z_MetaDumpSetting__c]) {
            records.add(new z_SchemaTemp__c(objname__c = setting.name__c));
        }
        insert records;
    }   
    
}