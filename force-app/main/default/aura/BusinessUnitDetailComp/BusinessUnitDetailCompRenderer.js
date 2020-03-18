({
	// Your renderer method overrides go here
    rerender: function(cmp, helper) {
        this.superRerender();
 	
        var editMode = cmp.find('budEdit');
        var viewMode = cmp.find('budView');
        
        // Get the v.inViewMode and Record View
            var currentInView = cmp.get("v.inViewModeBtn");
            
            // Show or Hide the Edit View depending on the inViewModeBtn value
            if (currentInView)
            {
                $A.util.addClass(editMode, 'hideme');
                $A.util.removeClass(viewMode, 'hideme');
            }
            else
            {
                $A.util.addClass(viewMode, 'hideme');
                $A.util.removeClass(editMode, 'hideme');
            }
     },
})