({
    doInit: function(component, event, helper) {
       
       
    },

    handleSaveContact: function(component, event, helper) {
        	
        if(helper.validateContactForm(component)) {
                       
            var con = component.get("v.strFirstName")
           
            var action = component.get("c.saveContactRecord");            
            action.setParams({ 
                "strFirstName": component.get("v.strFirstName"),
                "strLastName": component.get("v.strLastName"),                
                "strEmail": component.get("v.strEmail"),
                "strPhone": component.get("v.strPhone")
            });
            
            action.setCallback(this, function(data){
                if(data.getReturnValue().startsWith("003") && data.getReturnValue().length == 18){                    
                    alert('Contact is saved successfully');
                    window.location.href = '/' + data.getReturnValue();
                    //window.location.reload();
                    
                }else{
                    if(data.getReturnValue().indexOf('INVALID_EMAIL_ADDRESS') != -1){
                        alert('Invalid Email');
                    }else{
                        alert('Problem saving contact - ' + data.getReturnValue());
                    }
                }                
            });
            $A.enqueueAction(action);
            
        }
    },
    onCancel : function(component, event, helper) {
 
        var url = window.location.href; 
            var value = url.substr(0,url.lastIndexOf('/') + 1);
            window.history.back();
            return false;
    },
})