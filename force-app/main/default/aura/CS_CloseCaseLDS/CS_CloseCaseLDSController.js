({
    doInit : function(component, event, helper) {
        console.log('doInit Called for Closed Case Controller');
        helper.checkCaseContainsNewEmail(component, event, helper);
    },

    recordUpdated: function(component, event, helper) {
        var changeType = event.getParams().changeType;
        var eventParams = event.getParams();
        if (changeType === "CHANGED") { 
            var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            // record is changed, so refresh the component (or other component logic)
            if(changedFields.OwnerId != undefined){
                if(changedFields.OwnerId.oldValue != changedFields.OwnerId.value) {
                    console.log('..........Called for Closed Case Controller...........');
                    helper.checkCaseContainsNewEmail(component, event, helper);
                }
            }
        }
    }
})