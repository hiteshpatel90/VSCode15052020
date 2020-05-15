({
	itemSelected : function(component, event, helper) {
		helper.itemSelected(component, event, helper);
	}, 
    itemSelectedParent : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var param1 = params.param1;
            // add your code here
        }
        
		helper.itemSelectedParent(component, event, helper, param1);
	},
    serverCall :  function(component, event, helper) {
		helper.serverCall(component, event, helper);
	},
    clearSelection : function(component, event, helper){
        helper.clearSelection(component, event, helper);
    } 
})