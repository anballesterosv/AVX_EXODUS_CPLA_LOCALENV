({
	getRecord : function(component, event, helper) {
	
		var pageRef = component.get("v.pageReference");
		console.log('pageRef',pageRef);
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;

        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        
        var addressableContext;
        addressableContext = JSON.parse(window.atob(base64Context));
        console.log('recordId', addressableContext.attributes.recordId);
        var recordId = addressableContext.attributes.recordId;
        
        /*
		 * 
		 * The following code has issues when a record is created one after
		 * another,
		 * 
		 * 
		 * ////////////////////////////////////////////////////////////////////////
		 * 
		 * var value = helper.getParameterByName(component, event,
		 * 'inContextOfRef'); console.log('value : ',value); var context =
		 * JSON.parse(window.atob(value)); var recordId =
		 * context.attributes.recordId;
		 */
		
		if (recordId != null && recordId != undefined ) {
			
			console.log('Inside != -1');
			var action = component.get("c.getcaseReason");
			action.setParams({
				'caseId' : recordId
			});
			
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					component.set('v.additionalParams', response
							.getReturnValue());

					var createSerCompEvent = $A.get("e.force:createRecord");

					createSerCompEvent.setParams({
						"entityApiName" : "CS_Service_Complaint_Product__c",
						"defaultFieldValues" : {
							'CS_Case__c' : recordId,
							'CS_Case_Reason__c' : component
									.get('v.additionalParams')
						}
					});

					createSerCompEvent.fire();
					
				}
				

			});
			$A.enqueueAction(action);
		}
		/*
		 * else { console.log('Inside equal -1'); var createSerCompEvent =
		 * $A.get("e.force:createRecord");
		 * 
		 * createSerCompEvent.setParams({ "entityApiName" :
		 * "CS_Service_Complaint_Product__c", "defaultFieldValues" : {
		 * 'CS_Case__c' : context.attributes.recordId }
		 * 
		 * });
		 * 
		 * createSerCompEvent.fire(); }
		 */

	},
	
	
	/*getParameterByName : function(component, event, name) {
		name = name.replace(/[\[\]]/g, "\\$&");
		var url = window.location.href;
		var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
		var results = regex.exec(url);
		if (!results)
			return null;
		if (!results[2])
			return '';
		return decodeURIComponent(results[2].replace(/\+/g, " "));
	}*/

})