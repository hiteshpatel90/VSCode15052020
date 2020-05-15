({
	doInit : function(component, event, helper) {
		helper.fetchColumnList(component, event);
        helper.fetchRowList(component, event);
	}
})