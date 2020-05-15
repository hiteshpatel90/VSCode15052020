({
	    
    packItem : function(component, event, helper) {
		var pack = component.get("v.item");
        pack.Packed__c = true;
        component.set("v.item",pack);
        var btnClicked = event.getSource();
        btnClicked.set("v.disabled",true);
        
	}
    
    
})