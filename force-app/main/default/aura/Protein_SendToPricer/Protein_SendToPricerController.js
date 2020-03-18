({
    doinit : function(component, event, helper) {
        
        var action = component.get("c.sendEmail");
             action.setParams({
                "prodColId": component.get("v.recordId")
         });
        console.log("v.recordId"+component.get("v.recordId"));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse++=='+storeResponse);
                
                if(storeResponse == 'Checkbox Checked') {
                	component.set("v.PricingFieldCheck", true);    
                }
                else if(storeResponse == 'Record Type not matched') {
                	component.set("v.RecordTypeCheck", true);  
                    console.log('storeResponse++ inside=='+storeResponse);
                }
               
                else if(storeResponse == 'Pricing date blank') {
                	component.set("v.PricingDateAndTime", true);  
                    console.log('storeResponse++ inside11=='+storeResponse);
                }
                else if (storeResponse == 'Success Email') {
                    $A.get('e.force:refreshView').fire();
                    component.set("v.isEmailSuccess", true);                                       
                  //  alert('Email send successfully');
                }
                
            }
            
        });
        $A.enqueueAction(action);
    },
})