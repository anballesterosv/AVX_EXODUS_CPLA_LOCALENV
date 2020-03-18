({
	getStratObjectives : function(component, event) {
		// call apex method for fetch child records list.
        var action = component.get('c.getStratObjectives');
        action.setParams({
        	"accountplanid": component.get("v.recordId")
    	});	
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === 'SUCCESS') {
                //set response value in ChildRecordList attribute on component.
                component.set('v.StratObjList', actionResult.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    addSelectedHelperStrat: function(component, event, StratIds) {
        //call apex class method
        var action = component.get('c.addAPobjectives');
        // Pass the all selected child record's Id's and
        action.setParams({
            "StratIds": StratIds,
            "accountplanid": component.get("v.recordId")
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                //set response value in OppList attribute on component.
                component.set('v.OppList', actionResult.getReturnValue());
                if(component.get('v.OppList').length==0){   
                    var toastEvent = $A.get("e.force:showToast");
          			toastEvent.setParams({
        				"title": "Success!",
        				"message": "Account Plan Detail has been created successfully!"
    				});
                    toastEvent.fire();
              
                // refresh/reload the page view
                //$A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire() ;
                window.location.reload();
                }
                else{
                    component.set('v.hasOpp',true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    saveSelectedHelper: function(component, event, OppIds) {
        //call apex class method	
        var action = component.get('c.saveAP');
        // Pass the all selected Opportunity record's Id's
        action.setParams({
            "OppIds": OppIds,
            "accountplanid": component.get("v.recordId"),
            "StratIds" : component.get("v.StratIdList")
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
            	//alert("inside save"+component.get("v.StratIdList"));	
            	// display SUCCESS message
                 var toastEvent = $A.get("e.force:showToast");
          			toastEvent.setParams({
        				"title": "Success!",
        				"message": "Account Plan Detail has been created successfully!"
    				});
                    toastEvent.fire();
              
                // refresh/reload the page view
                //$A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire() ;
                window.location.reload();
            }
        });
        $A.enqueueAction(action);
      },
    initHelper: function(component, event) {
        var action = component.get('c.getStratObjectives');
        action.setParams({
        	"accountplanid": null
    	});	
  
        action.setCallback(this, function(response) {
            this.getStratObjectives(component,event);
        });
        $A.enqueueAction(action);
    },
    initHelperOpp: function(component, event) {
        var action = component.get('c.getStratObjectives');
        action.setParams({
        	"accountplanid": null
    	});	
  
        action.setCallback(this, function(response) {
            this.addSelectedHelperStrat(component, event, null);
        });
        $A.enqueueAction(action);
    }
})