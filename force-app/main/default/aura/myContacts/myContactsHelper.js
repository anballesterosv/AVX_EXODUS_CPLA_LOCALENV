({
  // Fetch the accounts from the Apex controller
    getContactList: function(component) {
    var action = component.get('c.getuContacts');
      
      if (typeof action !== 'undefined' ) {
        action.setParams({
            "parentAccount": component.get("v.recordId")
        });
        // Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
         component.set('v.contacts', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
      }
  },
    pollApex : function(component,helper) {
      //$A.get('e.force:refreshView').fire();
      helper.getContactList(component);
      //execute callApexMethod() again after 5 sec each
      window.setInterval(
          $A.getCallback(function() {
              //$A.get('e.force:refreshView').fire();
            helper.getContactList(component);
              //alert("inside poller");
          }), 2000
      );     
  }
})