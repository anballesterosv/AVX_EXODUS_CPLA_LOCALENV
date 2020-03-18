({
	getDataHelper : function(component, event) {
		var action = component.get("c.getShipToContactFromCase");
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
								component.set("v.selectedShipToId", response
										.getReturnValue().shipToId);
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
														record.CS_Ship_To__c);
												formattedRec.CS_Ship_To__c = location.origin+'/lightning/r/Ship_To__c/'+record.CS_Ship_To__c+'/view';
												formattedRec.linkLabel = record.CS_Ship_To__r.Name;

												return formattedRec;
											});
								}
								component.set("v.mydata", formattedData);
								console.log('ShipToRelatedContacts data : ',formattedData); 
								try{	
									this.getSelectedShipTo(component, event);
								}catch(err){
									console.log('error :',err);
								}
								
								console.log('*** ShipToRelatedContacts response.getReturnValue() :',response.getReturnValue());
								console.log('*** ShipToRelatedContacts v.preventRecurssion :',component.get("v.preventRecurssion"));
								if(response.getReturnValue().isSingleShipTo && !response.getReturnValue().hasShipTo && component.get("v.preventRecurssion")){
				                    $A.get('e.force:refreshView').fire();
				                    //component.set("v.preventRecurssion",false);
				                }
								
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
								component.set("v.IsSpinner", false);
							} else {
								console
										.log('Something went wrong, Please check with your admin');
								component.set("v.IsSpinner", false);
							}
							component.set("v.IsSpinner", false);
						});
		$A.enqueueAction(action);
	},

	callmapShipToCase : function(component, event) {
		var selectedRows = event.getParam('selectedRows');
		console.log('selectedRows', selectedRows[0]);
		
		if(selectedRows != undefined){
			var action = component.get("c.mapShipToCase");
	
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
										console.log("Error message: "
												+ errors[0].message);
									}
								} else {
									console.log("Unknown error");
								}
					component.set("v.IsSpinner", false);
				
				}
				
				component.set("v.IsSpinner", false);
			});
			$A.enqueueAction(action);
		}
	},

	getSelectedShipTo : function(component, event) {

		var shipToContactRelationRecords = component.get("v.mydata");
		var shipToId = component.get("v.selectedShipToId");
		console.log('selected ShipToId : ', shipToId);
		var tableComponent = component.find("shipToTable");
		var selectedShipTos = [];
		tableComponent.set("v.selectedRows", selectedShipTos);

		if (shipToId != null || shipToId != undefined) {

			shipToContactRelationRecords.forEach(function(record) {
				console.log('shipToContactRelatn : ', record);
				if (record.CS_Ship_To__c == location.origin+'/lightning/r/Ship_To__c/'+shipToId+'/view') {
					selectedShipTos.push(record.Id);
					tableComponent.set("v.selectedRows", selectedShipTos);
					console.log('selectedShipTos : ', selectedShipTos);
				}
			});
		} else {
			var tableComponent = component.find("shipToTable");
			tableComponent.set("v.selectedRows", []);
		}
	},

})