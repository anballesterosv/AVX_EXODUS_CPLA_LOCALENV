({
    doInit : function(component, event, helper) {

    },
    
    addRow : function(component, event, helper){
        component.getEvent("AddRowEvent1").fire();  
    },
    
    Remove: function(component, event, helper) {
        var UnselectedProducts = [];
        var checkvalue = component.find("UncheckProduct");
        
        UnselectedProducts = component.get("v.item.prdId");
        console.log('UnselectedProducts-' + UnselectedProducts); 
        var action = component.get("c.getRemovedProductDetails");         
        var sampleReqRecordId = component.get("v.recordId");
        console.log(sampleReqRecordId);
        action.setParams({"sampleRequestProd": UnselectedProducts,"sampleReqFulFillId":sampleReqRecordId});
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log(a.getReturnValue());
                var result= a.getReturnValue(); 
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
})