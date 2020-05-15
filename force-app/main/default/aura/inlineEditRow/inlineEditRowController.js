({
    
    doInit: function(component, event, helper) {
      // call the fetchPickListVal(component, field_API_Name, aura_attribute_name_for_store_options) -
      // method for get picklist values dynamic   
        helper.fetchPickListVal(component, 'StageName', 'ratingPicklistOpts');
        
      
        var retObj = JSON.parse('[{"val":"' + component.get("v.singleRec.AccountId") + '","text":"' + component.get("v.singleRec.Account.Name") + '","objName":"Account"}]');
        console.log(retObj);
        
        component.set("v.server_result",retObj);               
        if(retObj && retObj.length > 0){
            var childCmp = component.find("txtLookup");
            childCmp.itemSelectedFun(1);
           
        }
    },
    
    inlineEditName : function(component,event,helper){   
        // show the name edit field popup 
        component.set("v.nameEditMode", true); 
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("inputId").focus();
        }, 100);
    },
    inlineEditAccountName : function(component,event,helper){   
        // show the name edit field popup 
        component.set("v.accountNameEditMode", true); 
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("inputId").focus();
        }, 100);
    },
    inlineEditRating : function(component,event,helper){   
        // show the rating edit field popup 
        component.set("v.ratingEditMode", true); 
        // after set ratingEditMode true, set picklist options to picklist field 
        component.find("accRating").set("v.options" , component.get("v.ratingPicklistOpts"));
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("accRating").focus();
        }, 100);
    },
    inlineEditCloseDate : function(component,event,helper){   
        // show the name edit field popup 
        component.set("v.closeDateditMode", true); 
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("inputIdCloseDate").focus();
        }, 100);
    },
     onNameChange : function(component,event,helper){ 
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        if(event.getSource().get("v.value").trim() != ''){ 
            component.set("v.showSaveCancelBtn",true);
        }
    },
 
    onRatingChange : function(component,event,helper){ 
        // if picklist value change,
        // then show save and cancel button by set attribute to true
        component.set("v.showSaveCancelBtn",true);
    },
    
    onCloseDateChange : function(component,event,helper){ 
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        if(event.getSource().get("v.value").trim() != ''){ 
            component.set("v.showSaveCancelBtn",true);
        }
    },
    closeNameBox : function (component, event, helper) {
      // on focus out, close the input section by setting the 'nameEditMode' att. as false   
        component.set("v.nameEditMode", false); 
      // check if change/update Name field is blank, then add error class to column -
      // by setting the 'showErrorClass' att. as True , else remove error class by setting it False   
        
        if(event.getSource().get("v.value") == ''){
            component.set("v.showErrorClass",true);
        }else{
            component.set("v.showErrorClass",false);
        }
    }, 
    
    closeRatingBox : function (component, event, helper) {
       // on focus out, close the input section by setting the 'ratingEditMode' att. as false
        component.set("v.ratingEditMode", false); 
    },     
    
    closeCloseDateBox : function (component, event, helper) {
      // on focus out, close the input section by setting the 'amountEditMode' att. as false   
        component.set("v.closeDateditMode", false); 
      // check if change/update Name field is blank, then add error class to column -
      // by setting the 'showErrorClass' att. as True , else remove error class by setting it False   
       
        if(event.getSource().get("v.value") == ''){
            component.set("v.showErrorClass",true);
        }else{
            component.set("v.showErrorClass",false);
        }
    },
    // Expand/ Collapse
    ToggleExpandCollapse : function(component, event, helper) {
        
        helper.ToggleExpandCollapseHandler(component, event);
        
    },
    
    Save: function(component, event, helper) {
        alert('1');
      // Check required fields(Name) first in helper method which is return true/false
        if (helper.requiredValidation(component, event)){
            alert('2');
            
              // call the saveAccount apex method for update inline edit fields update 
               var action = component.get("c.saveOpportunityProduct");
                  action.setParams({
                    'lstOpportunityProduct': component.get("v.singleRec.OpportunityLineItems"),
                    'strOppId':component.get("v.singleRec.OpportunityId")
                  });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    // set OpportunityList list with return value from server.
                    component.set("v.OpportunityList", storeResponse);
                    // Hide the save and cancel buttons by setting the 'showSaveCancelBtn' false 
                    component.set("v.showSaveCancelBtn",false);
                    alert('Opportunity Product Updated Successfully.');
                }
            });
            $A.enqueueAction(action);
        } 
    },
    cancel : function(component,event,helper){
       // on cancel refresh the view (This event is handled by the one.app container. It’s supported in Lightning Experience, the Salesforce app, and Lightning communities. ) 
       //$A.get('e.force:refreshView').fire(); 
       component.set("v.showSaveCancelBtn_OLI",false);
    }
    
   
})