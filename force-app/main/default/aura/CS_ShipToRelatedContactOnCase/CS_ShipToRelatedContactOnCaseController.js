({
	doInit : function(component, event, helper) {
        component.set("v.IsSpinner",true);
        helper.getDataHelper(component, event);
    },
    
    onSelectingShipTo: function (component, event,helper) {
        helper.callmapShipToCase(component,event);
    },
    
    refreshPage : function(component, event, helper) {
        component.set("v.IsSpinner",true);
        component.set("v.selectedSearchField",'Ship To');
        component.set("v.searchKey",'');
        helper.getDataHelper(component, event);
	},
	
	recordUpdated: function(component, event, helper) {
        var changeType = event.getParams().changeType;
        var eventParams = event.getParams();
        if (changeType === "CHANGED") { 
            var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            // record is changed, so refresh the component (or other component logic)
            if(changedFields.ContactId != undefined){
                if(changedFields.ContactId.oldValue != changedFields.ContactId.value) {
                    console.log('..........Called change in ShipTo From CS_ShipToRelatedContact...........');
                    helper.getSelectedShipTo(component, event);
                }
            }
        }
	},
	
    searchByField : function (component,event,helper){
    	
    	console.log('****************************************************************');
    	var fieldtobeSearched = component.get("v.selectedSearchField");
    	var searchKey = component.get("v.searchKey");
    	var updatedData = [];
    	var mydata ;
    	var tempdata = [];
    	var atOnce = component.get("v.atOnce");
    	
    	if(atOnce){
    		mydata = component.get("v.tempMydata");
    	}else{
    		mydata = component.get("v.mydata");
    	}
    	
    	console.log("fieldtobeSearched : ",fieldtobeSearched);
    	
    	
    		var c = component.get("v.mycolumns");
    		c.forEach(function(col){
    			if(col.label ==  fieldtobeSearched){
    				fieldtobeSearched = col.fieldName;
    			}
    		});
    	
    	console.log("fieldtobeSearched : ",fieldtobeSearched);
    	console.log('searchKey :',searchKey);
    	
    	mydata.forEach(function(data){
    		
    		console.log('data values : ',data[fieldtobeSearched]);
    		
    		if(!atOnce)
    			tempdata.push(data);
    		
    		var searchData ;
    		
    		if(fieldtobeSearched == 'CS_Ship_To__c'){
    			searchData =  data['CS_Ship_To__r']['Name'];
    			console.log('searchData : ',searchData);
    		}else{
    			searchData = data[fieldtobeSearched];
    			console.log('searchData : ',searchData);
    		}
    		
    		if(searchData.toLowerCase().includes(searchKey.toLowerCase())){
    			updatedData.push(data);
    		}
    		
    	}); 
    	
    	if(!atOnce){
    		component.set("v.atOnce",true);
    		component.set("v.tempMydata",tempdata);
    		console.log('tempData : ',tempdata);
    	}
    	
    	console.log('updatedData : ',updatedData);
   		component.set("v.mydata",updatedData);
    	
    }
})