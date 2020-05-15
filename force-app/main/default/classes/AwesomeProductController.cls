public class AwesomeProductController {
    @AuraEnabled
    public static List<Product__c> getProducts() {
        return [select id, name, photo__c, Product_Version__c, File_Size__c, Release_Date__c from product__c order by createddate];
    }
    
    @AuraEnabled
    public static Product__c getProductByName(String name) {
        return [select id, name, photo__c,Product_Version__c, File_Size__c,Release_Date__c
                from product__c where name = :name];
    }
}