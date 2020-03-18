({
    populateAppUrl : function(component, event, helper) {
        //Get  Fiori/Hybris URL details from Custom label 
        var labelReference = $A.getReference("$Label.c." + component.get("v.labelName"));
		component.set("v.appURL", labelReference);
    },
    
	openActionWindow : function(component, event, helper) {
        //dynamically set external App URL
        var dynamicLabel = component.get("v.appURL");
        window.open(dynamicLabel);        
    },
    
    hideSpinner : function(component,event,helper){
     	// make Spinner attribute to false for hide loading spinner    
		component.set("v.Spinner", false);
    }
})