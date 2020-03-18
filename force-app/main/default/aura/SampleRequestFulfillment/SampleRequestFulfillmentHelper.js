({
    showselectedProducts : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var selectedProducts = [];
        var action = component.get("c.getSelectedProductList");       
        action.setParams({"sampleRequestProd": selectedProducts,"sampleReqFulFillId":recId});
        //console.log('******selected green table'+action);
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var ret = response.getReturnValue();
                console.log(ret.data);
                if(ret.data.length>0)
                    component.set("v.sampleRequestSelectedProductWrap",ret.data);
                
                console.log('@@@@@sampleRequestSelectedProductWrap=='+component.get("v.sampleRequestSelectedProductWrap")); 
                
            }
        });
        $A.enqueueAction(action); 	
    },
    
    save: function(component, event, helper) { 
        
     console.log('*****after success check table data');
        console.log(component.get("v.sampleRequestSelectedProductWrap"));
        var updateSampleData = component.get("v.sampleRequestSelectedProductWrap");
        var recId = component.get("v.recordId");
        console.log('###idcheck===='+recId);
        console.log(recId);
        var action = component.get("c.saveSampleRequestDetails");
        var positionRecords = JSON.stringify(updateSampleData);
        console.log('%%%positionRecords=='+positionRecords);
        action.setParams({"sampleWrapper": positionRecords,"sampleReqFulFillId": recId});
        
        action.setCallback(this, function(a) {
            component.set("v.spinner",false);
            var state = a.getState();
            if (state === "SUCCESS") {
                var retValue = a.getReturnValue();
                console.log('*****retValue =='+retValue);
                //alert("hello from here"+name);
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action)
        component.set("v.spinner",true);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();  
        
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent .setParams({
            "recordId": component.find("sampleLK").get("v.value") ,
            "slideDevName": "detail"
        });
        sObectEvent.fire(); 
    },
    
    

})