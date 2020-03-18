({
    doInit : function(component, event, helper) {
        // get the fields API name and pass it to helper function  
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var objDetails = component.get("v.objDetail");
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);
        
    },
    
    setEditable : function(component, event, helper) {
        if(component.get("v.isEditable")){
            component.set("v.isEditable",false);
            var rec=component.get("v.productWrapper");
            rec['hasEdited']=false;
            component.set("v.productWrapper",rec);
        }else{
            component.set("v.isEditable",true);
            var rec=component.get("v.productWrapper");
            rec['hasEdited']=true;
            component.set("v.productWrapper",rec);
            
        }
    },
    
    deleteRow : function(component,event,helper){
        var eve = component.getEvent("deleteEvent");
        var index = component.get("v.rowIndex");
        console.log('Deleted Row with Index: ');
        console.log(index);
        eve.setParam("data",index);
        eve.fire();
    }
})