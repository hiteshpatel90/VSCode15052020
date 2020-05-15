({
    onSearchTextChange: function(component, event, helper) {
        var myEvent = $A.get("e.c:accountSearchText");
        myEvent.setParams({"accountSearchText": event.target.value});
        myEvent.fire();
    }
})