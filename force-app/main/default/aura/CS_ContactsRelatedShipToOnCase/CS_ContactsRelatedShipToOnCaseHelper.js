({
    getDataHelper : function(component, event) {
		var action = component.get("c.getContactsRelToShipToFromCase");
		//Set the Object parameters and Field Set name
		action.setParams({
			'caseId' : component.get("v.recordId")
		});
		
		action.setCallback(
						this,
						function(response) {

							var state = response.getState();
							if (state === 'SUCCESS') {
								component.set("v.mycolumns", response
										.getReturnValue().lstDataTableColumns);
								component.set("v.selectedContactId", response
										.getReturnValue().contactId);
								var data = response.getReturnValue().lstDataTableData;
								console.log('columns', response
										.getReturnValue().lstDataTableColumns);
								var formattedData = null;
								if (data) {
									formattedData = data
											.map(function(record) {
												var formattedRec = record;
												console.log(
														'even.getSource : ',
														location.origin);
												console.log('url :',
														record.CS_Contact__c);
												formattedRec.CS_Contact__c = location.origin+'/lightning/r/Contact/'+record.CS_Contact__c+'/view';
												formattedRec.linkLabel = record.CS_Contact__r.Name;

												return formattedRec;
											});
								}
								component.set("v.mydata", formattedData);
								console.log('**** ContactRelatedShipTos mydata : ',formattedData); 
								try{	
									this.getSelectedContact(component, event);
								}catch(err){
									console.log('error :',err);
								}
								
								console.log('*** ContactRelatedShipTos response.getReturnValue() :',response.getReturnValue());
								console.log('*** ContactRelatedShipTos v.preventRecurssion :',component.get("v.preventRecurssion"));
								if(response.getReturnValue().isSingleContact && !response.getReturnValue().hasContact && component.get("v.preventRecurssion")){
				                    $A.get('e.force:refreshView').fire();
				                    //component.set("v.preventRecurssion",false);
				                }
								
							} else if (state === 'ERROR') {
								var errors = response.getError();
								if (errors) {
									if (errors[0] && errors[0].message) {
										console.log("Error message in getDataHelper: "
												+ errors[0].message);
									}
								} else {
									console.log("Unknown error in getDataHelper");
								}
								component.set("v.IsSpinner", false);
							} else {
								console
										.log('Something went wrong in getDataHelper, Please check with your admin');
								component.set("v.IsSpinner", false);
							}
							component.set("v.IsSpinner", false);
						});
		$A.enqueueAction(action);
	},

	callmapContactToCase : function(component, event) {
		var selectedRows = event.getParam('selectedRows');
		console.log('selectedRows : ', selectedRows[0]);
		
		if(selectedRows != undefined){
			var action = component.get("c.mapContactToCase");
			
			action.setParams({
				'jsonShipToRelation' : JSON.stringify(selectedRows[0]),
				'caseId' : component.get("v.recordId")
			})
	
			action.setCallback(this, function(response) {
	
				var state = response.getState();
				if (state == 'SUCCESS') {
					if (response.getReturnValue()) {
						console.log('successfully updated');
						$A.get('e.force:refreshView').fire();
					}
				}else{
				
					var errors = response.getError();
								if (errors) {
									if (errors[0] && errors[0].message) {
										console.log("Error message in callmapContactToCase: "
												+ errors[0].message);
									}
								} else {
									console.log("Unknown error in callmapContactToCase");
								}
					component.set("v.IsSpinner", false);
				
				}
				
				component.set("v.IsSpinner", false);
			});
			$A.enqueueAction(action);
		}
	},

	getSelectedContact : function(component, event) {

		var shipToContactRelationRecords = component.get("v.mydata");
		var contactId = component.get("v.selectedContactId");
		console.log('selected contactId : ', contactId);
		var tableComponent = component.find("contactTable");
		var selectedContacts = [];
		tableComponent.set("v.selectedRows", selectedContacts);

		if (contactId != null || contactId != undefined) {

			shipToContactRelationRecords.forEach(function(record) {
				console.log('shipToContactRelatn : ', record);
				if (record.CS_Contact__c == location.origin+'/lightning/r/Contact/'+contactId+'/view') {
					selectedContacts.push(record.Id);
					tableComponent.set("v.selectedRows", selectedContacts);
					console.log('selectedContacts : ', selectedContacts);
				}
			});
		} else {
			var tableComponent = component.find("contactTable");
			tableComponent.set("v.selectedRows", []);
		}
	},

	showError : function(component, event, helper, errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:errorMessage,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
})