({
    getProducts: function(component) {
        var action = component.get("c.getProducts");
        action.setCallback(this, function(a) {
            component.set("v.products", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    getProduct: function(component, productName) {
        var action = component.get("c.getProductByName");
        action.setParams({
          "name": productName
        });
        action.setCallback(this, function(a) {
            // display the product to the chrome dev console (for fun)
            console.log(a.getReturnValue());
            component.set("v.product", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
})