({
    init: function(component, event, helper) {
      // call the apex class method and fetch account list  
         var action = component.get("c.integrationLayer");
        	action.setParams({
                
            });        
             action.setCallback(this, function(response) {
              var state = response.getState();
              if (state === "SUCCESS") {
                  var storeResponse = response.getReturnValue();
                  console.log(JSON.stringify(storeResponse));
               // set contactlayer list with return value from server.
                  component.set("v.contactlayer", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    
	login : function(component, event, helper) {
		var action = component.get("c.loginFun");
        	action.setParams({
                'Username':component.get("v.strUsername"),
                'Password':component.get("v.strPassword")
            });
        
             action.setCallback(this, function(response) {
              var state = response.getState();
              if (state === "SUCCESS") {
                  var storeResponse = response.getReturnValue();
                  console.log(JSON.stringify(storeResponse));
                  if(storeResponse === false){
                      component.set("v.UsernotexistText", "User does not exist.");
                  }else{
						$A.createComponent(
                            "c:loginSuccessful",
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
            }
        });
        $A.enqueueAction(action);
	}
})