({
    doInit: function(component, event, helper) {
        var recID = component.get("v.recordId");
        console.log('*****do init data check');
        console.log(component.get("v.sampleRequestSelectedProductWrap"));
         var action = component.get("c.getSRP_BUs");
        var opts=[];
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS"){
                opts.push({
                    class: "optionClass",
                    label: "--None--",
                    value: ""
                });
                for(var i=0;i< response.getReturnValue().length;i++){
                    opts.push({class: "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
                }
                component.set("v.srpBUs", opts);
                console.log('####srpbus===');
                console.log(component.get("v.srpBUs"));
            }
            else if (state === "ERROR")
                console.log(response.getError());
        });
        $A.enqueueAction(action);
    },
    addRow: function(component, event, helper) {
        helper.createObjectData(component, event);
    },
    
})