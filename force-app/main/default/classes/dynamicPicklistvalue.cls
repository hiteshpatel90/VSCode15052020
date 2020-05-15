public class dynamicPicklistvalue{
    public static List<String> getPicklistValues (String sobjectName, String fieldName) {
        List<String> values = new List<String>();
        
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(sobjectName);
        Schema.DescribeSObjectResult o = sobjType.getDescribe();
        Map<String, Schema.SObjectField> m = o.fields.getMap();
        Schema.SObjectField field = m.get(fieldName);
        
        Schema.DescribeFieldResult fieldResult = field.getDescribe();        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        system.debug('@@@@@@@@@@@@@@@'+ple );
        for (Schema.PicklistEntry f : ple) {
            values.add(f.getValue());
        }
        system.debug('@@@@@@@@@@'+values);
        return values;
    } 
}