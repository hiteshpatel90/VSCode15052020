({
	doInit : function(component, event, helper) {
		
	},
    onSave : function(component, event, helper) {
 
        var action = component.get("c.saveCase");
        action.setParams({
            "caseRec":component.get("v.objCase")
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                var accId = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"Success",
                    "message": "Case created successfully."
                });
                toastEvent.fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": accId,
                    "slideDevName": "related"
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(action);
    
    },
    onCancel : function(component, event, helper) {
 
        // Navigate back to the record view
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get('v.recordId') });
        navigateEvent.fire();
    }
})