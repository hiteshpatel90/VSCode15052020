@isTest(seeAlldata=true)
public class displayContentExtensionTest{
    private static testmethod void myTestmethod1(){ 
        ContentDocument objContentDoc = new ContentDocument();
        objContentDoc = [select id, title, ParentId , ContentSize, FileExtension, LastModifieddate, ownerid, owner.name from ContentDocument limit 1];

        Apexpages.standardcontroller stdCon = new Apexpages.standardcontroller(objContentDoc);
        displayContentExtension objdisplayContentExt = new displayContentExtension(stdCon);
        objdisplayContentExt.getLibraries();
        
        objdisplayContentExt.lstwrapperFilterOptions[0].lstInnerFilter[0].blnFilterSelected = true;
        objdisplayContentExt.filterContentRecords();
        objdisplayContentExt.searchContentRecords();
        objdisplayContentExt.clearSearchContentRecords();
        objdisplayContentExt.GoNextClick();
        objdisplayContentExt.getMyCommandButtons();
        
        apexpages.currentpage().getparameters().put('firstParam','1');
        objdisplayContentExt.refreshGrid();
    }
}