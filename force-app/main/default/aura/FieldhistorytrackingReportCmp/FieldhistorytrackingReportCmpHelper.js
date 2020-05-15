({
	getFieldHistoriesold : function(component) {
     var action = component.get("c.getFieldHistories");
        action.setCallback(this, function(data) {
        	component.set("v.fHistories", data.getReturnValue());
        });
        $A.enqueueAction(action);
	},
    getFieldHistories : function(component) {    
     var action=component.get("c.getFieldHistories");
        
     var dataSet;
        var columns;        
        var objectName = component.get("v.objectName");        
        var fieldName = component.get("v.fieldName");;        
        var fields;
        var splitfileds;        
        action.setParams({
            "objectName":objectName,
            "fieldName":fieldName
        }) ;
        var self = this;        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {           
            dataSet = eval(response.getReturnValue());
            $(function(){
                    /* initiate the plugin */                
                    $(window).resize(function(){
                           if ($(window).width() <= 700) {                      
                               $('.container ').css({"overflow-x":"scroll","width":"100%"});                     
                           }
                        else{
                            $('.container ').css({"overflow-x":"none","width":"100%"});
                        }
                    });
                    var table = $('#example').DataTable({
                        data: dataSet,
                        columns:splitfileds,
                        "fnDrawCallback": function( oSettings ) {                          
                          $('.showDetail').css({"cursor":"pointer","text-decoration":"none"});                        
                            $('.showDetail').click(function(){
                                var recordId = $(this).attr('id');
                                helper.navigateToDetailsView(recordId);   
                            });
                        }
                    }); 
                    
                });                
            }
            
        });        
             
      alert(JSON.stringify(action));
      
      /*   action.setCallback(this, function(data){
            alert(JSON.stringify(data.getReturnValue()));
                           component.set("v.objectName",data.getReturnValue());
                           }); */
      $A.enqueueAction(action);  
	},
    navigateToDetailsView : function(accountId) {
    var event = $A.get("e.force:navigateToSObject");
    event.setParams({
        "recordId": accountId
    });
    event.fire();
  }
})