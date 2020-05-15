({
	myAction : function(component, event, helper) {
		
	},
    toggle : function(component, event, helper) {
        	
        var toggleText = component.find("hideTEXT");
        
        $A.util.toggleClass(toggleText, "toggle");
        
    },
    navigateToSearchProduct : function(component, event, helper) {
         var toggleText = component.find("dvSearchProduct");
        
        $A.util.toggleClass(toggleText, "searchProductDiv");
        
        var toggleTexttellusAbountCmp = component.find("tellusAbountCmp");
        
        $A.util.toggleClass(toggleTexttellusAbountCmp, "toggle");
        
        var toggleTexthideTEXT = component.find("hideTEXT");
        
        $A.util.toggleClass(toggleTexthideTEXT, "toggle");
        
        var toggleTexthelpText = component.find("helpText");
        
        $A.util.toggleClass(toggleTexthelpText, "toggle");
    }
})