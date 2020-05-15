@isTest(seeAlldata=true)
public class contentPageExtensionTest{
    private static testmethod void myTestmethod1(){ 
        Contentversion objContentversion = new Contentversion();
        objContentversion = [select id, ContentDocument.Title, ContentUrl, FeaturedContentBoost, FirstPublishLocationId from Contentversion limit 1];
        
        apexpages.currentpage().getParameters().put('id', objContentversion.id);
        Apexpages.standardcontroller stdCon = new Apexpages.standardcontroller(objContentversion);
        contentPageExtension objcontentPageExtension = new contentPageExtension(stdCon);
        objcontentPageExtension.downloadPDFfile();        
        objcontentPageExtension.searchContentRecords();        
        objcontentPageExtension.getLibraries();
       
    }
}