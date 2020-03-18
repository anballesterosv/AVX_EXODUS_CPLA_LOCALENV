({
    doInit : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        var cmrId = component.get("v.recordId");
        urlEvent.setParams({
            "url": "/apex/Protein_CMRTemplate?Id="+component.get("v.recordId")
        });              
        urlEvent.fire();
        
        //Redirecting back to the record page
        var navEvent = $A.get("e.force:navigateToURL");
        navEvent.setParams({
            "url": "/"+cmrId
        });              
        navEvent.fire();
        console.log(cmrId);
        
    }
    
})