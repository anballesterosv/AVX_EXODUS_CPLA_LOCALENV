({
    doInit : function(component, event) {
        var action = component.get("c.findTopOppty");
        action.setCallback(this, function(a) {
            component.set("v.Opporunities", a.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})