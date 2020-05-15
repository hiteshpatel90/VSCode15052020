@isTest
public class contentPageExtensionTest1{
    private static testmethod void myTestmethod1(){
        
        Contentworkspace cv = [select id from Contentworkspace];
        system.debug('@@@@@@@'+cv);
       
    }
}