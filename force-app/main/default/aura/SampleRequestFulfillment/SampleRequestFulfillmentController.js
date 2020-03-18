({
    redirect: function (component){ // FOR CANCEL
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent .setParams({
            "recordId": component.find("sampleLK").get("v.value") ,
            "slideDevName": "detail"
        });
        sObectEvent.fire(); 
    },
    
    parentComponentEvent : function(cmp, event) { 
        var message = event.getParam("message"); 
        cmp.set("v.eventMessage", message + 'Biswajeet');         
    } ,
    
    doInit : function(component, event, helper){
        console.log('******testt'+component.get("v.recordId"));
        var recId = component.get("v.recordId");       
        var action = component.get("c.getProductWrapperList"); 
        var sampleStatus = component.find('sampleStatus');
        action.setParams({sampleRequestId:recId});
		helper.showselectedProducts(component, event, helper);  //added by Latha
        action.setCallback(this, function(response) {
            component.set("v.spinner",false);
            if (response.getState() == "SUCCESS") {
                var ret = response.getReturnValue();
                console.log(ret.data);
                if(ret.data.length>0){
                    component.set("v.sampleRequestProductWrapper",ret.data);
                    console.log('###red table=='+component.get("v.sampleRequestProductWrapper"));
                }
            }
        });
        $A.enqueueAction(action); 
        component.set("v.spinner",true);
    },
    handleLoad :function(component, event, helper) { 
        var statusval = component.find("sampleStatus").get("v.value");
        console.log('$$$statusval');
        console.log(statusval);
        if(statusval == "Complete"){
            component.set("v.IsSRFOnComplete",true);
            console.log('$$$$IsSRFOnComplete=='+component.get("v.IsSRFOnComplete"));
        }
        else{
            component.set("v.IsSRFOnComplete",false);
        }
        
    },
    onRecordSubmit : function(component, event, helper) { 
        
        component.set("v.showError",[]);
        event.preventDefault(); 
        var eventFields = event.getParam("fields"); 
        var arr=component.get("v.sampleRequestSelectedProductWrap");
        console.log('component*****');
        console.log(component.get("v.sampleRequestSelectedProductWrap").length);
        console.log(eventFields['Status__c']);
        console.log(component.get("v.sampleRequestSelectedProductWrap"));
        console.log('component&&&&&&');
        var hasError=false;
        
         if(arr.length == 0 && (eventFields['Status__c']=='Complete' || eventFields['Status__c']=='Not Approved')){
           // event.preventDefault();
            hasError=true;
             console.log('%%test 1st error');
            component.set("v.showError",'Status cannot be set to Complete or Not Approved if no products are selected.');
        }   
        
       if(eventFields['Status__c']=='Complete'){
            for (var i = 0; i < arr.length; i++) {
                console.log(arr[i].prdFulfillmentStatus);
                if((arr[i].prdFulfillmentStatus == undefined) || (arr[i].prdFulfillmentStatus =='--None--' ) ){
                    component.set("v.showError",'Status cannot be set to Complete if any selected products do not have a Fulfillment Status.');
                    hasError=true;
                    console.log('%%test 2nd error');
                    break;
                }
            }
        } 
        
       
       
          if(eventFields['Status__c'] == 'Complete' && (eventFields['Tracking__c'] != '')){
                for (var i = 0; i < arr.length; i++) {
                    console.log('arr[i].prdJulianProductionDate');
                    console.log(arr[i].prdJulianProductionDate);
                    if(arr[i].prdJulianProductionDate == undefined || arr[i].prdJulianProductionDate == null || arr[i].prdJulianProductionDate =='' ){
                        component.set("v.showError",'Please Enter Julian Date when status is completed');   
                        hasError=true;
                        break;
                    }
                }    
            }  
        
        if(eventFields['Status__c'] == 'Complete'  && (eventFields['Shipping_Company__c'] == 'Metro' || eventFields['Shipping_Company__c'] == 'Pick Up') ){
            for (var i = 0; i < arr.length; i++) {
                console.log('arr[i].prdJulianProductionDate');
                console.log(arr[i].prdJulianProductionDate);
                if(arr[i].prdJulianProductionDate == undefined || arr[i].prdJulianProductionDate == null || arr[i].prdJulianProductionDate =='' ){
                    component.set("v.showError",'Julian Date is required when fulfillment Status marked as Complete or Tracking # entered (unless shipping company is Metro or Pickup)');   
                    hasError=true;
                    break;   
                }
            }    
        }  
        

        if(hasError==false){
            component.find('FulViewForm').submit(eventFields);    
        }
 
 },
    
    onRecordSuccess: function(component, event, helper) { 
        console.log('Success$$$');
        var recId = component.get("v.recordId");
        console.log(recId);
        helper.save(component, event, helper);       
    },
    
    clearError:function(cmp,event,helper){
        cmp.set("v.showError",[]);
    }, 
    
    onError:function(cmp,event,helper){
        var showError=cmp.get("v.showError");
        var params=event.getParams();
        console.log(JSON.stringify(params));
        if(params['output']['fieldErrors']!=undefined){
            for(var fieldName in params['output']['fieldErrors']){
                var rec=params['output']['fieldErrors'][fieldName];
                for(var i=0;i<rec.length;i++){
                    showError.push(rec[i]['message']);
                }
            }
        }
        if(params['output']['errors']!=undefined){
            var rec=params['output']['errors'];
            for(var i=0;i<rec.length;i++){
                showError.push(rec[i]['message']);
            }
        }
        
       cmp.set("v.showError",showError);
      
    },  

    
    
})