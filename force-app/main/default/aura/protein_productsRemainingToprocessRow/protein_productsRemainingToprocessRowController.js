({
    addRow : function(component, event, helper){
        //Execute the AddRowEvent Lightning Event 
        component.getEvent("AddRowEvent").fire();  
    },
    
    Select: function(component, event, helper) {
        component.set("v.DisclaimerValue",false); 
    },
    handleEvent : function(component, event, helper) {
        var name =event.getParam("message");// getting the value of event attribute
        //console.log('name:::'+JSON.stringify(name));
        component.set("v.DisclaimerValue1",name); // Setting the value of parent attribute with event attribute value
    },
    checkboxSelect: function(component, event, helper) {
        var selectedProducts = [];
        var checkvalue = component.find("checkProduct");
        console.log('%%%%%checkval');        
        var listOfAllProducts = component.get("v.sampleRequestProductWrapper");
        if(!Array.isArray(checkvalue)){
            
            for (var i = 0; i < listOfAllProducts.length; i++) {
                if (listOfAllProducts[i].isChecked) {
                    selectedProducts.push(listOfAllProducts[i].prdId);
                    console.log('%%% if selectedProducts-' + selectedProducts); 
                }
            }
        }
        
        console.log('%%selectedProducts-' + selectedProducts); 
        //component.set("v.sampleRequestProductWrapper",selectedProducts);       
        var action = component.get("c.getSelectedProductList");         
        var sampleReqRecordId = component.get("v.recordId");
        console.log(action);
        console.log(sampleReqRecordId);
        action.setParams({"sampleRequestProd": selectedProducts,"sampleReqFulFillId":sampleReqRecordId});
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                //console.log('###state =='+state);
                console.log(a.getReturnValue());
                var result= a.getReturnValue(); 
                $A.get('e.force:refreshView').fire();
                
            }
        });
        $A.enqueueAction(action);
    },
    
})