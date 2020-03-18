({
    doInit : function(component, event, helper){
        //Get the current user's business unit value
       //alert('InitX');
       component.set("v.foundBusinessUnitData", true);
		var userBizUnit;
        var action = component.get("c.getCurrentUserBusinessUnit");
        //Set the return value to v.userBusinessUnit
        action.setCallback(this, function(data){
            if(data.getReturnValue!=null){
                component.set("v.userBusinessUnit", data.getReturnValue());
                userBizUnit = data.getReturnValue();
                //alert('User has BU defined');
            }
            else{
                //alert('User do not have BU defined');
            }
        });
        $A.enqueueAction(action);

        //Invoke server-side controller action to retrive the list of Business Unit Detail
        var action = component.get("c.getBusinessUnitDetail");
        var bizUnitDetailData = [];
        //Pass the current account id
        action.setParams({
            "acctId": component.get("v.recordId")
        });
        //Set the return value to v.budList
        action.setCallback(this, function(data){
            //alert(JSON.stringify(data));
            var isMatch = false;
            if(data.getReturnValue().length>0){
                //alert('bud data returned');
                //Get the list of Business Units from return data
                bizUnitDetailData = data.getReturnValue();
                //Check if the user's Business Unit match with any of the returned data
                console.log(userBizUnit);
                if(userBizUnit!=null){
                    isMatch = helper.matchUserBusinessUnit(userBizUnit, bizUnitDetailData);
                    //alert('Matching BU: ' + isMatch);
                    
                    if(isMatch){
                        //Set the display Business Unit 
                        //alert('set display BU');
                        component.set("v.displayBusinessUnit", helper.findBusinessUnitDetail(bizUnitDetailData, userBizUnit));
                    	
                    }
                }
                
                if(isMatch == false){
                    //default to the first Business Unit
                    userBizUnit = bizUnitDetailData[0].BusinessUnit__r.Name;
                    component.set("v.displayBusinessUnit", bizUnitDetailData[0]);
                    //alert('Default user BU: ') + userBizUnit
                }
               
                //alert('display BU set');
                //Populate the Business Unit dropdown
                var bizUnitOptions = helper.populateBusinessUnit(bizUnitDetailData, userBizUnit);
                //alert(JSON.stringify(component.find("BizUnitDropDown")));
                component.find("BizUnitDropDown").set("v.options", bizUnitOptions);
                
                //alert('set bud data')
                //Populate the Business Unit Detail Data List
                component.set("v.budList", bizUnitDetailData);
            	
                //Populate account team for this Biz Unit
                var actionMember = component.get("c.getAccountTeamList");
                //Set parameters
                actionMember.setParams({
                    "businessUnit" : component.get("v.userBusinessUnit"),
                    "accountId": component.get("v.recordId")
                });
                //Set the return value to v.accountTeamList
                actionMember.setCallback(this, function(a){
                    //alert('return list of acct member: ' + a.getReturnValue());
                    component.set("v.accountTeamList", a.getReturnValue());
                });
                $A.enqueueAction(actionMember);   
                //End of populating Acct Member List
            
            }
            else{
                component.set("v.foundBusinessUnitData", false);
            }
           
        });
        $A.enqueueAction(action);
      
        
        
    },
   
    reLoadView : function(component, event, helper){
    
        //Refresh the bus list
        component.set("v.foundBusinessUnitData", true);
        doInit(component, event, helper);
    },
    
    
    //Handle dropdown list change for Business Unit Change
    onBizUnitSelectChange : function(component, event, helper) {
        var selectedBizUnit = component.find("BizUnitDropDown").get("v.value");
        //alert('New value: ' + selectedBizUnit);
        //update the displayBusinessUnit
        var budListValue = component.get("v.budList");
        var newBizUnitDetail = helper.findBusinessUnitDetail(budListValue, selectedBizUnit);
        component.set("v.displayBusinessUnit", newBizUnitDetail);
           
        var actionMember = component.get("c.getAccountTeamList");
            //Set parameters
            actionMember.setParams({
                "businessUnit" : newBizUnitDetail.BusinessUnit__r.Name,
                "accountId": component.get("v.recordId")
            });
            //Set the return value to v.accountTeamList
            actionMember.setCallback(this, function(a){
                //alert('return list of acct member: ' + a.getReturnValue());
                component.set("v.accountTeamList", a.getReturnValue());
            });
            $A.enqueueAction(actionMember);   
        	//End of populating Acct Member List
    
    	//Rebuild the view component
    	//helper.updateRecordView(component, event, helper);
        
        //Rebuild the edit component
        //helper.updateRecordEdit(component, event, helper);
        
        
       
         helper.createRecordEdit(component); 
    },
    
    editBudRecord : function(component, event, helper){
		var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
             "recordId": component.get("v.displayBusinessUnit.Id")
        });
        editRecordEvent.fire();
    },
    
    saveSuccessHandler : function(component, event, helper){

        var businessDetailId = component.get("v.displayBusinessUnit.Id");
        var actionReload = component.get("c.getUpdatedBusinessDetail");
            //Set parameters
            actionReload.setParams({
                "id" : businessDetailId
            });
            //Set the return value to v.accountTeamList
            actionReload.setCallback(this, function(a){
                component.set("v.displayBusinessUnit", a.getReturnValue());
                
                //update the current business unit array
                helper.updateBusinessDetailList(component, component.get("v.budList"), a.getReturnValue());
                
                
                //reset the view
                //component.set("v.inViewModeBtn", true);
                
                //alert(component.get("v.displayBusinessUnit.Status__c"));
            	//$A.get("e.force:refreshView").fire();
            });
            $A.enqueueAction(actionReload);   
        
        
    },
    
    //Save BUD record
    saveBudRecord : function(component, event, helper){
        debugger;
       
        
       // var editView = component.find("edit");
        var parentCmp = component.find("budEdit");
		var parentBody = parentCmp.get("v.body");
		var editView = parentBody[0].find("edit");
        
       
        try{
          editView.get("e.recordSave").fire();
          
        }
        catch(arrayException){
           //This exception is used to avoid the is Dirty record workaround issue where
           //the component find function returns an array the second time is ran
           alert(arrayException.message);
            //editView[0].get("e.recordSave").fire();
        }
        
        component.set("v.inViewModeBtn", true);
        
    },
    
    //Switch between View/Edit mode
    switchView : function(component, helper){
        //alert(currentbud);
        debugger;
        var currentView = component.get("v.inViewModeBtn");
        //alert('Current view mode?' + currentView);
        if(currentView == true){
            currentView = false;
        }
        else{
            currentView = true;
        }
        //alert('Change to view mode?' + currentView);
        component.set("v.inViewModeBtn", currentView);        
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