({
	doInit: function(component, event, helper) {
        // call the helper function on component load
        helper.getStratObjectives(component, event);
        helper.initHelper(component, event);
    },
    addSelectedStrat: function(component, event, helper) {
        
        // create array[list] type temp. variable for storing Strategic Objectives from selected checkboxes.  
        var tempIDs = [];
        // get(find) all checkboxes with aura:id "checkBox"
        var getAllId = component.find("checkBox");
       for (var i = 0; i < getAllId.length; i++) {
       		if (getAllId[i].get("v.value") == true) {
                tempIDs.push(getAllId[i].get("v.text"));
            }
        }
        component.set('v.StratIdList',tempIDs);
        
        
        // call the helper function and pass all selected record id's.   
        if(tempIDs.length>0){
        	helper.addSelectedHelperStrat(component, event, tempIDs);
            helper.initHelperOpp(component, event);
        }
    }, 
    saveSelected: function(component, event, helper) {
        
        // create array[list] type temp. variable for storing Opportunities from selected checkboxes.  
        var tempIDs = [];
        // get(find) all checkboxes with aura:id "checkBoxOpp"
        var getAllIdOpp = component.find("checkBoxOpp");
       for (var i = 0; i < getAllIdOpp.length; i++) {
       		if (getAllIdOpp[i].get("v.value") == true) {
                tempIDs.push(getAllIdOpp[i].get("v.text"));
            }
        }
        // call the helper function and pass all selected record id's.   
        if(tempIDs.length>0){
        	helper.saveSelectedHelper(component, event, tempIDs);
        }
    }, 
})