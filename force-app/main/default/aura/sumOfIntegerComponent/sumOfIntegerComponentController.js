({
    /** Called when button is pressed to add numbers **/
    add : function(component) {
        var sum = component.get("v.num1") 
                + component.get("v.num2");
        component.set("v.sum", sum);
    }
})