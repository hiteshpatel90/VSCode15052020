({
	myAction : function(component, event, helper) {
		var action = component.get("c.getContacts");
        action.setCallback(this, function(data) {
        component.set("v.contacts", data.getReturnValue());
        });
        $A.enqueueAction(action);
        
        var action1=component.get("c.getPicklistValues");
     	action1.setCallback(this, function(data){
                           component.set("v.Picklists",data.getReturnValue());
                           });
     	$A.enqueueAction(action1); 
        
	},
    change : function(component, event, helper) {
		
       selectedName = event.target.value;
    },
    displayContactsByPicklist:function(component, event, helper) {       
               helper.getContactByPicklists(component, selectedName);
    }
})