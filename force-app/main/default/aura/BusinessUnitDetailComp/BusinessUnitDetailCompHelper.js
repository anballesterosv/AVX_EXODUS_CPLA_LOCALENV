({
    //Return true if the userBiz with any BusienssUnit__r.Name from the bizUnitList
	matchUserBusinessUnit : function(userBiz, bizUnitList){
        for(var i in bizUnitList){
            if(bizUnitList[i].BusinessUnit__c != null){
                console.log('Matching with: ' + bizUnitList[i].BusinessUnit__r.Name);
                if(userBiz!=null && userBiz == bizUnitList[i].BusinessUnit__r.Name){
                    console.log('Matched with: ' + bizUnitList[i].BusinessUnit__r.Name);
                    return true; 
                }
            }
        }
        return false;
    },
    
    //Given a list of bizUnitList, return a list of options with Business Unit values
    populateBusinessUnit : function(bizUnitList, userBizUnit){
        var opts = [];
        for(var i in bizUnitList){
            if(bizUnitList[i].BusinessUnit__r.Name == userBizUnit){
            	opts.push({class : "optionClass", 
                           label : bizUnitList[i].BusinessUnit__r.Name, 
                           value : bizUnitList[i].BusinessUnit__r.Name,
                           selected : "true"
                          });
            }
            else{
                opts.push({class : "optionClass", 
                           label : bizUnitList[i].BusinessUnit__r.Name, 
                           value : bizUnitList[i].BusinessUnit__r.Name});
            }
            console.log('Add an option: ' + opts[i].label);
        }
        
    	return opts;
    },
    
    //Refresh the recordView component after update
    updateRecordView: function(component, event, helper) {
        var id = component.get("v.displayBusinessUnit.Id");
        var container = component.find("budView");
        container.set("")
        //$A.createComponent("force:recordView",
          //                 {recordId: id,type: "FULL", id : "view"},
            //               function(cmp) {
              //                 container.set("v.body", [cmp]);
                //           });
    },
    
	//Refresh the recordEdit component after update
    updateRecordEdit: function(component, event, helper) {
        var id = component.get("v.displayBusinessUnit.Id");
        var container = component.find("budEdit");
        $A.createComponent("force:recordEdit",
                           {recordId: id, id : "edit"},
                           function(cmp) {
                               container.set("v.body", [cmp]);
                           });
    },

    
    //Return the Business Unit Detail value matching the bizUnit
    findBusinessUnitDetail : function(bizUnitList, bizUnit){
    	var result;
        if(bizUnit != null){
            for(var i in bizUnitList){
                if(bizUnitList[i].BusinessUnit__c != null && bizUnitList[i].BusinessUnit__r.Name == bizUnit){
                    result = bizUnitList[i];
                }   
            }    
        }
        
    	return result;
    },
    
    //Update the current business unit list 
    updateBusinessDetailList : function(component, bizDetailList, bizDetail){
        if(bizDetail != null){
            for(var i in bizDetailList){
                if(bizDetailList[i].Id == bizDetail.Id){
                    //alert('swap the updated biz detail');
                    bizDetailList[i] = bizDetail;
                }
            }
            
            component.set("v.budList", bizDetailList);
        }
    },
    
    //create record Edit dynamically
    createRecordEdit : function(component){
		console.log(component.get("v.displayBusinessUnit.Id"));
        $A.createComponent(              
            "force:recordEdit",
                {
                    "aura:id": "edit",
                    "class":"Testing",
                    "recordId":component.get("v.displayBusinessUnit.Id")
                },            
                function(recordEdit, status, errorMessage){
                    //Add the new button to the body array
                    if (status === "SUCCESS") {
                          debugger;                    
                          var divAuraId = "budEdit";
                          var divComponent = component.find(divAuraId);                      
                          divComponent.set("v.body",[]); 
                          var divBody = divComponent.get("v.body");
                          divBody.push(recordEdit);
                          divComponent.set("v.body", divBody);
                    }
             }
        );        
    }
   
})