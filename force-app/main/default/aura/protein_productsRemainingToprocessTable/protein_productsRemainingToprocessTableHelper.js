({
    getAccountsHelper : function(component, event, helper) {
        //call apex class method
        var action = component.get('c.getSelectedProductList');
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in accListToDisplay attribute on component.
               // component.set('v.SampleProductParent', response.getReturnValue());
                
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
         component.set("v.spinner", true); 
    },

})