({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
         var actionGetMemberRequestDetails = component.get("c.getOpportunity");
        actionGetMemberRequestDetails.setParams({
            strRecordId: recordId
        });
        actionGetMemberRequestDetails.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid && state == 'SUCCESS') {
        	component.set("v.objOpportunity", response.getReturnValue());
                }            
            });
            
      $A.enqueueAction(actionGetMemberRequestDetails);
	}
})