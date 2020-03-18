({
	closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    checkCaseContainsNewEmail : function(component,event,helper){
        
        var action = component.get("c.getCaseContainsOpenEmailMessages");
        //Set the Object parameters and Field Set name
        action.setParams({
            'caseId' : component.get("v.recordId")
        });
        
        action.setCallback(
            this,
            function(response) {
                
                var state = response.getState();
                if (state === 'SUCCESS') {
                    console.log('called checkCaseContainsNewEmail and is success');
                    
                } else if (state === 'ERROR') {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: "
                                        + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    
                } else {
                    console.log('Something went wrong, Please check with your admin');
                }
                
            });
        $A.enqueueAction(action);
    },

})