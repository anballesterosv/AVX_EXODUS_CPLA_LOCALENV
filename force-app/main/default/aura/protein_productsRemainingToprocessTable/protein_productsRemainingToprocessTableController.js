({
    doInit : function(component, event, helper) {
        
    },
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var checkvalue = component.find("selectAllId");
        var updatedAllRecords = [];
        var sampleRequestProductWrapper = component.get("v.sampleRequestProductWrapper");
        for (var i = 0; i < sampleRequestProductWrapper.length; i++) {
            if (selectedHeaderCheck == true) {
                sampleRequestProductWrapper[i].isChecked = true;
                component.set("v.selectedCount", sampleRequestProductWrapper.length);
                console.log(component.get("v.selectedCount"));
            }
            
            else {
                sampleRequestProductWrapper[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(sampleRequestProductWrapper[i].prdId);
            console.log('%%%%updatedAllRecords=='+updatedAllRecords);
        }
        
        var action = component.get("c.getSelectedProductList");         
        var sampleReqRecordId = component.get("v.recordId");
        console.log(action);
        console.log(sampleReqRecordId);
        action.setParams({"sampleRequestProd": updatedAllRecords,"sampleReqFulFillId":sampleReqRecordId});
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log('###state =='+state);
                console.log(a.getReturnValue());
                var result = a.getReturnValue(); 
                console.log('###result =='+result);
                $A.get('e.force:refreshView').fire();
                console.log('###result 222=='+result);
                //    var cmpEvent = component.getEvent("sampleCmpEvent"); 
                //Set event attribute value
                //  cmpEvent.setParams({"message" : "Welcome "}); 
                //  console.log(cmpEvent);
                //  cmpEvent.fire(); 
                //  console.log('&&Row Data&&'+cmpEvent.fire());
                
                // $A.get('e.force:refreshView').fire();
            }
            
            
        });
        $A.enqueueAction(action);
        component.set("v.sampleRequestProductWrapper", updatedAllRecords);
        console.log('%%%%%all seelct data='+component.get("v.sampleRequestProductWrapper"));
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
        component.set("v.spinner", false);
    },
    
})