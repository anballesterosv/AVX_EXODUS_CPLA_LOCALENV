({
	doInit : function(component, event, helper) {
		helper.getRecord(component, event, helper);
		
	},
	
	afterSave : function(cmp, event, helper) {
	},
	
	onTabFocused : function(component, event, helper) {
        console.log("Tab Focused");
        var focusedTabId = event.getParam('currentTabId');
        var previousTabId = event.getParam('previousTabId');
        var workspaceAPI = component.find("workspace"); 
        var isSubTab = false;       
       
        console.log('previousTabId : '+ previousTabId);
        workspaceAPI.isSubtab({
                tabId: previousTabId
            }).then(function(response) {
                if (response) {
                    workspaceAPI.closeTab({tabId: previousTabId});
                }
                else {
                    
                }
            });
        
    }

})