({
	myAction : function(component, event, helper) {
		
	},
    
    inlineEditImpressions : function(component,event,helper){   
        // show the name edit field popup 
        component.set("v.ImpressionsEditMode", true); 
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("inputIdImpressions").focus();
        }, 100);
    },     
    
    onImpressionsChange : function(component,event,helper){ 
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        if(event.getSource().get("v.value").trim() != ''){ 
            component.set("v.showSaveCancelBtn_OLI",true);
        }
    },
    closeImpressionsBox : function (component, event, helper) {
      // on focus out, close the input section by setting the 'amountEditMode' att. as false   
        component.set("v.ImpressionsEditMode", false); 
      // check if change/update Name field is blank, then add error class to column -
      // by setting the 'showErrorClass' att. as True , else remove error class by setting it False   
       
        if(event.getSource().get("v.value") == ''){
            component.set("v.showErrorClass",true);
        }else{
            component.set("v.showErrorClass",false);
        }
    }
})