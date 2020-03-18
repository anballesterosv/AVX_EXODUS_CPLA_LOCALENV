({
    
    
    
    populateObjectList : function(objectList){
        
        var opts = [];
        
        opts.push({class : "optionClass", 
                   
                   label : 'All', 
                   
                   value : 'All',
                   
                   selected : "true"
                   
                  });
        
        
        
        for(var i in objectList){
            
            opts.push({class : "optionClass", 
                       
                       label : objectList[i], 
                       
                       value : objectList[i],
                       
                       selected : "true"
                       
                      });
            
        }
        
        
        
        return opts;
        
    },
    
    
    
    getSpecificTaskList : function(component,event,objectList){
        
        
        var action = component.get("c.createActivityObjectList");
        
        action.setParams({
            
            "recordId": component.get("v.recordId"),
            
        });
        
        action.setCallback(this, function(data){
            
            var Objectvalues = data.getReturnValue();
            
                    
            
            if(Objectvalues!=null && Objectvalues.length!=0){
                 debugger;  
                console.log('>>>specific list>>>'+Objectvalues);
                 component.set("v.TaskList",Objectvalues);
                component.set("v.isResponse",true);
                component.set("v.isNotContact",true);
                component.set("v.isContact",false);
                component.set("v.isAll",true);
                

            }
            
            else{
                
                component.set("v.isResponse",false);
                component.set("v.isAll",true); 
                
            }             
            
            
            
        });
        
        
        
        
        
        $A.enqueueAction(action); 
        
    }
    
    
    
    
    
})