({
	Navigate : function(component, event, helper) {
         $A.createComponent(
            "c:C1",
            {
                 
            },
            function(newCmp){
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newCmp);
                    component.set("v.body", body);
                }
            }
        );	        
		
	}
})