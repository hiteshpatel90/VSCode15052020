({
    initRecords: function(component, event, helper) {
      // call the apex class method and fetch account list  
         var action = component.get("c.fetchOpportunity");
        	action.setParams({
                'strAccId':component.get("v.accId")
            });
        
             action.setCallback(this, function(response) {
              var state = response.getState();
              if (state === "SUCCESS") {
                  var storeResponse = response.getReturnValue();
                  console.log(JSON.stringify(storeResponse));
               // set OpportunityList list with return value from server.
                  component.set("v.OpportunityList", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    
    Save: function(component, event, helper) {
      // Check required fields(Name) first in helper method which is return true/false
        if (helper.requiredValidation(component, event)){
            
            
              // call the saveAccount apex method for update inline edit fields update 
               var action = component.get("c.saveOpportunity");
                  action.setParams({
                    'lstOpportunity': component.get("v.OpportunityList"),
                    'strAccId':component.get("v.accId")
                  });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    // set OpportunityList list with return value from server.
                    component.set("v.OpportunityList", storeResponse);
                    // Hide the save and cancel buttons by setting the 'showSaveCancelBtn' false 
                    component.set("v.showSaveCancelBtn",false);
                    alert('Opportunity Updated Successfully.');
                }
            });
            $A.enqueueAction(action);
        } 
    },
    
    cancel : function(component,event,helper){
       // on cancel refresh the view (This event is handled by the one.app container. It’s supported in Lightning Experience, the Salesforce app, and Lightning communities. ) 
       //$A.get('e.force:refreshView').fire(); 
       component.set("v.showSaveCancelBtn",false);
    } 
    
})