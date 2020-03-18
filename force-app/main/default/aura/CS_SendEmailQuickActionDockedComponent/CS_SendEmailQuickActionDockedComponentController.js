({
    openModel: function(component, event, helper) {
		// for Display Model,set the "isOpen" attribute to "true"
		component.set("v.isOpen", true);
	},
 
   	closeModel: function(component, event, helper) {
		// for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
		component.set("v.isOpen", false);
	},
    
	handleKeyEvent: function(component, event, helper) {
		if(event.keyCode ===27) {
			alert('Set Close');
            //closeModel();
        }
    },
    
	toggleModel: function(component, event, helper) {
		//minimize & restore the modal
		if($A.util.hasClass(component.find("emailDockedOuterSection"), "slds-modal_medium")) {
            helper.switchView(component);
        }
        var cmpTarget = component.find("emailDockedSection");
		$A.util.toggleClass(cmpTarget,"slds-is-open");
		$A.util.toggleClass(cmpTarget,"slds-is-closed");
	},
    
    switchView: function(component, event, helper) {
        // Switch between popout and docked
    	helper.switchView(component);
	}
})