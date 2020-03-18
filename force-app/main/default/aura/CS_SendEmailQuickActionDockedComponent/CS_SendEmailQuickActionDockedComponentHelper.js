({
	switchView : function(component) {
        // Switch between popout and docked
		var outerSection = component.find("emailDockedOuterSection");
        var outerContainer = component.find("emailDockedOuterContainer");
        var innerContainer = component.find("emailDockedInnerContainer");
        var innerSection = component.find("emailDockedSection");
        var backgroundContainer = component.find("backgroundContainer");
        
        // toggling the classes that needed to change view docked to popout and viceversa.
        $A.util.toggleClass(outerSection,"slds-modal");
        $A.util.toggleClass(outerSection,"slds-fade-in-open");
        $A.util.toggleClass(outerSection,"slds-docked-composer-modal");
        $A.util.toggleClass(outerSection,"slds-modal_medium");
        
        $A.util.toggleClass(outerContainer,"slds-docked_container");
        $A.util.toggleClass(outerContainer,"slds-modal__container");
        $A.util.toggleClass(outerContainer,"email-docked-container");
        $A.util.toggleClass(outerContainer,"email-popout-container");
        
        $A.util.toggleClass(innerContainer,"slds-modal__content");
        
        // Case Handle : When minimized then click expand button
        if($A.util.hasClass(innerSection, "slds-is-closed")) {
            $A.util.toggleClass(innerSection,"slds-is-closed");
        } else {
            $A.util.toggleClass(innerSection,"slds-is-open");
        }
        
        $A.util.toggleClass(backgroundContainer,"hide");
	}
})