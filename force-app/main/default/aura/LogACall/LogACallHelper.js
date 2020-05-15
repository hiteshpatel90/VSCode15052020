({
	createTask : function(component,task) {      
        var action=component.get("c.saveTask");
        action.setParams({"task":task});
        action.setCallback(this,function(response){
            var state = response.getState();
            alert(state);
			if (state === "SUCCESS") {

                var subject=component.find("Subject");
                subject.set("v.value","");
                
                var comments=component.find("Comments");
                comments.set("v.value","");
                
                var taskdate=component.find("Taskdate");
                taskdate.set("v.value","");                                

                var today = new Date();
				var taskdate=component.find("Taskdate");
        		taskdate.set('v.value', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());              
            }
        });
		$A.enqueueAction(action);
	}    
})