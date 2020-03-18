({
  doInit: function(component, event, helper) {     
    // Fetch the account list from the Apex controller  
    helper.getContactList(component);
    helper.pollApex(component, helper);
  },
  deleteContact: function(component, event, helper) {
    // Prevent the form from getting submitted
    //event.preventDefault(); 

    // Get the value from the field that's in the form
    var conId = event.currentTarget.id;
    var action = component.get('c.removeuContact');
    action.setParams({
            "conId": conId
        });
    action.setCallback(this, function(response) {
    	var state = response.getState();
        if (state === "SUCCESS") {
        	$A.get('e.force:refreshView').fire();
            helper.getContactList(component);
        }
    });
    $A.enqueueAction(action);
  }
})