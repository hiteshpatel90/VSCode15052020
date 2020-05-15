({
   addItem: function(component, item) {
    this.saveItem(component, item, function(response){
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {
        }
    });
},
     createItem: function(component, newItem) {
    	var action = component.get("c.saveItem");
         action.setParams({"item": newItem});
    		action.setCallback(this, function(response){
        		var state = response.getState();
        		if (component.isValid() && state === "SUCCESS") {
            		// all good, nothing to do.
            var items = component.get("v.items");
            items.push(response.getReturnValue());
            component.set("v.items", items);
        		}
    		});
    		$A.enqueueAction(action);
        		
    }
})