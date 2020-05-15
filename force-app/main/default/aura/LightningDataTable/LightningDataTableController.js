({
    doInit : function(component, event, helper) {		                
        helper.getDataHelper(component, event);
        
        
    },
     // Client-side controller called by the onsort event handler
     updateColumnSorting: function (cmp, event, helper) {
         
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    getSelectedName: function (component, event) {
              
    },
    handleRowAction: function (component, event) {
        alert('hi');
        alert(JSON.stringify(event.getParam('row')));
    }
})