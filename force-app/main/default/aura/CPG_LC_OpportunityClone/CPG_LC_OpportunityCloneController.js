({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId")
        console.log('recordId = ' + recordId);
        var action = component.get("c.getCloneOpp");
        action.setParams({"oldId": recordId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returned =response.getReturnValue();
                console.log("SUCCESS returned: " + JSON.stringify(returned));
                //Below two lines were added by Sri Harshitha as per the User Story with the VSTS ID #41678.
                component.set("v.hasInactiveProduct", returned[1]);
                console.log(component.get("v.hasInactiveProduct"));
                helper.cloneToastGreen();
                //Below 5 lines were added by Sri Harshitha as per the User Story with the VSTS ID #41678.
                var hasInactiveProduct = component.get("v.hasInactiveProduct");
                if(hasInactiveProduct == 'true') {
                    console.log('Inactive Products removed!');
                    helper.alertToast();
                }
                var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": returned[0],
                      "slideDevName": "detail"
                    });
                    navEvt.fire();
                
            }
        });
        $A.enqueueAction(action);            
    } // end doInit function
})