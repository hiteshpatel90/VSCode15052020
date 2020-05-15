({
	showError : function(component, event, helper) {
        var action = component.get("c.saveContactRecordFrom_LC");
        action.setParams({ strLastName : component.find("lastname").get("v.value"), 
                          strPhonenumber : component.find("phoneNum").get("v.value")});
        action.setCallback(this, function(a) {
            
            component.set("v.message", a.getReturnValue());
            // Handling a server error -- START
            if (a.getState() === "SUCCESS") {
                component.set("v.message", a.getReturnValue());
            } else if (a.getState() === "ERROR"){
                console.log(a.getError());
               
                var errors = a.getError();
                //alert(a.getError()[0].pageErrors);
                if(errors[0] && errors[0].pageErrors)
                    component.set("v.message", errors[0].pageErrors[0].message);    
            }
            // Handling a server error -- END 
        });
        $A.enqueueAction(action);
    },
    // Throwing and catching client-side errors (try, catch, finally) -- START
    throwErrorForKicks: function(cmp) {
        // this sample always throws an error to demo try/catch
        var hasPerm = false;
        try {
            if (!hasPerm) {               
                throw new Error("You don't have permission to edit this record.");
            }
        }
        catch (e) {            
            $A.createComponents([
                ["ui:message",{
                    "title" : "Sample Thrown Error",
                    "severity" : "error",
                }],
                ["ui:outputText",{
                    "value" : e.message
                }]
                ],
                function(components, status, errorMessage){
                    if (status === "SUCCESS") {
                        var message = components[0];
                        var outputText = components[1];
                        // set the body of the ui:message to be the ui:outputText
                        message.set("v.body", outputText);
                        var div1 = cmp.find("div1");
                        // Replace div body with the dynamic component
                        div1.set("v.body", message);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                        // Show offline error
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
                }
            );
        }
    }
    // Throwing and catching client-side errors (try, catch, finally) -- END
})