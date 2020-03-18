({
    fetchSampleRequestInfo : function(component, event, helper) {
        console.log('#### enter page='); 
        
        var action = component.get('c.getSampleRequestWrapperList');
        var reqId = component.get("v.recordId");
        action.setParams({sampleRequestId:reqId});
        console.log('#### reqId id=='+reqId); 
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var ret = response.getReturnValue();
                console.log(ret.data);
                if(ret.data.length>0)
                    component.set("v.wrapper",ret.data[0]);
                console.log(component.get("v.wrapper")); 
                
            }
        });
        $A.enqueueAction(action); 
        
    }
})