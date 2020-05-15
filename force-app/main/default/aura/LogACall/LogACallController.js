({
    
    doInit:function(component,event,helper){
        var today = new Date();
		var taskdate=component.find("Taskdate");
        taskdate.set('v.value', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
    },
    getInput:function(component,event,helper){
		alert('h');
        var task = component.get("v.newTask");        
        task.Type = 'Lightning';
        alert('k');
        //call the helper method to create the task in the salesforce
        helper.createTask(component,task);        
	},
    resetControls:function(component,event,helper){
        
        var subject=component.find("Subject");
        subject.set("v.value","");    //Set Subject to Blank
        
        var comments=component.find("Comments");
        comments.set("v.value","");    //Set Comments to Blank
        
        var taskdate=component.find("Taskdate");
        taskdate.set("v.value","");    //Set Taskdate to Blank
        
        var comments=component.find("Comments");
        comments.set("v.placeholder","");    //Set Comment placeholder to Blank
                
        var today = new Date();
	    var taskdate=component.find("Taskdate");
        taskdate.set('v.value', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());        
    }
})