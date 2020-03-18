({
	cloneToastGreen : function() {
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'title' : 'Success!',
            'message' : 'Record Cloned Successfully.',
            'type' : 'success'
        });
        showToast.fire();
    },
    
    alertToast : function() {
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'title' : 'Info',
            'message' : 'Opportunity line items with Inactive Products were removed.',
            'type' : 'info'
        });
        showToast.fire();
    }
})