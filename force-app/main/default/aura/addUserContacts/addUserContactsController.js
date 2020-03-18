({
	doInit: function(component, event, helper) {
        // call the helper function on component load
        helper.getallContacts(component, event);
        helper.initHelper(component, event, null);
    },
 
    addSelected: function(component, event, helper) {
        // create array[list] type temp. variable for store child record's id's from selected checkboxes.  
        var tempIDs = [];
        // get(find) all checkboxes with aura:id "checkBox"
        var getAllId = component.find("checkBox");
       for (var i = 0; i < getAllId.length; i++) {
       		if (getAllId[i].get("v.value") == true) {
                tempIDs.push(getAllId[i].get("v.text"));
            }
        }
        // call the helper function and pass all selected record id's.   
        if(tempIDs.length>0){
        	helper.addSelectedHelper(component, event, tempIDs);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
          			toastEvent.setParams({
        				"title": "Error!",
        				"message": "Please select a contact to add to My Contacts."
    				});
        	toastEvent.fire();
        }
    },
    createContact : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Contact",
             "defaultFieldValues": {
                 'AccountId': component.get("v.recordId")
             }
        });
        createRecordEvent.fire();
    },
})