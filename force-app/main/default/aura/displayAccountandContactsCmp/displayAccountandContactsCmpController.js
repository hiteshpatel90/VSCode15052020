({
	doInit : function(component, event, helper) {
        helper.fetchAccounts(component, event);
        helper.fetchContacts(component, event);
	}
})