({
    getallContacts: function(component, event) {
        // call apex method for fetch child records list.
        var action = component.get('c.getContacts');
        action.setParams({
        	"parentAccount": component.get("v.recordId")
    	});
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === 'SUCCESS') {
                //set response value in ChildRecordList attribute on component.
                component.set('v.ChildRecordList', actionResult.getReturnValue());
                if(component.get('v.ChildRecordList').length>0){   
                    component.set('v.hasContact',true);
                }
                if(component.get('v.ChildRecordList').length==0){   
                    component.set('v.hasContact',false);
                }
            }
        });
        $A.enqueueAction(action);
    },
 
    addSelectedHelper: function(component, event, childRecordsIds) {
        //call apex class method
        var action = component.get('c.addCons');
 
        // Pass the all selected child record's Id's and
        action.setParams({
            "lstOfContactIds": childRecordsIds
        });
 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // display SUCCESS message
                 var toastEvent = $A.get("e.force:showToast");
          			toastEvent.setParams({
        				"title": "Success!",
        				"message": "Contact has been added successfully."
    				});
                    toastEvent.fire();
              
                // refresh/reload the page view
                $A.get('e.force:refreshView').fire();
                
                // call init function again [clear selected checkboxes]
                this.getallContacts(component,event);  
                
            }
        });
        $A.enqueueAction(action);
    },
    initHelper: function(component, event, childRecordsIds) {
        //call apex class method
        var action = component.get('c.addCons');
 
        // Pass the all selected child record's Id's and
        action.setParams({
            "lstOfContactIds": childRecordsIds
        });
 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.getallContacts(component,event);                 
            }
        });
        $A.enqueueAction(action);
    }
})