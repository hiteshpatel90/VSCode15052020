({
    getContactByPicklists : function(component, picklistValue) {    
     var action=component.get("c.getContactsByPicklist");
        action.setParams({
          "picklistValue": picklistValue
        });
        action.setCallback(this, function(data){
                           component.set("v.contacts", data.getReturnValue());
                           });
      $A.enqueueAction(action);  
	}
})