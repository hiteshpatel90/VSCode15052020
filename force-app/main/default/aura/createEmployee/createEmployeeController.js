({
	handleSuccess : function(component, event, helper) {
        var emp = event.getParams();
        alert(JSON.stringify(emp));
        var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": emp.Name,
      "slideDevName": "related"
    });
    navEvt.fire();
    },
    
    
	Cancel : function(component, event, helper) {
        //var emp = event.getParams();
        //alert(JSON.stringify(emp));
        var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": component.get("v.recordId"),
      "slideDevName": "related"
    });
    navEvt.fire();
    }
    
})