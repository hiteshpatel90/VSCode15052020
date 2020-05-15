({
   // fetch picklist values dynamic from apex controller 
    fetchPickListVal: function(component, fieldName, picklistOptsAttributeName) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": component.get("v.objInfoForPicklistValues"),
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
 
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.set("v." + picklistOptsAttributeName, opts);
            }
        });
        $A.enqueueAction(action);
    },
    // Helper class to help toggle based on clicks
    ToggleExpandCollapseHandler : function(component, event, helper) {
        var existingText = component.get("v.expand_collapse_Text");
        if(existingText === "-"){
            component.set("v.expand_collapse_Text", "+");
            component.set("v.expand_collapse_Value", "none");
        }else{
            component.set("v.expand_collapse_Text", "-");
            component.set("v.expand_collapse_Value", "table-row");
        }
        
    },requiredValidation : function(component,event) {
        // get all accounts.. 	
        var allRecords = component.get("v.singleRec.OpportunityLineItems");
        var isValid = true;
        // play a for loop on all account list and check that account name is not null,   
        
        return isValid;
    },
})