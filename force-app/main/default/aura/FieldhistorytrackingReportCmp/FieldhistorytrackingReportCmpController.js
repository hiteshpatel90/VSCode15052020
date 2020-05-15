({
	myAction : function(component, event, helper) {
		var action = component.get("c.getFieldHistories");
        action.setCallback(this, function(data) {
        component.set("v.FieldHistories", data.getReturnValue());
        });
        $A.enqueueAction(action);
        
      
	}
})