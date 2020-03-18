({
    doInit : function(component, event, helper) {
        var recID = component.get("v.recordId");
        //Call apex method getSampleDetails() to get the Sample details of the Sample record
        var getSampleDetails = component.get("c.getSampleDetails");
        getSampleDetails.setParams({
            sampleId : recID
        });
        getSampleDetails.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.sampleBU", response.getReturnValue().CFNA_Business_Unit__c);
                console.log(component.get("v.sampleBU"));
                component.set("v.sampleRecType", response.getReturnValue().RecordType.DeveloperName);
                console.log(component.get("v.sampleRecType"));
                $A.util.toggleClass(component.find("Spinner"), "slds-hide");
            }
            else if (state === "ERROR")
                console.log(response.getError());
        });
        $A.enqueueAction(getSampleDetails);
        
        var getSampleRequestProductsOfASample = component.get("c.getSampleRequestProductsOfASample");
        getSampleRequestProductsOfASample.setParams({
            sampleId: recID
        });
        getSampleRequestProductsOfASample.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.lstProductsWrapper", response.getReturnValue());
                console.log(component.get("v.lstProductsWrapper"));
            }
            else if (state === "ERROR")
                console.log(response.getError());
        });
        $A.enqueueAction(getSampleRequestProductsOfASample);
    },
    
    addProductRow : function(component, event, helper){
        var prdWrpNew = component.get("v.lstProductsWrapper");
        var temp = {};
        temp['isNew'] = true;
        prdWrpNew.unshift(temp);
        component.set("v.lstProductsWrapper",prdWrpNew);    
    },
    
    deleteSRProduct : function(component, event, helper){
        $A.util.toggleClass(component.find("Spinner"), "slds-hide");
        var index = event.getParam("data");
        console.log('Index number: ');
        console.log(index);
        var lstProductsWrapper = component.get("v.lstProductsWrapper");
        console.log(lstProductsWrapper);        
        if(lstProductsWrapper[index]['isNew']) {
            lstProductsWrapper.splice(index,1);
            component.set("v.lstProductsWrapper", lstProductsWrapper);
            component.set("v.isContactValidationError", false);
            console.log(component.get("v.lstProductsWrapper"));
            helper.deleteToastGrey();
            $A.util.toggleClass(component.find("Spinner"), "slds-hide");
        }
        else {
            var deleteRecord = component.get("c.deleteRecord");
            deleteRecord.setParams({
                recId : lstProductsWrapper[index]['srProduct']['Id']
            });
            deleteRecord.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS') {
                    lstProductsWrapper.splice(index,1);
                    component.set("v.lstProductsWrapper", lstProductsWrapper);
                    helper.deleteToastGreen();
                    $A.util.toggleClass(component.find("Spinner"), "slds-hide");
                    component.set("v.isContactValidationError",false);
                }
                if(state === 'ERROR') {
                    var errors = response.getError();
                    console.log('errors');
                    console.log(errors);
                    console.log(errors[0].pageErrors); 
                    console.log(errors[0].pageErrors[0].message);
                    component.set("v.isContactValidationError",true);
                    component.set("v.DisplayMsg",errors[0].pageErrors[0].message);
                    $A.util.toggleClass(component.find("Spinner"), "slds-hide");
                }
            });
            $A.enqueueAction(deleteRecord);
        }
    },
    
    saveSRProducts : function(component, event, helper){
        component.set("v.isContactValidationError", false);
        component.set("v.DisplayMsg", 'All fields are mandatory');
        var records = component.get("v.lstProductsWrapper");
        console.log(records);
        var isValid = helper.validateSRProduct(records);
        console.log('Valid: ');
        console.log(isValid);
        if(!isValid){
            component.set("v.isContactValidationError",true);
            component.set("v.DisplayMsg",'Please enter valid inputs in all the mandatory fields: Product, Quantity and Type');
            return;
        }
        $A.util.toggleClass(component.find("Spinner"), "slds-hide");
        console.log('Contact records: ');
        console.log(records);
        var data = [];
        for(var i =0;i<records.length;i++) {
            var temp = {};
            if(records[i].srProduct.Id == null)
                temp['isNew'] = true;
            else
                temp['isNew'] = false;
            temp['relatedProduct'] = records[i].relatedProduct;
            temp['relatedProductId'] = records[i].relatedProductId;
            temp['srProduct'] = records[i].srProduct;
            data.push(temp);
            console.log('Product After pushing:' +data[i].relatedProduct.Id);
            console.log('Type After pushing:' +data[i].srProduct.CFNA_Type__c);
        }
        console.log(data);
        console.log('All SRProducts added to data list!');
        //component.set("v.lstProductsWrapper", data);
        helper.doSaveSRProducts(component, data);        
    },
    clearError:function(cmp,event,helper){
      //  cmp.set("v.DisplayMsg",[]);
        cmp.set("v.isContactValidationError",false);
    }, 
    
})