({
    myAction : function(component, event, helper) {
        var objectData = [];
        var status;
        //to get all the objects of the specific profile
        var action = component.get("c.retrieveActivityObjectList");
        
        action.setCallback(this, function(data){
            var ObjectListvalues = data.getReturnValue();
            if(ObjectListvalues!=null){
                objectData = ObjectListvalues.objectlistSeperated;
                debugger;
                var objectOptions = helper.populateObjectList(objectData);
                component.find("ObjectDropDown").set("v.options", objectOptions);
                var s = component.find("ObjectDropDown").get("v.options");
                component.set("v.ObjectListDropdown",objectData);
                component.set("v.status", objectOptions);
                helper.getSpecificTaskList(component,event,objectOptions);
            }
            else{
                alert('no objects retrieved');
            }
        });
        $A.enqueueAction(action);	
        
    },
    onObjectSelectChange : function(component, event, helper) {
        var selectedObject = component.find("ObjectDropDown").get("v.value");
        
        if(selectedObject != 'All')
        {
             if(selectedObject!='Contact'){
                component.set("v.isContact",false);
                 component.set("v.isNotContact",true);
            }
            else{
                component.set("v.isContact",true);
                component.set("v.isNotContact",false);
            }
            var action = component.get('c.getObjectSpecificTaskList');
            
            action.setParams({
                "recordId": component.get("v.recordId"),
                "selectedObject": selectedObject
            });
            action.setCallback(this, function(data){
                var Objectvalues = data.getReturnValue();
                debugger;
                if(Objectvalues!=null && Objectvalues.length !=0){
                    console.log('>>>specific list>>>'+Objectvalues);
                    component.set("v.TaskList",Objectvalues);
                    component.set("v.isResponse",true);
                    component.set("v.isAll",false);
                    debugger;
                }
                else{
                    component.set("v.isResponse",false);
                    component.set("v.isAll",false);
                    debugger;
                    
                }
            });
            $A.enqueueAction(action); 
        }
        else{
            component.set("v.isContact",false);
            component.set("v.isNotContact",true);
            var action = component.get('c.createActivityObjectList');
            
            action.setParams({
                "recordId": component.get("v.recordId"),
            });
            action.setCallback(this, function(data){
                var Objectvalues = data.getReturnValue();
                if(Objectvalues!=null && Objectvalues.length !=0){
                    debugger;
                    console.log('>>>All  Tasks>>>'+JSON.stringify(Objectvalues.taskList));
                    component.set("v.TaskList",Objectvalues);
                    component.set("v.isResponse",true);
                    component.set("v.isAll",true);
                    debugger;
                }
                else{
                    component.set("v.isResponse",false);
                    component.set("v.isAll",true);
                    debugger;
                    
                }
            });
            $A.enqueueAction(action); 
            
        }
    } ,
    ShowSpinner : function(component, event, helper,params) {
        
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component, event, helper,params) {
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide");
    } 
})