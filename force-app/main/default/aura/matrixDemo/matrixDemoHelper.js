({
	fetchColumnList : function(component, event) {
		var action = component.get("c.getColumnList");
        if ( action !== undefined ) {
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    component.set("v.columnList", response.getReturnValue());
                }else{
                    console.log('Error during fetch column');
                }
            
            });
        
            $A.enqueueAction(action);
        }
	},
    fetchRowList : function(component, event) {
		var action = component.get("c.getRowList");
        if ( action !== undefined ) {
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    component.set("v.rowList", response.getReturnValue());
                }else{
                    console.log('Error during fetch Rows');
                }
            
            });
        
            $A.enqueueAction(action);
        }
	}
})