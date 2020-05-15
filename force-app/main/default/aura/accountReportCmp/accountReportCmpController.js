({
	doInit : function(component, event, helper) {       
      helper.filterAccountByName(component);
   },
   accountSearchTextChange : function(component, event, helper){
        helper.filterAccountByName(component,event); 
    },
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    }
})