({
	filterAccountByName: function(component,event) {
        var SearchText = '';
        if(event != undefined){
            SearchText = event.getParam("accountSearchText");
        }
        
        var action = component.get("c.filterAccountByName");
        action.setParams({
          "strSearchText": SearchText
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.accounts", response.getReturnValue());
                
                component.set('v.mycolumns', [
                        {label: 'Account Name', fieldName: 'Name', type: 'text', sortable: true},
                        {label: 'Address', fieldName: 'BillingStreet', type: 'text', sortable: true},
                        {label: 'City', fieldName: 'BillingCity', type: 'Text', sortable: true},
                        {label: 'Province', fieldName: 'BillingState', type: 'Text', sortable: true},
                        {label: 'Number of employees', fieldName: 'NumberOfEmployees', type: 'Integer', sortable: true}
                    ]);
                this.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
            }
        });
        $A.enqueueAction(action);  
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.accounts");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.accounts", data);
        cmp.set("v.sortedBy", fieldName);
    },
    sortBy: function (field, reverse, primer) {
        
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})